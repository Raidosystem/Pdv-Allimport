@echo off
REM ====================================================
REM AGENDADOR DE BACKUP AUTOMÁTICO NO WINDOWS
REM ====================================================

echo ========================================
echo CONFIGURANDO BACKUP AUTOMATICO DIARIO
echo ========================================
echo.

REM Caminho do Python e do script
set PYTHON_PATH=C:\Users\GrupoRaval\Desktop\Pdv-Allimport\.venv\Scripts\python.exe
set SCRIPT_PATH=C:\Users\GrupoRaval\Desktop\Pdv-Allimport\scripts\backup-multiprojetos-automatico.py

REM Criar tarefa agendada para executar todo dia às 03:00
echo Criando tarefa agendada...
schtasks /Create /SC DAILY /TN "Backup-Supabase-Automatico" /TR "\"%PYTHON_PATH%\" \"%SCRIPT_PATH%\"" /ST 03:00 /F

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCESSO! Backup agendado para 03:00
    echo ========================================
    echo.
    echo Para verificar: Abra "Agendador de Tarefas"
    echo Para testar agora: schtasks /Run /TN "Backup-Supabase-Automatico"
    echo Para desabilitar: schtasks /Change /TN "Backup-Supabase-Automatico" /DISABLE
    echo Para remover: schtasks /Delete /TN "Backup-Supabase-Automatico" /F
) else (
    echo.
    echo ERRO ao criar tarefa agendada!
    echo Execute este arquivo como Administrador
    echo Clique com botao direito e "Executar como administrador"
)

echo.
pause
