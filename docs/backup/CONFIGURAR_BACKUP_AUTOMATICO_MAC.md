# 🔄 Configurar Backup Automático no macOS

Este guia mostra como configurar o backup automático do banco de dados para rodar todos os dias.

## 📋 Opções Disponíveis

### Opção 1: Backup Diário às 3h da manhã (Recomendado)
### Opção 2: Backup a cada 6 horas
### Opção 3: Backup manual quando quiser

---

## 🚀 Opção 1: Backup Automático Diário (launchd)

O macOS usa **launchd** para agendar tarefas (equivalente ao cron do Linux).

### Passo 1: Criar arquivo de configuração

```bash
cd ~/Documents/Pdv-Allimport
nano ~/Library/LaunchAgents/com.allimport.backup.plist
```

### Passo 2: Colar este conteúdo:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Nome do serviço -->
    <key>Label</key>
    <string>com.allimport.backup</string>
    
    <!-- Caminho do script Python -->
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>/Users/gruporaval/Documents/Pdv-Allimport/scripts/backup-direto-api.py</string>
    </array>
    
    <!-- Diretório de trabalho -->
    <key>WorkingDirectory</key>
    <string>/Users/gruporaval/Documents/Pdv-Allimport</string>
    
    <!-- Horário: todos os dias às 3h da manhã -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    
    <!-- Logs de saída -->
    <key>StandardOutPath</key>
    <string>/Users/gruporaval/Documents/Pdv-Allimport/backups/backup.log</string>
    
    <!-- Logs de erro -->
    <key>StandardErrorPath</key>
    <string>/Users/gruporaval/Documents/Pdv-Allimport/backups/backup_error.log</string>
    
    <!-- Rodar mesmo quando usuário não está logado -->
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
```

### Passo 3: Ativar o backup automático

```bash
# Dar permissão ao arquivo
chmod 644 ~/Library/LaunchAgents/com.allimport.backup.plist

# Carregar o serviço
launchctl load ~/Library/LaunchAgents/com.allimport.backup.plist

