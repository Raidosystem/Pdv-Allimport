# =============================================
# SCRIPT DE BACKUP AUTOMÁTICO LOCAL
# =============================================
# Este script faz backup do Supabase para uma pasta local
# Agende no Task Scheduler do Windows para rodar automaticamente

# CONFIGURAÇÕES
$SUPABASE_URL = "https://seu-projeto.supabase.co"
$SUPABASE_ANON_KEY = "sua-chave-anon"
$SUPABASE_ACCESS_TOKEN = "seu-token-de-usuario"  # Token JWT do usuário logado
$BACKUP_FOLDER = "C:\Backups\PDV-Allimport"
$MAX_BACKUPS = 30  # Manter últimos 30 backups

# =============================================
# FUNÇÕES
# =============================================

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path "$BACKUP_FOLDER\backup.log" -Value $logMessage
}

function Criar-PastaBackup {
    if (-not (Test-Path $BACKUP_FOLDER)) {
        New-Item -ItemType Directory -Path $BACKUP_FOLDER -Force | Out-Null
        Write-Log "Pasta de backup criada: $BACKUP_FOLDER"
    }
}

function Upload-ParaStorage {
    param(
        $BackupId,
        $FilePath,
        $StoragePath
    )
    
    try {
        Write-Log "Fazendo upload para Supabase Storage..."
        
        # Ler arquivo como bytes
        $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
        $fileSize = $fileBytes.Length
        
        $headers = @{
            "apikey" = $SUPABASE_ANON_KEY
            "Authorization" = "Bearer $SUPABASE_ACCESS_TOKEN"
            "Content-Type" = "application/zip"
        }
        
        # Upload para Storage
        $uploadUrl = "$SUPABASE_URL/storage/v1/object/backups/$StoragePath"
        
        $response = Invoke-RestMethod -Uri $uploadUrl `
            -Method POST `
            -Headers $headers `
            -Body $fileBytes `
            -ContentType "application/zip"
        
        # Finalizar backup no banco
        $finalizarHeaders = @{
            "apikey" = $SUPABASE_ANON_KEY
            "Authorization" = "Bearer $SUPABASE_ACCESS_TOKEN"
            "Content-Type" = "application/json"
        }
        
        $finalizarBody = @{
            p_backup_id = $BackupId
            p_file_size = $fileSize
        } | ConvertTo-Json
        
        $finalizar = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/rpc/finalizar_backup_storage" `
            -Method POST `
            -Headers $finalizarHeaders `
            -Body $finalizarBody
        
        Write-Log "   - Upload concluído: $($fileSize / 1MB) MB"
        return $true
    }
    catch {
        Write-Log "❌ Erro no upload para Storage: $_"
        return $false
    }
}

function Chamar-BackupSupabase {
    try {
        Write-Log "Iniciando backup no Supabase..."
        
        $headers = @{
            "apikey" = $SUPABASE_ANON_KEY
            "Authorization" = "Bearer $SUPABASE_ACCESS_TOKEN"
            "Content-Type" = "application/json"
        }
        
        # Chamar função RPC (retorna dados + metadata)
        $response = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/rpc/criar_backup_automatico_individual" `
            -Method POST `
            -Headers $headers `
            -Body "{}"
        
        Write-Log "✅ Backup criado no Supabase"
        Write-Log "   - Backup ID: $($response.backup_id)"
        Write-Log "   - Empresa ID: $($response.empresa_id)"
        Write-Log "   - Storage Path: $($response.storage_path)"
        
        return $response
    }
    catch {
        Write-Log "❌ Erro ao criar backup no Supabase: $_"
        return $null
    }
}

