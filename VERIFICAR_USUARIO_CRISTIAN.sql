-- Verificar dados da subscription do usuário
SELECT 
  user_id,
  email,
  status,
  plan_type,
  trial_start_date,
  trial_end_date,
  subscription_start_date,
  subscription_end_date,
  payment_method,
  amount,
  created_at,
  updated_at
FROM subscriptions
WHERE email = 'cris-ramos30@hotmail.com';

-- Verificar se há algum problema de dados
SELECT 
  CASE 
    WHEN status = 'active' AND subscription_end_date > now() THEN '✅ Premium Válido'
    WHEN status = 'trial' AND trial_end_date > now() THEN '✅ Trial Válido'
    WHEN status = 'active' AND subscription_end_date < now() THEN '❌ Premium Expirado'
    WHEN status = 'trial' AND trial_end_date < now() THEN '❌ Trial Expirado'
    ELSE '⚠️ Status Inválido: ' || status
  END as situacao,
  status,
  plan_type,
  subscription_end_date,
  trial_end_date,
  (subscription_end_date - now()) as tempo_restante_premium,
  (trial_end_date - now()) as tempo_restante_trial
FROM subscriptions
WHERE email = 'cris-ramos30@hotmail.com';
