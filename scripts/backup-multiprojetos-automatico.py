#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🗄️ SISTEMA DE BACKUP AUTOMÁTICO MULTI-PROJETOS
Faz backup isolado por empresa de múltiplos projetos Supabase
Salva em pasta local sincronizada com nuvem (Google Drive/OneDrive/Dropbox)
"""

import os
import json
import requests
import shutil
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Optional

# =====================================================
# CARREGAR CONFIGURAÇÃO
# =====================================================

CONFIG_FILE = Path(__file__).parent.parent / 'config-backup-multiprojetos.json'

def carregar_config():
    """Carrega configuração de múltiplos projetos"""
    if not CONFIG_FILE.exists():
        print(f"❌ Arquivo de configuração não encontrado: {CONFIG_FILE}")
        print("📝 Crie o arquivo config-backup-multiprojetos.json")
        exit(1)
    
    with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

config = carregar_config()

# Validar pasta de backup
PASTA_BACKUP = Path(config['pasta_backup_local'])
if not PASTA_BACKUP.exists():
    print(f"📁 Criando pasta de backup: {PASTA_BACKUP}")
    PASTA_BACKUP.mkdir(parents=True, exist_ok=True)

# Validar pasta de logs
if config['logs']['salvar_logs']:
    PASTA_LOGS = Path(config['logs']['pasta_logs'])
    if not PASTA_LOGS.exists():
        print(f"📁 Criando pasta de logs: {PASTA_LOGS}")
        PASTA_LOGS.mkdir(parents=True, exist_ok=True)

# =====================================================
# FUNÇÕES DE LOG
# =====================================================

LOG_ATUAL = []

def log(mensagem: str, nivel: str = "INFO"):
    """Registra mensagem no log"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    linha = f"[{timestamp}] [{nivel}] {mensagem}"
    LOG_ATUAL.append(linha)
    print(mensagem)

def salvar_log():
    """Salva log em arquivo"""
    if not config['logs']['salvar_logs']:
        return
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    log_file = Path(config['logs']['pasta_logs']) / f'backup_{timestamp}.log'
    
    with open(log_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(LOG_ATUAL))
    
    log(f"📝 Log salvo em: {log_file}", "INFO")

# =====================================================
# FUNÇÕES SUPABASE
# =====================================================

