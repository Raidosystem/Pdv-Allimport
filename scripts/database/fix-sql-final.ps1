$inputFile = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA.sql"
$outputFile = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA-FINAL.sql"
$userId = "f7fdf4cf-7101-45ab-86db-5248a7ac58c1"

# Ler arquivo como texto puro
$content = [System.IO.File]::ReadAllText($inputFile, [System.Text.Encoding]::UTF8)

# 1. Corrigir tipos (com e sem acento)
$content = $content.Replace("'Física',", "'fisica',")
$content = $content.Replace("'Fisica',", "'fisica',")
$content = $content.Replace("'Jurídica',", "'juridica',")
$content = $content.Replace("'Juridica',", "'juridica',")

# 2. Adicionar user_id nas colunas (onde não existe)
$content = $content -replace '(?m)^INSERT INTO clientes \(\r?\n  id, empresa_id, nome,', "INSERT INTO clientes (`r`n  id, user_id, empresa_id, nome,"

# 3. Adicionar user_id nos VALUES (onde não existe)  
# Pattern: UUID, empresa_id, nome
$pattern = "VALUES \(\r?\n  '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})',\r?\n  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',\r?\n  '([^']+)',"
$replacement = "VALUES (`r`n  '$1',`r`n  '$userId',`r`n  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',`r`n  '$2',"
$content = $content -replace $pattern, $replacement

# Salvar com UTF8
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.Encoding]::UTF8)

Write-Host "Arquivo corrigido salvo: $outputFile" -ForegroundColor Green
Write-Host "- Tipos corrigidos: Fisica/Juridica para minusculas" -ForegroundColor Cyan
Write-Host "- user_id adicionado em todos os INSERTs" -ForegroundColor Cyan
