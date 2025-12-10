-- ============================================
-- ATIVAR TRIAL SIMPLES - cristiano@gruporaval.com.br
-- ============================================

-- Inserir assinatura trial com user_id correto
INSERT INTO subscriptions (
  user_id,
  email,
  status,
  trial_end_date,
  created_at,
  updated_at
)
SELECT 
  id as user_id,
  email,
  'trial' as status,
  NOW() + INTERVAL '15 days' as trial_end_date,
  NOW() as created_at,
  NOW() as updated_at
FROM auth.users
WHERE email = 'cristiano@gruporaval.com.br'
ON CONFLICT (email) 
DO UPDATE SET
  user_id = EXCLUDED.user_id,
  status = 'trial',
  trial_end_date = NOW() + INTERVAL '15 days',
  updated_at = NOW();

-- Verificar se foi criado
SELECT 
  s.email,
  s.status,
  s.trial_end_date,
  EXTRACT(DAY FROM (s.trial_end_date - NOW())) as dias_restantes,
  s.trial_end_date > NOW() as trial_valido,
  u.id as user_id_existe
FROM subscriptions s
JOIN auth.users u ON u.email = s.email
WHERE s.email = 'cristiano@gruporaval.com.br';

-- Testar a função
SELECT check_subscription_status('cristiano@gruporaval.com.br');

-- ============================================
-- RESULTADO ESPERADO:
-- ✅ Linha inserida com sucesso
-- ✅ dias_restantes: 15
-- ✅ trial_valido: true
-- ✅ access_allowed: true no check_subscription_status
-- ============================================
