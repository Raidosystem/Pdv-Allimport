-- ================================================
-- ATIVAR SUPABASE REALTIME PARA user_approvals
-- Execute no SQL Editor do Supabase
-- ================================================

-- 1. HABILITAR REPLICA IDENTITY (necessário para Realtime)
ALTER TABLE public.user_approvals REPLICA IDENTITY FULL;

-- 2. VERIFICAR SE A PUBLICAÇÃO EXISTE
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime'
  ) THEN
    CREATE PUBLICATION supabase_realtime;
    RAISE NOTICE '✅ Publicação supabase_realtime criada';
  ELSE
    RAISE NOTICE '✅ Publicação supabase_realtime já existe';
  END IF;
END $$;

-- 3. ADICIONAR user_approvals À PUBLICAÇÃO REALTIME
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_approvals;

-- 4. VERIFICAR CONFIGURAÇÃO
SELECT 
  '✅ REALTIME ATIVADO PARA user_approvals!' as status,
  pc.relname as tablename,
  CASE pc.relreplident
    WHEN 'd' THEN 'default'
    WHEN 'n' THEN 'nothing'
    WHEN 'f' THEN 'full'
    WHEN 'i' THEN 'index'
  END as replica_identity
FROM pg_class pc
JOIN pg_namespace pn ON pc.relnamespace = pn.oid
WHERE pn.nspname = 'public' 
AND pc.relname = 'user_approvals';

-- 5. VERIFICAR TABELAS NA PUBLICAÇÃO
SELECT 
  schemaname,
  tablename
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime';

-- ================================================
-- ✅ PRONTO! AGORA O ADMIN PANEL VAI ATUALIZAR AUTOMATICAMENTE
-- ================================================

-- 📋 O QUE FOI CONFIGURADO:
-- 1. REPLICA IDENTITY FULL: Permite que o Realtime capture todas as mudanças
-- 2. Publicação: Habilita broadcasting de eventos
-- 3. Auto-refresh: A cada 30 segundos
-- 4. Realtime: Instantâneo quando houver INSERT/UPDATE/DELETE

-- 🎯 COMO FUNCIONA:
-- - Novo usuário se cadastra
-- - Trigger insere em user_approvals
-- - Realtime detecta o INSERT
-- - AdminPanel recebe notificação
-- - Lista atualiza automaticamente
-- - Toast: "Nova solicitação de cadastro recebida!"
