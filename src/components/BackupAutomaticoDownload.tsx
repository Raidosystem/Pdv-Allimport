import React, { useState } from 'react';
import { Download, HelpCircle, CheckCircle } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import toast from 'react-hot-toast';
import JSZip from 'jszip';

/**
 * Componente para usuário baixar instalador de backup automático
 * Cada usuário baixa um instalador personalizado com suas credenciais
 */
export function BackupAutomaticoDownload() {
  const [loading, setLoading] = useState(false);
  const [mostrarInstrucoes, setMostrarInstrucoes] = useState(false);

  const gerarInstalador = async () => {
    try {
      setLoading(true);

      // Pegar sessão do usuário
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        toast.error('Você precisa estar logado');
        return;
      }

      // Pegar dados da empresa
      const { data: empresa } = await supabase
        .from('empresas')
        .select('nome, razao_social')
        .eq('user_id', session.user.id)
        .single();

      const empresaNome = empresa?.nome || empresa?.razao_social || 'Minha Empresa';

      // Gerar script Python
      const scriptPython = gerarScriptBackup({
        userId: session.user.id,
        empresaNome,
        supabaseUrl: import.meta.env.VITE_SUPABASE_URL,
        accessToken: session.access_token
      });

      // Gerar instalador macOS
      const instaladorMac = gerarInstaladorMac({
        userId: session.user.id,
        empresaNome,
        scriptPython
      });

      // Gerar instalador Windows
      const instaladorWindows = gerarInstaladorWindows({
        userId: session.user.id,
        empresaNome,
        scriptPython
      });

      // Criar ZIP com os 3 arquivos
      const zip = await criarZip({
        'backup.py': scriptPython,
        'instalar-mac.sh': instaladorMac,
        'instalar-windows.bat': instaladorWindows,
        'LEIA-ME.txt': gerarReadme(empresaNome)
      });

      // Download do ZIP
      const blob = new Blob([zip], { type: 'application/zip' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `Backup-Automatico-${empresaNome.replace(/\s+/g, '-')}.zip`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);

      toast.success('Instalador baixado com sucesso!');
      setMostrarInstrucoes(true);

    } catch (error) {
      console.error('Erro ao gerar instalador:', error);
      toast.error('Erro ao gerar instalador');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-start gap-4">
        <div className="p-3 bg-blue-50 rounded-lg">
          <Download className="w-6 h-6 text-blue-600" />
        </div>
        
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            Backup Automático Local
          </h3>
          
          <p className="text-sm text-gray-600 mb-4">
            Configure backup automático no seu computador. Os dados serão salvos 
            localmente, apenas da sua empresa.
          </p>

          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
            <div className="flex items-start gap-2">
              <CheckCircle className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-blue-900">
                <strong>Segurança:</strong> Seus dados ficam salvos no seu próprio computador. 
                O backup roda automaticamente todo dia às 2h da manhã.
              </div>
            </div>
          </div>

          <button
            onClick={gerarInstalador}
            disabled={loading}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 
                     disabled:opacity-50 disabled:cursor-not-allowed transition-colors
                     flex items-center gap-2"
          >
            <Download className="w-4 h-4" />
            {loading ? 'Gerando...' : 'Baixar Instalador'}
          </button>

          <button
            onClick={() => setMostrarInstrucoes(!mostrarInstrucoes)}
            className="mt-2 text-sm text-blue-600 hover:text-blue-700 flex items-center gap-1"
          >
            <HelpCircle className="w-4 h-4" />
            Como instalar?
          </button>

          {mostrarInstrucoes && (
            <div className="mt-4 p-4 bg-gray-50 rounded-lg border border-gray-200">
              <h4 className="font-semibold text-gray-900 mb-2">📋 Instruções:</h4>
              
              <div className="space-y-3 text-sm text-gray-700">
                <div>
                  <strong className="text-gray-900">macOS:</strong>
                  <ol className="list-decimal list-inside mt-1 space-y-1 ml-4">
                    <li>Extraia o arquivo ZIP baixado</li>
                    <li>Abra o Terminal</li>
                    <li>Execute: <code className="bg-gray-200 px-1 rounded">bash instalar-mac.sh</code></li>
                    <li>Pronto! Backup configurado para rodar às 2h da manhã</li>
                  </ol>
                </div>

                <div>
                  <strong className="text-gray-900">Windows:</strong>
                  <ol className="list-decimal list-inside mt-1 space-y-1 ml-4">
                    <li>Extraia o arquivo ZIP baixado</li>
                    <li>Clique com botão direito em <code>instalar-windows.bat</code></li>
                    <li>Selecione "Executar como administrador"</li>
                    <li>Pronto! Backup configurado para rodar às 2h da manhã</li>
                  </ol>
                </div>

                <div className="pt-2 border-t border-gray-200">
                  <strong className="text-gray-900">📁 Onde ficam salvos os backups?</strong>
                  <p className="mt-1">
                    <code className="bg-gray-200 px-2 py-1 rounded block mt-1">
                      Documentos/Backup-[Nome-da-Empresa]/
                    </code>
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// Funções auxiliares para gerar os scripts
function gerarScriptBackup({ userId, empresaNome, supabaseUrl, accessToken }: {
  userId: string;
  empresaNome: string;
  supabaseUrl: string;
  accessToken: string;
}) {
  return `#!/usr/bin/env python3
"""
BACKUP AUTOMÁTICO - ${empresaNome}
Gerado automaticamente pelo sistema PDV Allimport
"""

import os
import json
import requests
from datetime import datetime
from pathlib import Path

SUPABASE_URL = "${supabaseUrl}"
USER_ID = "${userId}"
EMPRESA = "${empresaNome}"
ACCESS_TOKEN = "${accessToken}"

HEADERS = {
    "apikey": ACCESS_TOKEN,
    "Authorization": f"Bearer {ACCESS_TOKEN}",
    "Content-Type": "application/json"
}

TABELAS = [
    'user_approvals', 'empresas', 'subscriptions', 'produtos',
    'clientes', 'vendas', 'vendas_itens', 'caixa',
    'categorias', 'fornecedores', 'despesas', 'ordens_servico', 'funcionarios'
]

def backup_tabela(tabela, backup_dir):
    try:
        url = f"{SUPABASE_URL}/rest/v1/{tabela}?select=*"
        response = requests.get(url, headers=HEADERS, timeout=30)
        
        if response.status_code != 200:
            return None
        
        dados = response.json()
        if not dados:
            return 0
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = backup_dir / f'{tabela}_{timestamp}.json'
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(dados, f, indent=2, ensure_ascii=False)
        
        return len(dados)
    except:
        return None

def main():
    print(f"🔒 Backup: {EMPRESA}")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    backup_dir = Path.home() / 'Documents' / f'Backup-{EMPRESA.replace(" ", "-")}'
    backup_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"📁 {backup_dir}")
    
    total = 0
    for tabela in TABELAS:
        resultado = backup_tabela(tabela, backup_dir)
        if resultado is not None and resultado > 0:
            print(f"✅ {tabela}: {resultado}")
            total += resultado
    
    print(f"\\n✅ Total: {total} registros salvos")

if __name__ == "__main__":
    main()
`;
}

function gerarInstaladorMac({ userId, empresaNome, scriptPython }: {
  userId: string;
  empresaNome: string;
  scriptPython: string;
}) {
  const empresaSlug = empresaNome.replace(/\s+/g, '-');
  return `#!/bin/bash
# Instalador de Backup Automático - ${empresaNome}

echo "╔════════════════════════════════════════╗"
echo "║   🔒 INSTALANDO BACKUP AUTOMÁTICO     ║"
echo "╚════════════════════════════════════════╝"
echo ""

INSTALL_DIR="$HOME/Documents/PDV-Backup-${empresaSlug}"
mkdir -p "$INSTALL_DIR"

cat > "$INSTALL_DIR/backup.py" << 'SCRIPT_END'
${scriptPython}
SCRIPT_END

chmod +x "$INSTALL_DIR/backup.py"

# Configurar launchd
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/com.pdv.backup.${userId.substring(0, 8)}.plist << 'PLIST_END'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.pdv.backup.${userId.substring(0, 8)}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>$HOME/Documents/PDV-Backup-${empresaSlug}/backup.py</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$HOME/Documents/PDV-Backup-${empresaSlug}/backup.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Documents/PDV-Backup-${empresaSlug}/backup_error.log</string>
</dict>
</plist>
PLIST_END

chmod 644 ~/Library/LaunchAgents/com.pdv.backup.${userId.substring(0, 8)}.plist
launchctl load ~/Library/LaunchAgents/com.pdv.backup.${userId.substring(0, 8)}.plist

echo "✅ Backup automático configurado!"
echo ""
echo "📋 Horário: Todo dia às 2h da manhã"
echo "📁 Pasta: $INSTALL_DIR"
echo ""
echo "🧪 Testar agora: python3 $INSTALL_DIR/backup.py"
`;
}

function gerarInstaladorWindows({ userId, empresaNome, scriptPython }: {
  userId: string;
  empresaNome: string;
  scriptPython: string;
}) {
  const empresaSlug = empresaNome.replace(/\s+/g, '-');
  return `@echo off
REM Instalador de Backup Automático - ${empresaNome}

echo ╔════════════════════════════════════════╗
echo ║   🔒 INSTALANDO BACKUP AUTOMÁTICO     ║
echo ╚════════════════════════════════════════╝
echo.

set INSTALL_DIR=%USERPROFILE%\\Documents\\PDV-Backup-${empresaSlug}
mkdir "%INSTALL_DIR%" 2>nul

(
${scriptPython.split('\n').map((line: string) => `echo ${line}`).join('\n')}
) > "%INSTALL_DIR%\\backup.py"

schtasks /create /tn "PDV Backup ${empresaNome}" /tr "python \\"%INSTALL_DIR%\\backup.py\\"" /sc daily /st 02:00 /f

echo.
echo ✅ Backup automático configurado!
echo.
echo 📋 Horário: Todo dia às 2h da manhã
echo 📁 Pasta: %INSTALL_DIR%
echo.
pause
`;
}

function gerarReadme(empresaNome: string) {
  return `BACKUP AUTOMÁTICO - ${empresaNome}
======================================

Este pacote contém o instalador de backup automático para sua empresa.

📦 CONTEÚDO:
- backup.py: Script de backup
- instalar-mac.sh: Instalador para macOS
- instalar-windows.bat: Instalador para Windows

🚀 INSTALAÇÃO:

macOS:
1. Abra o Terminal
2. Execute: bash instalar-mac.sh

Windows:
1. Clique com botão direito em instalar-windows.bat
2. Selecione "Executar como administrador"

⏰ HORÁRIO:
O backup roda automaticamente todo dia às 2h da manhã

📁 LOCALIZAÇÃO DOS BACKUPS:
Documentos/Backup-${empresaNome.replace(/\s+/g, '-')}/

🔒 SEGURANÇA:
Seus dados ficam salvos apenas no seu computador.
Ninguém mais tem acesso a eles.

📧 SUPORTE:
Em caso de dúvidas, entre em contato pelo sistema.
`;
}

async function criarZip(arquivos: Record<string, string>) {
  const zip = new JSZip();
  
  for (const [nome, conteudo] of Object.entries(arquivos)) {
    zip.file(nome, conteudo);
  }
  
  return await zip.generateAsync({ type: 'blob' });
}
