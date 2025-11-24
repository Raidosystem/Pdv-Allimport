-- =============================================
-- AGENDAR BACKUP AUTOMÁTICO DIÁRIO
-- =============================================
-- Execute este script no Supabase Dashboard > SQL Editor
-- IMPORTANTE: Este comando usa a extensão pg_cron do Supabase

-- =============================================
-- 1. VERIFICAR SE A EXTENSÃO pg_cron ESTÁ DISPONÍVEL
-- =============================================
-- A extensão pg_cron vem habilitada por padrão no Supabase
-- Mas você pode verificar com:
SELECT * FROM pg_extension WHERE extname = 'pg_cron';

-- =============================================
-- 2. AGENDAR BACKUP DIÁRIO ÀS 2:00 AM (HORÁRIO UTC)
-- =============================================
-- Este comando agenda a execução automática da função de backup
-- todos os dias às 2:00 AM (horário UTC)
SELECT cron.schedule(
    'daily-user-backup',           -- Nome do job
    '0 2 * * *',                    -- Cron expression: todos os dias às 2:00 AM UTC
    'SELECT public.daily_backup_all_users();'  -- Função a executar
);

-- =============================================
-- 3. VERIFICAR SE O JOB FOI CRIADO COM SUCESSO
-- =============================================
SELECT 
    jobid,
    jobname,
    schedule,
    command,
    active
FROM cron.job
WHERE jobname = 'daily-user-backup';

-- =============================================
-- 4. COMANDOS ÚTEIS PARA GERENCIAR O CRON JOB
-- =============================================

-- Listar todos os jobs agendados:
-- SELECT * FROM cron.job;

-- Verificar histórico de execuções do job:
-- SELECT * FROM cron.job_run_details 
-- WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-user-backup')
-- ORDER BY start_time DESC
-- LIMIT 10;

-- Desagendar o job (remover agendamento):
-- SELECT cron.unschedule('daily-user-backup');

-- Reagendar com horário diferente (exemplo: 3:00 AM):
-- SELECT cron.unschedule('daily-user-backup');
-- SELECT cron.schedule('daily-user-backup', '0 3 * * *', 'SELECT public.daily_backup_all_users();');

-- =============================================
-- 5. TESTAR A FUNÇÃO DE BACKUP MANUALMENTE
-- =============================================
-- Você pode executar o backup manualmente para testar:
-- SELECT public.daily_backup_all_users();

-- Verificar se os backups foram criados:
-- SELECT 
--     user_id,
--     backup_date,
--     created_at,
--     pg_size_pretty(pg_column_size(backup_data)) as tamanho
-- FROM user_backups
-- ORDER BY created_at DESC
-- LIMIT 10;

-- =============================================
-- OBSERVAÇÕES IMPORTANTES
-- =============================================

-- SOBRE O HORÁRIO:
-- O horário do cron é sempre em UTC (Universal Time Coordinated)
-- Se você está no Brasil (GMT-3), 2:00 AM UTC = 23:00 (11 PM) horário de Brasília
-- Ajuste o horário conforme necessário para seu fuso horário

-- CRON EXPRESSION EXPLICADA:
-- 0 2 * * * significa:
-- Primeiro campo (0): minuto 0
-- Segundo campo (2): hora 2 (2:00 AM)
-- Terceiro campo (*): todos os dias do mês
-- Quarto campo (*): todos os meses
-- Quinto campo (*): todos os dias da semana

-- EXEMPLOS DE OUTRAS EXPRESSÕES CRON:
-- A cada 6 horas: 0 */6 * * *
-- Meia-noite todos os dias: 0 0 * * *
-- Meia-noite todo domingo: 0 0 * * 0
-- 3:30 AM todos os dias: 30 3 * * *

-- RETENÇÃO DE BACKUPS:
-- Backups com mais de 30 dias são automaticamente excluídos
-- Isso está configurado na função daily_backup_all_users()
-- Para alterar o período, modifique o intervalo de 30 dias na função

-- LIMITAÇÕES DO SUPABASE FREE TIER:
-- O plano gratuito pode ter limitações no uso do pg_cron
-- Se o cron não funcionar, você pode implementar backup via:
-- 1. Webhook externo (cron-job.org, etc.) chamando uma Edge Function
-- 2. GitHub Actions com agendamento
-- 3. Backup manual pelo frontend (já implementado)

-- MONITORAMENTO:
-- Verifique regularmente o histórico de execução do job
-- Configure alertas se o backup falhar
-- Teste a restauração periodicamente

-- =============================================
-- ✅ RESULTADO ESPERADO
-- =============================================
SELECT 'BACKUP AUTOMÁTICO CONFIGURADO COM SUCESSO!' as status;

-- Para verificar o status do job criado:
SELECT 
    jobid,
    jobname,
    schedule,
    command,
    active
FROM cron.job
WHERE jobname = 'daily-user-backup';

-- Para testar manualmente:
-- SELECT public.daily_backup_all_users();

-- Para verificar histórico de execuções:
-- SELECT * FROM cron.job_run_details 
-- WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-user-backup')
-- ORDER BY start_time DESC
-- LIMIT 10;

