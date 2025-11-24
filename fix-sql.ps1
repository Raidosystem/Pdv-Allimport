# Script para adicionar user_id nos INSERT statements
$arquivo = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA.sql"
$saida = "c:\Users\crism\Desktop\Pdv-Allimport\RESTAURAR-EMPRESA-CORRETA-FIXED.sql"
$userId = "f7fdf4cf-7101-45ab-86db-5248a7ac58c1"

# Ler arquivo linha por linha preservando encoding
$linhas = Get-Content $arquivo -Encoding UTF8

$novasLinhas = @()
$dentroInsert = $false

foreach ($linha in $linhas) {
    if ($linha -match '^INSERT INTO clientes \(') {
        # Adicionar user_id na lista de colunas
        $linha = $linha -replace 'INSERT INTO clientes \(', 'INSERT INTO clientes ('
        $novasLinhas += $linha
        $dentroInsert = $true
    }
    elseif ($dentroInsert -and $linha -match '^\s+id, empresa_id,') {
        # Adicionar user_id entre id e empresa_id
        $linha = $linha -replace 'id, empresa_id,', "id, user_id, empresa_id,"
        $novasLinhas += $linha
        $dentroInsert = $false
    }
    elseif ($linha -match "^\s+'([0-9a-f-]{36})',\s*$") {
        # Esta é a linha do ID, próxima linha será empresa_id
        $novasLinhas += $linha
        # Marcar para adicionar user_id na próxima iteração
        $dentroInsert = $true
    }
    elseif ($dentroInsert -and $linha -match "^\s+'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',\s*$") {
        # Esta é a linha do empresa_id, adicionar user_id antes
        $novasLinhas += "  '$userId',"
        $novasLinhas += $linha
        $dentroInsert = $false
    }
    else {
        $novasLinhas += $linha
    }
}

# Salvar arquivo
$novasLinhas | Set-Content $saida -Encoding UTF8

Write-Host "Arquivo corrigido salvo em: $saida" -ForegroundColor Green
Write-Host "Total de linhas: $($novasLinhas.Count)" -ForegroundColor Cyan