def criar_headers(service_role_key: str) -> Dict[str, str]:
    """Cria headers para requisições Supabase"""
    return {
        'apikey': service_role_key,
        'Authorization': f'Bearer {service_role_key}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }

def chamar_funcao_rpc(url_base: str, headers: Dict[str, str], funcao: str, params: dict = None):
    """Chama função RPC do Supabase"""
    url = f"{url_base}/rest/v1/rpc/{funcao}"
    
    try:
        response = requests.post(url, headers=headers, json=params or {}, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.HTTPError as e:
        log(f"❌ Erro HTTP {response.status_code}: {response.text[:200]}", "ERROR")
        return None
    except Exception as e:
        log(f"❌ Erro ao chamar {funcao}: {e}", "ERROR")
        return None

def listar_empresas(projeto: Dict) -> List[Dict]:
    """Lista todas as empresas de um projeto"""
    headers = criar_headers(projeto['service_role_key'])
    data = chamar_funcao_rpc(projeto['supabase_url'], headers, 'backup_listar_empresas')
    return data or []

def backup_tabela_empresa(projeto: Dict, tabela: str, user_id: str, pasta_destino: Path) -> Optional[int]:
    """Faz backup de uma tabela específica"""
    headers = criar_headers(projeto['service_role_key'])
    
    data = chamar_funcao_rpc(
        projeto['supabase_url'],
        headers,
        'backup_tabela_por_user',
        {'tabela_nome': tabela, 'filtro_user_id': user_id}
    )
    
    if not data:
        return None
    
    # Salvar JSON
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = pasta_destino / f'{tabela}_{timestamp}.json'
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False, default=str)
    
    return len(data)

# =====================================================
# BACKUP DE PROJETO
# =====================================================

def backup_empresa(projeto: Dict, empresa: Dict, pasta_projeto: Path) -> Dict:
    """Faz backup completo de uma empresa"""
    user_id = empresa['user_id']
    nome = empresa.get('nome') or empresa.get('razao_social') or 'Sem Nome'
    
    log(f"\n{'='*60}")
    log(f"🏢 Empresa: {nome}")
    log(f"🆔 User ID: {user_id[:8]}...")
    log(f"{'='*60}")
    
    # Criar pasta da empresa
    empresa_dir = pasta_projeto / f'empresa_{user_id[:8]}'
    empresa_dir.mkdir(parents=True, exist_ok=True)
    
    sucessos = 0
    falhas = 0
    total_registros = 0
    
    for tabela in projeto['tabelas']:
        resultado = backup_tabela_empresa(projeto, tabela, user_id, empresa_dir)
        
        if resultado is not None:
            if resultado > 0:
                log(f"   ✅ {tabela}: {resultado} registros")
                sucessos += 1
                total_registros += resultado
            else:
                log(f"   ⚠️ {tabela}: vazia")
                falhas += 1
        else:
            log(f"   ❌ {tabela}: erro", "ERROR")
            falhas += 1
    
    # Salvar metadados
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    metadata = {
        'empresa': nome,
        'user_id': user_id,
        'data_backup': timestamp,
        'tabelas_sucesso': sucessos,
        'tabelas_falha': falhas,
        'total_registros': total_registros
    }
    
    metadata_file = empresa_dir / f'_metadata_{timestamp}.json'
    with open(metadata_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    return {
        'nome': nome,
        'user_id': user_id,
        'sucessos': sucessos,
        'falhas': falhas,
        'registros': total_registros
    }

def backup_projeto(projeto: Dict) -> Dict:
    """Faz backup de um projeto completo"""
    log(f"\n{'#'*60}")
    log(f"# 🚀 PROJETO: {projeto['nome']}")
    log(f"{'#'*60}")
    
    # Criar pasta do projeto
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    pasta_projeto = PASTA_BACKUP / projeto['nome'] / timestamp
    pasta_projeto.mkdir(parents=True, exist_ok=True)
    
    # Listar empresas
    empresas = listar_empresas(projeto)
    
    if not empresas:
        log(f"⚠️ Nenhuma empresa encontrada no projeto {projeto['nome']}", "WARNING")
        return {
            'projeto': projeto['nome'],
            'empresas': 0,
            'sucesso': False,
            'erro': 'Nenhuma empresa encontrada'
        }
    
    log(f"✅ {len(empresas)} empresa(s) encontrada(s)")
    
    # Fazer backup de cada empresa
    resultados = []
    for empresa in empresas:
        resultado = backup_empresa(projeto, empresa, pasta_projeto)
        resultados.append(resultado)
    
    # Estatísticas do projeto
    total_empresas = len(resultados)
    total_tabelas_sucesso = sum(r['sucessos'] for r in resultados)
    total_tabelas_falha = sum(r['falhas'] for r in resultados)
    total_registros = sum(r['registros'] for r in resultados)
    
    log(f"\n📊 Resumo do projeto {projeto['nome']}:")
    log(f"   🏢 Empresas: {total_empresas}")
    log(f"   ✅ Tabelas com sucesso: {total_tabelas_sucesso}")
    log(f"   ❌ Tabelas com falha: {total_tabelas_falha}")
    log(f"   📦 Total de registros: {total_registros}")
    log(f"   📁 Pasta: {pasta_projeto}")
    
    return {
        'projeto': projeto['nome'],
        'empresas': total_empresas,
        'tabelas_sucesso': total_tabelas_sucesso,
        'tabelas_falha': total_tabelas_falha,
        'registros': total_registros,
        'pasta': str(pasta_projeto),
        'sucesso': True
    }

# =====================================================
# LIMPEZA DE BACKUPS ANTIGOS
# =====================================================

def limpar_backups_antigos():
    """Remove backups antigos mantendo apenas os N mais recentes"""
    dias_manter = config.get('manter_ultimos_backups', 7)
    
    log(f"\n🧹 Limpando backups com mais de {dias_manter} dias...")
    
    data_limite = datetime.now() - timedelta(days=dias_manter)
    removidos = 0
    
    for projeto_dir in PASTA_BACKUP.iterdir():
        if not projeto_dir.is_dir():
            continue
        
        for backup_dir in projeto_dir.iterdir():
            if not backup_dir.is_dir():
                continue
            
            # Extrair data do nome da pasta (formato: YYYYMMDD_HHMMSS)
            try:
                timestamp_str = backup_dir.name
                backup_date = datetime.strptime(timestamp_str, '%Y%m%d_%H%M%S')
                
                if backup_date < data_limite:
                    log(f"   🗑️ Removendo: {backup_dir.name}")
                    shutil.rmtree(backup_dir)
                    removidos += 1
            except:
                continue
    
    if removidos > 0:
        log(f"✅ {removidos} backup(s) antigo(s) removido(s)")
    else:
        log(f"✅ Nenhum backup antigo para remover")

# =====================================================
# FUNÇÃO PRINCIPAL
# =====================================================

def main():
    """Função principal - executa backup de todos os projetos"""
    log("="*60)
    log("🚀 BACKUP AUTOMÁTICO MULTI-PROJETOS")
    log(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    log("="*60)
    
    projetos_ativos = [p for p in config['projetos'] if p.get('ativo', True)]
    
    if not projetos_ativos:
        log("⚠️ Nenhum projeto ativo configurado!", "WARNING")
        salvar_log()
        return
    
    log(f"📋 Projetos configurados: {len(projetos_ativos)}")
    log(f"📁 Pasta de backup: {PASTA_BACKUP}")
    
    # Fazer backup de cada projeto
    resultados = []
    for projeto in projetos_ativos:
        try:
            resultado = backup_projeto(projeto)
            resultados.append(resultado)
        except Exception as e:
            log(f"❌ Erro ao fazer backup do projeto {projeto['nome']}: {e}", "ERROR")
            resultados.append({
                'projeto': projeto['nome'],
                'sucesso': False,
                'erro': str(e)
            })
    
    # Limpar backups antigos
    limpar_backups_antigos()
    
    # Resumo final
    log(f"\n{'='*60}")
    log("🎉 BACKUP COMPLETO CONCLUÍDO!")
    log("="*60)
    
    projetos_sucesso = sum(1 for r in resultados if r.get('sucesso', False))
    projetos_falha = len(resultados) - projetos_sucesso
    total_empresas = sum(r.get('empresas', 0) for r in resultados if r.get('sucesso', False))
    total_registros = sum(r.get('registros', 0) for r in resultados if r.get('sucesso', False))
    
    log(f"📊 Resumo Geral:")
    log(f"   ✅ Projetos com sucesso: {projetos_sucesso}/{len(resultados)}")
    if projetos_falha > 0:
        log(f"   ❌ Projetos com falha: {projetos_falha}", "ERROR")
    log(f"   🏢 Total de empresas: {total_empresas}")
    log(f"   📦 Total de registros: {total_registros}")
    log(f"   📁 Backups em: {PASTA_BACKUP}")
    log(f"   ☁️ Sincronizado com nuvem automaticamente")
    
    # Salvar log
    salvar_log()
    
    # Retornar código de saída
    if projetos_falha > 0:
        exit(1)
    else:
        exit(0)

if __name__ == '__main__':
    main()
