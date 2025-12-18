# =====================================================
# 🔒 SCRIPT DE VERIFICAÇÃO DE SEGURANÇA AUTOMÁTICA
# =====================================================
# Execute com: .\verificar-seguranca.ps1
# =====================================================

Write-Host "`n🔒 INICIANDO VERIFICAÇÃO DE SEGURANÇA DO PDV ALLIMPORT`n" -ForegroundColor Cyan

$problemas = @()
$avisos = @()
$sucesso = @()

# =====================================================
# 1. VERIFICAR SE .ENV ESTÁ NO GIT HISTORY
# =====================================================
Write-Host "1️⃣  Verificando se .env foi commitado no Git..." -ForegroundColor Yellow

$gitHistory = git log --all --full-history -- ".env" 2>&1
if ($LASTEXITCODE -eq 0 -and $gitHistory) {
    $problemas += "🚨 CRÍTICO: Arquivo .env encontrado no histórico Git!"
    $problemas += "   → Ação: Execute GUIA_ROTACAO_CHAVES.md IMEDIATAMENTE"
    Write-Host "   ❌ .env ENCONTRADO no histórico Git!" -ForegroundColor Red
} else {
    $sucesso += "✅ .env não está no histórico Git"
    Write-Host "   ✅ .env não encontrado no histórico Git" -ForegroundColor Green
}

# =====================================================
# 2. VERIFICAR SE .ENV ESTÁ NO .GITIGNORE
# =====================================================
Write-Host "`n2️⃣  Verificando .gitignore..." -ForegroundColor Yellow

$gitignoreContent = Get-Content .gitignore -Raw
if ($gitignoreContent -match "\.env") {
    $sucesso += "✅ .env está listado no .gitignore"
    Write-Host "   ✅ .env está no .gitignore" -ForegroundColor Green
} else {
    $problemas += "🚨 CRÍTICO: .env NÃO está no .gitignore!"
    $problemas += "   → Ação: Adicione '.env' ao .gitignore AGORA"
    Write-Host "   ❌ .env NÃO está no .gitignore!" -ForegroundColor Red
}

# =====================================================
# 3. VERIFICAR CORS WILDCARD EM APIs
# =====================================================
Write-Host "`n3️⃣  Verificando configuração CORS em APIs..." -ForegroundColor Yellow

$corsWildcard = Get-ChildItem -Path "api" -Recurse -Include "*.js" -ErrorAction SilentlyContinue | 
    Select-String -Pattern "Access-Control-Allow-Origin.*\*" -ErrorAction SilentlyContinue
if ($corsWildcard) {
    $count = ($corsWildcard | Measure-Object).Count
    $problemas += "🚨 CRÍTICO: CORS com wildcard (*) encontrado em $count arquivo(s)!"
    $problemas += "   → Arquivos: $($corsWildcard.Path | Select-Object -Unique | Join-String -Separator ', ')"
    $problemas += "   → Ação: Use CORRIGIR_CORS_EXEMPLO.js como modelo"
    Write-Host "   ❌ CORS wildcard (*) encontrado em $count arquivo(s)!" -ForegroundColor Red
    
    foreach ($match in $corsWildcard | Select-Object -First 3) {
        Write-Host "      - $($match.Path):$($match.LineNumber)" -ForegroundColor DarkRed
    }
} else {
    $sucesso += "✅ Nenhum CORS wildcard encontrado"
    Write-Host "   ✅ CORS configurado corretamente" -ForegroundColor Green
}

# =====================================================
# 4. VERIFICAR SENHAS HARDCODED
# =====================================================
Write-Host "`n4️⃣  Verificando senhas hardcoded..." -ForegroundColor Yellow

$passwordPatterns = @(
    "password\s*:\s*['\`"].*['\`"]",
    "senha\s*:\s*['\`"].*['\`"]",
    "admin123",
    "test123"
)
$senhasEncontradas = @()
foreach ($pattern in $passwordPatterns) {
    $matches = Get-ChildItem -Path "." -Recurse -Include "*.js","*.ts","*.tsx","*.jsx" -ErrorAction SilentlyContinue | 
               Where-Object { $_.FullName -notmatch "node_modules" } |
               Select-String -Pattern $pattern -ErrorAction SilentlyContinue
    if ($matches) {
        $senhasEncontradas += $matches
    }
}   }
}

if ($senhasEncontradas) {
    $count = ($senhasEncontradas | Measure-Object).Count
    $avisos += "⚠️  ALTA: $count senha(s) hardcoded encontrada(s)"
    $avisos += "   → Ação: Substituir por variáveis de ambiente"
    Write-Host "   ⚠️  $count senha(s) hardcoded encontrada(s)" -ForegroundColor DarkYellow
    
    foreach ($match in $senhasEncontradas | Select-Object -First 3) {
        Write-Host "      - $($match.Path):$($match.LineNumber)" -ForegroundColor DarkYellow
    }
} else {
    $sucesso += "✅ Nenhuma senha hardcoded encontrada"
    Write-Host "   ✅ Nenhuma senha hardcoded encontrada" -ForegroundColor Green
}

