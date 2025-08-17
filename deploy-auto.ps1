# Script de Deploy Automático - PDV Allimport (PowerShell)
# Garante que o deploy seja feito corretamente e sem cache

Write-Host "🚀 Iniciando deploy do PDV Allimport..." -ForegroundColor Green

# 1. Limpar cache local
Write-Host "🧹 Limpando cache local..." -ForegroundColor Yellow
if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }
if (Test-Path "node_modules\.vite") { Remove-Item -Recurse -Force "node_modules\.vite" }
if (Test-Path ".vercel") { Remove-Item -Recurse -Force ".vercel" }

# 2. Fazer build fresh
Write-Host "🔨 Fazendo build fresh..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro no build! Parando deploy." -ForegroundColor Red
    exit 1
}

# 3. Fazer commit das mudanças
Write-Host "📝 Fazendo commit..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git add .
git commit -m "🚀 Deploy: $timestamp"
git push

# 4. Deploy no Vercel
Write-Host "☁️ Fazendo deploy no Vercel..." -ForegroundColor Yellow
npx vercel --prod

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro no deploy! Verificar configurações." -ForegroundColor Red
    exit 1
}

# 5. Obter URL do último deploy e configurar alias
Write-Host "🔄 Configurando alias para URL principal..." -ForegroundColor Yellow
$deployList = npx vercel ls --json | ConvertFrom-Json
$latestUrl = "https://" + $deployList[0].url

npx vercel alias $latestUrl pdv-allimport.vercel.app

Write-Host ""
Write-Host "✅ Deploy concluído com sucesso!" -ForegroundColor Green
Write-Host "🌐 URL Principal: https://pdv-allimport.vercel.app" -ForegroundColor Cyan
Write-Host "🔗 URL Específica: $latestUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "📱 Teste o PWA em: https://pdv-allimport.vercel.app" -ForegroundColor Magenta
Write-Host "🔍 Pressione Ctrl+F5 para forçar reload do cache" -ForegroundColor Yellow