# Verificar se foi carregado
launchctl list | grep allimport
```

### Passo 4: Testar agora (sem esperar às 3h)

```bash
launchctl start com.allimport.backup
```

### Verificar se funcionou:

```bash
# Ver último backup
ls -lht backups/*.json | head -5

# Ver log
cat backups/backup.log
```

---

## ⚙️ Opção 2: Backup a cada 6 horas

Se quiser backup mais frequente, use este `StartCalendarInterval`:

```xml
<!-- Backup 4x ao dia: 3h, 9h, 15h, 21h -->
<key>StartCalendarInterval</key>
<array>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <dict>
        <key>Hour</key>
        <integer>15</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <dict>
        <key>Hour</key>
        <integer>21</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</array>
```

Depois recarregar:
```bash
launchctl unload ~/Library/LaunchAgents/com.allimport.backup.plist
launchctl load ~/Library/LaunchAgents/com.allimport.backup.plist
```

---

## 🖱️ Opção 3: Atalho no Desktop (Backup Manual)

Criar arquivo `Backup-Allimport.command` no Desktop:

```bash
# Criar script
cat > ~/Desktop/Backup-Allimport.command << 'EOF'
#!/bin/bash
cd /Users/gruporaval/Documents/Pdv-Allimport
echo "🚀 Iniciando backup manual..."
python3 scripts/backup-direto-api.py
echo ""
echo "✅ Backup concluído! Pressione ENTER para fechar."
read
EOF

# Dar permissão de execução
chmod +x ~/Desktop/Backup-Allimport.command
```

Agora você pode **dar duplo-clique** no ícone no Desktop para fazer backup!

---

## 📊 Comandos Úteis

### Ver status do backup automático:
```bash
launchctl list | grep allimport
```

### Parar backup automático:
```bash
launchctl unload ~/Library/LaunchAgents/com.allimport.backup.plist
```

### Reativar backup automático:
```bash
launchctl load ~/Library/LaunchAgents/com.allimport.backup.plist
```

### Ver últimos backups:
```bash
ls -lht backups/*.json | head -10
```

### Ver logs:
```bash
# Log de sucesso
tail -f backups/backup.log

# Log de erros
tail -f backups/backup_error.log
```

### Limpar backups antigos (manter últimos 30 dias):
```bash
find backups/*.json -mtime +30 -delete
```

---

## 🔔 Notificações (Opcional)

Para receber notificação quando backup rodar, adicione ao final do script `backup-direto-api.py`:

```python
# No final do main()
try:
    import subprocess
    subprocess.run([
        'osascript', '-e', 
        f'display notification "Backup concluído: {sucessos}/{len(TABELAS)} tabelas" with title "Backup Allimport"'
    ])
except:
    pass
```

---

## 🗑️ Limpeza Automática de Backups Antigos

Criar script de limpeza:

```bash
cat > scripts/limpar-backups-antigos.sh << 'EOF'
#!/bin/bash
# Apagar backups com mais de 30 dias
cd /Users/gruporaval/Documents/Pdv-Allimport
find backups/*.json -mtime +30 -delete
echo "✅ Backups antigos removidos"
EOF

chmod +x scripts/limpar-backups-antigos.sh
```

Adicionar ao launchd para rodar toda semana:

```xml
<!-- No arquivo plist, adicionar -->
<key>StartCalendarInterval</key>
<dict>
    <key>Weekday</key>
    <integer>0</integer> <!-- Domingo -->
    <key>Hour</key>
    <integer>4</integer>
    <key>Minute</key>
    <integer>0</integer>
</dict>
```

---

## ✅ Checklist de Instalação

- [ ] Arquivo `.env` configurado com `SUPABASE_SERVICE_ROLE_KEY`
- [ ] Script `backup-direto-api.py` testado manualmente
- [ ] Arquivo `com.allimport.backup.plist` criado
- [ ] Serviço carregado com `launchctl load`
- [ ] Testado com `launchctl start`
- [ ] Verificado logs em `backups/backup.log`
- [ ] (Opcional) Atalho no Desktop criado

---

## 🆘 Problemas Comuns

### Backup não roda automaticamente
```bash
# Ver erros
launchctl list | grep allimport
# Se aparecer número negativo, há erro

# Ver log de erro
cat backups/backup_error.log
```

### Permissão negada
```bash
# Garantir que Python tem acesso ao diretório
chmod -R 755 /Users/gruporaval/Documents/Pdv-Allimport/backups
```

### Python não encontrado
```bash
# Verificar caminho do Python
which python3

# Atualizar no plist se necessário
```

---

## 📈 Monitoramento

Criar dashboard simples:

```bash
cat > ver-status-backup.sh << 'EOF'
#!/bin/bash
echo "📊 Status do Backup Allimport"
echo "=============================="
echo ""
echo "🕐 Último backup:"
ls -lt backups/backup_metadata_*.json | head -1 | awk '{print $6, $7, $8, $9}'
echo ""
echo "📁 Total de arquivos de backup:"
ls backups/*.json | wc -l
echo ""
echo "💾 Espaço usado:"
du -sh backups/
echo ""
echo "✅ Últimos 5 backups:"
ls -lt backups/backup_metadata_*.json | head -5 | awk '{print $6, $7, $8, $9}'
EOF

chmod +x ver-status-backup.sh
```

Rodar: `./ver-status-backup.sh`

---

## 🎯 Recomendação Final

**Configuração Ideal:**
1. ✅ Backup automático diário às 3h da manhã (Opção 1)
2. ✅ Atalho no Desktop para backup manual quando precisar
3. ✅ Limpeza automática de backups com +30 dias
4. ✅ Logs habilitados para monitoramento

**Pronto! Seus dados estarão sempre seguros! 🛡️**
