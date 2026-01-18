# 🔄 RESTAURAÇÃO ISOLADA POR EMPRESA - Multi-Tenancy Seguro
# Restaura APENAS os dados de UMA empresa específica, sem afetar outras

import os
import json
from datetime import datetime
from pathlib import Path
from supabase import create_client
from dotenv import load_dotenv

# Carregar variáveis de ambiente
env_path = Path(__file__).parent.parent / '.env'
load_dotenv(env_path)

# =====================================================
# CONFIGURAÇÕES
# =====================================================

SUPABASE_URL = os.getenv('VITE_SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY') or os.getenv('VITE_SUPABASE_ANON_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ ERRO: Configure VITE_SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY no .env")
    exit(1)

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def listar_empresas_com_backup():
    """Lista empresas que possuem backup"""
    backup_dir = Path('./backups')
    
    if not backup_dir.exists():
        print("❌ Pasta de backups não encontrada")
        return []
    
    empresas = []
    
    for pasta in backup_dir.iterdir():
        if pasta.is_dir() and pasta.name.startswith('empresa_'):
            # Buscar metadata mais recente
            metadata_files = list(pasta.glob('backup_metadata_*.json'))
            
            if metadata_files:
                # Pegar o mais recente
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
    """Lista backups disponíveis de uma tabela"""
    pasta = Path('./backups') / empresa_pasta
    backups = list(pasta.glob(f'{tabela}_*.json'))
    
    return sorted(backups, key=lambda x: x.stat().st_mtime, reverse=True)

def restaurar_tabela(arquivo_backup: Path, tabela: str, user_id: str):
    """Restaura uma tabela de um arquivo de backup"""
    try:
        # Ler arquivo JSON
        with open(arquivo_backup, 'r', encoding='utf-8') as f:
            dados = json.load(f)
        
        if not dados:
            print(f"   ⚠️ Arquivo vazio: {arquivo_backup.name}")
            return 0
        
        # Verificar se dados pertencem ao user_id correto
        if dados[0].get('user_id') != user_id:
            print(f"   ⚠️ AVISO: Dados não pertencem ao user_id {user_id}")
            resposta = input("   Continuar mesmo assim? (s/N): ")
            if resposta.lower() != 's':
                return 0
        
        # Usar upsert para restaurar (insere novos, atualiza existentes)
        resultado = supabase.from_(tabela).upsert(dados).execute()
        
        print(f"   ✅ {len(dados)} registros restaurados em {tabela}")
        return len(dados)
        
    except Exception as e:
        print(f"   ❌ Erro ao restaurar {tabela}: {e}")
        return 0

def menu_selecionar_empresa():
    """Menu para selecionar empresa"""
    empresas = listar_empresas_com_backup()
    
    if not empresas:
        print("❌ Nenhuma empresa com backup encontrada")
        return None
    
    print(f"\n{'='*60}")
    print("🏢 EMPRESAS COM BACKUP DISPONÍVEL")
    print(f"{'='*60}")
    
    for i, empresa in enumerate(empresas, 1):
        print(f"{i}. {empresa['nome']}")
        print(f"   User ID: {empresa['user_id'][:8]}...")
        print(f"   Último backup: {empresa['ultimo_backup']}")
        print(f"   Total registros: {empresa['total_registros']}")
        print()
    
    try:
        escolha = int(input("Escolha a empresa (número): "))
        
        if 1 <= escolha <= len(empresas):
            return empresas[escolha - 1]
        else:
            print("❌ Opção inválida")
            return None
    except ValueError:
        print("❌ Digite um número válido")
        return None

def menu_selecionar_tabelas(empresa_pasta: str):
    """Menu para selecionar quais tabelas restaurar"""
    pasta = Path('./backups') / empresa_pasta
    
    # Listar tabelas com backup
    tabelas_disponiveis = set()
    for arquivo in pasta.glob('*.json'):
        if not arquivo.name.startswith('backup_metadata'):
            tabela = arquivo.name.split('_')[0]
            tabelas_disponiveis.add(tabela)
    
    tabelas = sorted(tabelas_disponiveis)
    
    print(f"\n{'='*60}")
    print("📋 TABELAS DISPONÍVEIS PARA RESTAURAR")
    print(f"{'='*60}")
    print("0. [TODAS AS TABELAS]")
    
    for i, tabela in enumerate(tabelas, 1):
        backups = listar_backups_tabela(empresa_pasta, tabela)
        print(f"{i}. {tabela} ({len(backups)} backup(s))")
    
    print()
    escolhas = input("Escolha as tabelas (ex: 1,3,5 ou 0 para todas): ").strip()
    
    if escolhas == '0':
        return tabelas
    
    try:
        indices = [int(x.strip()) for x in escolhas.split(',')]
        return [tabelas[i-1] for i in indices if 1 <= i <= len(tabelas)]
    except (ValueError, IndexError):
        print("❌ Opção inválida")
        return []

def restaurar_empresa_interativo():
    """Processo interativo de restauração"""
    print("🔄 RESTAURAÇÃO ISOLADA POR EMPRESA")
    print(f"📅 Data/Hora: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    
    # Selecionar empresa
    empresa = menu_selecionar_empresa()
    if not empresa:
        return
    
    # Selecionar tabelas
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
    print(f"\n🚨 ATENÇÃO: Esta operação irá SOBRESCREVER os dados atuais!")
    print(f"✅ Apenas os dados da empresa {empresa['nome']} serão afetados")
    print(f"✅ Outras empresas NÃO serão afetadas")
    print(f"{'='*60}")
    
    confirmacao = input("\nDigite 'RESTAURAR' para confirmar: ")
    
    if confirmacao != 'RESTAURAR':
        print("❌ Operação cancelada")
        return
    
    # Executar restauração
    print(f"\n🚀 Iniciando restauração...\n")
    
    total_restaurados = 0
    
    for tabela in tabelas:
        print(f"📥 Restaurando {tabela}...")
        
        # Pegar backup mais recente
        backups = listar_backups_tabela(empresa['pasta'], tabela)
        
        if backups:
            resultado = restaurar_tabela(backups[0], tabela, empresa['user_id'])
            total_restaurados += resultado
        else:
            print(f"   ⚠️ Nenhum backup encontrado para {tabela}")
    
    # Resumo
    print(f"\n{'='*60}")
    print("✅ RESTAURAÇÃO CONCLUÍDA!")
    print(f"{'='*60}")
    print(f"Empresa: {empresa['nome']}")
    print(f"Tabelas restauradas: {len(tabelas)}")
    print(f"Total de registros: {total_restaurados}")
    print(f"{'='*60}")
    print(f"✅ Apenas a empresa {empresa['nome']} foi restaurada")
    print(f"✅ Outras empresas permanecem intactas")

if __name__ == '__main__':
    restaurar_empresa_interativo()
