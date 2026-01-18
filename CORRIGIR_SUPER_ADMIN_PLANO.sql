-- ============================================================================
-- CORRIGIR PLANO DO SUPER ADMIN (novaradiosystem@outlook.com)
-- ============================================================================

-- 1️⃣ Ver situação atual
SELECT 
  '🔍 SITUAÇÃO ATUAL DO SUPER ADMIN:' as info,
  email,
  status,
  plan_type,
  trial_end_date,
  subscription_end_date,
  EXTRACT(DAY FROM (subscription_end_date - NOW()))::INTEGER as dias_restantes
FROM subscriptions
WHERE email = 'novaradiosystem@outlook.com';

-- 2️⃣ Atualizar para plano vitalício (999999 dias)
UPDATE subscriptions
SET 
  status = 'active',
  plan_type = 'premium',
  trial_end_date = NULL,
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '999999 days',
  updated_at = NOW()
WHERE email = 'novaradiosystem@outlook.com';

SELECT '✅ Plano do super admin atualizado!' as resultado;

-- 3️⃣ Verificar após atualização
SELECT 
  '✅ APÓS ATUALIZAÇÃO:' as info,
  email,
  status,
  plan_type,
  trial_end_date,
  subscription_start_date,
  subscription_end_date,
  EXTRACT(DAY FROM (subscription_end_date - NOW()))::INTEGER as dias_restantes,
  CASE 
    WHEN EXTRACT(DAY FROM (subscription_end_date - NOW()))::INTEGER > 365000 
    THEN '🔥 VITALÍCIO (999999 dias)'
    ELSE '⚠️ Verificar'
  END as status_visual
FROM subscriptions
WHERE email = 'novaradiosystem@outlook.com';

-- 4️⃣ Verificar dados em user_approvals
SELECT 
  '📋 USER_APPROVALS:' as info,
  email,
  full_name,
  company_name,
  status,
  user_role
FROM user_approvals
WHERE email = 'novaradiosystem@outlook.com';
