-- ============================================
-- TESTE RÁPIDO: Verificar o que está retornando
-- ============================================

-- Teste com seus emails reais
SELECT check_subscription_status('marcovalentim04@outlook.com');
SELECT check_subscription_status('novaradiosystem@outlook.com');
SELECT check_subscription_status('cris-ramos30@hotmail.com');

-- Ver o que está na tabela
SELECT 
  email,
  status,
  trial_end_date > NOW() as trial_ainda_valido,
  EXTRACT(DAY FROM (trial_end_date - NOW())) as dias_calculados,
  trial_end_date,
  NOW() as agora
FROM subscriptions
WHERE email IN (
  'marcovalentim04@outlook.com',
  'novaradiosystem@outlook.com', 
  'cris-ramos30@hotmail.com'
);

-- ============================================
-- Se o check_subscription_status retornar:
-- "access_allowed": false
-- 
-- Então o problema está na função!
-- Execute o FIX_TESTE_15_DIAS_COMPLETO.sql
-- ============================================
