# ========================================================
# 🚀 COMANDOS INDIVIDUAIS NO POWERSHELL
# ========================================================
# Execute um por vez, linha por linha

# 1️⃣ NAVEGAR PARA O PROJETO
Set-Location "c:\Users\crism\Desktop\PDV Allimport\Pdv-Allimport"

# 2️⃣ VERIFICAR SE ESTÁ NA PASTA CORRETA
Get-Location

# 3️⃣ INSTALAR DEPENDÊNCIAS (se necessário)
npm install

# 4️⃣ FAZER BUILD
npm run build

# 5️⃣ VERIFICAR SE PASTA DIST FOI CRIADA
Test-Path "dist"

# 6️⃣ LISTAR ARQUIVOS DA PASTA DIST
Get-ChildItem dist/

# 7️⃣ LISTAR ARQUIVOS DA PASTA ASSETS
Get-ChildItem dist/assets/

# 8️⃣ MOSTRAR TAMANHO DOS ARQUIVOS
Get-ChildItem dist/ -Recurse | Select-Object Name, Length, LastWriteTime

# 9️⃣ CALCULAR TAMANHO TOTAL
$totalSize = (Get-ChildItem dist/ -Recurse | Measure-Object -Property Length -Sum).Sum
$totalMB = [math]::Round($totalSize / 1MB, 2)
Write-Host "Tamanho total: $totalMB MB"

# 🔟 CRIAR BACKUP (OPCIONAL)
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item -Recurse -Force "." "../backup-$timestamp"

# ========================================================
# APÓS EXECUTAR OS COMANDOS ACIMA:
# 1. Acesse https://pdv.crmvsystem.com/ (painel de controle)
# 2. Faça backup dos arquivos atuais do site
# 3. Delete todos os arquivos antigos do servidor
# 4. Copie TODOS os arquivos da pasta 'dist/' para o servidor
# 5. Teste o site: https://pdv.crmvsystem.com/
# ========================================================
