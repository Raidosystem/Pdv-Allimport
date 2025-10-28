-- Testar a função check_subscription_status para o usuário específico
SELECT check_subscription_status('cris-ramos30@hotmail.com');

-- Verificar manualmente se o usuário deveria ter acesso
SELECT 
  email,
  status,
  plan_type,
  subscription_end_date > now() as subscription_valida,
  trial_end_date > now() as trial_valido,
  CASE 
    WHEN status = 'active' AND subscription_end_date > now() THEN 'DEVERIA TER ACESSO (Premium)'
    WHEN status = 'trial' AND trial_end_date > now() THEN 'DEVERIA TER ACESSO (Trial)'
    ELSE 'SEM ACESSO'
  END as deveria_ter_acesso
FROM subscriptions
WHERE email = 'cris-ramos30@hotmail.com';
