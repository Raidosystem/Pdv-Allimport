-- ============================================
-- CRIAR EMPRESA PARA O USUÁRIO LOGADO ATUAL
-- ============================================
-- Execute este script enquanto estiver logado com cris-ramos30@hotmail.com

-- 1. VERIFICAR SEU USER_ID ATUAL
SELECT 
  auth.uid() as meu_user_id,
  auth.email() as meu_email;

-- 2. VERIFICAR SE JÁ EXISTE EMPRESA PARA VOCÊ
SELECT 
  id,
  nome,
  user_id,
  created_at
FROM empresas
WHERE user_id = auth.uid();

-- 3. CRIAR EMPRESA PARA O USUÁRIO ATUAL (se não existir)
INSERT INTO empresas (
  user_id,
  nome,
  cnpj,
  telefone,
  email,
  endereco,
  cidade,
  estado,
  cep
)
SELECT
  auth.uid(),
  'Assistência All-Import',
  '00.000.000/0000-00',
  '(11) 99999-9999',
  'cris-ramos30@hotmail.com',
  'Rua Exemplo, 123',
  'São Paulo',
  'SP',
  '00000-000'
WHERE NOT EXISTS (
  SELECT 1 FROM empresas WHERE user_id = auth.uid()
);

-- 4. VERIFICAR SE FOI CRIADA
SELECT 
  id,
  nome,
  user_id,
  email,
  created_at
FROM empresas
WHERE user_id = auth.uid();

-- 5. CRIAR SUBSCRIPTION PARA O USUÁRIO ATUAL (se não existir)
INSERT INTO subscriptions (
  user_id,
  plan_type,
  status,
  subscription_start_date,
  subscription_end_date
)
SELECT
  auth.uid(),
  'yearly',
  'active',
  NOW(),
  NOW() + INTERVAL '1 year'
WHERE NOT EXISTS (
  SELECT 1 FROM subscriptions WHERE user_id = auth.uid()
);

-- 6. VERIFICAR SUBSCRIPTION
SELECT 
  id,
  user_id,
  plan_type,
  status,
  subscription_start_date,
  subscription_end_date
FROM subscriptions
WHERE user_id = auth.uid();

-- 7. RESULTADO FINAL - TUDO JUNTO
SELECT 
  e.id as empresa_id,
  e.nome as empresa_nome,
  e.email as empresa_email,
  s.plan_type as plano,
  s.status as status_assinatura,
  s.subscription_end_date as validade,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW())) as dias_restantes
FROM empresas e
LEFT JOIN subscriptions s ON s.user_id = e.user_id
WHERE e.user_id = auth.uid();
