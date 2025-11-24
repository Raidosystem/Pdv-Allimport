# Script to add user_id to all clientes INSERT statements
$inputFile = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA.sql"
$outputFile = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA-FIXED.sql"
$userId = "f7fdf4cf-7101-45ab-86db-5248a7ac58c1"

# Read the file as UTF8
$content = Get-Content $inputFile -Raw -Encoding UTF8

# Pattern 1: Fix INSERT INTO clientes column list
# Add user_id after id in the column list
$content = $content -replace `
    '(?m)^INSERT INTO clientes \(\r?\n  id, empresa_id,', `
    "INSERT INTO clientes (`r`n  id, user_id, empresa_id,"

# Pattern 2: Fix VALUES clause
# Add user_id value after the id UUID
# This regex captures the UUID and then adds user_id before empresa_id
$content = $content -replace `
    "(?m)VALUES \(\r?\n  '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})',\r?\n  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',", `
    "VALUES (`r`n  '$1',`r`n  '$userId',`r`n  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',"

# Save with UTF8 encoding
$content | Set-Content $outputFile -Encoding UTF8

Write-Host "✅ Fixed SQL file created: $outputFile" -ForegroundColor Green
Write-Host "✅ All INSERT statements now include user_id column" -ForegroundColor Green
