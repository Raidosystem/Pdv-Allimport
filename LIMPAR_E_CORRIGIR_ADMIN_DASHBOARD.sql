-- =====================================================
-- 🔧 LIMPAR DADOS E CORRIGIR ADMIN DASHBOARD
-- =====================================================
-- Remover usuários deletados e corrigir dados dos válidos
-- =====================================================

-- =====================================================
-- 1️⃣ REMOVER USUÁRIO DELETADO (E DADOS RELACIONADOS)
-- =====================================================

-- Deletar funcionários do usuário deletado
DELETE FROM funcionarios
WHERE empresa_id = '5e050793-d2f2-45ef-abbd-16d86f328c52';

-- Deletar empresa do usuário deletado
DELETE FROM empresas
WHERE id = '5e050793-d2f2-45ef-abbd-16d86f328c52';

-- Deletar user_approval do usuário deletado
DELETE FROM user_approvals
WHERE user_id = '5716d14d-4d2d-44e1-96e5-92c07503c263';

-- =====================================================
-- 2️⃣ CRIAR SUBSCRIPTIONS PARA USUÁRIOS VÁLIDOS
-- =====================================================

-- Criar subscription para quem não tem (apenas usuários válidos)
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
  AND au.email NOT LIKE '%DELETED%'
  AND au.email NOT LIKE '%@deleted.invalid'
ON CONFLICT (user_id) DO NOTHING;

-- =====================================================
-- 3️⃣ SINCRONIZAR user_approvals COM auth.users
-- =====================================================

INSERT INTO user_approvals (
  user_id,
  email,
  full_name,
  company_name,
  status,
  created_at,
  updated_at
)
SELECT 
  au.id,
  au.email,
  COALESCE(
    au.raw_user_meta_data->>'full_name',
    au.raw_user_meta_data->>'company_name',
    'Usuário ' || SPLIT_PART(au.email, '@', 1)
  ) as full_name,
  COALESCE(
    au.raw_user_meta_data->>'company_name',
    e.nome,
    'Empresa ' || SPLIT_PART(au.email, '@', 1)
  ) as company_name,
  'approved' as status,
  au.created_at,
  NOW()
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id
LEFT JOIN user_approvals ua ON ua.user_id = au.id
WHERE ua.user_id IS NULL
  AND au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
  AND au.email NOT LIKE '%@deleted.invalid'
ON CONFLICT (user_id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  company_name = EXCLUDED.company_name,
  updated_at = NOW();

-- =====================================================
-- 4️⃣ ATUALIZAR EMAIL NAS SUBSCRIPTIONS
-- =====================================================

UPDATE subscriptions s
SET email = au.email
FROM auth.users au
WHERE s.user_id = au.id
  AND (s.email IS NULL OR s.email = '');

-- =====================================================
-- 5️⃣ VERIFICAR RESULTADO FINAL
-- =====================================================

-- Ver todos os usuários VÁLIDOS com dados completos
SELECT 
  'Verificação Final' as status,
  au.id as user_id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'company_name', e.nome) as company_name,
  COALESCE(au.raw_user_meta_data->>'full_name', 'Sem nome') as full_name,
  s.status as subscription_status,
  s.plan_type,
  CASE 
    WHEN s.status = 'trial' AND s.trial_end_date IS NOT NULL THEN 
      GREATEST(0, EXTRACT(DAY FROM (s.trial_end_date - NOW())))
    WHEN s.status = 'active' AND s.subscription_end_date IS NOT NULL THEN 
      GREATEST(0, EXTRACT(DAY FROM (s.subscription_end_date - NOW())))
    ELSE 0
  END as days_remaining,
  e.nome as empresa_nome,
  CASE 
    WHEN s.id IS NULL THEN '❌ SEM SUBSCRIPTION'
    WHEN e.id IS NULL THEN '❌ SEM EMPRESA'
    ELSE '✅ COMPLETO'
  END as validacao
FROM auth.users au
LEFT JOIN subscriptions s ON s.user_id = au.id
LEFT JOIN empresas e ON e.user_id = au.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
  AND au.email NOT LIKE '%@deleted.invalid'
ORDER BY au.created_at DESC;

-- =====================================================
-- 6️⃣ ESTATÍSTICAS FINAIS (APENAS USUÁRIOS VÁLIDOS)
-- =====================================================

SELECT 
  '📊 Estatísticas Finais' as info,
  COUNT(DISTINCT au.id) as total_usuarios_validos,
  COUNT(DISTINCT e.id) as total_empresas,
  COUNT(DISTINCT s.id) as total_subscriptions,
  COUNT(DISTINCT ua.user_id) as total_user_approvals,
  COUNT(DISTINCT CASE WHEN s.status = 'trial' THEN s.id END) as subscriptions_trial,
  COUNT(DISTINCT CASE WHEN s.status = 'active' THEN s.id END) as subscriptions_active,
  COUNT(DISTINCT CASE WHEN s.status = 'expired' THEN s.id END) as subscriptions_expired
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id
LEFT JOIN subscriptions s ON s.user_id = au.id
LEFT JOIN user_approvals ua ON ua.user_id = au.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
  AND au.email NOT LIKE '%@deleted.invalid';

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ Usuário deletado removido
-- ✅ 4 usuários válidos com dados completos:
--    - 4 registros em auth.users
--    - 4 registros em empresas
--    - 4 registros em subscriptions
--    - 4 registros em user_approvals
-- ✅ Admin Dashboard deve mostrar 4 usuários corretos
-- =====================================================
