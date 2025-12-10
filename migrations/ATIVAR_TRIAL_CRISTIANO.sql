-- ============================================
-- ATIVAR TESTE DE 15 DIAS - cristiano@gruporaval.com.br
-- ============================================

-- 1. Deletar assinatura antiga (se existir)
DELETE FROM subscriptions 
WHERE email = 'cristiano@gruporaval.com.br';

-- 2. Inserir nova assinatura com teste de 15 dias
INSERT INTO subscriptions (
  email,
  status,
  trial_end_date,
  created_at,
  updated_at
)
VALUES (
  'cristiano@gruporaval.com.br',
  'trial',
  NOW() + INTERVAL '15 days',
  NOW(),
  NOW()
);

-- 3. Verificar se foi criado corretamente
SELECT 
  email,
  status,
  trial_end_date,
  EXTRACT(DAY FROM (trial_end_date - NOW())) as dias_restantes,
  trial_end_date > NOW() as trial_valido
FROM subscriptions
WHERE email = 'cristiano@gruporaval.com.br';

-- 4. Testar a função check_subscription_status
SELECT check_subscription_status('cristiano@gruporaval.com.br');

-- ============================================
-- RESULTADO ESPERADO:
-- ✅ access_allowed: true
-- ✅ status: trial
-- ✅ days_remaining: 15
-- ✅ is_trial: true
-- ============================================
