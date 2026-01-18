import os
from pathlib import Path

# Ler .env
env_path = Path('.env')
for line in open(env_path, encoding='utf-8'):
    line = line.strip()
    if '=' in line and not line.startswith('#'):
        key, value = line.split('=', 1)
        os.environ[key] = value

# Testar acesso com requests
import requests

url = os.getenv('VITE_SUPABASE_URL') + '/rest/v1/empresas?select=*'
headers = {
    'apikey': os.getenv('SUPABASE_SERVICE_ROLE_KEY'),
    'Authorization': 'Bearer ' + os.getenv('SUPABASE_SERVICE_ROLE_KEY')
}

print("🔍 Testando acesso com SERVICE_ROLE_KEY...")
print(f"URL: {url}")
print(f"Key (primeiros 30 chars): {os.getenv('SUPABASE_SERVICE_ROLE_KEY')[:30]}...")

response = requests.get(url, headers=headers)

print(f"\n✅ Status: {response.status_code}")
if response.status_code == 200:
    data = response.json()
    print(f"✅ Empresas encontradas: {len(data)}")
    for emp in data:
        print(f"   - {emp.get('nome', 'Sem nome')}")
else:
    print(f"❌ Erro: {response.text}")
