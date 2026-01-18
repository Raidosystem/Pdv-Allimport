-- ============================================
-- 7️⃣ VERIFICAR DADOS DO USUÁRIO EM subscriptions
-- ============================================

SELECT 
  'subscriptions' as tabela,
  id,
  user_id,
  email,
  status,
  plan_type,
  trial_start_date,
  trial_end_date,
  subscription_start_date,
  subscription_end_date,
  CASE 
    WHEN trial_end_date IS NOT NULL AND trial_end_date > NOW() THEN 
      EXTRACT(DAY FROM (trial_end_date - NOW()))::INTEGER
    WHEN subscription_end_date IS NOT NULL AND subscription_end_date > NOW() THEN
      EXTRACT(DAY FROM (subscription_end_date - NOW()))::INTEGER
    ELSE 0
  END as dias_restantes
FROM subscriptions
WHERE email = 'silviobritoempreendedor@gmail.com';