# =====================================================
# 5. VERIFICAR SERVICE_ROLE_KEY NO FRONTEND
# =====================================================
Write-Host "`n5️⃣  Verificando SERVICE_ROLE_KEY no frontend..." -ForegroundColor Yellow

$serviceRoleInFrontend = Get-ChildItem -Path "src" -Recurse -Include "*.ts","*.tsx","*.js","*.jsx" -ErrorAction SilentlyContinue | 
    Select-String -Pattern "SERVICE_ROLE" -ErrorAction SilentlyContinue
if ($serviceRoleInFrontend) {
    $count = ($serviceRoleInFrontend | Measure-Object).Count
    $problemas += "🚨 CRÍTICA: SERVICE_ROLE_KEY encontrado no frontend em $count arquivo(s)!"
    $problemas += "   → Ação: REMOVER IMEDIATAMENTE - essa chave bypassa RLS!"
    Write-Host "   ❌ SERVICE_ROLE_KEY encontrado no frontend!" -ForegroundColor Red
    
    foreach ($match in $serviceRoleInFrontend) {
        Write-Host "      - $($match.Path):$($match.LineNumber)" -ForegroundColor DarkRed
    }
} else {
    $sucesso += "✅ SERVICE_ROLE_KEY não está no frontend"
    Write-Host "   ✅ SERVICE_ROLE_KEY não encontrado no frontend" -ForegroundColor Green
}

# =====================================================
# 6. VERIFICAR ARQUIVOS SQL COM RLS DISABLED
# =====================================================
Write-Host "`n6️⃣  Verificando arquivos SQL com RLS desabilitado..." -ForegroundColor Yellow
$rlsDisabled = Get-ChildItem -Path "." -Recurse -Include "*.sql" -ErrorAction SilentlyContinue | 
    Select-String -Pattern "DISABLE ROW LEVEL SECURITY" -ErrorAction SilentlyContinue
$rlsDisabled = Select-String -Path "**/*.sql" -Pattern "DISABLE ROW LEVEL SECURITY" -Recurse 2>$null
if ($rlsDisabled) {
    $count = ($rlsDisabled | Measure-Object).Count
    $avisos += "⚠️  CRÍTICA: RLS desabilitado em $count arquivo(s) SQL"
    $avisos += "   → Ação: Execute CORRIGIR_RLS_URGENTE.sql no Supabase"
    $avisos += "   → Depois execute VERIFICAR_RLS_ATUAL.sql para confirmar"
    Write-Host "   ⚠️  RLS desabilitado em $count arquivo(s) SQL" -ForegroundColor DarkYellow
    Write-Host "   ℹ️  Isso pode ser normal em migrations antigas" -ForegroundColor Cyan
    Write-Host "   ℹ️  Verifique o estado ATUAL no Supabase com VERIFICAR_RLS_ATUAL.sql" -ForegroundColor Cyan
} else {
    $sucesso += "✅ Nenhum arquivo SQL com RLS desabilitado"
    Write-Host "   ✅ Nenhum RLS desabilitado encontrado" -ForegroundColor Green
}

# =====================================================
# 7. VERIFICAR innerHTML SEM SANITIZAÇÃO
# =====================================================
$innerHTMLUsage = Get-ChildItem -Path "src" -Recurse -Include "*.ts","*.tsx","*.js","*.jsx" -ErrorAction SilentlyContinue | 
    Select-String -Pattern "\.innerHTML\s*=" -ErrorAction SilentlyContinue

$innerHTMLUsage = Select-String -Path "src/**/*.{ts,tsx,js,jsx}" -Pattern "\.innerHTML\s*=" -Recurse 2>$null
if ($innerHTMLUsage) {
    $count = ($innerHTMLUsage | Measure-Object).Count
    $avisos += "⚠️  MÉDIA: innerHTML usado em $count local(is) - verificar se há sanitização"
    Write-Host "   ℹ️  innerHTML usado em $count local(is)" -ForegroundColor Cyan
    Write-Host "   ℹ️  Verificar se DOMPurify está sendo usado" -ForegroundColor Cyan
    
    foreach ($match in $innerHTMLUsage | Select-Object -First 3) {
        Write-Host "      - $($match.Path):$($match.LineNumber)" -ForegroundColor Cyan
    }
} else {
    $sucesso += "✅ Nenhum innerHTML encontrado"
    Write-Host "   ✅ Nenhum innerHTML encontrado" -ForegroundColor Green
}

# =====================================================
# 8. VERIFICAR VERCEL.JSON EXISTE
# =====================================================
Write-Host "`n8️⃣  Verificando configuração Vercel..." -ForegroundColor Yellow

if (Test-Path "vercel.json") {
    $sucesso += "✅ vercel.json existe"
    Write-Host "   ✅ vercel.json encontrado" -ForegroundColor Green
    
    $vercelContent = Get-Content "vercel.json" -Raw
    if ($vercelContent -match "headers") {
        $sucesso += "✅ Headers HTTP configurados"
        Write-Host "   ✅ Headers HTTP configurados" -ForegroundColor Green
    } else {
        $avisos += "⚠️  BAIXA: Adicionar headers de segurança HTTP"
        Write-Host "   ℹ️  Considere adicionar headers de segurança" -ForegroundColor Cyan
    }
} else {
    $avisos += "⚠️  vercel.json não encontrado"
    Write-Host "   ⚠️  vercel.json não encontrado" -ForegroundColor DarkYellow
}

