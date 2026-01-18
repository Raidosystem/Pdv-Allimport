#!/usr/bin/env python3
"""
BACKUP ISOLADO POR EMPRESA via API REST
========================================
Cada empresa tem backup em pasta separada: backups/empresa_[user_id]/

Usa SERVICE_ROLE_KEY com API REST direta (bypass RLS)
"""

import os
import json
import requests
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv

# Carregar variáveis de ambiente
load_dotenv()

SUPABASE_URL = os.getenv('VITE_SUPABASE_URL')
SERVICE_ROLE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

if not SUPABASE_URL or not SERVICE_ROLE_KEY:
    print("❌ ERRO: Configure VITE_SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY no .env")
    exit(1)

# Headers com SERVICE_ROLE_KEY (bypass RLS)
HEADERS = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

# Tabelas com user_id (isolamento por empresa)
TABELAS = [
    'user_approvals',
    'empresas',
    'subscriptions',
    'produtos',
    'clientes',
    'vendas',
    'vendas_itens',
    'caixa',
    'categorias',
    'fornecedores',
    'despesas',
    'ordens_servico',
    'funcionarios'
]

def listar_empresas():
    """Lista todas as empresas cadastradas"""
    url = f"{SUPABASE_URL}/rest/v1/empresas?select=id,user_id,nome,razao_social"
    response = requests.get(url, headers=HEADERS, timeout=30)
    
    if response.status_code == 200:
        return response.json()
    else:
        print(f"❌ Erro ao listar empresas: {response.status_code}")
        return []

def backup_tabela_empresa(tabela: str, user_id: str, empresa_nome: str, empresa_dir: Path):
    """Faz backup de uma tabela para uma empresa específica"""
    try:
        # Buscar dados filtrados por user_id
        url = f"{SUPABASE_URL}/rest/v1/{tabela}?user_id=eq.{user_id}&select=*"
        response = requests.get(url, headers=HEADERS, timeout=30)
        
        if response.status_code != 200:
            print(f"   ❌ {tabela}: Erro {response.status_code}")
            return None
        
        dados = response.json()
        
        if not dados:
            print(f"   ⚪ {tabela}: 0 registros")
            return 0
        
        # Nome do arquivo com timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = empresa_dir / f'{tabela}_{timestamp}.json'
        
        # Salvar JSON
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(dados, f, indent=2, ensure_ascii=False)
        
        print(f"   ✅ {tabela}: {len(dados)} registros")
        return len(dados)
        
    except Exception as e:
        print(f"   ❌ {tabela}: {str(e)}")
        return None

def backup_empresa(empresa):
    """Faz backup completo de uma empresa"""
    user_id = empresa['user_id']
    nome = empresa.get('nome') or empresa.get('razao_social') or 'Sem Nome'
    
    print(f"\n{'='*60}")
    print(f"🏢 {nome}")
    print(f"🆔 {user_id}")
    print(f"{'='*60}")
    
    # Criar diretório da empresa
    empresa_dir = Path('./backups') / f'empresa_{user_id[:8]}'
    empresa_dir.mkdir(parents=True, exist_ok=True)
    
    sucessos = 0
    falhas = 0
    total_registros = 0
    
    for tabela in TABELAS:
        resultado = backup_tabela_empresa(tabela, user_id, nome, empresa_dir)
        
        if resultado is not None:
            sucessos += 1
            total_registros += resultado
        else:
            falhas += 1
    
    # Salvar metadata
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    metadata = {
        "backup_date": datetime.now().isoformat(),
        "empresa": nome,
        "user_id": user_id,
        "total_tables": len(TABELAS),
        "success": sucessos,
        "failures": falhas,
        "total_records": total_registros
    }
    
    metadata_file = empresa_dir / f'backup_metadata_{timestamp}.json'
    with open(metadata_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    print(f"\n📊 Resumo:")
    print(f"   ✅ Sucesso: {sucessos}/{len(TABELAS)} tabelas")
    print(f"   ❌ Falhas: {falhas}")
    print(f"   📝 Total: {total_registros} registros")
    print(f"   📁 Pasta: {empresa_dir}")
    
    return {
        "empresa": nome,
        "user_id": user_id,
        "success": sucessos,
        "failures": falhas,
        "records": total_registros,
        "directory": str(empresa_dir)
    }

def main():
    print("╔════════════════════════════════════════╗")
    print("║  🔒 BACKUP ISOLADO POR EMPRESA        ║")
    print("╚════════════════════════════════════════╝")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Listar empresas
    print("🔍 Buscando empresas...")
    empresas = listar_empresas()
    
    if not empresas:
        print("❌ Nenhuma empresa encontrada!")
        return
    
    print(f"✅ {len(empresas)} empresa(s) encontrada(s)\n")
    
    # Backup de cada empresa
    resultados = []
    for empresa in empresas:
        resultado = backup_empresa(empresa)
        resultados.append(resultado)
    
    # Resumo geral
    print("\n" + "="*60)
    print("📊 RESUMO GERAL")
    print("="*60)
    
    total_empresas = len(resultados)
    total_registros_geral = sum(r['records'] for r in resultados)
    
    for r in resultados:
        status = "✅" if r['failures'] == 0 else "⚠️"
        print(f"{status} {r['empresa'][:30]:30} | {r['records']:5} registros | {r['success']}/{len(TABELAS)} tabelas")
    
    print("="*60)
    print(f"🏢 Total: {total_empresas} empresas")
    print(f"📝 Total: {total_registros_geral} registros salvos")
    print("="*60)

if __name__ == "__main__":
    main()
