-- =====================================================
-- CORREÇÃO TOTAL DO SISTEMA DE BACKUPS
-- =====================================================
-- Remove TODAS as políticas e recria do zero
-- =====================================================

-- 1. DESABILITAR RLS temporariamente
ALTER TABLE public.backups DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER TODAS as políticas antigas
DROP POLICY IF EXISTS "backups_select_policy" ON public.backups;
DROP POLICY IF EXISTS "backups_insert_policy" ON public.backups;
DROP POLICY IF EXISTS "backups_update_policy" ON public.backups;
DROP POLICY IF EXISTS "backups_delete_policy" ON public.backups;

-- Políticas alternativas que podem existir
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.backups;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.backups;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.backups;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.backups;

-- 3. REABILITAR RLS
ALTER TABLE public.backups ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR políticas ULTRA PERMISSIVAS para authenticated users
CREATE POLICY "allow_all_authenticated_select" ON public.backups
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "allow_all_authenticated_insert" ON public.backups
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "allow_all_authenticated_update" ON public.backups
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_all_authenticated_delete" ON public.backups
  FOR DELETE
  TO authenticated
  USING (true);

-- 5. VERIFICAR se funcionou
DO $$
DECLARE
  v_rls_enabled BOOLEAN;
  v_policy_count INTEGER;
BEGIN
  -- Verificar RLS
  SELECT rowsecurity INTO v_rls_enabled
  FROM pg_tables
  WHERE schemaname = 'public'
  AND tablename = 'backups';
  
  -- Contar políticas
  SELECT COUNT(*) INTO v_policy_count
  FROM pg_policies
  WHERE schemaname = 'public'
  AND tablename = 'backups';
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ CORREÇÃO DE BACKUPS APLICADA';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'RLS habilitado: %', v_rls_enabled;
  RAISE NOTICE 'Políticas ativas: %', v_policy_count;
  RAISE NOTICE '';
  RAISE NOTICE '🔓 Políticas ULTRA PERMISSIVAS ativas';
  RAISE NOTICE '   Todos os usuários autenticados têm acesso total';
  RAISE NOTICE '';
  RAISE NOTICE '🎯 Teste agora:';
  RAISE NOTICE '   1. Recarregue a página (F5)';
  RAISE NOTICE '   2. Vá em Administração > Backups';
  RAISE NOTICE '   3. Clique em "Criar Backup Manual"';
  RAISE NOTICE '========================================';
END $$;
