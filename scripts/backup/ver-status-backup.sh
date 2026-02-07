#!/bin/bash
# ============================================
# VISUALIZAR STATUS DO BACKUP
# ============================================

cd /Users/gruporaval/Documents/Pdv-Allimport

echo "╔════════════════════════════════════════╗"
echo "║   📊 STATUS DO BACKUP ALLIMPORT       ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Verificar se serviço está ativo
echo "🔍 Serviço automático:"
if launchctl list | grep -q "com.allimport.backup"; then
    echo "   ✅ ATIVO - Backup automático às 3h da manhã"
else
    echo "   ❌ INATIVO - Execute: bash instalar-backup-automatico.sh"
fi
echo ""

# Último backup
echo "🕐 Último backup:"
if [ -f backups/backup.log ]; then
    tail -1 backups/backup.log
else
    echo "   ⚠️  Nenhum backup realizado ainda"
fi
echo ""

# Total de arquivos
TOTAL_BACKUPS=$(ls backups/*.json 2>/dev/null | wc -l | tr -d ' ')
echo "📁 Total de arquivos de backup: $TOTAL_BACKUPS"
echo ""

# Espaço usado
echo "💾 Espaço em disco:"
du -sh backups/
echo ""

# Últimos 5 backups
echo "📋 Últimos 5 backups:"
ls -lt backups/backup_metadata_*.json 2>/dev/null | head -5 | awk '{print "   ", $6, $7, $8, $9}'
echo ""

# Ver se há erros
if [ -f backups/backup_error.log ] && [ -s backups/backup_error.log ]; then
    echo "⚠️  Há erros no log:"
    tail -5 backups/backup_error.log
    echo ""
fi

echo "════════════════════════════════════════"
echo "💡 Comandos úteis:"
echo "   - Backup manual: bash Desktop/Backup-Allimport.command"
echo "   - Testar agora: launchctl start com.allimport.backup"
echo "   - Ver logs: tail -f backups/backup.log"
echo "════════════════════════════════════════"
