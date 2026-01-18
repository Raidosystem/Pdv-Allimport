#!/usr/bin/env python3
"""
GERADOR DE INSTALADOR DE BACKUP PERSONALIZADO
==============================================
Gera um instalador específico para cada usuário com suas credenciais
"""

import sys
import os
from pathlib import Path

def gerar_instalador(user_id: str, empresa_nome: str, supabase_url: str, access_token: str):
    """Gera instalador personalizado para o usuário"""
    
    # Script Python personalizado
    script_backup = f'''#!/usr/bin/env python3
"""
BACKUP AUTOMÁTICO - {empresa_nome}
Gerado automaticamente pelo sistema PDV Allimport
"""

import os
import json
import requests
from datetime import datetime
from pathlib import Path

SUPABASE_URL = "{supabase_url}"
USER_ID = "{user_id}"
EMPRESA = "{empresa_nome}"

# Token será atualizado automaticamente
ACCESS_TOKEN = "{access_token}"

HEADERS = {{
    "apikey": ACCESS_TOKEN,
    "Authorization": f"Bearer {{ACCESS_TOKEN}}",
    "Content-Type": "application/json"
}}

TABELAS = [
    'user_approvals', 'empresas', 'subscriptions', 'produtos',
    'clientes', 'vendas', 'vendas_itens', 'caixa',
    'categorias', 'fornecedores', 'despesas', 'ordens_servico', 'funcionarios'
]

def backup_tabela(tabela: str, backup_dir: Path):
    try:
        url = f"{{SUPABASE_URL}}/rest/v1/{{tabela}}?select=*"
        response = requests.get(url, headers=HEADERS, timeout=30)
        
        if response.status_code != 200:
            return None
        
        dados = response.json()
        if not dados:
            return 0
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = backup_dir / f'{{tabela}}_{{timestamp}}.json'
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(dados, f, indent=2, ensure_ascii=False)
        
        return len(dados)
    except:
        return None

def main():
    print(f"🔒 Backup: {{EMPRESA}}")
    print(f"📅 {{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}}")
    
    backup_dir = Path.home() / 'Documents' / f'Backup-{{EMPRESA.replace(" ", "-")}}'
    backup_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"📁 {{backup_dir}}")
    
    total = 0
    for tabela in TABELAS:
        resultado = backup_tabela(tabela, backup_dir)
        if resultado is not None and resultado > 0:
            print(f"✅ {{tabela}}: {{resultado}}")
            total += resultado
    
    print(f"\\n✅ Total: {{total}} registros salvos")

if __name__ == "__main__":
    main()
'''
    
    # Instalador macOS (launchd)
    instalador_mac = f'''#!/bin/bash
# Instalador de Backup Automático - {empresa_nome}

echo "╔════════════════════════════════════════╗"
echo "║   🔒 BACKUP AUTOMÁTICO                ║"
echo "║   {empresa_nome:38} ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Criar diretório
INSTALL_DIR="$HOME/Documents/PDV-Backup-{empresa_nome.replace(" ", "-")}"
mkdir -p "$INSTALL_DIR"

# Copiar script
cat > "$INSTALL_DIR/backup.py" << 'SCRIPT_END'
{script_backup}
SCRIPT_END

# Script wrapper
cat > "$INSTALL_DIR/run-backup.sh" << 'WRAPPER_END'
#!/bin/bash
cd "$HOME/Documents/PDV-Backup-{empresa_nome.replace(" ", "-")}"
/usr/bin/python3 backup.py >> backup.log 2>> backup_error.log
WRAPPER_END

chmod +x "$INSTALL_DIR/run-backup.sh"

# Configurar launchd
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/com.pdv.backup.{user_id[:8]}.plist << 'PLIST_END'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.pdv.backup.{user_id[:8]}</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$HOME/Documents/PDV-Backup-{empresa_nome.replace(" ", "-")}/run-backup.sh</string>
    </array>
    
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
PLIST_END

chmod 644 ~/Library/LaunchAgents/com.pdv.backup.{user_id[:8]}.plist

# Carregar serviço
launchctl unload ~/Library/LaunchAgents/com.pdv.backup.{user_id[:8]}.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/com.pdv.backup.{user_id[:8]}.plist

echo ""
echo "✅ Backup automático configurado!"
echo ""
echo "📋 Configurações:"
echo "   - Empresa: {empresa_nome}"
echo "   - Horário: Todo dia às 2h da manhã"
echo "   - Pasta: $INSTALL_DIR"
echo ""
echo "🧪 Testar agora:"
echo "   python3 $INSTALL_DIR/backup.py"
echo ""
'''
    
    # Instalador Windows (Task Scheduler)
    instalador_windows = f'''@echo off
REM Instalador de Backup Automático - {empresa_nome}

echo ╔════════════════════════════════════════╗
echo ║   🔒 BACKUP AUTOMÁTICO                ║
echo ║   {empresa_nome:38} ║
echo ╚════════════════════════════════════════╝
echo.

set INSTALL_DIR=%USERPROFILE%\\Documents\\PDV-Backup-{empresa_nome.replace(" ", "-")}
mkdir "%INSTALL_DIR%" 2>nul

REM Criar script Python
(
echo {script_backup.replace(chr(10), "^" + chr(10))}
) > "%INSTALL_DIR%\\backup.py"

REM Criar tarefa agendada
schtasks /create /tn "PDV Backup {empresa_nome}" /tr "python \\"%INSTALL_DIR%\\backup.py\\"" /sc daily /st 02:00 /f

echo.
echo ✅ Backup automático configurado!
echo.
echo 📋 Configurações:
echo    - Empresa: {empresa_nome}
echo    - Horário: Todo dia às 2h da manhã
echo    - Pasta: %INSTALL_DIR%
echo.
echo 🧪 Testar agora:
echo    python "%INSTALL_DIR%\\backup.py"
echo.
pause
'''
    
    return {{
        'script_backup': script_backup,
        'instalador_mac': instalador_mac,
        'instalador_windows': instalador_windows
    }}

if __name__ == "__main__":
    # Exemplo de uso
    if len(sys.argv) < 5:
        print("Uso: python3 gerar-instalador.py USER_ID EMPRESA SUPABASE_URL ACCESS_TOKEN")
        sys.exit(1)
    
    user_id = sys.argv[1]
    empresa = sys.argv[2]
    url = sys.argv[3]
    token = sys.argv[4]
    
    arquivos = gerar_instalador(user_id, empresa, url, token)
    
    # Salvar arquivos
    output_dir = Path(f'instalador_{empresa.replace(" ", "_")}')
    output_dir.mkdir(exist_ok=True)
    
    with open(output_dir / 'backup.py', 'w') as f:
        f.write(arquivos['script_backup'])
    
    with open(output_dir / 'instalar-mac.sh', 'w') as f:
        f.write(arquivos['instalador_mac'])
    
    with open(output_dir / 'instalar-windows.bat', 'w') as f:
        f.write(arquivos['instalador_windows'])
    
    os.chmod(output_dir / 'instalar-mac.sh', 0o755)
    
    print(f"✅ Instalador gerado em: {{output_dir}}/")
    print(f"   - backup.py")
    print(f"   - instalar-mac.sh")
    print(f"   - instalar-windows.bat")
