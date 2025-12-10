-- ================================================
-- DEBUG: Verificar dados de usuários com teste
-- ================================================

-- 1. Usuário: cris-ramos1979@hotmail.com
SELECT 
  '=== CRISTIANE RAMOS ===' as debug,
  u.id as user_id,
  u.email,
  u.created_at as usuario_criado_em
FROM auth.users u
WHERE u.email = 'cris-ramos1979@hotmail.com';

-- Empresa
SELECT 
  'EMPRESA' as tipo,
  e.*
FROM empresas e
WHERE e.user_id = (SELECT id FROM auth.users WHERE email = 'cris-ramos1979@hotmail.com');

-- Subscription
SELECT 
  'SUBSCRIPTION' as tipo,
  s.*
FROM subscriptions s
WHERE s.user_id = (SELECT id FROM auth.users WHERE email = 'cris-ramos1979@hotmail.com');

-- User Approvals
SELECT 
  'USER_APPROVAL' as tipo,
  ua.*
FROM user_approvals ua
WHERE ua.email = 'cris-ramos1979@hotmail.com';

-- ================================================

-- 2. Usuário: jf6059256@gmail.com
SELECT 
  '=== JULIANO GOMES ===' as debug,
  u.id as user_id,
  u.email,
  u.created_at as usuario_criado_em
FROM auth.users u
WHERE u.email = 'jf6059256@gmail.com';

-- Empresa
SELECT 
  'EMPRESA' as tipo,
  e.*
FROM empresas e
WHERE e.user_id = (SELECT id FROM auth.users WHERE email = 'jf6059256@gmail.com');

-- Subscription
SELECT 
  'SUBSCRIPTION' as tipo,
  s.*
FROM subscriptions s
WHERE s.user_id = (SELECT id FROM auth.users WHERE email = 'jf6059256@gmail.com');

-- User Approvals
SELECT 
  'USER_APPROVAL' as tipo,
  ua.*
FROM user_approvals ua
WHERE ua.email = 'jf6059256@gmail.com';

-- ================================================
-- 3. VERIFICAR TODAS AS COLUNAS DA TABELA EMPRESAS
-- ================================================
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'empresas'
  AND table_schema = 'public'
ORDER BY ordinal_position;
