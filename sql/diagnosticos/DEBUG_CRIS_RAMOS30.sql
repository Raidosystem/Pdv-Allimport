-- ============================================
-- DIAGNOSTICAR cris-ramos30@hotmail.com
-- ============================================

-- PASSO 1: Ver subscription no banco
SELECT 
  id,
  user_id,
  email,
  plan_type,
  status,
  trial_start_date,
  trial_end_date,
  subscription_end_date,
  EXTRACT(DAY FROM (COALESCE(trial_end_date, subscription_end_date) - NOW())) as dias_restantes,
  CASE 
    WHEN status = 'trial' AND trial_end_date > NOW() THEN '✅ DEVERIA PERMITIR ACESSO'
    ELSE '❌ BLOQUEADO'
  END as deveria_ser
FROM subscriptions
WHERE email = 'cris-ramos30@hotmail.com';

-- PASSO 2: Testar RPC (como super admin)
SELECT * FROM check_subscription_status('cris-ramos30@hotmail.com');

-- PASSO 3: Ver se há algum problema com a coluna trial_end_date
SELECT 
  trial_end_date,
  trial_end_date IS NULL as "é_null",
  trial_end_date > NOW() as "é_maior_que_agora",
  NOW() as "agora"
FROM subscriptions
WHERE email = 'cris-ramos30@hotmail.com';
