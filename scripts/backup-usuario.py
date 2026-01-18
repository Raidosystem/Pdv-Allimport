#!/usr/bin/env python3
"""
BACKUP LOCAL DO USUÁRIO - PWA
==============================
Este script faz backup APENAS dos dados da empresa do usuário logado.
Cada usuário instala no próprio computador e backup roda localmente.

IMPORTANTE: Este script usa o access_token do usuário, não SERVICE_ROLE_KEY
"""

import os
import json
import requests
from datetime import datetime
from pathlib import Path

# =====================================================
# CONFIGURAÇÃO - USUÁRIO DEVE PREENCHER
# =====================================================

# Pegar do navegador após login (F12 > Application > Local Storage)
SUPABASE_URL = "COLE_AQUI_O_SUPABASE_URL"  # Ex: https://xxx.supabase.co
ACCESS_TOKEN = "COLE_AQUI_SEU_ACCESS_TOKEN"  # Token do localStorage após login

# =====================================================

if SUPABASE_URL == "COLE_AQUI_O_SUPABASE_URL" or ACCESS_TOKEN == "COLE_AQUI_SEU_ACCESS_TOKEN":
    print("=" * 60)
    print("❌ CONFIGURAÇÃO NECESSÁRIA!")
    print("=" * 60)
    print()
    print("📋 PASSO A PASSO:")
    print()
    print("1. Abra o PDV no navegador e faça LOGIN")
    print("2. Pressione F12 (abrir DevTools)")
    print("3. Vá em: Application > Local Storage")
    print("4. Copie os valores:")
    print()
    print("   SUPABASE_URL:")
    print("   Procure por algo como: sb-xxx-auth-token")
    print("   Dentro tem 'iss' (issuer) que é o URL")
    print()
    print("   ACCESS_TOKEN:")
    print("   Procure por: sb-xxx-auth-token")
    print("   Copie o valor de 'access_token'")
    print()
    print("5. Cole esses valores no início deste arquivo (backup-usuario.py)")
    print("6. Execute novamente: python3 backup-usuario.py")
    print()
    print("=" * 60)
    exit(1)

# Headers com token do usuário (RLS filtra automaticamente)
HEADERS = {
    "apikey": ACCESS_TOKEN,  # Pode ser anon key ou access token
    "Authorization": f"Bearer {ACCESS_TOKEN}",
    "Content-Type": "application/json"
}

# Tabelas do usuário
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

def backup_tabela(tabela: str, backup_dir: Path):
    """Faz backup de uma tabela (RLS filtra automaticamente pelo user_id)"""
    try:
        # Buscar TODOS os dados - RLS filtra automaticamente
        url = f"{SUPABASE_URL}/rest/v1/{tabela}?select=*"
        response = requests.get(url, headers=HEADERS, timeout=30)
        
        if response.status_code == 401:
            print(f"   ❌ {tabela}: Token expirado! Faça login novamente e atualize o ACCESS_TOKEN")
            return None
        
        if response.status_code != 200:
            print(f"   ❌ {tabela}: Erro {response.status_code}")
            return None
        
        dados = response.json()
        
        if not dados:
            print(f"   ⚪ {tabela}: 0 registros")
            return 0
        
        # Salvar arquivo
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = backup_dir / f'{tabela}_{timestamp}.json'
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(dados, f, indent=2, ensure_ascii=False)
        
        print(f"   ✅ {tabela}: {len(dados)} registros")
        return len(dados)
        
    except Exception as e:
        print(f"   ❌ {tabela}: {str(e)}")
        return None

def main():
    print("╔════════════════════════════════════════╗")
    print("║   💼 BACKUP LOCAL DO USUÁRIO          ║")
    print("╚════════════════════════════════════════╝")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Criar diretório de backup
    backup_dir = Path.home() / 'Documents' / 'Backup-PDV-Allimport'
    backup_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"📁 Salvando em: {backup_dir}")
    print()
    
    # Backup de cada tabela
    sucessos = 0
    falhas = 0
    total_registros = 0
    
    for tabela in TABELAS:
        resultado = backup_tabela(tabela, backup_dir)
        
        if resultado is not None:
            sucessos += 1
            total_registros += resultado
        else:
            falhas += 1
    
    # Salvar metadata
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    metadata = {
        "backup_date": datetime.now().isoformat(),
        "total_tables": len(TABELAS),
        "success": sucessos,
        "failures": falhas,
        "total_records": total_registros,
        "tipo": "backup_usuario_local"
    }
    
    metadata_file = backup_dir / f'backup_metadata_{timestamp}.json'
    with open(metadata_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    print()
    print("=" * 60)
    print(f"✅ Backup concluído!")
    print(f"   Sucesso: {sucessos}/{len(TABELAS)} tabelas")
    print(f"   Falhas: {falhas}")
    print(f"   Total: {total_registros} registros")
    print(f"   📁 Pasta: {backup_dir}")
    print("=" * 60)

if __name__ == "__main__":
    main()
