# 🔍 ANÁLISE DE BACKUP SUPABASE
# Analisa backup .backup do Supabase para identificar dados por empresa

import subprocess
import os
from pathlib import Path

backup_file = Path('./backups/supabase-backup-15-01-2026.backup')

print("🔍 ANÁLISE DO BACKUP SUPABASE")
print("=" * 60)
print(f"📁 Arquivo: {backup_file}")
print(f"📦 Tamanho: {backup_file.stat().st_size / 1024 / 1024:.2f} MB")
print()

# Verificar se é um backup pg_dump
print("📋 Verificando formato do backup...")

# Ler primeiros bytes
with open(backup_file, 'rb') as f:
    header = f.read(50)
    print(f"Header (primeiros 50 bytes): {header[:50]}")
    
    # Verificar formato
    if header.startswith(b'PGDMP'):
        print("✅ Formato: PostgreSQL Custom Dump (pg_dump -Fc)")
        formato = 'custom'
    elif header.startswith(b'--'):
        print("✅ Formato: SQL Plain Text")
        formato = 'plain'
    else:
        print("⚠️ Formato desconhecido - tentando detectar...")
        formato = 'unknown'

print()
print("=" * 60)
print("📊 INFORMAÇÕES DO BACKUP:")
print("=" * 60)

if formato == 'custom':
    print("""
✅ Este é um backup CUSTOM do PostgreSQL (.backup)

🔍 O QUE ESTE BACKUP CONTÉM:
   - Estrutura completa do banco (tabelas, índices, constraints)
   - TODOS os dados de TODAS as tabelas
   - Triggers, funções, views
   - Políticas RLS

⚠️ LIMITAÇÃO IMPORTANTE:
   Este backup NÃO permite restauração seletiva por empresa!
   
   Motivo: É um dump completo do cluster PostgreSQL.
   Restaurar este backup = SOBRESCREVER TUDO no banco.

✅ O QUE VOCÊ PODE FAZER:

1. 🔄 RESTAURAÇÃO COMPLETA (todos os clientes):
   - Cria um novo banco de dados vazio
   - Restaura TODO o backup nele
   - Usa pg_restore para isso
   
2. 📊 EXTRAIR DADOS PARA ANÁLISE:
   - Restaurar em banco local temporário
   - Exportar dados de empresa específica
   - Depois importar no Supabase
   
3. 🎯 MELHOR SOLUÇÃO - BACKUP ISOLADO:
   Use os scripts Python que criamos:
   - backup-por-empresa-http.py
   - Cada empresa em pasta separada
   - Restauração seletiva por empresa

📖 COMANDOS PARA ANÁLISE (requer pg_restore):

# Ver lista de tabelas no backup:
pg_restore --list backups/supabase-backup-15-01-2026.backup

# Restaurar apenas uma tabela específica:
pg_restore -t empresas -d database_name backups/supabase-backup-15-01-2026.backup

# Restaurar backup completo:
pg_restore -d database_name backups/supabase-backup-15-01-2026.backup

⚠️ IMPORTANTE:
   - pg_restore NÃO vem instalado por padrão no Windows
   - Precisa instalar PostgreSQL Client Tools
   - Ou usar Docker com PostgreSQL

💡 RECOMENDAÇÃO:
   Use o sistema de backup isolado por empresa que criamos!
   Permite restaurar Cliente A sem afetar Cliente B.
""")

else:
    print("""
⚠️ Formato de backup não reconhecido ou plain text.

Se for plain text (.sql):
- Pode abrir em editor de texto
- Buscar por dados específicos
- Executar SQL seletivamente

Se for outro formato:
- Pode precisar de ferramenta específica
""")

print()
print("=" * 60)
print("🎯 PRÓXIMOS PASSOS:")
print("=" * 60)
print("""
OPÇÃO 1 - Usar Backup Isolado (RECOMENDADO):
   1. Configure SERVICE_ROLE_KEY no .env (já feito ✅)
   2. Execute: python scripts/backup-por-empresa-http.py
   3. Cada empresa ficará em ./backups/empresa_[id]/
   4. Restaure apenas a empresa desejada

OPÇÃO 2 - Analisar Backup Atual:
   1. Instale PostgreSQL Client Tools
   2. Liste conteúdo: pg_restore --list backups/supabase-backup-15-01-2026.backup
   3. Restaure em banco temporário para análise

OPÇÃO 3 - Restaurar Tudo (⚠️ CUIDADO):
   1. Faça backup do estado atual antes!
   2. Use Supabase Dashboard → Database → Backups → Restore
   3. Isso SOBRESCREVERÁ todos os dados atuais
""")

print("\n💬 Precisa de ajuda? Me diga qual opção prefere!")
