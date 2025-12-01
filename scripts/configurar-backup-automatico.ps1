# =============================================
# CONFIGURADOR DE BACKUP AUTOMÁTICO
# =============================================
# Este script configura o Task Scheduler do Windows
# para executar o backup automaticamente

# Verificar se está rodando como Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ Este script precisa ser executado como Administrador!" -ForegroundColor Red
    Write-Host "   Clique com botão direito no PowerShell e escolha 'Executar como Administrador'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "CONFIGURADOR DE BACKUP AUTOMÁTICO" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Configurações
$scriptPath = Join-Path $PSScriptRoot "backup-automatico.ps1"
$taskName = "PDV-Allimport-Backup-Automatico"

# Solicitar informações ao usuário
Write-Host "📋 Por favor, forneça as seguintes informações:" -ForegroundColor Yellow
Write-Host ""

$supabaseUrl = Read-Host "URL do Supabase (ex: https://seu-projeto.supabase.co)"
$supabaseKey = Read-Host "Chave Anon do Supabase"
$supabaseToken = Read-Host "Token de Acesso do Usuário (JWT) - Pegue no console do navegador após login"
$backupFolder = Read-Host "Pasta para salvar backups (ex: C:\Backups\PDV-Allimport)"
$horario = Read-Host "Horário do backup diário (formato 24h, ex: 23:00)"

# Validar horário
if ($horario -notmatch "^\d{2}:\d{2}$") {
    Write-Host "❌ Horário inválido! Use o formato HH:MM (ex: 23:00)" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "⚙️  Configurando..." -ForegroundColor Yellow

# Atualizar arquivo de script com as configurações
$scriptContent = Get-Content $scriptPath -Raw
$scriptContent = $scriptContent -replace '\$SUPABASE_URL = ".*"', "`$SUPABASE_URL = `"$supabaseUrl`""
$scriptContent = $scriptContent -replace '\$SUPABASE_ANON_KEY = ".*"', "`$SUPABASE_ANON_KEY = `"$supabaseKey`""
$scriptContent = $scriptContent -replace '\$SUPABASE_ACCESS_TOKEN = ".*"', "`$SUPABASE_ACCESS_TOKEN = `"$supabaseToken`""
$scriptContent = $scriptContent -replace '\$BACKUP_FOLDER = ".*"', "`$BACKUP_FOLDER = `"$backupFolder`""
Set-Content -Path $scriptPath -Value $scriptContent -Encoding UTF8

Write-Host "✅ Script configurado" -ForegroundColor Green

# Criar pasta de backup
if (-not (Test-Path $backupFolder)) {
    New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
    Write-Host "✅ Pasta de backup criada: $backupFolder" -ForegroundColor Green
}

# Remover tarefa existente (se houver)
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "✅ Tarefa anterior removida" -ForegroundColor Green
}

# Criar ação da tarefa
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Criar gatilho (trigger) diário
$trigger = New-ScheduledTaskTrigger -Daily -At $horario

# Configurações da tarefa
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

# Criar principal (executar com maior privilégio)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -RunLevel Highest

# Registrar tarefa
Register-ScheduledTask -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Backup automático diário do PDV Allimport para pasta local" | Out-Null

Write-Host "✅ Tarefa agendada criada com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "CONFIGURAÇÃO CONCLUÍDA! ✅" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Resumo da configuração:" -ForegroundColor Yellow
Write-Host "   • Tarefa: $taskName" -ForegroundColor White
Write-Host "   • Horário: $horario (todos os dias)" -ForegroundColor White
Write-Host "   • Pasta: $backupFolder" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Para verificar a tarefa:" -ForegroundColor Yellow
Write-Host "   1. Abra o 'Agendador de Tarefas' (taskschd.msc)" -ForegroundColor White
Write-Host "   2. Procure por '$taskName'" -ForegroundColor White
Write-Host ""
Write-Host "▶️  Para testar o backup agora:" -ForegroundColor Yellow
Write-Host "   Start-ScheduledTask -TaskName '$taskName'" -ForegroundColor White
Write-Host ""
Write-Host "📁 Os backups serão salvos em:" -ForegroundColor Yellow
Write-Host "   $backupFolder" -ForegroundColor White
Write-Host ""

pause
