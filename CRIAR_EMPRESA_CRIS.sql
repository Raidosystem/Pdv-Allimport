-- ============================================
-- VERIFICAR E CRIAR EMPRESA PARA cris-ramos30@hotmail.com
-- ============================================

-- 1. Ver o seu user_id
SELECT 
  id as user_id,
  email,
  raw_user_meta_data->>'full_name' as nome_perfil,
  created_at
FROM auth.users
WHERE email = 'cris-ramos30@hotmail.com';

-- 2. Verificar se você tem empresa cadastrada
SELECT 
  e.id,
  e.nome,
  e.cnpj,
  e.email,
  e.user_id
FROM empresas e
WHERE e.user_id = (
  SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com'
);

-- 3. Se não existir, criar empresa para você
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
  u.id,
  'Assistência All-Import',  -- MUDE AQUI PARA O NOME DA SUA EMPRESA
  '11.111.111/0001-11',       -- MUDE AQUI PARA O CNPJ REAL
  '(11) 99999-9999',          -- MUDE AQUI PARA O TELEFONE REAL
  u.email,
  'Rua Exemplo, 123',
  'São Paulo',
  'SP',
  '00000-000'
FROM auth.users u
WHERE u.email = 'cris-ramos30@hotmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM empresas WHERE user_id = u.id
  );

-- 4. Verificar subscription
SELECT 
  s.id,
  s.user_id,
  s.plan_type,
  s.status,
  s.subscription_end_date
FROM subscriptions s
WHERE s.user_id = (
  SELECT id FROM auth.users WHERE email = 'cris-ramos30@hotmail.com'
);

-- 5. Se não existir subscription, criar
INSERT INTO subscriptions (
  user_id,
  plan_type,
  status,
  subscription_start_date,
  subscription_end_date
)
SELECT
  u.id,
  'yearly',
  'active',
  NOW(),
  NOW() + INTERVAL '1 year'
FROM auth.users u
WHERE u.email = 'cris-ramos30@hotmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM subscriptions WHERE user_id = u.id
  );

-- 6. RESULTADO FINAL - Verificar tudo criado
SELECT 
  u.email as usuario_email,
  e.nome as empresa_nome,
  e.cnpj,
  s.plan_type as plano,
  s.status,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW())) as dias_restantes
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE u.email = 'cris-ramos30@hotmail.com';
