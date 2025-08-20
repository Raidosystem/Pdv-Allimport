# ========================================================
# 🚀 COMANDOS POWERSHELL PARA DEPLOY PDV.CRMVSYSTEM.COM
# ========================================================

# 1. NAVEGAR PARA A PASTA DO PROJETO
cd "c:\Users\crism\Desktop\PDV Allimport\Pdv-Allimport"

# 2. CRIAR BACKUP (OPCIONAL)
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = "../backup-$timestamp"
Write-Host "Criando backup em: $backupDir"
Copy-Item -Recurse -Force "." "$backupDir"

# 3. FAZER BUILD DO PROJETO
Write-Host "Executando build..."
npm install
npm run build

# 4. VERIFICAR SE BUILD FOI CRIADO
if (Test-Path "dist") {
    Write-Host "✅ Build criado com sucesso!"
} else {
    Write-Host "❌ Erro no build!"
    exit
}

# 5. LISTAR ARQUIVOS PRONTOS
Write-Host "📁 Arquivos prontos para upload:"
Get-ChildItem dist/ -Recurse | Select-Object Name, Length, LastWriteTime

# 6. MOSTRAR TAMANHO TOTAL
$totalSize = (Get-ChildItem dist/ -Recurse | Measure-Object -Property Length -Sum).Sum
$totalMB = [math]::Round($totalSize / 1MB, 2)
Write-Host "📊 Tamanho total: $totalMB MB"

Write-Host ""
Write-Host "🎯 PRÓXIMOS PASSOS MANUAIS:"
Write-Host "1. Acesse o painel de https://pdv.crmvsystem.com/"
Write-Host "2. Faça backup dos arquivos atuais"
Write-Host "3. Delete arquivos antigos do servidor"
Write-Host "4. Copie TODOS os arquivos da pasta 'dist/' para o servidor"
Write-Host "5. Teste: https://pdv.crmvsystem.com/"
