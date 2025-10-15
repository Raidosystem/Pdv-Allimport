-- ============================================
-- RESTAURAR ASSINATURAS PERDIDAS - EMERGÊNCIA
-- ============================================

-- 1. CRIAR REGISTRO DE TESTE ATIVO PARA TODOS OS USUÁRIOS EXISTENTES
-- Isso dá 15 dias de teste para todos a partir de HOJE
INSERT INTO subscriptions (user_id, status, plan_type, trial_start_date, trial_end_date, created_at, updated_at)
SELECT 
  id as user_id,
  'trial' as status,
  'free' as plan_type,
  NOW() as trial_start_date,
  NOW() + INTERVAL '15 days' as trial_end_date,
  NOW() as created_at,
  NOW() as updated_at
FROM auth.users
ON CONFLICT (user_id) DO UPDATE SET
  status = 'trial',
  trial_start_date = NOW(),
  trial_end_date = NOW() + INTERVAL '15 days',
  updated_at = NOW();

-- 2. VERIFICAR TODOS OS USUÁRIOS COM SUAS ASSINATURAS
SELECT 
  u.email,
  s.status,
  s.trial_start_date,
  s.trial_end_date,
  EXTRACT(DAY FROM (s.trial_end_date - NOW())) as dias_restantes
FROM auth.users u
LEFT JOIN subscriptions s ON u.id = s.user_id
ORDER BY u.created_at DESC;

-- ============================================
-- PARA USUÁRIOS QUE ERAM PAGOS
-- Execute manualmente para cada usuário pago:
-- ============================================

-- EXEMPLO: Usuário c6864d69-a55c-4aca-8fe4-87841ac1084a (você)
-- Substitua o user_id e as datas conforme necessário
/*
UPDATE subscriptions 
SET 
  status = 'active',
  plan_type = 'premium',
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '1 year',
  trial_start_date = NULL,
  trial_end_date = NULL,
  updated_at = NOW()
WHERE user_id = 'c6864d69-a55c-4aca-8fe4-87841ac1084a';
*/

SELECT 'Assinaturas restauradas para 15 dias de teste!' as status;
