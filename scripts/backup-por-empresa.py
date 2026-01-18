# 🗄️ BACKUP ISOLADO POR EMPRESA - Multi-Tenancy Seguro
# Cada empresa tem backup SEPARADO - restaurar uma empresa não afeta outras

import os
import json
from datetime import datetime
from pathlib import Path
from supabase import create_client
from dotenv import load_dotenv

# Carregar variáveis de ambiente
env_path = Path(__file__).parent.parent / '.env'
print(f"🔍 Lendo .env de: {env_path}")
print(f"   Arquivo existe: {env_path.exists()}")

# SEMPRE ler manualmente para garantir
try:
    with open(env_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '=' in line:
                key, value = line.split('=', 1)
                os.environ[key] = value
                if key == 'SUPABASE_SERVICE_ROLE_KEY':
                    print(f"✅ SERVICE_ROLE_KEY carregada (primeiros 30 chars): {value[:30]}...")
except Exception as e:
    print(f"❌ Erro ao ler .env: {e}")

# =====================================================
# CONFIGURAÇÕES
# =====================================================

# SERVICE_ROLE_KEY é necessária para acessar dados de todas as empresas
SUPABASE_URL = os.getenv('VITE_SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY') or os.getenv('VITE_SUPABASE_ANON_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ ERRO: Configure VITE_SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY no .env")
    exit(1)

# Debug: verificar qual chave está sendo usada
print(f"🔑 SUPABASE_URL: {SUPABASE_URL}")
print(f"🔑 SUPABASE_KEY (primeiros 50 chars): {SUPABASE_KEY[:50]}...")

# Detectar qual chave está sendo usada (decode JWT para verificar)
import base64
try:
    # JWT format: header.payload.signature
    payload = SUPABASE_KEY.split('.')[1]
    # Adicionar padding se necessário
    payload += '=' * (4 - len(payload) % 4)
    decoded = json.loads(base64.b64decode(payload))
    role = decoded.get('role', 'unknown')
    print(f"✅ Usando chave com role: {role}")
    if role != 'service_role':
        print("⚠️ AVISO: Para backup completo de TODAS as empresas, use SERVICE_ROLE_KEY!")
except:
    print("⚠️ Não foi possível detectar o tipo de chave")
print()

# Tabelas críticas com user_id (isolamento por empresa)
TABELAS_COM_USER_ID = [
    'user_approvals',   # Dados do owner
    'empresas',         # Dados da empresa
    'subscriptions',    # Assinatura
    'produtos',         # Produtos
    'clientes',         # Clientes
    'vendas',           # Vendas
    'vendas_itens',     # Itens das vendas
    'caixa',            # Movimentação de caixa
    'categorias',       # Categorias de produtos
    'fornecedores',     # Fornecedores
    'despesas',         # Despesas
    'ordens_servico',   # Ordens de serviço
    'funcionarios',     # Funcionários da empresa
]

# Inicializar cliente Supabase
# IMPORTANTE: service_role bypassa RLS automaticamente via PostgREST
# Mas precisamos usar postgrest_client_timeout para garantir
from supabase.client import ClientOptions

options = ClientOptions(
    schema="public",
    headers={"x-client-info": "backup-script"},
    auto_refresh_token=False,
    persist_session=False,
    postgrest_client_timeout=None
)

supabase = create_client(SUPABASE_URL, SUPABASE_KEY, options)

def listar_empresas():
    """Lista todas as empresas cadastradas"""
    try:
        response = supabase.from_('empresas').select('id, user_id, nome, razao_social').execute()
        return response.data
    except Exception as e:
        print(f"❌ Erro ao listar empresas: {e}")
        return []

def backup_tabela_empresa(tabela: str, user_id: str, empresa_nome: str):
    """Faz backup de uma tabela para uma empresa específica"""
    try:
        # Buscar dados filtrados por user_id
        response = supabase.from_(tabela).select('*').eq('user_id', user_id).execute()
        
        if not response.data:
            print(f"   ⚠️ {tabela} vazia para {empresa_nome}")
            return None
        
        # Criar estrutura de pastas: backups/empresa_[user_id]/
        empresa_dir = Path('./backups') / f'empresa_{user_id[:8]}'
        empresa_dir.mkdir(parents=True, exist_ok=True)
        
        # Nome do arquivo com timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = empresa_dir / f'{tabela}_{timestamp}.json'
        
        # Salvar JSON
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(response.data, f, indent=2, ensure_ascii=False, default=str)
        
        print(f"   ✅ {len(response.data)} registros salvos em {filename}")
        return len(response.data)
        
    except Exception as e:
        print(f"   ❌ Erro ao fazer backup de {tabela}: {e}")
        return None

def backup_empresa_completa(empresa):
    """Faz backup completo de uma empresa"""
    user_id = empresa['user_id']
    nome = empresa.get('nome') or empresa.get('razao_social') or 'Sem Nome'
    
    print(f"\n{'='*60}")
    print(f"🏢 Empresa: {nome}")
    print(f"🆔 User ID: {user_id}")
    print(f"{'='*60}")
    
    sucessos = 0
    falhas = 0
    total_registros = 0
    
    for tabela in TABELAS_COM_USER_ID:
        print(f"📥 Backing up {tabela}...")
        resultado = backup_tabela_empresa(tabela, user_id, nome)
        
        if resultado is not None:
            sucessos += 1
            total_registros += resultado
        else:
            falhas += 1
    
    # Salvar metadados do backup
    empresa_dir = Path('./backups') / f'empresa_{user_id[:8]}'
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    metadata = {
        'empresa_id': empresa['id'],
        'user_id': user_id,
        'nome': nome,
        'data_backup': datetime.now().isoformat(),
        'tabelas_backup': sucessos,
        'tabelas_falha': falhas,
        'total_registros': total_registros,
        'tabelas': TABELAS_COM_USER_ID
    }
    
    metadata_file = empresa_dir / f'backup_metadata_{timestamp}.json'
    with open(metadata_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    print(f"\n{'='*60}")
    print(f"✅ Backup de {nome} concluído!")
    print(f"   Sucesso: {sucessos} tabelas")
    print(f"   Falhas: {falhas} tabelas")
    print(f"   Total: {total_registros} registros")
    print(f"   Pasta: {empresa_dir}")
    print(f"{'='*60}")
    
    return sucessos, falhas, total_registros

def main():
    """Executa backup de todas as empresas"""
    print("🚀 Iniciando backup isolado por empresa...")
    print(f"📅 Data/Hora: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Listar empresas
    empresas = listar_empresas()
    
    if not empresas:
        print("❌ Nenhuma empresa encontrada ou erro ao buscar empresas")
        return
    
    print(f"\n📊 Total de empresas: {len(empresas)}")
    
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
    print("🎉 BACKUP COMPLETO DE TODAS AS EMPRESAS CONCLUÍDO!")
    print(f"{'='*60}")
    print(f"📊 Estatísticas:")
    print(f"   Empresas processadas: {len(empresas)}")
    print(f"   Tabelas com sucesso: {total_sucessos}")
    print(f"   Tabelas com falha: {total_falhas}")
    print(f"   Total de registros: {total_registros}")
    print(f"{'='*60}")
    print(f"📁 Backups salvos em: ./backups/empresa_[id]/")
    print(f"🔄 Cada empresa tem sua própria pasta isolada")
    print(f"✅ Restaurar uma empresa não afeta outras empresas!")

if __name__ == '__main__':
    main()
