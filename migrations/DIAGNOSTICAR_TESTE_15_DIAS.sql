-- ============================================
-- DIAGNÓSTICO COMPLETO - TESTE 15 DIAS
-- ============================================

-- 1️⃣ Verificar se o trigger existe e está ativo
SELECT 
  '1️⃣ VERIFICAR TRIGGER' as passo,
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- 2️⃣ Verificar se a função handle_new_user existe
SELECT 
  '2️⃣ VERIFICAR FUNÇÃO' as passo,
  routine_name,
  routine_type,
  data_type as return_type
FROM information_schema.routines
WHERE routine_name = 'handle_new_user';

-- 3️⃣ Listar todos os usuários em auth.users
SELECT 
  '3️⃣ USUÁRIOS AUTH' as passo,
  id,
  email,
  created_at,
  email_confirmed_at,
  raw_user_meta_data->>'full_name' as full_name,
  raw_user_meta_data->>'company_name' as company_name
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;

-- 4️⃣ Listar empresas criadas
SELECT 
  '4️⃣ EMPRESAS' as passo,
  id,
  user_id,
  nome,
  email,
  tipo_conta,
  data_cadastro,
  data_fim_teste,
  CASE 
    WHEN data_fim_teste > NOW() THEN '✅ ATIVO'
    WHEN data_fim_teste IS NULL THEN '⚠️ SEM DATA'
    ELSE '❌ EXPIRADO'
  END as status_teste
FROM empresas
ORDER BY data_cadastro DESC
LIMIT 5;

-- 5️⃣ Verificar subscriptions
SELECT 
  '5️⃣ SUBSCRIPTIONS' as passo,
  id,
  user_id,
  empresa_id,
  status,
  plan_type,
  trial_end_date,
  subscription_end_date,
  created_at
FROM subscriptions
ORDER BY created_at DESC
LIMIT 5;

-- 6️⃣ Verificar usuários SEM empresa (problema!)
SELECT 
  '6️⃣ USUÁRIOS SEM EMPRESA' as passo,
  u.id,
  u.email,
  u.created_at,
  'PROBLEMA: Trigger não executou!' as diagnostico
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE e.id IS NULL
ORDER BY u.created_at DESC
LIMIT 5;

-- 7️⃣ Testar função check_subscription_status com usuários existentes
SELECT 
  '7️⃣ TESTAR FUNÇÃO' as passo,
  u.email,
  check_subscription_status(u.email) as resultado
FROM auth.users u
ORDER BY u.created_at DESC
LIMIT 3;

-- 8️⃣ Verificar se RLS está bloqueando
SELECT 
  '8️⃣ POLÍTICAS RLS' as passo,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('empresas', 'subscriptions')
ORDER BY tablename, policyname;
