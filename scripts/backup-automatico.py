# 🗄️ SISTEMA DE BACKUP AUTOMÁTICO LOCAL
# Execute este script periodicamente para fazer backup dos dados

import os
from datetime import datetime
from supabase import create_client
import json
from dotenv import load_dotenv
from pathlib import Path

# Carregar variáveis de ambiente do arquivo .env
env_path = Path(__file__).parent.parent / '.env'
load_dotenv(env_path)

# =====================================================
# CONFIGURAÇÕES
# =====================================================

# Tentar usar SERVICE_ROLE_KEY primeiro (backup completo sem RLS)
# Se não existir, usa ANON_KEY (limitado por RLS)
SUPABASE_URL = os.getenv('VITE_SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY') or os.getenv('VITE_SUPABASE_ANON_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ ERRO: Configure VITE_SUPABASE_URL e (SUPABASE_SERVICE_ROLE_KEY ou VITE_SUPABASE_ANON_KEY) no .env")
    exit(1)

# Diretório para salvar backups
BACKUP_DIR = './backups'

# Tabelas críticas para backup
CRITICAL_TABLES = [
    'user_approvals',
    'empresas',
    'funcionarios',
    'subscriptions',
    'produtos',
    'clientes',
    'vendas',
    'vendas_itens',
    'caixa',
    'ordens_servico',
    'categorias',
    'fornecedores',
    'despesas'
]

# =====================================================
# FUNÇÕES DE BACKUP
# =====================================================

def create_backup_directory():
    """Cria diretório de backup se não existir"""
    os.makedirs(BACKUP_DIR, exist_ok=True)
    print(f"✅ Diretório de backup: {BACKUP_DIR}")

def backup_table(supabase, table_name):
    """Faz backup de uma tabela específica"""
    try:
        print(f"📥 Backing up {table_name}...")
        
        # Buscar todos os dados da tabela
        response = supabase.table(table_name).select('*').execute()
        
        if response.data:
            # Salvar em arquivo JSON
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"{BACKUP_DIR}/{table_name}_{timestamp}.json"
            
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(response.data, f, indent=2, ensure_ascii=False, default=str)
            
            print(f"   ✅ {len(response.data)} registros salvos em {filename}")
            return True
        else:
            print(f"   ⚠️ {table_name} está vazia")
            return True
            
    except Exception as e:
        print(f"   ❌ Erro ao fazer backup de {table_name}: {str(e)}")
        return False

def backup_all_tables():
    """Faz backup de todas as tabelas críticas"""
    print("🚀 Iniciando backup completo...")
    print(f"📅 Data/Hora: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("")
    
    # Criar cliente Supabase
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Criar diretório
    create_backup_directory()
    
    # Fazer backup de cada tabela
    success_count = 0
    fail_count = 0
    
    for table in CRITICAL_TABLES:
        if backup_table(supabase, table):
            success_count += 1
        else:
            fail_count += 1
    
    print("")
    print("=" * 50)
    print(f"✅ Backup concluído!")
    print(f"   Sucesso: {success_count} tabelas")
    print(f"   Falhas: {fail_count} tabelas")
    print(f"   Total: {success_count + fail_count} tabelas")
    print("=" * 50)

def create_metadata_file():
    """Cria arquivo de metadados do backup"""
    metadata = {
        'backup_date': datetime.now().isoformat(),
        'supabase_url': SUPABASE_URL,
        'tables_backed_up': CRITICAL_TABLES,
        'backup_directory': BACKUP_DIR
    }
    
    filename = f"{BACKUP_DIR}/backup_metadata_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"📋 Metadados salvos em {filename}")

# =====================================================
# EXECUÇÃO PRINCIPAL
# =====================================================

if __name__ == "__main__":
    try:
        backup_all_tables()
        create_metadata_file()
        print("")
        print("🎉 Backup completo realizado com sucesso!")
        
    except Exception as e:
        print(f"❌ Erro fatal no backup: {str(e)}")
        exit(1)
