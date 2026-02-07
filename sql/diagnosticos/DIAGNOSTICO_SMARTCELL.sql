-- ============================================================================
-- DIAGNOSTICAR smartcellinova@gmail.com
-- ============================================================================

-- 1️⃣ Buscar EXATAMENTE smartcellinova@gmail.com
SELECT 
  '🔍 SMARTCELLINOVA EXATO:' as info,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' THEN '✅ DEVERIA APARECER NO ADMIN'
    WHEN status != 'approved' THEN '❌ NÃO APROVADO (status: ' || status || ')'
    WHEN user_role != 'owner' THEN '❌ ROLE ERRADO (role: ' || COALESCE(user_role, 'NULL') || ')'
    ELSE '❓ VERIFICAR'
  END as diagnostico
FROM user_approvals
WHERE email = 'smartcellinova@gmail.com';

-- 2️⃣ Buscar com ILIKE (case insensitive, com variações)
SELECT 
  '🔍 SMARTCELL* (qualquer variação):' as info,
  email,
  status,
  user_role,
  email_verified,
  created_at
FROM user_approvals
WHERE email ILIKE '%smartcell%';

-- 3️⃣ Buscar em auth.users (pode estar lá mas não em user_approvals)
SELECT 
  '🔍 EM AUTH.USERS:' as info,
  email,
  email_confirmed_at,
  created_at
FROM auth.users
WHERE email ILIKE '%smartcell%';

-- 4️⃣ Ver assinatura se existir
SELECT 
  '💳 ASSINATURA:' as info,
  email,
  status,
  plan_type,
  trial_end_date
FROM subscriptions
WHERE email ILIKE '%smartcell%';

-- 5️⃣ Ver TODOS os emails cadastrados hoje
SELECT 
  '📅 TODOS CADASTROS DE HOJE:' as info,
  ua.email,
  ua.status,
  ua.user_role,
  ua.created_at,
  au.email_confirmed_at
FROM user_approvals ua
LEFT JOIN auth.users au ON ua.email = au.email
WHERE ua.created_at::DATE = CURRENT_DATE
ORDER BY ua.created_at DESC;

-- 6️⃣ Contar total em user_approvals vs auth.users
SELECT 
  '📊 TOTAIS:' as info,
  (SELECT COUNT(*) FROM user_approvals) as total_user_approvals,
  (SELECT COUNT(*) FROM auth.users) as total_auth_users,
  (SELECT COUNT(*) FROM user_approvals WHERE status = 'approved') as aprovados;
