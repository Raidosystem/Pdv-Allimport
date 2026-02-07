# 🚀 CRIAR TABELAS E RLS PARA assistenciaallimport10@gmail.com
Write-Host "🚀 Criando tabelas e configurando RLS..." -ForegroundColor Green

# Verificar se existe o arquivo SQL
if (-not (Test-Path "CRIAR_TABELAS_E_RLS.sql")) {
    Write-Host "❌ Arquivo CRIAR_TABELAS_E_RLS.sql não encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host "📋 INSTRUÇÕES PARA EXECUTAR NO SUPABASE:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 🌐 Acesse: https://app.supabase.com" -ForegroundColor Yellow
Write-Host "2. 🔑 Faça login na sua conta"
Write-Host "3. 📊 Selecione seu projeto"
Write-Host "4. 💾 Vá para 'SQL Editor'"
Write-Host "5. 📝 Cole o conteúdo do arquivo: CRIAR_TABELAS_E_RLS.sql"
Write-Host "6. ▶️ Clique em 'Run' para executar"
Write-Host ""

# Mostrar o conteúdo do arquivo SQL
Write-Host "📄 CONTEÚDO DO ARQUIVO SQL:" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Gray

$sqlContent = Get-Content "CRIAR_TABELAS_E_RLS.sql" -Raw
Write-Host $sqlContent -ForegroundColor White

Write-Host ""
Write-Host "================================" -ForegroundColor Gray
Write-Host ""

Write-Host "🎯 APÓS EXECUTAR O SQL:" -ForegroundColor Cyan
Write-Host "✅ Tabelas serão criadas automaticamente"
Write-Host "✅ RLS será configurado para assistenciaallimport10@gmail.com"
Write-Host "✅ Este usuário terá acesso TOTAL a todos os dados"
Write-Host "✅ Outros usuários continuarão isolados"
Write-Host ""

Write-Host "🚀 TESTE A IMPORTAÇÃO:" -ForegroundColor Green  
Write-Host "npm run dev"
Write-Host "Acesse: http://localhost:5175/import-automatico"
Write-Host ""

# Copiar conteúdo para clipboard se possível
try {
    $sqlContent | Set-Clipboard
    Write-Host "📋 Conteúdo copiado para a área de transferência!" -ForegroundColor Green
    Write-Host "Cole diretamente no Supabase SQL Editor" -ForegroundColor Yellow
} catch {
    Write-Host "⚠️ Não foi possível copiar para clipboard" -ForegroundColor Yellow
    Write-Host "Copie manualmente o conteúdo do arquivo CRIAR_TABELAS_E_RLS.sql" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "💡 DICA: Se der erro, execute linha por linha no SQL Editor" -ForegroundColor Cyan
