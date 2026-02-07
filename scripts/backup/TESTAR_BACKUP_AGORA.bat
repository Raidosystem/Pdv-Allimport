@echo off
REM ====================================================
REM TESTAR BACKUP MANUAL
REM ====================================================

echo ========================================
echo EXECUTANDO BACKUP MANUAL DE TESTE
echo ========================================
echo.

cd /d "%~dp0"
.venv\Scripts\python.exe scripts\backup-multiprojetos-automatico.py

echo.
echo ========================================
echo BACKUP CONCLUIDO!
echo ========================================
echo.
echo Verifique a pasta de backups configurada
echo Para ver o log completo, verifique a pasta de logs
echo.
pause
