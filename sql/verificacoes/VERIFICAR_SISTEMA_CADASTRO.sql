-- =============================================
-- VERIFICAÇÃO FINAL DO SISTEMA DE CADASTRO
-- =============================================
-- Execute este SQL no Supabase SQL Editor para garantir que tudo está OK

-- 1. Verificar se o trigger existe e está ativo
SELECT 
  '=== TRIGGER on_auth_user_created ===' as secao,
  t.tgname as trigger_name,
  c.relname as tabela,
  p.proname as funcao,
  CASE t.tgenabled 
    WHEN 'O' THEN '✅ ATIVO'
    WHEN 'D' THEN '❌ DESABILITADO'
    ELSE '⚠️ DESCONHECIDO'
  END as status
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE t.tgname = 'on_auth_user_created';

-- 2. Verificar se a função create_empresa_for_new_user existe
SELECT 
  '=== FUNÇÃO create_empresa_for_new_user ===' as secao,
  proname as funcao,
  prosecdef as security_definer,
  CASE 
    WHEN prosecdef THEN '✅ SECURITY DEFINER (bypassa RLS)'
    ELSE '⚠️ SEM SECURITY DEFINER'
  END as status
FROM pg_proc
WHERE proname = 'create_empresa_for_new_user';

-- 3. Verificar se as funções RPC existem
SELECT 
  '=== FUNÇÕES RPC ===' as secao,
  proname as funcao,
  prosecdef as security_definer
FROM pg_proc
WHERE proname IN ('activate_trial_for_new_user', 'approve_user_after_email_verification')
ORDER BY proname;

-- 4. Verificar Marco está OK
SELECT 
  '=== CADASTRO MARCO ===' as secao,
  *
FROM user_approvals
WHERE email = 'marcovalentim04@outlook.com';

SELECT 
  '=== SUBSCRIPTION MARCO ===' as secao,
  *
FROM subscriptions
WHERE email = 'marcovalentim04@outlook.com';

-- 5. Verificar RLS das tabelas críticas
SELECT 
  '=== RLS STATUS ===' as secao,
  schemaname,
  tablename,
  CASE 
    WHEN rowsecurity THEN '✅ RLS ATIVO'
    ELSE '❌ RLS DESATIVADO'
  END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('user_approvals', 'subscriptions', 'empresas')
ORDER BY tablename;

-- 6. Contar políticas RLS
SELECT 
  '=== POLÍTICAS RLS ===' as secao,
  tablename,
  COUNT(*) as total_politicas,
  COUNT(*) FILTER (WHERE cmd = 'INSERT') as insert_policies,
  COUNT(*) FILTER (WHERE cmd = 'SELECT') as select_policies,
  COUNT(*) FILTER (WHERE cmd = 'UPDATE') as update_policies
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('user_approvals', 'subscriptions', 'empresas')
GROUP BY tablename
ORDER BY tablename;

SELECT '✅ VERIFICAÇÃO CONCLUÍDA!' as resultado;
