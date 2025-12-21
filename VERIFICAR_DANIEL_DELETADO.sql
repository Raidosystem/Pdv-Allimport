-- ============================================
-- VERIFICAR SE DANIEL FOI DELETADO COMPLETAMENTE
-- ============================================

-- PASSO 1: Buscar emails que contenham "daniel"
SELECT 
  'auth.users' as tabela,
  email,
  id
FROM auth.users
WHERE email ILIKE '%daniel%';

-- PASSO 2: Verificar em user_approvals
SELECT 
  'user_approvals' as tabela,
  email,
  full_name,
  user_id
FROM user_approvals
WHERE email ILIKE '%daniel%' OR full_name ILIKE '%daniel%';

-- PASSO 3: Verificar em empresas
SELECT 
  'empresas' as tabela,
  email,
  nome,
  user_id
FROM empresas
WHERE email ILIKE '%daniel%' OR nome ILIKE '%daniel%';

-- PASSO 4: Verificar em subscriptions
SELECT 
  'subscriptions' as tabela,
  email,
  status,
  user_id
FROM subscriptions
WHERE email ILIKE '%daniel%';

-- PASSO 5: Verificar em funcionarios
SELECT 
  'funcionarios' as tabela,
  email,
  nome,
  user_id
FROM funcionarios
WHERE email ILIKE '%daniel%' OR nome ILIKE '%daniel%';

-- RESULTADO: Se NENHUMA query retornar registros = ✅ Deletado completamente
-- Se ALGUMA retornar registros = ❌ Ainda existem dados órfãos
