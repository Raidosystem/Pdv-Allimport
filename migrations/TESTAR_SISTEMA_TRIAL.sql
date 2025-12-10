-- ============================================
-- TESTES COM USUÁRIO REAL
-- ============================================

-- 1. Verificar seu status atual
SELECT check_subscription_status('cris-ramos30@hotmail.com');

-- 2. Verificar status do cliente pago
SELECT check_subscription_status('assistenciaallimport10@gmail.com');

-- 3. Testar upgrade simulando que o cliente pago está em trial
-- Primeiro, vamos ver se ele ainda está em período de teste
SELECT 
  u.email,
  s.status,
  s.trial_end_date,
  s.subscription_end_date,
  CASE 
    WHEN s.status = 'trial' AND s.trial_end_date > NOW() THEN 
      EXTRACT(DAY FROM (s.trial_end_date - NOW()))::integer
    WHEN s.status = 'active' AND s.subscription_end_date > NOW() THEN
      EXTRACT(DAY FROM (s.subscription_end_date - NOW()))::integer
    ELSE 0
  END as dias_restantes
FROM auth.users u
JOIN subscriptions s ON s.user_id = u.id
WHERE u.email IN (
  'cris-ramos30@hotmail.com',
  'assistenciaallimport10@gmail.com',
  'novaradiosystem@outlook.com',
  'marcovalentim04@gmail.com'
);

-- ============================================
-- TESTE PRÁTICO: Criar usuário trial de verdade
-- ============================================

-- OPÇÃO 1: Se você tem um email secundário para testar
-- Substitua 'seu_email_teste@gmail.com' por um email real
-- Depois cadastre esse email no sistema e confirme o código

-- OPÇÃO 2: Simular criando registro manualmente
-- Criar usuário de teste diretamente (APENAS PARA TESTAR A FUNÇÃO)

-- Primeiro, deletar se já existe
DELETE FROM subscriptions WHERE user_id IN (
  SELECT id FROM auth.users WHERE email LIKE '%teste%'
);

-- ============================================
-- VERIFICAR SE A FUNÇÃO EXISTE
-- ============================================
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'activate_trial_for_new_user',
    'upgrade_to_paid_subscription',
    'check_subscription_status'
  );

-- ============================================
-- TESTE COM USUÁRIO EXISTENTE
-- ============================================

-- Ver todos os usuários e suas assinaturas
SELECT 
  u.id,
  u.email,
  s.status,
  s.plan_type,
  COALESCE(s.trial_end_date, s.subscription_end_date) as expira_em,
  CASE 
    WHEN s.status = 'trial' THEN '🎁 Teste'
    WHEN s.status = 'active' THEN '✅ Ativo'
    ELSE '❌ ' || s.status
  END as situacao
FROM auth.users u
LEFT JOIN subscriptions s ON s.user_id = u.id
ORDER BY u.created_at DESC;

-- ============================================
-- SIMULAR UPGRADE DO CLIENTE PAGO (EXEMPLO)
-- ============================================

-- Se o assistenciaallimport10 ainda tivesse dias de teste e fosse fazer upgrade:
-- (Não vai funcionar porque ele já está com assinatura ativa, mas mostra o conceito)
SELECT upgrade_to_paid_subscription(
  'assistenciaallimport10@gmail.com', 
  'yearly',  -- Plano anual
  99.90
);

-- ============================================
-- PARA TESTAR DE VERDADE A SOMA DE DIAS
-- ============================================

-- 1. Criar usuário trial manualmente (simular novo cadastro)
INSERT INTO subscriptions (
  user_id,
  status,
  plan_type,
  trial_start_date,
  trial_end_date,
  created_at,
  updated_at
)
SELECT 
  id,
  'trial',
  'free',
  NOW() - INTERVAL '5 days',  -- Simular que começou há 5 dias
  NOW() + INTERVAL '10 days',  -- Ainda tem 10 dias
  NOW(),
  NOW()
FROM auth.users 
WHERE email = 'novaradiosystem@outlook.com'
ON CONFLICT (user_id) DO UPDATE SET
  status = 'trial',
  plan_type = 'free',
  trial_start_date = NOW() - INTERVAL '5 days',
  trial_end_date = NOW() + INTERVAL '10 days',
  subscription_start_date = NULL,
  subscription_end_date = NULL,
  updated_at = NOW();

-- 2. Verificar status (deve mostrar ~10 dias de trial)
SELECT check_subscription_status('novaradiosystem@outlook.com');

-- 3. Fazer upgrade para mensal (vai somar 10 + 30 = 40 dias)
SELECT upgrade_to_paid_subscription(
  'novaradiosystem@outlook.com',
  'monthly',
  29.90
);

-- 4. Verificar resultado (deve mostrar ~40 dias de assinatura ativa)
SELECT check_subscription_status('novaradiosystem@outlook.com');

-- 5. Ver detalhes
SELECT 
  u.email,
  s.status,
  s.plan_type,
  s.subscription_end_date,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW()))::integer as dias_totais
FROM auth.users u
JOIN subscriptions s ON s.user_id = u.id
WHERE u.email = 'novaradiosystem@outlook.com';
