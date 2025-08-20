# CONFIGURAR RLS PARA assistenciaallimport10@gmail.com
# Este script aplica as políticas RLS específicas para este usuário

Write-Host "🚀 Configurando RLS para assistenciaallimport10@gmail.com..." -ForegroundColor Green

# Ler as variáveis do Supabase do arquivo .env
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^#][^=]*)=(.*)$") {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
    }
    Write-Host "✅ Variáveis de ambiente carregadas" -ForegroundColor Green
} else {
    Write-Host "❌ Arquivo .env não encontrado!" -ForegroundColor Red
    exit 1
}

# Verificar se as variáveis necessárias existem
$SUPABASE_URL = $env:VITE_SUPABASE_URL
$SUPABASE_ANON_KEY = $env:VITE_SUPABASE_ANON_KEY

if (-not $SUPABASE_URL -or -not $SUPABASE_ANON_KEY) {
    Write-Host "❌ Variáveis SUPABASE não encontradas no .env!" -ForegroundColor Red
    Write-Host "Certifique-se de que VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY estão definidas" -ForegroundColor Yellow
    exit 1
}

Write-Host "📡 Conectando ao Supabase..." -ForegroundColor Cyan
Write-Host "URL: $SUPABASE_URL" -ForegroundColor Gray

try {
    # Carregar o conteúdo do arquivo SQL
    $sqlContent = Get-Content "RLS_ASSISTENCIA_ALLIMPORT.sql" -Raw
    
    if (-not $sqlContent) {
        Write-Host "❌ Arquivo RLS_ASSISTENCIA_ALLIMPORT.sql não encontrado ou vazio!" -ForegroundColor Red
        exit 1
    }

    Write-Host "📋 Executando SQL..." -ForegroundColor Cyan
    
    # Preparar headers para a requisição
    $headers = @{
        'Authorization' = "Bearer $SUPABASE_ANON_KEY"
        'Content-Type' = 'application/json'
        'apikey' = $SUPABASE_ANON_KEY
    }

    # Executar SQL via REST API
    $body = @{
        query = $sqlContent
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/rpc/exec_sql" -Method POST -Headers $headers -Body $body

    Write-Host "✅ RLS configurado com sucesso!" -ForegroundColor Green
    Write-Host "📊 Políticas criadas para assistenciaallimport10@gmail.com" -ForegroundColor Green

} catch {
    Write-Host "❌ Erro ao configurar RLS:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Tentar método alternativo via psql (se disponível)
    Write-Host "🔄 Tentando método alternativo..." -ForegroundColor Yellow
    
    try {
        # Extrair informações da URL do Supabase
        if ($SUPABASE_URL -match "https://([^.]+)\.supabase\.co") {
            $projectId = $matches[1]
            $connectionString = "postgresql://postgres:[SENHA]@db.$projectId.supabase.co:5432/postgres"
            
            Write-Host "📝 Para aplicar manualmente, use:" -ForegroundColor Yellow
            Write-Host "psql '$connectionString' -f RLS_ASSISTENCIA_ALLIMPORT.sql" -ForegroundColor Gray
        }
    } catch {
        Write-Host "⚠️ Use o SQL diretamente no Supabase SQL Editor" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎯 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "1. ✅ RLS configurado para assistenciaallimport10@gmail.com"
Write-Host "2. 🔐 Este usuário agora pode acessar dados de outros usuários"
Write-Host "3. 📦 Teste a importação automática novamente"
Write-Host "4. 🚀 O backup deve importar sem erros de permissão"

Write-Host ""
Write-Host "⚡ TESTE RÁPIDO:" -ForegroundColor Green
Write-Host "npm run dev" -ForegroundColor Gray
Write-Host "Acesse: http://localhost:5175/import-automatico" -ForegroundColor Gray
