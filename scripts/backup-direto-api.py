#!/usr/bin/env python3
"""
Backup usando API REST diretamente (bypass RLS com SERVICE_ROLE_KEY)
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
    print("❌ ERRO: Faltam variáveis de ambiente!")
    print(f"   SUPABASE_URL: {'✅' if SUPABASE_URL else '❌'}")
    print(f"   SERVICE_ROLE_KEY: {'✅' if SERVICE_ROLE_KEY else '❌'}")
    exit(1)

# Headers com SERVICE_ROLE_KEY (bypass RLS)
HEADERS = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json"
}

# Tabelas críticas para backup
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
    'ordens_servico',
    'categorias',
    'fornecedores',
    'despesas'
]

def fazer_backup_tabela(tabela: str, backup_dir: Path) -> dict:
    """Faz backup de uma tabela usando API REST direta"""
    try:
        # URL da API REST do Supabase
        url = f"{SUPABASE_URL}/rest/v1/{tabela}?select=*"
        
        print(f"   🔄 Buscando dados de {tabela}...")
        
        # Fazer requisição GET
        response = requests.get(url, headers=HEADERS, timeout=30)
        
        if response.status_code == 200:
            dados = response.json()
            total = len(dados)
            
            # Salvar arquivo JSON
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            arquivo = backup_dir / f"{tabela}_{timestamp}.json"
            
            with open(arquivo, 'w', encoding='utf-8') as f:
                json.dump(dados, f, indent=2, ensure_ascii=False)
            
            print(f"   ✅ {tabela}: {total} registros salvos em {arquivo.name}")
            return {"status": "success", "count": total, "file": arquivo.name}
            
        else:
            erro = response.json() if response.headers.get('content-type') == 'application/json' else response.text
            print(f"   ❌ {tabela}: Erro {response.status_code}")
            print(f"      Detalhes: {erro}")
            return {"status": "error", "code": response.status_code, "error": erro}
            
    except Exception as e:
        print(f"   ❌ {tabela}: Exceção - {str(e)}")
        return {"status": "error", "error": str(e)}

def main():
    print("=" * 50)
    print("🚀 BACKUP DIRETO VIA API REST")
    print("=" * 50)
    print(f"📅 Data/Hora: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"🔑 Usando: SERVICE_ROLE_KEY (bypass RLS)")
    print()
    
    # Criar diretório de backup
    backup_dir = Path('./backups')
    backup_dir.mkdir(exist_ok=True)
    print(f"✅ Diretório de backup: {backup_dir}")
    print()
    
    # Backup de cada tabela
    resultados = {}
    sucessos = 0
    falhas = 0
    
    for tabela in TABELAS:
        resultado = fazer_backup_tabela(tabela, backup_dir)
        resultados[tabela] = resultado
        
        if resultado["status"] == "success":
            sucessos += 1
        else:
            falhas += 1
    
    # Salvar metadata
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    metadata = {
        "backup_date": datetime.now().isoformat(),
        "method": "direct_rest_api",
        "key_type": "service_role",
        "total_tables": len(TABELAS),
        "success_count": sucessos,
        "failure_count": falhas,
        "results": resultados
    }
    
    metadata_file = backup_dir / f"backup_metadata_{timestamp}.json"
    with open(metadata_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    print()
    print("=" * 50)
    print(f"✅ Backup concluído!")
    print(f"   Sucesso: {sucessos} tabelas")
    print(f"   Falhas: {falhas} tabelas")
    print(f"   Total: {len(TABELAS)} tabelas")
    print(f"   Metadata: {metadata_file.name}")
    print("=" * 50)

if __name__ == "__main__":
    main()
