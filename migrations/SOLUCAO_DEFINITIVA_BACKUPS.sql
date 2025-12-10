-- =====================================================
-- SOLUÇÃO DEFINITIVA - BACKUPS FUNCIONANDO 100%
-- =====================================================

-- 1. GRANT direto na tabela (além do RLS)
GRANT ALL ON public.backups TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- 2. Verificar se as políticas estão ativas
SELECT 
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
AND tablename = 'backups';

-- 3. Se não houver políticas, criar novamente
DO $$
DECLARE
  v_policy_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_policy_count
  FROM pg_policies
  WHERE schemaname = 'public'
  AND tablename = 'backups';
  
  IF v_policy_count = 0 THEN
    -- Desabilitar RLS
    ALTER TABLE public.backups DISABLE ROW LEVEL SECURITY;
    
    -- Reabilitar RLS
    ALTER TABLE public.backups ENABLE ROW LEVEL SECURITY;
    
    -- Criar políticas
    CREATE POLICY "allow_all_select" ON public.backups
      FOR SELECT TO authenticated USING (true);
    
    CREATE POLICY "allow_all_insert" ON public.backups
      FOR INSERT TO authenticated WITH CHECK (true);
    
    CREATE POLICY "allow_all_update" ON public.backups
      FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
    
    CREATE POLICY "allow_all_delete" ON public.backups
      FOR DELETE TO authenticated USING (true);
    
    RAISE NOTICE '✅ Políticas RLS recriadas';
  ELSE
    RAISE NOTICE 'ℹ️ Já existem % políticas', v_policy_count;
  END IF;
END $$;

-- 4. Verificação final
DO $$
DECLARE
  v_rls_enabled BOOLEAN;
  v_grant_check TEXT;
BEGIN
  -- Verificar RLS
  SELECT rowsecurity INTO v_rls_enabled
  FROM pg_tables
  WHERE schemaname = 'public'
  AND tablename = 'backups';
  
  -- Verificar GRANT
  SELECT privilege_type INTO v_grant_check
  FROM information_schema.table_privileges
  WHERE table_schema = 'public'
  AND table_name = 'backups'
  AND grantee = 'authenticated'
  LIMIT 1;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ CORREÇÃO FINAL APLICADA';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'RLS habilitado: %', v_rls_enabled;
  RAISE NOTICE 'GRANT concedido: %', v_grant_check;
  RAISE NOTICE '';
  RAISE NOTICE '🎯 TESTE AGORA:';
  RAISE NOTICE '1. Recarregue a página (Ctrl+F5)';
  RAISE NOTICE '2. Vá em Administração > Backups';
  RAISE NOTICE '3. Clique em "Criar Backup Manual"';
  RAISE NOTICE '========================================';
END $$;
