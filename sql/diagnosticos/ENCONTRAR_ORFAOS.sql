-- ============================================================================
-- ENCONTRAR OS 3 USUÁRIOS ÓRFÃOS (em auth.users mas não em user_approvals)
-- ============================================================================

-- 1️⃣ Listar os 3 usuários órfãos
SELECT 
  '⚠️ USUÁRIOS ÓRFÃOS (em auth.users mas NÃO em user_approvals):' as info,
  au.email,
  au.email_confirmed_at,
  au.created_at,
  CASE 
    WHEN au.email_confirmed_at IS NOT NULL THEN '✅ Email confirmado'
    ELSE '❌ Email não confirmado'
  END as status_confirmacao
FROM auth.users au
LEFT JOIN user_approvals ua ON au.email = ua.email
WHERE ua.email IS NULL
ORDER BY au.created_at DESC;

-- 2️⃣ Verificar se smartcellinova está entre os órfãos
SELECT 
  '🔍 SMARTCELLINOVA É UM ÓRFÃO?:' as info,
  au.email,
  au.id as user_id,
  au.email_confirmed_at,
  au.created_at,
  CASE 
    WHEN ua.email IS NULL THEN '❌ SIM! Está em auth.users mas NÃO em user_approvals'
    ELSE '✅ NÃO, está em ambas as tabelas'
  END as diagnostico
FROM auth.users au
LEFT JOIN user_approvals ua ON au.email = ua.email
WHERE au.email ILIKE '%smartcell%';

-- 3️⃣ Criar registro em user_approvals para os 3 órfãos
-- (Vamos preparar o INSERT mas NÃO executar ainda - você vai revisar primeiro)

SELECT 
  '📝 PREPARANDO INSERT PARA ÓRFÃOS:' as info,
  au.id as user_id,
  au.email,
  'owner' as user_role_sugerido,
  'approved' as status_sugerido,
  NOW() as approved_at_sugerido
FROM auth.users au
LEFT JOIN user_approvals ua ON au.email = ua.email
WHERE ua.email IS NULL;

-- 4️⃣ Ver se tem assinatura para os órfãos
SELECT 
  '💳 ASSINATURAS DOS ÓRFÃOS:' as info,
  s.email,
  s.status,
  s.plan_type,
  s.trial_end_date
FROM subscriptions s
WHERE s.email IN (
  SELECT au.email 
  FROM auth.users au
  LEFT JOIN user_approvals ua ON au.email = ua.email
  WHERE ua.email IS NULL
);
