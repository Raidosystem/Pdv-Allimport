-- =====================================================
-- 🔍 VERIFICAR DADOS DO ADMIN DASHBOARD
-- =====================================================
-- Verificar se os dados estão corretos para cada empresa
-- =====================================================

-- =====================================================
-- 1️⃣ VER TODOS OS USUÁRIOS COM SUBSCRIPTIONS
-- =====================================================

SELECT 
  au.id as user_id,
  au.email,
  au.raw_user_meta_data->>'company_name' as company_name,
  au.raw_user_meta_data->>'full_name' as full_name,
  au.created_at as user_created_at,
  s.status as subscription_status,
  s.plan_type,
  s.trial_end_date,
  s.subscription_end_date,
  CASE 
    WHEN s.status = 'trial' AND s.trial_end_date IS NOT NULL THEN 
      GREATEST(0, EXTRACT(DAY FROM (s.trial_end_date - NOW())))
    WHEN s.status = 'active' AND s.subscription_end_date IS NOT NULL THEN 
      GREATEST(0, EXTRACT(DAY FROM (s.subscription_end_date - NOW())))
    ELSE 0
  END as days_remaining,
  e.nome as empresa_nome,
  e.id as empresa_id
FROM auth.users au
LEFT JOIN subscriptions s ON s.user_id = au.id
LEFT JOIN empresas e ON e.user_id = au.id
WHERE au.email NOT LIKE '%@supabase%'
ORDER BY au.created_at DESC;

-- =====================================================
-- 2️⃣ VERIFICAR user_approvals
-- =====================================================

SELECT 
  user_id,
  email,
  full_name,
  company_name,
  status,
  created_at
FROM user_approvals
ORDER BY created_at DESC;

-- =====================================================
-- 3️⃣ VERIFICAR EMPRESAS SEM SUBSCRIPTION
-- =====================================================

SELECT 
  '⚠️ Empresas sem subscription' as alerta,
  au.id as user_id,
  au.email,
  e.nome as empresa_nome,
  e.id as empresa_id
FROM auth.users au
INNER JOIN empresas e ON e.user_id = au.id
LEFT JOIN subscriptions s ON s.user_id = au.id
WHERE s.id IS NULL
  AND au.email NOT LIKE '%@supabase%';

-- =====================================================
-- 4️⃣ CRIAR SUBSCRIPTIONS FALTANTES (SE NECESSÁRIO)
-- =====================================================

-- Descomente e execute se encontrar usuários sem subscription
/*
INSERT INTO subscriptions (
  user_id,
  email,
  status,
  plan_type,
  trial_start_date,
  trial_end_date,
  created_at,
  updated_at
)
SELECT 
  au.id,
  au.email,
  'trial',
  'trial',
  NOW(),
  NOW() + INTERVAL '7 days',
  NOW(),
  NOW()
FROM auth.users au
INNER JOIN empresas e ON e.user_id = au.id
LEFT JOIN subscriptions s ON s.user_id = au.id
WHERE s.id IS NULL
  AND au.email NOT LIKE '%@supabase%'
ON CONFLICT (user_id) DO NOTHING;
*/

-- =====================================================
-- 5️⃣ VERIFICAR DADOS COMPLETOS PARA ADMIN DASHBOARD
-- =====================================================

SELECT 
  'Dados para Admin Dashboard' as info,
  COUNT(DISTINCT au.id) as total_usuarios,
  COUNT(DISTINCT e.id) as total_empresas,
  COUNT(DISTINCT s.id) as total_subscriptions,
  COUNT(DISTINCT CASE WHEN s.status = 'trial' THEN s.id END) as subscriptions_trial,
  COUNT(DISTINCT CASE WHEN s.status = 'active' THEN s.id END) as subscriptions_active,
  COUNT(DISTINCT CASE WHEN s.status = 'expired' THEN s.id END) as subscriptions_expired
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id
LEFT JOIN subscriptions s ON s.user_id = au.id
WHERE au.email NOT LIKE '%@supabase%';

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ Cada usuário deve ter:
--    - 1 registro em auth.users
--    - 1 registro em empresas
--    - 1 registro em subscriptions
-- ✅ Admin Dashboard deve mostrar dados corretos de cada empresa
-- =====================================================
