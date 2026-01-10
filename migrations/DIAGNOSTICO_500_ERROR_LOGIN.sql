-- ============================================================================
-- DIAGNÓSTICO 500 ERROR NO LOGIN
-- ============================================================================
-- Este script verifica o que pode estar causando 500 Internal Server Error
-- durante a tentativa de login
-- ============================================================================

-- 1. Verificar triggers que executam em auth.users
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement,
  action_timing,
  action_orientation
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users'
ORDER BY trigger_name;

-- 2. Verificar funções que podem estar com erro
SELECT 
  routine_name,
  routine_type,
  data_type,
  routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (
    routine_name LIKE '%user%' 
    OR routine_name LIKE '%auth%'
    OR routine_name LIKE '%login%'
  )
ORDER BY routine_name;

-- 3. Verificar se há constraints quebradas em tabelas relacionadas
SELECT 
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.table_name IN ('user_approvals', 'empresas', 'subscriptions', 'funcionarios')
ORDER BY tc.table_name, tc.constraint_type;

-- 4. Verificar se há registros órfãos que podem causar erro
SELECT 
  'user_approvals sem user_id válido' as problema,
  COUNT(*) as quantidade
FROM user_approvals ua
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users au WHERE au.id = ua.user_id
)
UNION ALL
SELECT 
  'empresas sem user_id válido' as problema,
  COUNT(*) as quantidade
FROM empresas e
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users au WHERE au.id = e.user_id
)
UNION ALL
SELECT 
  'subscriptions sem user_id válido' as problema,
  COUNT(*) as quantidade
FROM subscriptions s
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users au WHERE au.id = s.user_id
);

-- 5. Primeiro verificar estrutura da tabela user_approvals
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_approvals'
ORDER BY ordinal_position;

-- 6. Verificar o registro específico do admin (usando apenas colunas básicas)
SELECT 
  ua.*,
  au.email_confirmed_at,
  au.created_at as user_created,
  au.role as auth_role
FROM user_approvals ua
JOIN auth.users au ON ua.user_id = au.id
WHERE ua.email = 'novaradiosystem@outlook.com';

-- 7. Verificar empresas do admin
SELECT *
FROM empresas e
WHERE e.user_id = (SELECT id FROM auth.users WHERE email = 'novaradiosystem@outlook.com');

-- 7b. Verificar subscriptions do admin
SELECT *
FROM subscriptions s
WHERE s.user_id = (SELECT id FROM auth.users WHERE email = 'novaradiosystem@outlook.com');

-- 8. Verificar policies que podem estar bloqueando durante auth
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('user_approvals', 'empresas', 'subscriptions')
ORDER BY tablename, policyname;

-- 9. Verificar se extensão pgcrypto está instalada (necessária para crypt)
SELECT 
  extname,
  extversion,
  'Extensão instalada' as status
FROM pg_extension
WHERE extname = 'pgcrypto';
