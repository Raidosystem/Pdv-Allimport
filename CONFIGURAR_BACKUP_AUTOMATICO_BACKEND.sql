-- =====================================================
-- CONFIGURAÇÃO DE BACKUP AUTOMÁTICO NO BACKEND
-- Execute este SQL no Supabase Dashboard SQL Editor
-- =====================================================

-- =====================================================
-- 1. CRIAR BUCKET DE STORAGE PARA BACKUPS
-- =====================================================

-- Criar bucket 'backups' (se não existir)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'backups',
  'backups',
  false, -- Não público (apenas autenticados)
  52428800, -- 50MB por arquivo
  ARRAY['application/json']
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. POLÍTICAS DE ACESSO AO BUCKET
-- =====================================================

-- Remover políticas antigas (se existirem) - SEM ERRO se não existirem
DROP POLICY IF EXISTS "usuarios_podem_ver_proprios_backups" ON storage.objects;
DROP POLICY IF EXISTS "usuarios_podem_upload_proprios_backups" ON storage.objects;
DROP POLICY IF EXISTS "usuarios_podem_deletar_proprios_backups" ON storage.objects;

-- Usuários podem ver apenas seus próprios backups
CREATE POLICY "usuarios_podem_ver_proprios_backups"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'backups' 
  AND (storage.foldername(name))[1] = 'empresa_' || substring(auth.uid()::text, 1, 8)
);

-- Usuários podem fazer upload de backups
CREATE POLICY "usuarios_podem_upload_proprios_backups"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'backups' 
  AND (storage.foldername(name))[1] = 'empresa_' || substring(auth.uid()::text, 1, 8)
);

-- Usuários podem deletar seus próprios backups
CREATE POLICY "usuarios_podem_deletar_proprios_backups"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'backups' 
  AND (storage.foldername(name))[1] = 'empresa_' || substring(auth.uid()::text, 1, 8)
);

-- =====================================================
-- 3. HABILITAR EXTENSÃO pg_cron (Supabase Pro)
-- =====================================================

-- Verificar se pg_cron está disponível
-- SELECT * FROM pg_available_extensions WHERE name = 'pg_cron';

-- Habilitar pg_cron (pode dar erro se não tiver plano Pro)
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;

-- =====================================================
-- 4. AGENDAR BACKUP AUTOMÁTICO DIÁRIO
-- =====================================================

-- Remover agendamento anterior (se existir) - SEM ERRO se não existir
DO $$
BEGIN
  PERFORM cron.unschedule('backup-automatico-diario');
EXCEPTION
  WHEN OTHERS THEN
    NULL; -- Ignora erro se job não existe
END $$;

-- Agendar backup diário às 03:00 (horário UTC)
-- ATENÇÃO: 03:00 UTC = 00:00 BRT (horário de Brasília)
-- Ajuste se necessário: 06:00 UTC = 03:00 BRT
SELECT cron.schedule(
  'backup-automatico-diario',
  '0 6 * * *', -- Todo dia às 06:00 UTC (03:00 BRT)
  $$
  SELECT
    net.http_post(
      url := 'https://kmcaaqetxtwkdcczdomw.supabase.co/functions/v1/backup-automatico',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.Zd4CKd0yoMk0Mv-T9AkN7j0bP3XlE9LjLZ5P0WpuJ0E'
      ),
      body := '{}'::jsonb
    ) AS request_id;
  $$
);

-- =====================================================
-- 5. VERIFICAR AGENDAMENTO
-- =====================================================

-- Listar tarefas agendadas
SELECT * FROM cron.job WHERE jobname = 'backup-automatico-diario';

-- Ver histórico de execuções (últimas 10)
SELECT 
  jobid,
  runid,
  job_pid,
  database,
  username,
  command,
  status,
  return_message,
  start_time,
  end_time
FROM cron.job_run_details 
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'backup-automatico-diario')
ORDER BY start_time DESC
LIMIT 10;

-- =====================================================
-- 6. FUNÇÃO PARA EXECUTAR BACKUP MANUALMENTE
-- =====================================================

CREATE OR REPLACE FUNCTION executar_backup_manual()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  resultado jsonb;
BEGIN
  -- Chamar Edge Function via HTTP
  SELECT content::jsonb INTO resultado
  FROM http_post(
    'https://kmcaaqetxtwkdcczdomw.supabase.co/functions/v1/backup-automatico',
    '{}'::jsonb,
    'application/json',
    jsonb_build_object(
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.Zd4CKd0yoMk0Mv-T9AkN7j0bP3XlE9LjLZ5P0WpuJ0E'
    )
  );
  
  RETURN resultado;
END;
$$;

-- Testar backup manual (executar após fazer deploy da Edge Function)
-- SELECT executar_backup_manual();

-- =====================================================
-- 7. TABELA DE LOG DE BACKUPS (OPCIONAL)
-- =====================================================

CREATE TABLE IF NOT EXISTS backup_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  total_empresas INT,
  empresas_sucesso INT,
  empresas_falha INT,
  total_registros INT,
  detalhes JSONB,
  erro TEXT
);

-- RLS para a tabela de logs (apenas admins podem ver)
ALTER TABLE backup_logs ENABLE ROW LEVEL SECURITY;

-- Remover política antiga (se existir)
DROP POLICY IF EXISTS "apenas_admins_veem_logs_backup" ON backup_logs;

-- Criar política para logs (apenas usuários aprovados podem ver seus logs)
CREATE POLICY "usuarios_aprovados_veem_logs"
ON backup_logs FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM user_approvals
    WHERE user_id = auth.uid()
    AND status = 'approved'
  )
);

-- =====================================================
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- ✅ Verificar se funções de backup existem
SELECT proname, prosecdef 
FROM pg_proc 
WHERE proname IN ('backup_listar_empresas', 'backup_tabela_por_user');

-- ✅ Verificar se bucket foi criado
SELECT id, name, public FROM storage.buckets WHERE id = 'backups';

-- ✅ Verificar se pg_cron está ativo
SELECT * FROM cron.job WHERE jobname = 'backup-automatico-diario';

-- =====================================================
-- DESABILITAR BACKUP AUTOMÁTICO (SE NECESSÁRIO)
-- =====================================================

-- Para desabilitar temporariamente:
-- SELECT cron.unschedule('backup-automatico-diario');

-- Para habilitar novamente:
-- Execute o SELECT cron.schedule(...) acima novamente

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================

-- 1. pg_cron requer Supabase Pro Plan ($25/mês)
-- 2. Ajuste o horário UTC para seu timezone
-- 3. Substitua o Authorization Bearer token se necessário
-- 4. Backups são salvos no bucket 'backups' do Storage
-- 5. Backups antigos (>7 dias) são deletados automaticamente
-- 6. Cada empresa tem sua pasta: empresa_[user_id]
-- 7. Para testar: SELECT executar_backup_manual();
