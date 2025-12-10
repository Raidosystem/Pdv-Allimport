-- ============================================
-- INICIAR PERÍODO DE TESTE DE 30 DIAS
-- Execute para o seu usuário
-- ============================================

-- Verificar seu user_id primeiro
SELECT id, email FROM auth.users WHERE email LIKE '%@%' LIMIT 5;

-- Depois execute este (substitua YOUR_USER_ID pelo id retornado acima)
-- Ou execute direto com a subconsulta:

INSERT INTO subscriptions (
  user_id,
  status,
  plan_type,
  trial_start_date,
  trial_end_date,
  created_at,
  updated_at
)
VALUES (
  'c6864d69-a55c-4aca-8fe4-87841ac1084a', -- Seu user_id
  'trial',
  'free',
  NOW(), -- Início do teste: AGORA
  NOW() + INTERVAL '30 days', -- Fim do teste: daqui 30 dias
  NOW(),
  NOW()
)
ON CONFLICT (user_id) 
DO UPDATE SET
  status = 'trial',
  trial_start_date = NOW(),
  trial_end_date = NOW() + INTERVAL '30 days',
  updated_at = NOW();

-- ============================================
-- VERIFICAÇÃO
-- ============================================
SELECT 
  user_id,
  status,
  plan_type,
  trial_start_date,
  trial_end_date,
  EXTRACT(DAY FROM (trial_end_date - NOW())) as dias_restantes
FROM subscriptions
WHERE user_id = 'c6864d69-a55c-4aca-8fe4-87841ac1084a';
