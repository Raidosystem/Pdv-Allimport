#!/bin/bash
# ============================================
# INSTALADOR DE BACKUP AUTOMÁTICO
# ============================================
# Este script configura o backup diário às 3h da manhã

echo "🚀 Configurando Backup Automático Allimport"
echo "=========================================="
echo ""

# Criar diretório LaunchAgents se não existir
mkdir -p ~/Library/LaunchAgents

# Criar script wrapper para evitar problemas de permissão
cat > /Users/gruporaval/Documents/Pdv-Allimport/scripts/run-backup.sh << 'WRAPPER'
#!/bin/bash
cd /Users/gruporaval/Documents/Pdv-Allimport
/usr/bin/python3 scripts/backup-direto-api.py >> backups/backup.log 2>> backups/backup_error.log
WRAPPER

chmod +x /Users/gruporaval/Documents/Pdv-Allimport/scripts/run-backup.sh

# Criar arquivo plist
cat > ~/Library/LaunchAgents/com.allimport.backup.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.allimport.backup</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/gruporaval/Documents/Pdv-Allimport/scripts/run-backup.sh</string>
    </array>
    
    <key>WorkingDirectory</key>
    <string>/Users/gruporaval/Documents/Pdv-Allimport</string>
    
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
EOF

# Dar permissão
chmod 644 ~/Library/LaunchAgents/com.allimport.backup.plist

echo "✅ Arquivo de configuração criado"
echo ""

# Descarregar se já existir
launchctl unload ~/Library/LaunchAgents/com.allimport.backup.plist 2>/dev/null

# Carregar serviço
echo "🔄 Carregando serviço..."
launchctl load ~/Library/LaunchAgents/com.allimport.backup.plist

echo ""
echo "✅ Backup automático configurado!"
echo ""
echo "📋 Informações:"
echo "   - Horário: Todo dia às 3h da manhã"
echo "   - Logs: backups/backup.log"
echo "   - Erros: backups/backup_error.log"
echo ""
echo "🧪 Para testar agora, execute:"
echo "   launchctl start com.allimport.backup"
echo ""
echo "📊 Para ver status:"
echo "   launchctl list | grep allimport"
echo ""
