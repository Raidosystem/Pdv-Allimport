-- ============================================
-- VERIFICAR STATUS DO CRISTIANO
-- ============================================

-- 1. Verificar na tabela subscriptions
SELECT 
  email,
  status,
  trial_end_date,
  EXTRACT(DAY FROM (trial_end_date - NOW())) as dias_restantes,
  trial_end_date > NOW() as trial_valido
FROM subscriptions
WHERE email = 'cristiano@gruporaval.com.br';

-- 2. Testar a função check_subscription_status
SELECT 'cristiano@gruporaval.com.br' as usuario, 
       check_subscription_status('cristiano@gruporaval.com.br') as status;

-- 3. Ver TODOS os usuários com assinatura
SELECT 
  email,
  status,
  CASE 
    WHEN status = 'trial' THEN EXTRACT(DAY FROM (trial_end_date - NOW()))
    WHEN status = 'active' THEN EXTRACT(DAY FROM (subscription_end_date - NOW()))
    ELSE 0
  END as dias_restantes,
  CASE 
    WHEN status = 'trial' THEN trial_end_date
    WHEN status = 'active' THEN subscription_end_date
  END as data_expiracao
FROM subscriptions
ORDER BY email;

-- ============================================
-- RESULTADO ESPERADO PARA CRISTIANO:
-- ✅ status: trial
-- ✅ dias_restantes: 15
-- ✅ trial_valido: true
-- ✅ access_allowed: true no check_subscription_status
-- ============================================
