# Script para remover completamente código de visibilitychange e SIGNED_IN

Write-Host "🔧 Corrigindo usePermissions.tsx..." -ForegroundColor Cyan

$permissionsFile = "src\hooks\usePermissions.tsx"
$content = Get-Content $permissionsFile -Raw

# Remover bloco SIGNED_IN completo (linhas 547-619)
$content = $content -replace '(?s)      \/\/ Escutar mudanças na autenticação - SINGLETON\s+const \{ data: \{ subscription \} \} = supabase\.auth\.onAuthStateChange\(async \(event, session\) => \{\s+if \(event === ''SIGNED_IN''\) \{.*?else if \(event === ''SIGNED_OUT''\) \{', '      // Escutar mudanças na autenticação - SINGLETON
      const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event) => {
        if (event === ''SIGNED_OUT'') {'

$content | Set-Content $permissionsFile -NoNewline

Write-Host "✅ usePermissions.tsx corrigido!" -ForegroundColor Green

Write-Host "🔧 Corrigindo useSubscription.ts..." -ForegroundColor Cyan

$subscriptionFile = "src\hooks\useSubscription.ts"
$content2 = Get-Content $subscriptionFile -Raw

# Remover bloco SIGNED_IN completo
$content2 = $content2 -replace '(?s)      const \{ data: authListener \} = supabase\.auth\.onAuthStateChange\(async \(event, session\) => \{\s+if \(event === ''SIGNED_IN''\) \{.*?else if \(event === ''SIGNED_OUT''\) \{', '      const { data: authListener } = supabase.auth.onAuthStateChange(async (event) => {
        if (event === ''SIGNED_OUT'') {'

$content2 | Set-Content $subscriptionFile -NoNewline

Write-Host "✅ useSubscription.ts corrigido!" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Correções aplicadas! Teste o sistema agora:" -ForegroundColor Yellow
Write-Host "   1. Abra o console do navegador" -ForegroundColor White
Write-Host "   2. Troque de aba" -ForegroundColor White
Write-Host "   3. NÃO deve aparecer 'visibilitychange' ou 'LOCK'" -ForegroundColor White
