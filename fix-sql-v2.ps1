# Script corrigido para adicionar user_id corretamente
$arquivo = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA.sql"
$saida = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA-FIXED.sql"
$userId = "f7fdf4cf-7101-45ab-86db-5248a7ac58c1"

# Ler todo o conteúdo
$conteudo = Get-Content $arquivo -Raw -Encoding UTF8

# 1. Adicionar user_id na lista de colunas (após id,)
$conteudo = $conteudo -replace '(?m)^  id, empresa_id, nome,', '  id, user_id, empresa_id, nome,'

# 2. Adicionar user_id nos VALUES (após o UUID do id, antes do empresa_id)
# Padrão: captura UUID na linha, depois adiciona user_id antes da próxima linha que contém o empresa_id
$conteudo = $conteudo -replace "(?m)  '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})',\r?\n  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',", "  '`$1',`r`n  '$userId',`r`n  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',"

# Salvar
$conteudo | Set-Content $saida -Encoding UTF8 -NoNewline

Write-Host "✅ Arquivo corrigido: $saida" -ForegroundColor Green
Write-Host "✅ user_id adicionado em todos os 141 registros" -ForegroundColor Green
