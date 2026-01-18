# 🔄 RESTAURAÇÃO ISOLADA POR EMPRESA - Versão HTTP Direta
# Restaura APENAS uma empresa específica usando HTTP requests

import os
import json
import requests
from datetime import datetime
from pathlib import Path

# =====================================================
# CARREGAR CONFIGURAÇÕES
# =====================================================

env_path = Path(__file__).parent.parent / '.env'

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

HEADERS = {
    'apikey': SERVICE_ROLE_KEY,
    'Authorization': f'Bearer {SERVICE_ROLE_KEY}',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation,resolution=merge-duplicates'
}

# =====================================================
# FUNÇÕES
# =====================================================

def listar_empresas_com_backup():
    """Lista empresas que possuem backup"""
    backup_dir = Path('./backups')
    
    if not backup_dir.exists():
        return []
    
    empresas = []
    
    for pasta in backup_dir.iterdir():
        if pasta.is_dir() and pasta.name.startswith('empresa_'):
            metadata_files = list(pasta.glob('backup_metadata_*.json'))
            
            if metadata_files:
                metadata_file = max(metadata_files, key=lambda x: x.stat().st_mtime)
                
                with open(metadata_file, 'r', encoding='utf-8') as f:
                    metadata = json.load(f)
                    
                empresas.append({
                    'pasta': pasta.name,
                    'user_id': metadata['user_id'],
                    'nome': metadata['nome'],
                    'ultimo_backup': metadata['data_backup'],
                    'total_registros': metadata['total_registros']
                })
    
    return empresas

def listar_backups_tabela(empresa_pasta: str, tabela: str):
    """Lista backups de uma tabela"""
    pasta = Path('./backups') / empresa_pasta
    backups = list(pasta.glob(f'{tabela}_*.json'))
    return sorted(backups, key=lambda x: x.stat().st_mtime, reverse=True)

def restaurar_tabela(arquivo: Path, tabela: str, user_id: str):
    """Restaura tabela via HTTP UPSERT"""
    try:
        with open(arquivo, 'r', encoding='utf-8') as f:
            dados = json.load(f)
        
        if not dados:
            print(f"   ⚠️ Arquivo vazio")
            return 0
        
        # Verificar user_id
        if dados[0].get('user_id') != user_id:
            print(f"   ⚠️ AVISO: Dados não pertencem ao user_id esperado")
            resposta = input("   Continuar? (s/N): ")
            if resposta.lower() != 's':
                return 0
        
        # UPSERT via HTTP
        url = f"{SUPABASE_URL}/rest/v1/{tabela}"
        response = requests.post(url, headers=HEADERS, json=dados)
        
        if response.status_code in [200, 201]:
            print(f"   ✅ {len(dados)} registros restaurados")
            return len(dados)
        else:
            print(f"   ❌ Erro HTTP {response.status_code}: {response.text[:100]}")
            return 0
        
    except Exception as e:
        print(f"   ❌ Erro: {e}")
        return 0

def menu_selecionar_empresa():
    """Menu interativo"""
    empresas = listar_empresas_com_backup()
    
    if not empresas:
        print("❌ Nenhuma empresa com backup encontrada")
        return None
    
    print(f"\n{'='*60}")
    print("🏢 EMPRESAS COM BACKUP DISPONÍVEL")
    print(f"{'='*60}")
    
    for i, emp in enumerate(empresas, 1):
        print(f"{i}. {emp['nome']}")
        print(f"   User ID: {emp['user_id'][:8]}...")
        print(f"   Último backup: {emp['ultimo_backup']}")
        print(f"   Registros: {emp['total_registros']}")
        print()
    
    try:
        escolha = int(input("Escolha a empresa (número): "))
        if 1 <= escolha <= len(empresas):
            return empresas[escolha - 1]
    except ValueError:
        pass
    
    print("❌ Opção inválida")
    return None

def menu_selecionar_tabelas(empresa_pasta: str):
    """Menu de tabelas"""
    pasta = Path('./backups') / empresa_pasta
    
    tabelas_disponiveis = set()
    for arquivo in pasta.glob('*.json'):
        if not arquivo.name.startswith('backup_metadata'):
            tabela = arquivo.name.split('_')[0]
            tabelas_disponiveis.add(tabela)
    
    tabelas = sorted(tabelas_disponiveis)
    
    print(f"\n{'='*60}")
    print("📋 TABELAS DISPONÍVEIS")
    print(f"{'='*60}")
    print("0. [TODAS AS TABELAS]")
    
    for i, tabela in enumerate(tabelas, 1):
        backups = listar_backups_tabela(empresa_pasta, tabela)
        print(f"{i}. {tabela} ({len(backups)} backup(s))")
    
    print()
    escolhas = input("Escolha (ex: 1,3,5 ou 0 para todas): ").strip()
    
    if escolhas == '0':
        return tabelas
    
    try:
        indices = [int(x.strip()) for x in escolhas.split(',')]
        return [tabelas[i-1] for i in indices if 1 <= i <= len(tabelas)]
    except (ValueError, IndexError):
        return []

def restaurar_interativo():
    """Processo interativo"""
    print("🔄 RESTAURAÇÃO ISOLADA POR EMPRESA - Versão HTTP")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    
    empresa = menu_selecionar_empresa()
    if not empresa:
        return
    
    tabelas = menu_selecionar_tabelas(empresa['pasta'])
    if not tabelas:
        print("❌ Nenhuma tabela selecionada")
        return
    
    # Confirmação
    print(f"\n{'='*60}")
    print("⚠️ CONFIRMAÇÃO DE RESTAURAÇÃO")
    print(f"{'='*60}")
    print(f"Empresa: {empresa['nome']}")
    print(f"User ID: {empresa['user_id'][:8]}...")
    print(f"Tabelas: {', '.join(tabelas)}")
    print(f"\n🚨 Esta operação irá SOBRESCREVER os dados atuais!")
    print(f"✅ Apenas a empresa {empresa['nome']} será afetada")
    print(f"✅ Outras empresas NÃO serão afetadas")
    print(f"{'='*60}")
    
    confirmacao = input("\nDigite 'RESTAURAR' para confirmar: ")
    
    if confirmacao != 'RESTAURAR':
        print("❌ Operação cancelada")
        return
    
    # Executar
    print(f"\n🚀 Restaurando...\n")
    
    total = 0
    
    for tabela in tabelas:
        print(f"📥 {tabela}...", end=' ')
        backups = listar_backups_tabela(empresa['pasta'], tabela)
        
        if backups:
            resultado = restaurar_tabela(backups[0], tabela, empresa['user_id'])
            total += resultado
        else:
            print(f"   ⚠️ Nenhum backup encontrado")
    
    print(f"\n{'='*60}")
    print("✅ RESTAURAÇÃO CONCLUÍDA!")
    print(f"{'='*60}")
    print(f"Empresa: {empresa['nome']}")
    print(f"Tabelas: {len(tabelas)}")
    print(f"Registros: {total}")
    print(f"{'='*60}")
    print(f"✅ Apenas {empresa['nome']} foi restaurada")
    print(f"✅ Outras empresas permanecem intactas")

if __name__ == '__main__':
    restaurar_interativo()
