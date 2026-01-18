# 🔄 SISTEMA DE RESTAURAÇÃO DE BACKUP
# Restaura dados de um backup específico

import os
import json
from datetime import datetime
from supabase import create_client

# =====================================================
# CONFIGURAÇÕES
# =====================================================

SUPABASE_URL = os.getenv('VITE_SUPABASE_URL')
SUPABASE_KEY = os.getenv('VITE_SUPABASE_ANON_KEY')  # Use service_role para restauração completa

BACKUP_DIR = './backups'

# =====================================================
# FUNÇÕES DE RESTAURAÇÃO
# =====================================================

def list_backups(table_name=None):
    """Lista todos os backups disponíveis"""
    if not os.path.exists(BACKUP_DIR):
        print("❌ Diretório de backups não encontrado")
        return []
    
    files = os.listdir(BACKUP_DIR)
    
    if table_name:
        files = [f for f in files if f.startswith(table_name) and f.endswith('.json')]
    else:
        files = [f for f in files if f.endswith('.json') and not f.startswith('backup_metadata')]
    
    files.sort(reverse=True)  # Mais recentes primeiro
    return files

def restore_table(supabase, table_name, backup_file):
    """Restaura uma tabela específica de um backup"""
    try:
        filepath = os.path.join(BACKUP_DIR, backup_file)
        
        print(f"📥 Lendo backup: {backup_file}")
        
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if not data:
            print(f"   ⚠️ Backup vazio, nada a restaurar")
            return True
        
        print(f"📤 Restaurando {len(data)} registros em {table_name}...")
        
        # Opção 1: Upsert (atualiza ou insere)
        # Melhor para restauração parcial
        for record in data:
            supabase.table(table_name).upsert(record).execute()
        
        print(f"   ✅ {len(data)} registros restaurados!")
        return True
        
    except Exception as e:
        print(f"   ❌ Erro ao restaurar {table_name}: {str(e)}")
        return False

def restore_interactive():
    """Modo interativo de restauração"""
    print("=" * 60)
    print("🔄 SISTEMA DE RESTAURAÇÃO DE BACKUP")
    print("=" * 60)
    print("")
    
    # Listar tabelas disponíveis
    all_backups = list_backups()
    
    if not all_backups:
        print("❌ Nenhum backup encontrado!")
        return
    
    # Agrupar por tabela
    tables = {}
    for backup in all_backups:
        table = backup.split('_')[0]
        if table not in tables:
            tables[table] = []
        tables[table].append(backup)
    
    print("📋 Tabelas com backup disponível:")
    for i, table in enumerate(tables.keys(), 1):
        print(f"   {i}. {table} ({len(tables[table])} backups)")
    
    print("")
    table_choice = input("Escolha a tabela (número) ou 'all' para todas: ").strip()
    
    if table_choice.lower() == 'all':
        # Restaurar todas as tabelas
        print("\n⚠️  ATENÇÃO: Isso irá restaurar TODAS as tabelas!")
        confirm = input("Digite 'CONFIRMAR' para continuar: ").strip()
        
        if confirm != 'CONFIRMAR':
            print("❌ Restauração cancelada")
            return
        
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        for table, backups in tables.items():
            latest_backup = backups[0]  # Mais recente
            print(f"\n📦 Restaurando {table}...")
            restore_table(supabase, table, latest_backup)
        
        print("\n✅ Restauração completa concluída!")
        
    else:
        # Restaurar tabela específica
        try:
            table_index = int(table_choice) - 1
            table_name = list(tables.keys())[table_index]
        except (ValueError, IndexError):
            print("❌ Escolha inválida")
            return
        
        # Listar backups da tabela
        print(f"\n📋 Backups disponíveis para {table_name}:")
        backups = tables[table_name]
        
        for i, backup in enumerate(backups[:10], 1):  # Mostrar últimos 10
            # Extrair timestamp do nome do arquivo
            timestamp = backup.split('_')[-1].replace('.json', '')
            date = datetime.strptime(timestamp, '%Y%m%d%H%M%S').strftime('%Y-%m-%d %H:%M:%S')
            print(f"   {i}. {date}")
        
        print("")
        backup_choice = input("Escolha o backup (número): ").strip()
        
        try:
            backup_index = int(backup_choice) - 1
            backup_file = backups[backup_index]
        except (ValueError, IndexError):
            print("❌ Escolha inválida")
            return
        
        # Confirmar
        print(f"\n⚠️  Você vai restaurar: {table_name}")
        print(f"   Usando backup de: {backup_file}")
        confirm = input("Confirmar? (s/n): ").strip().lower()
        
        if confirm != 's':
            print("❌ Restauração cancelada")
            return
        
        # Restaurar
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        restore_table(supabase, table_name, backup_file)
        
        print("\n✅ Restauração concluída!")

# =====================================================
# EXECUÇÃO PRINCIPAL
# =====================================================

if __name__ == "__main__":
    try:
        restore_interactive()
    except KeyboardInterrupt:
        print("\n\n❌ Restauração cancelada pelo usuário")
        exit(0)
    except Exception as e:
        print(f"\n❌ Erro fatal: {str(e)}")
        exit(1)
