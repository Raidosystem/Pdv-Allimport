-- ============================================================================
-- VERIFICAR FUNÇÕES RPC DO PAINEL ADMIN
-- ============================================================================
-- Verificar se as funções RPC existem e testá-las com super admin
-- ============================================================================

-- 1. Verificar se as funções existem
SELECT 
  routine_name,
  routine_type,
  'Função existe' as status
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'get_admin_subscribers',
    'get_all_empresas_admin',
    'get_all_subscriptions_admin'
  )
ORDER BY routine_name;

-- 2. Testar get_admin_subscribers (deve retornar todos os owners)
SELECT * FROM get_admin_subscribers();

-- 3. Testar get_all_empresas_admin (deve retornar todas as empresas)
SELECT * FROM get_all_empresas_admin();

-- 4. Testar get_all_subscriptions_admin (deve retornar todas as subscriptions)
SELECT * FROM get_all_subscriptions_admin();

-- 5. Verificar quantos registros existem em cada tabela
SELECT 
  'user_approvals' as tabela,
  COUNT(*) as total,
  COUNT(CASE WHEN user_role = 'owner' THEN 1 END) as owners,
  COUNT(CASE WHEN user_role = 'employee' THEN 1 END) as funcionarios
FROM user_approvals
UNION ALL
SELECT 
  'empresas' as tabela,
  COUNT(*) as total,
  0 as owners,
  0 as funcionarios
FROM empresas
UNION ALL
SELECT 
  'subscriptions' as tabela,
  COUNT(*) as total,
  0 as owners,
  0 as funcionarios
FROM subscriptions;
