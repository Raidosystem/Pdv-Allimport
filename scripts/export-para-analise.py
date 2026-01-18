# 📥 EXPORT COMPLETO PARA ANÁLISE
# Exporta todas as tabelas em um único arquivo JSON para análise

import os
import json
from pathlib import Path
from datetime import datetime

# Carregar .env
env_path = Path('.env')
for line in open(env_path, encoding='utf-8'):
    line = line.strip()
    if line and not line.startswith('#') and '=' in line:
        key, value = line.split('=', 1)
        os.environ[key] = value

# Configurações
from supabase import create_client

SUPABASE_URL = os.getenv('VITE_SUPABASE_URL')
SERVICE_ROLE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

supabase = create_client(SUPABASE_URL, SERVICE_ROLE_KEY)

# Tabelas para exportar
TABELAS = [
    'user_approvals',
    'empresas',
    'funcionarios',
    'subscriptions',
    'produtos',
    'clientes',
    'vendas',
    'vendas_itens',
    'caixa',
    'categorias',
]

print("🚀 Exportando backup para análise...")
print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

backup_completo = {
    'data_export': datetime.now().isoformat(),
    'tabelas': {}
}

for tabela in TABELAS:
    try:
        print(f"📥 {tabela}...", end=' ')
        response = supabase.from_(tabela).select('*').execute()
        
        if response.data:
            backup_completo['tabelas'][tabela] = response.data
            print(f"✅ {len(response.data)} registros")
        else:
            backup_completo['tabelas'][tabela] = []
            print(f"⚠️ vazia")
    except Exception as e:
        print(f"❌ Erro: {e}")
        backup_completo['tabelas'][tabela] = {'erro': str(e)}

# Salvar arquivo
filename = f'backup-analise-{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
with open(filename, 'w', encoding='utf-8') as f:
    json.dump(backup_completo, f, indent=2, ensure_ascii=False, default=str)

print(f"\n✅ Backup exportado: {filename}")
print(f"📦 Tamanho: {os.path.getsize(filename) / 1024:.2f} KB")
print(f"\n💡 Agora você pode:")
print(f"   1. Abrir o arquivo {filename} e copiar o conteúdo")
print(f"   2. Colar aqui no chat para análise")
print(f"   3. Ou anexar o arquivo se o tamanho for pequeno")
