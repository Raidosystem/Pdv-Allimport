-- ============================================
-- DEBUG: VERIFICAR POR QUE ADMIN PEDE PAGAMENTO
-- ============================================

-- 1. VERIFICAR ASSINATURA DO ADMIN
SELECT 
  '=== ASSINATURA DO ADMIN ===' as info,
  s.id,
  s.user_id,
  u.email,
  s.status,
  s.plan_type,
  s.subscription_start_date,
  s.subscription_end_date,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW())) as dias_restantes,
  (s.subscription_end_date > NOW()) as ainda_valida
FROM subscriptions s
JOIN auth.users u ON s.user_id = u.id
WHERE u.email = 'assistenciaallimport10@gmail.com';

-- 2. VERIFICAR SE ADMIN ESTÁ NA TABELA FUNCIONARIOS
SELECT 
  '=== ADMIN NA TABELA FUNCIONARIOS ===' as info,
  f.id,
  f.nome,
  f.email,
  f.empresa_id,
  f.status,
  f.tipo_admin
FROM funcionarios f
WHERE f.email = 'assistenciaallimport10@gmail.com';

-- 3. TESTAR FUNÇÃO check_subscription_status COM ADMIN
SELECT 
  '=== TESTE FUNÇÃO COM ADMIN ===' as info,
  check_subscription_status('assistenciaallimport10@gmail.com') as resultado;

-- 4. VERIFICAR USER_ID DO ADMIN NO AUTH
SELECT 
  '=== USER_ID DO ADMIN ===' as info,
  id,
  email,
  created_at
FROM auth.users
WHERE email = 'assistenciaallimport10@gmail.com';

-- 5. VERIFICAR SE TEM EMPRESA
SELECT 
  '=== EMPRESA DO ADMIN ===' as info,
  e.id,
  e.user_id,
  e.nome
FROM empresas e
JOIN auth.users u ON e.user_id = u.id
WHERE u.email = 'assistenciaallimport10@gmail.com';

-- ============================================
-- DIAGNÓSTICO
-- ============================================
-- 
-- POSSÍVEIS PROBLEMAS:
-- 1. Admin está na tabela funcionarios como 'ativo'
-- 2. Função detecta como funcionário e busca assinatura do empresa_id
-- 3. empresa_id pode estar diferente do user_id
-- 4. Assinatura não é encontrada
--
-- SOLUÇÃO:
-- Se admin (tipo_admin = 'admin_empresa') NÃO deve ser tratado como funcionário comum
-- Deve usar assinatura própria (user_id)
--
-- ============================================
