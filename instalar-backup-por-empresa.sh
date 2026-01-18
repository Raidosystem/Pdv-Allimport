#!/bin/bash
# ============================================
# INSTALADOR DE BACKUP POR EMPRESA
# ============================================
# Backup diário às 4h da manhã (1h depois do backup geral)
# Cada empresa em pasta separada

echo "🚀 Configurando Backup Por Empresa"
echo "=========================================="
echo ""

# Criar diretório LaunchAgents se não existir
mkdir -p ~/Library/LaunchAgents

# Criar script wrapper
cat > /Users/gruporaval/Documents/Pdv-Allimport/scripts/run-backup-empresas.sh << 'WRAPPER'
#!/bin/bash
cd /Users/gruporaval/Documents/Pdv-Allimport
/usr/bin/python3 scripts/backup-por-empresa-api.py >> backups/backup_empresas.log 2>> backups/backup_empresas_error.log
WRAPPER

chmod +x /Users/gruporaval/Documents/Pdv-Allimport/scripts/run-backup-empresas.sh

# Criar arquivo plist
cat > ~/Library/LaunchAgents/com.allimport.backup.empresas.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.allimport.backup.empresas</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/gruporaval/Documents/Pdv-Allimport/scripts/run-backup-empresas.sh</string>
    </array>
    
    <key>WorkingDirectory</key>
    <string>/Users/gruporaval/Documents/Pdv-Allimport</string>
    
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>4</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
EOF

# Dar permissão
chmod 644 ~/Library/LaunchAgents/com.allimport.backup.empresas.plist

echo "✅ Arquivo de configuração criado"
echo ""

# Descarregar se já existir
launchctl unload ~/Library/LaunchAgents/com.allimport.backup.empresas.plist 2>/dev/null

# Carregar serviço
echo "🔄 Carregando serviço..."
launchctl load ~/Library/LaunchAgents/com.allimport.backup.empresas.plist

echo ""
echo "✅ Backup por empresa configurado!"
echo ""
echo "📋 Informações:"
echo "   - Horário: Todo dia às 4h da manhã"
echo "   - Logs: backups/backup_empresas.log"
echo "   - Erros: backups/backup_empresas_error.log"
echo "   - Estrutura: backups/empresa_[id]/"
echo ""
echo "🧪 Para testar agora, execute:"
echo "   python3 scripts/backup-por-empresa-api.py"
echo ""
echo "📊 Para ver status:"
echo "   launchctl list | grep allimport"
echo ""
