# 🔄 AGENDADOR DE BACKUPS AUTOMÁTICOS
# Executa o script de backup em intervalos regulares

import schedule
import time
import subprocess
import sys
from datetime import datetime

# =====================================================
# CONFIGURAÇÕES
# =====================================================

# Frequência do backup
BACKUP_INTERVAL_HOURS = 24  # A cada 24 horas (diário)
# Ou use: BACKUP_INTERVAL_HOURS = 6  # A cada 6 horas

# Caminho do script de backup
BACKUP_SCRIPT = './backup-automatico.py'

# =====================================================
# FUNÇÕES
# =====================================================

def run_backup():
    """Executa o script de backup"""
    print("")
    print("=" * 60)
    print(f"⏰ INICIANDO BACKUP AGENDADO")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    try:
        # Executar script de backup
        result = subprocess.run(
            [sys.executable, BACKUP_SCRIPT],
            capture_output=True,
            text=True
        )
        
        print(result.stdout)
        
        if result.returncode == 0:
            print("✅ Backup agendado concluído com sucesso!")
        else:
            print("❌ Erro no backup agendado:")
            print(result.stderr)
            
    except Exception as e:
        print(f"❌ Erro ao executar backup: {str(e)}")

def start_scheduler():
    """Inicia o agendador de backups"""
    print("🚀 SISTEMA DE BACKUP AUTOMÁTICO INICIADO")
    print(f"⏰ Frequência: A cada {BACKUP_INTERVAL_HOURS} horas")
    print(f"📂 Script: {BACKUP_SCRIPT}")
    print("")
    print("💡 Pressione Ctrl+C para parar")
    print("=" * 60)
    
    # Fazer backup imediatamente ao iniciar
    run_backup()
    
    # Agendar backups futuros
    schedule.every(BACKUP_INTERVAL_HOURS).hours.do(run_backup)
    
    # Loop infinito
    while True:
        schedule.run_pending()
        time.sleep(60)  # Verificar a cada 1 minuto

# =====================================================
# EXECUÇÃO PRINCIPAL
# =====================================================

if __name__ == "__main__":
    try:
        start_scheduler()
    except KeyboardInterrupt:
        print("")
        print("⏹️ Sistema de backup automático encerrado pelo usuário")
        exit(0)
    except Exception as e:
        print(f"❌ Erro fatal: {str(e)}")
        exit(1)
