# Corrigir tipos Fisica/Juridica para minusculas
$inputFile = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA-FIXED.sql"
$outputFile = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA-FINAL.sql"

# Ler o conteudo
$content = Get-Content $inputFile -Raw -Encoding UTF8

# Substituir Fisica por fisica
$content = $content -replace "'Física'", "'fisica'"

# Substituir Juridica por juridica (caso exista)
$content = $content -replace "'Jurídica'", "'juridica'"

# Salvar
$content | Set-Content $outputFile -Encoding UTF8

Write-Host "Arquivo corrigido criado: $outputFile" -ForegroundColor Green
Write-Host "Tipos alterados: Fisica -> fisica, Juridica -> juridica" -ForegroundColor Cyan
