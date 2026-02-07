# Script para remover COMPLETAMENTE listeners de visibilitychange

Write-Host "🔧 Removendo código desnecessário..." -ForegroundColor Yellow

# Backup dos arquivos originais
Copy-Item "src\hooks\usePermissions.tsx" "src\hooks\usePermissions.tsx.backup"
Copy-Item "src\hooks\useSubscription.ts" "src\hooks\useSubscription.ts.backup"

Write-Host "✅ Backup criado" -ForegroundColor Green
Write-Host "❌ ATENÇÃO: O código ainda tem listeners de visibilitychange!" -ForegroundColor Red
Write-Host "📝 Precisa editar manualmente os arquivos para remover:" -ForegroundColor Yellow
Write-Host "  1. Todo código de globalVisibilityHandler em usePermissions.tsx"
Write-Host "  2. Todo código de visibilityHandler em useSubscription.ts"  
Write-Host "  3. Todo processamento de SIGNED_IN (exceto SIGNED_OUT)"
Write-Host ""
Write-Host "💡 A solução é CARREGAR UMA VEZ no mount e NUNCA MAIS!" -ForegroundColor Cyan
