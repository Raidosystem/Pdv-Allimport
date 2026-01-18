#!/bin/bash
echo "╔════════════════════════════════════════════════════════╗"
echo "║        📊 SISTEMA DE BACKUP ALLIMPORT                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🔄 SERVIÇOS AUTOMÁTICOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
launchctl list | grep allimport | while read status pid name; do
    if [ "$name" = "com.allimport.backup" ]; then
        echo "✅ Backup Geral           - 3h da manhã"
    elif [ "$name" = "com.allimport.backup.empresas" ]; then
        echo "✅ Backup Por Empresa     - 4h da manhã"
    fi
done
echo ""
echo "📁 ESTRUTURA DE ARQUIVOS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "backups/"
echo "├── [Backup Geral] - Todos os dados juntos"
GERAL=$(ls backups/*.json 2>/dev/null | wc -l | tr -d ' ')
echo "│   └── $GERAL arquivos"
echo "│"
echo "└── [Backup Por Empresa] - Isolado por cliente"
EMPRESAS=$(ls -d backups/empresa_* 2>/dev/null | wc -l | tr -d ' ')
echo "    └── $EMPRESAS empresas"
for dir in backups/empresa_*; do
    if [ -d "$dir" ]; then
        COUNT=$(ls $dir/*.json 2>/dev/null | wc -l | tr -d ' ')
        META=$(ls $dir/backup_metadata_*.json 2>/dev/null | tail -1)
        if [ -f "$META" ]; then
            EMPRESA=$(cat "$META" | grep -o '"empresa": "[^"]*"' | cut -d'"' -f4)
            REGISTROS=$(cat "$META" | grep -o '"total_records": [0-9]*' | cut -d' ' -f2)
            echo "        ├── ${EMPRESA:0:25} - $REGISTROS registros ($COUNT arquivos)"
        fi
    fi
done
echo ""
echo "💾 ESPAÇO EM DISCO:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
du -sh backups/
echo ""
echo "🖱️  ATALHOS NO DESKTOP:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f ~/Desktop/Backup-Allimport.command ]; then
    echo "✅ Backup-Allimport.command       (Backup geral)"
fi
if [ -f ~/Desktop/Backup-Por-Empresa.command ]; then
    echo "✅ Backup-Por-Empresa.command     (Backup isolado)"
fi
echo ""
echo "════════════════════════════════════════════════════════"