# =====================================================
# 9. VERIFICAR NODE_MODULES NÃO ESTÁ COMMITADO
# =====================================================
Write-Host "`n9️⃣  Verificando node_modules..." -ForegroundColor Yellow

$nodeModulesInGit = git ls-files | Select-String "node_modules" 2>$null
if ($nodeModulesInGit) {
    $problemas += "🚨 node_modules está commitado no Git!"
    $problemas += "   → Ação: Adicione node_modules ao .gitignore e remova do Git"
    Write-Host "   ❌ node_modules commitado!" -ForegroundColor Red
} else {
    $sucesso += "✅ node_modules não está commitado"
    Write-Host "   ✅ node_modules não commitado" -ForegroundColor Green
}

# =====================================================
# RELATÓRIO FINAL
# =====================================================
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "📊 RELATÓRIO FINAL DE SEGURANÇA" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

Write-Host "`n✅ SUCESSO ($($sucesso.Count) item(ns)):" -ForegroundColor Green
foreach ($item in $sucesso) {
    Write-Host "   $item" -ForegroundColor Green
}

if ($avisos.Count -gt 0) {
    Write-Host "`n⚠️  AVISOS ($($avisos.Count) item(ns)):" -ForegroundColor Yellow
    foreach ($item in $avisos) {
        Write-Host "   $item" -ForegroundColor Yellow
    }
}

if ($problemas.Count -gt 0) {
    Write-Host "`n🚨 PROBLEMAS CRÍTICOS ($($problemas.Count) item(ns)):" -ForegroundColor Red
    foreach ($item in $problemas) {
        Write-Host "   $item" -ForegroundColor Red
    }
}

# =====================================================
# PRÓXIMOS PASSOS
# =====================================================
Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "🎯 PRÓXIMOS PASSOS" -ForegroundColor Cyan
Write-Host ("="*60) -ForegroundColor Cyan

if ($problemas.Count -gt 0) {
    Write-Host "`n🚨 AÇÕES URGENTES:" -ForegroundColor Red
    Write-Host "   1. Leia o arquivo RELATORIO_SEGURANCA_COMPLETO.md" -ForegroundColor White
    Write-Host "   2. Execute CORRIGIR_RLS_URGENTE.sql no Supabase" -ForegroundColor White
    Write-Host "   3. Se .env estiver no Git, siga GUIA_ROTACAO_CHAVES.md" -ForegroundColor White
    Write-Host "   4. Corrija CORS usando CORRIGIR_CORS_EXEMPLO.js" -ForegroundColor White
} elseif ($avisos.Count -gt 0) {
    Write-Host "`n⚠️  MELHORIAS RECOMENDADAS:" -ForegroundColor Yellow
    Write-Host "   1. Revise os avisos acima" -ForegroundColor White
    Write-Host "   2. Execute VERIFICAR_RLS_ATUAL.sql no Supabase" -ForegroundColor White
    Write-Host "   3. Considere implementar rate limiting" -ForegroundColor White
} else {
    Write-Host "`n🎉 PARABÉNS! Nenhum problema crítico encontrado!" -ForegroundColor Green
    Write-Host "   Recomendação: Execute verificações periódicas" -ForegroundColor White
}

# =====================================================
# SALVAR RELATÓRIO EM ARQUIVO
# =====================================================
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportFile = "VERIFICACAO_SEGURANCA_$timestamp.txt"

$report = @"
RELATÓRIO DE VERIFICAÇÃO DE SEGURANÇA
Data: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Sistema: PDV Allimport

SUCESSOS ($($sucesso.Count)):
$($sucesso | ForEach-Object { "- $_" } | Out-String)

AVISOS ($($avisos.Count)):
$($avisos | ForEach-Object { "- $_" } | Out-String)

PROBLEMAS ($($problemas.Count)):
$($problemas | ForEach-Object { "- $_" } | Out-String)
"@

$report | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host "`n📄 Relatório salvo em: $reportFile" -ForegroundColor Cyan

# =====================================================
# PONTUAÇÃO DE SEGURANÇA
# =====================================================
$totalChecks = 9
$passed = $sucesso.Count
$scorePercentage = [math]::Round(($passed / $totalChecks) * 100, 1)

Write-Host "`n" + ("="*60) -ForegroundColor Cyan
Write-Host "`n[BLOQUEADO] PONTUACAO DE SEGURANCA: $scorePercentage%" -ForegroundColor $(
    if ($scorePercentage -ge 80) { "Green" }
    elseif ($scorePercentage -ge 60) { "Yellow" }
    else { "Red" }
)
Write-Host ("="*60) -ForegroundColor Cyan

Write-Host "`nPressione qualquer tecla para sair..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
