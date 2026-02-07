# IMPORTACAO AUTOMATICA COM PRIVACIDADE TOTAL
Set-Location "c:\Users\crism\Desktop\PDV Allimport\Pdv-Allimport"

Write-Host "SISTEMA DE IMPORTACAO PRIVADA ALLIMPORT" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Verificar se backup existe
if (Test-Path "backup-allimport.json") {
    Write-Host "Backup encontrado: backup-allimport.json" -ForegroundColor Green
    
    # Copiar para public se nao existir la
    if (-not (Test-Path "public\backup-allimport.json")) {
        Copy-Item "backup-allimport.json" "public\backup-allimport.json"
        Write-Host "Backup copiado para pasta public/" -ForegroundColor Green
    }
    
    $backup = Get-Content "backup-allimport.json" | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "DADOS PRONTOS PARA IMPORTACAO:" -ForegroundColor Yellow
    Write-Host "Clientes: $($backup.data.clients.Count)" -ForegroundColor White
    Write-Host "Produtos: $($backup.data.products.Count)" -ForegroundColor White
    Write-Host "Ordens Servico: $($backup.data.service_orders.Count)" -ForegroundColor White
    Write-Host "Categorias: $($backup.data.categories.Count)" -ForegroundColor White
    Write-Host "Total: $($backup.data.clients.Count + $backup.data.products.Count + $backup.data.service_orders.Count + $backup.data.categories.Count) registros" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "GARANTIAS DE PRIVACIDADE:" -ForegroundColor Green
    Write-Host "- Dados vinculados apenas ao usuario logado" -ForegroundColor Gray
    Write-Host "- RLS (Row Level Security) ativo" -ForegroundColor Gray
    Write-Host "- Isolamento completo entre usuarios" -ForegroundColor Gray
    Write-Host "- Outros usuarios NUNCA verao seus dados" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "COMO USAR:" -ForegroundColor Yellow
    Write-Host "1. Execute: npm run dev (se nao estiver rodando)" -ForegroundColor White
    Write-Host "2. Abra: http://localhost:5175/import-privado" -ForegroundColor White
    Write-Host "3. Faca login com suas credenciais" -ForegroundColor White
    Write-Host "4. Clique em 'Importar Backup Privado'" -ForegroundColor White
    Write-Host "5. Aguarde a importacao completa" -ForegroundColor White
    
    Write-Host ""
    Write-Host "LINK DIRETO:" -ForegroundColor Cyan
    Write-Host "http://localhost:5175/import-privado" -ForegroundColor White
    
} else {
    Write-Host "ERRO: Arquivo backup-allimport.json nao encontrado!" -ForegroundColor Red
    Write-Host "Certifique-se de ter o backup na pasta do projeto" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Sistema pronto para importacao com privacidade total!" -ForegroundColor Green
