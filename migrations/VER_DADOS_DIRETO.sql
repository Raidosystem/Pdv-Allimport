-- ============================================================================
-- VERIFICAR DADOS DIRETAMENTE (SEM RPC)
-- ============================================================================
-- Buscar dados diretamente das tabelas para ver o que realmente existe
-- ============================================================================

-- 1. Verificar user_approvals (todos os usuários)
SELECT 
  user_id,
  email,
  user_role,
  status,
  created_at
FROM user_approvals
ORDER BY created_at DESC;

-- 2. Verificar empresas
SELECT 
  user_id,
  nome,
  email,
  tipo_conta,
  created_at
FROM empresas
ORDER BY created_at DESC;

-- 3. Verificar subscriptions
SELECT 
  user_id,
  email,
  status,
  plan_type,
  trial_end_date,
  subscription_end_date,
  created_at
FROM subscriptions
ORDER BY created_at DESC;

-- 4. Contar totais
SELECT 
  'user_approvals' as tabela,
  COUNT(*) as total_registros
FROM user_approvals
UNION ALL
SELECT 
  'empresas',
  COUNT(*)
FROM empresas
UNION ALL
SELECT 
  'subscriptions',
  COUNT(*)
FROM subscriptions;
