-- SCRIPT SIMPLES PARA TESTAR COUNTDOWN
-- Altere o email abaixo para o seu email de teste

-- PASSO 1: Altere este email para o seu email de usuário
\set test_email 'admin@allimport.com'

-- PASSO 2: Execute este bloco para criar dados de teste
WITH user_data AS (
  SELECT id as user_id, email
  FROM auth.users 
  WHERE email = :'test_email'
  LIMIT 1
)
-- Inserir na tabela user_subscriptions
INSERT INTO user_subscriptions (
  user_id,
  email, 
  status,
  access_allowed,
  has_subscription,
  days_remaining,
  created_at,
  updated_at
)
SELECT 
  user_id,
  email,
  'active',
  true,
  true,
  25, -- 25 dias restantes para testar
  NOW() - INTERVAL '6 days', -- Criado há 6 dias
  NOW()
FROM user_data
ON CONFLICT (user_id) 
DO UPDATE SET
  status = 'active',
  access_allowed = true,
  has_subscription = true,
  days_remaining = 25,
  created_at = NOW() - INTERVAL '6 days',
  updated_at = NOW();

-- Inserir na tabela subscriptions
WITH user_data AS (
  SELECT id as user_id
  FROM auth.users 
  WHERE email = :'test_email'
  LIMIT 1
)
INSERT INTO subscriptions (
  user_id,
  status,
  plan_type,
  start_date,
  end_date,
  payment_method,
  amount_paid,
  created_at,
  updated_at
)
SELECT 
  user_id,
  'active',
  'monthly',
  NOW() - INTERVAL '6 days',
  NOW() + INTERVAL '25 days',
  'test',
  99.90,
  NOW() - INTERVAL '6 days',
  NOW()
FROM user_data
ON CONFLICT (user_id) 
DO UPDATE SET
  status = 'active',
  plan_type = 'monthly',
  start_date = NOW() - INTERVAL '6 days',
  end_date = NOW() + INTERVAL '25 days',
  updated_at = NOW();

-- PASSO 3: Verificar se funcionou
SELECT 
  'Status criado!' as resultado,
  us.email,
  us.status,
  us.days_remaining,
  s.plan_type
FROM user_subscriptions us
JOIN subscriptions s ON s.user_id = us.user_id
WHERE us.email = :'test_email';