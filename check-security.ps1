# =====================================================
# VERIFICACAO RAPIDA DE SEGURANCA
# =====================================================

Write-Host "`n=== VERIFICACAO DE SEGURANCA PDV ALLIMPORT ===`n" -ForegroundColor Cyan

# 1. Verificar .env no Git
Write-Host "[1] Verificando .env no Git..." -ForegroundColor Yellow
$envInGit = git log --all --full-history -- ".env" 2>&1
if ($envInGit -and $envInGit -notmatch "fatal") {
    Write-Host "    [CRITICO] .env encontrado no historico Git!" -ForegroundColor Red
    Write-Host "    Acao: Execute GUIA_ROTACAO_CHAVES.md" -ForegroundColor Red
} else {
    Write-Host "    [OK] .env nao esta no historico" -ForegroundColor Green
}

# 2. Verificar CORS wildcard
Write-Host "`n[2] Verificando CORS wildcard..." -ForegroundColor Yellow
$corsFiles = Get-ChildItem -Path "api" -Recurse -Filter "*.js" -ErrorAction SilentlyContinue | 
             Select-String -Pattern "Access-Control-Allow-Origin.*\*" -ErrorAction SilentlyContinue
if ($corsFiles) {
    Write-Host "    [CRITICO] CORS wildcard encontrado!" -ForegroundColor Red
    $corsFiles | ForEach-Object { Write-Host "    - $($_.Path)" -ForegroundColor Red }
} else {
    Write-Host "    [OK] CORS configurado corretamente" -ForegroundColor Green
}

# 3. Verificar senhas hardcoded
Write-Host "`n[3] Verificando senhas hardcoded..." -ForegroundColor Yellow
$senhas = Get-ChildItem -Recurse -Include "*.js","*.ts" -ErrorAction SilentlyContinue | 
          Where-Object { $_.FullName -notmatch "node_modules" } |
          Select-String -Pattern "admin123|test123" -ErrorAction SilentlyContinue
if ($senhas) {
    Write-Host "    [AVISO] Senhas hardcoded encontradas!" -ForegroundColor DarkYellow
    $senhas | Select-Object -First 3 | ForEach-Object { 
        Write-Host "    - $($_.Filename):$($_.LineNumber)" -ForegroundColor DarkYellow 
    }
} else {
    Write-Host "    [OK] Nenhuma senha hardcoded" -ForegroundColor Green
}

# 4. Verificar SERVICE_ROLE_KEY no frontend
Write-Host "`n[4] Verificando SERVICE_ROLE_KEY no frontend..." -ForegroundColor Yellow
$serviceRole = Get-ChildItem -Path "src" -Recurse -Include "*.ts","*.tsx" -ErrorAction SilentlyContinue | 
               Select-String -Pattern "SERVICE_ROLE" -ErrorAction SilentlyContinue
if ($serviceRole) {
    Write-Host "    [CRITICO] SERVICE_ROLE_KEY no frontend!" -ForegroundColor Red
    $serviceRole | ForEach-Object { Write-Host "    - $($_.Path)" -ForegroundColor Red }
} else {
    Write-Host "    [OK] SERVICE_ROLE_KEY nao esta no frontend" -ForegroundColor Green
}

# 5. Verificar arquivos criados
Write-Host "`n[5] Arquivos de seguranca criados:" -ForegroundColor Yellow
$arquivos = @(
    "RELATORIO_SEGURANCA_COMPLETO.md",
    "VERIFICAR_RLS_ATUAL.sql",
    "CORRIGIR_RLS_URGENTE.sql",
    "GUIA_ROTACAO_CHAVES.md",
    "CORRIGIR_CORS_EXEMPLO.js"
)

foreach ($arquivo in $arquivos) {
    if (Test-Path $arquivo) {
        Write-Host "    [OK] $arquivo" -ForegroundColor Green
    } else {
        Write-Host "    [FALTA] $arquivo" -ForegroundColor Red
    }
}

# Resumo
Write-Host "`n=== PROXIMOS PASSOS ===`n" -ForegroundColor Cyan
Write-Host "1. Leia RELATORIO_SEGURANCA_COMPLETO.md" -ForegroundColor White
Write-Host "2. Execute CORRIGIR_RLS_URGENTE.sql no Supabase" -ForegroundColor White
Write-Host "3. Execute VERIFICAR_RLS_ATUAL.sql no Supabase" -ForegroundColor White
Write-Host "4. Se .env estiver no Git, siga GUIA_ROTACAO_CHAVES.md`n" -ForegroundColor White

Read-Host "Pressione Enter para sair"
