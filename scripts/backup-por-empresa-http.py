# 🗄️ BACKUP ISOLADO POR EMPRESA - Versão HTTP Direta
# Bypassa RLS corretamente usando SERVICE_ROLE_KEY via HTTP requests

import os
import json
import requests
from datetime import datetime
from pathlib import Path

# =====================================================
# CARREGAR CONFIGURAÇÕES DO .ENV
# =====================================================

env_path = Path(__file__).parent.parent / '.env'
print(f"🔍 Lendo .env de: {env_path}")

# Ler .env manualmente
for line in open(env_path, encoding='utf-8'):
    line = line.strip()
    if line and not line.startswith('#') and '=' in line:
        key, value = line.split('=', 1)
        os.environ[key] = value

SUPABASE_URL = os.getenv('VITE_SUPABASE_URL')
SERVICE_ROLE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

if not SUPABASE_URL or not SERVICE_ROLE_KEY:
    print("❌ ERRO: Configure VITE_SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY no .env")
    exit(1)

# Detectar role da chave
import base64
try:
    payload = SERVICE_ROLE_KEY.split('.')[1]
    payload += '=' * (4 - len(payload) % 4)
    decoded = json.loads(base64.b64decode(payload))
    role = decoded.get('role', 'unknown')
    print(f"✅ Usando chave com role: {role}")
    if role != 'service_role':
        print("❌ ERRO: Precisa de SERVICE_ROLE_KEY para backup completo!")
        exit(1)
except Exception as e:
    print(f"⚠️ Não foi possível validar a chave: {e}")

print()

# =====================================================
# CONFIGURAÇÕES
# =====================================================

# Headers para requisições HTTP
HEADERS = {
    'apikey': SERVICE_ROLE_KEY,
    'Authorization': f'Bearer {SERVICE_ROLE_KEY}',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
}

# SERVICE_ROLE_KEY bypassa RLS automaticamente no PostgREST
# Não precisa de header adicional, mas vamos garantir

# Tabelas com user_id (isolamento por empresa)
TABELAS_COM_USER_ID = [
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
    'funcionarios',
]

# =====================================================
# FUNÇÕES HTTP
# =====================================================

def fazer_requisicao(endpoint: str, params: dict = None):
    """Faz requisição GET ao Supabase"""
    url = f"{SUPABASE_URL}/rest/v1/{endpoint}"
    
    try:
        response = requests.get(url, headers=HEADERS, params=params)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.HTTPError as e:
        print(f"   ❌ Erro HTTP {response.status_code}: {response.text[:200]}")
        return None
    except Exception as e:
        print(f"   ❌ Erro: {e}")
        return None

def chamar_funcao_rpc(funcao: str, params: dict = None):
    """Chama função RPC do Supabase (bypassa RLS com SECURITY DEFINER)"""
    url = f"{SUPABASE_URL}/rest/v1/rpc/{funcao}"
    
    try:
        response = requests.post(url, headers=HEADERS, json=params or {})
        response.raise_for_status()
        return response.json()
    except requests.exceptions.HTTPError as e:
        print(f"   ❌ Erro HTTP {response.status_code}: {response.text[:200]}")
        return None
    except Exception as e:
        print(f"   ❌ Erro: {e}")
        return None

def listar_empresas():
    """Lista todas as empresas usando função RPC que bypassa RLS"""
    print("📊 Buscando empresas cadastradas via RPC...")
    data = chamar_funcao_rpc('backup_listar_empresas')
    if data:
        print(f"✅ {len(data)} empresa(s) encontrada(s)")
    return data or []

def backup_tabela_empresa(tabela: str, user_id: str, empresa_nome: str):
    """Faz backup de uma tabela filtrada por user_id usando RPC"""
    try:
        # Buscar dados via função RPC que bypassa RLS
        data = chamar_funcao_rpc('backup_tabela_por_user', {
            'tabela_nome': tabela,
            'filtro_user_id': user_id
        })
        
        if not data:
            print(f"   ⚠️ {tabela} vazia")
            return None
        
        # Criar pasta da empresa
        empresa_dir = Path('./backups') / f'empresa_{user_id[:8]}'
        empresa_dir.mkdir(parents=True, exist_ok=True)
        
        # Salvar JSON
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = empresa_dir / f'{tabela}_{timestamp}.json'
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False, default=str)
        
        print(f"   ✅ {len(data)} registros → {filename.name}")
        return len(data)
        
    except Exception as e:
        print(f"   ❌ Erro ao fazer backup de {tabela}: {e}")
        return None

def backup_empresa_completa(empresa):
    """Faz backup completo de uma empresa"""
    user_id = empresa['user_id']
    nome = empresa.get('nome') or empresa.get('razao_social') or 'Sem Nome'
    
    print(f"\n{'='*60}")
    print(f"🏢 Empresa: {nome}")
    print(f"🆔 User ID: {user_id[:8]}...")
    print(f"{'='*60}")
    
    sucessos = 0
    falhas = 0
    total_registros = 0
    
    for tabela in TABELAS_COM_USER_ID:
        print(f"📥 {tabela}...", end=' ')
        resultado = backup_tabela_empresa(tabela, user_id, nome)
        
        if resultado is not None:
            sucessos += 1
            total_registros += resultado
        else:
            falhas += 1
    
    # Salvar metadados
    empresa_dir = Path('./backups') / f'empresa_{user_id[:8]}'
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    metadata = {
        'empresa_id': empresa['id'],
        'user_id': user_id,
        'nome': nome,
        'data_backup': datetime.now().isoformat(),
        'tabelas_sucesso': sucessos,
        'tabelas_falha': falhas,
        'total_registros': total_registros,
        'tabelas': TABELAS_COM_USER_ID
    }
    
    metadata_file = empresa_dir / f'backup_metadata_{timestamp}.json'
    with open(metadata_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    print(f"\n📊 Resumo:")
    print(f"   ✅ Sucesso: {sucessos} tabelas")
    print(f"   ❌ Falhas: {falhas} tabelas")
    print(f"   📦 Total: {total_registros} registros")
    print(f"   📁 Pasta: ./backups/empresa_{user_id[:8]}/")
    
    return sucessos, falhas, total_registros

# =====================================================
# EXECUÇÃO PRINCIPAL
# =====================================================

def main():
    print("🚀 BACKUP ISOLADO POR EMPRESA - Versão HTTP")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Criar diretório de backups
    Path('./backups').mkdir(exist_ok=True)
    
    # Listar empresas
    empresas = listar_empresas()
    
    if not empresas:
        print("❌ Nenhuma empresa encontrada")
        return
    
    # Backup de cada empresa
    total_sucessos = 0
    total_falhas = 0
    total_registros = 0
    
    for empresa in empresas:
        sucessos, falhas, registros = backup_empresa_completa(empresa)
        total_sucessos += sucessos
        total_falhas += falhas
        total_registros += registros
    
    # Resumo final
    print(f"\n{'='*60}")
    print("🎉 BACKUP COMPLETO CONCLUÍDO!")
    print(f"{'='*60}")
    print(f"📊 Estatísticas Gerais:")
    print(f"   🏢 Empresas: {len(empresas)}")
    print(f"   ✅ Tabelas com sucesso: {total_sucessos}")
    print(f"   ❌ Tabelas com falha: {total_falhas}")
    print(f"   📦 Total de registros: {total_registros}")
    print(f"{'='*60}")
    print(f"📁 Backups salvos em: ./backups/empresa_[id]/")
    print(f"🔐 Cada empresa isolada em sua própria pasta")
    print(f"✅ Restaurar uma empresa não afeta outras!")
    print()

if __name__ == '__main__':
    main()
