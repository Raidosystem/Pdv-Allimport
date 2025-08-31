# 🚀 Script para resolver problemas de WebSocket do Vite
# Versão atualizada com melhores práticas PowerShell

# Parar todos os processos Node.js
Write-Host "🔄 Parando processos Node.js..." -ForegroundColor Yellow
taskkill /F /IM node.exe 2>$null
Start-Sleep -Seconds 2

# Limpar cache do npm
Write-Host "🧹 Limpando cache..." -ForegroundColor Yellow
npm cache clean --force 2>$null

# Verificar portas em uso
Write-Host "🔍 Verificando portas em uso..." -ForegroundColor Yellow
$port5174 = netstat -an | Select-String ":5174 "
$port5175 = netstat -an | Select-String ":5175 "

if ($port5174) {
    Write-Host "⚠️  Porta 5174 em uso:" -ForegroundColor Red
    $port5174
}

if ($port5175) {
    Write-Host "⚠️  Porta 5175 em uso:" -ForegroundColor Red
    $port5175
}

# Iniciar servidor de desenvolvimento
Write-Host "🚀 Iniciando servidor de desenvolvimento..." -ForegroundColor Green
Set-Location "c:\Users\crism\Desktop\PDV Allimport\Pdv-Allimport"
npm run dev
