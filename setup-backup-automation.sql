-- =============================================
-- CONFIGURAÇÃO DE BACKUP AUTOMÁTICO DIÁRIO
-- Execute este script APÓS o script principal
-- =============================================

-- Verificar se a extensão pg_cron está disponível
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        RAISE NOTICE '✅ Extensão pg_cron já está ativa';
    ELSE
        RAISE NOTICE '❌ Extensão pg_cron não encontrada. Solicite ao administrador do Supabase para ativar.';
    END IF;
END $$;

-- =============================================
-- AGENDAR BACKUP DIÁRIO AUTOMÁTICO
-- =============================================

-- Backup diário às 2:00 AM (horário UTC)
SELECT cron.schedule(
    'daily-user-backup',           -- Nome do job
    '0 2 * * *',                   -- Cron schedule: todo dia às 2:00 AM
    'SELECT public.daily_backup_all_users();'  -- Comando a executar
);

-- Backup semanal de limpeza às 3:00 AM de domingo
SELECT cron.schedule(
    'weekly-backup-cleanup',
    '0 3 * * 0',                   -- Domingo às 3:00 AM
    'DELETE FROM user_backups WHERE created_at < NOW() - INTERVAL ''30 days'';'
);

-- =============================================
-- VERIFICAR JOBS AGENDADOS
-- =============================================
SELECT 
    jobid,
    schedule,
    command,
    nodename,
    nodeport,
    database,
    username,
    active
FROM cron.job 
ORDER BY jobid;

-- =============================================
-- FUNÇÕES UTILITÁRIAS PARA BACKUP MANUAL
-- =============================================

-- Função para backup manual do usuário atual
CREATE OR REPLACE FUNCTION public.backup_my_data()
RETURNS JSONB AS $$
DECLARE
    backup_data JSONB;
BEGIN
    SELECT jsonb_build_object(
        'user_id', auth.uid(),
        'backup_date', NOW(),
        'clientes', (SELECT jsonb_agg(to_jsonb(c)) FROM clientes c WHERE c.user_id = auth.uid()),
        'categorias', (SELECT jsonb_agg(to_jsonb(cat)) FROM categorias cat WHERE cat.user_id = auth.uid()),
        'produtos', (SELECT jsonb_agg(to_jsonb(p)) FROM produtos p WHERE p.user_id = auth.uid()),
        'vendas', (SELECT jsonb_agg(to_jsonb(v)) FROM vendas v WHERE v.user_id = auth.uid()),
        'itens_venda', (SELECT jsonb_agg(to_jsonb(i)) FROM itens_venda i WHERE i.user_id = auth.uid())
    ) INTO backup_data;
    
    -- Salvar backup
    INSERT INTO user_backups (user_id, backup_data, created_at)
    VALUES (auth.uid(), backup_data, NOW())
    ON CONFLICT (user_id, DATE(created_at)) DO UPDATE SET
        backup_data = EXCLUDED.backup_data,
        updated_at = NOW();
    
    RETURN backup_data;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para restaurar dados de backup
CREATE OR REPLACE FUNCTION public.restore_from_backup(backup_date DATE)
RETURNS TEXT AS $$
DECLARE
    backup_record RECORD;
BEGIN
    -- Buscar backup do usuário para a data especificada
    SELECT * INTO backup_record 
    FROM user_backups 
    WHERE user_id = auth.uid() 
    AND DATE(created_at) = backup_date;
    
    IF NOT FOUND THEN
        RETURN 'Backup não encontrado para a data: ' || backup_date;
    END IF;
    
    -- AVISO: Esta função apenas retorna os dados
    -- A restauração deve ser feita manualmente por segurança
    RETURN 'Backup encontrado. Use os dados em backup_data da tabela user_backups para restauração manual.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- INSTRUÇÕES DE USO
-- =============================================

SELECT 'BACKUP AUTOMÁTICO CONFIGURADO:

📅 Backup diário às 2:00 AM UTC
🧹 Limpeza semanal (mantém 30 dias)
💾 Backup manual: SELECT backup_my_data();
📋 Ver meus backups: SELECT * FROM user_backups WHERE user_id = auth.uid();
🔄 Restaurar: SELECT restore_from_backup(''2025-08-07'');

⚠️ IMPORTANTE:
- Backups são automáticos e privados por usuário
- Cada usuário só vê seus próprios backups
- Dados são mantidos por 30 dias
- Para restauração completa, use o backup_data em formato JSON

' AS instrucoes;