function Salvar-BackupLocal {
    param($BackupResponse)
    
    try {
        Write-Log "Salvando backup localmente..."
        
        $backupId = $BackupResponse.backup_id
        $empresaId = $BackupResponse.empresa_id
        $dados = $BackupResponse.dados
        $storagePath = $BackupResponse.storage_path
        
        # Criar estrutura de backup
        $backupData = @{
            metadata = @{
                id = $backupId
                empresa_id = $empresaId
                storage_path = $storagePath
                total_clientes = $BackupResponse.total_clientes
                total_produtos = $BackupResponse.total_produtos
                total_vendas = $BackupResponse.total_vendas
                tamanho_bytes = $BackupResponse.tamanho_bytes
                created_at = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            }
            dados = $dados
        }
        
        # Salvar em arquivo JSON
        $empresaIdShort = $empresaId.Substring(0, 8)
        $filename = "backup_${empresaIdShort}_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".json"
        $filepath = Join-Path $BACKUP_FOLDER $filename
        
        $backupData | ConvertTo-Json -Depth 10 -Compress | Set-Content -Path $filepath -Encoding UTF8
        
        # Comprimir arquivo
        $zipFile = $filepath -replace ".json", ".zip"
        Compress-Archive -Path $filepath -DestinationPath $zipFile -Force
        Remove-Item $filepath  # Remover JSON original
        
        $fileSize = (Get-Item $zipFile).Length
        $fileSizeMB = [math]::Round($fileSize / 1MB, 2)
        
        Write-Log "✅ Backup salvo localmente: $zipFile ($fileSizeMB MB)"
        Write-Log "   - Clientes: $($BackupResponse.total_clientes)"
        Write-Log "   - Produtos: $($BackupResponse.total_produtos)"
        Write-Log "   - Vendas: $($BackupResponse.total_vendas)"
        
        # Fazer upload para Storage do Supabase
        $uploadSuccess = Upload-ParaStorage -BackupId $backupId -FilePath $zipFile -StoragePath $storagePath
        
        if ($uploadSuccess) {
            Write-Log "✅ Backup enviado para Supabase Storage"
            return $true
        }
        else {
            Write-Log "⚠️  Backup salvo localmente, mas upload para Storage falhou"
            return $true  # Ainda considera sucesso (backup local existe)
        }
        
        return $true
    }
    catch {
        Write-Log "❌ Erro ao baixar dados do backup: $_"
        return $false
    }
}

function Limpar-BackupsAntigos {
    try {
        $backups = Get-ChildItem -Path $BACKUP_FOLDER -Filter "backup_*.zip" | 
                   Sort-Object LastWriteTime -Descending
        
        if ($backups.Count -gt $MAX_BACKUPS) {
            $backupsParaRemover = $backups | Select-Object -Skip $MAX_BACKUPS
            
            foreach ($backup in $backupsParaRemover) {
                Remove-Item $backup.FullName -Force
                Write-Log "🗑️  Backup antigo removido: $($backup.Name)"
            }
            
            Write-Log "Mantidos $MAX_BACKUPS backups mais recentes"
        }
    }
    catch {
        Write-Log "⚠️  Erro ao limpar backups antigos: $_"
    }
}

# =============================================
# EXECUÇÃO PRINCIPAL
# =============================================

Write-Log "========================================="
Write-Log "INICIANDO BACKUP AUTOMÁTICO"
Write-Log "========================================="

# 1. Criar pasta de backup
Criar-PastaBackup

# 2. Criar backup no Supabase e obter dados
$backupResponse = Chamar-BackupSupabase

if ($null -eq $backupResponse) {
    Write-Log "❌ Falha ao criar backup. Abortando..."
    exit 1
}

# 3. Salvar backup localmente e fazer upload para Storage
$sucesso = Salvar-BackupLocal -BackupResponse $backupResponse

if (-not $sucesso) {
    Write-Log "❌ Falha ao baixar backup. Abortando..."
    exit 1
}

# 4. Limpar backups antigos
Limpar-BackupsAntigos

Write-Log "========================================="
Write-Log "BACKUP CONCLUÍDO COM SUCESSO! ✅"
Write-Log "========================================="

exit 0
