-- Verificar o usuário smartcellinova@gmail.com

-- 1. Ver dados em user_approvals
SELECT 
  '🔍 USER_APPROVALS:' as tabela,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at
FROM user_approvals
WHERE email = 'smartcellinova@gmail.com';

-- 2. Ver dados em subscriptions
SELECT 
  '💳 SUBSCRIPTIONS:' as tabela,
  email,
  status,
  plan_type,
  trial_end_date,
  created_at
FROM subscriptions
WHERE email = 'smartcellinova@gmail.com';

-- 3. Ver TODOS os usuários que deveriam aparecer no admin
SELECT 
  '📋 TODOS QUE DEVEM APARECER NO ADMIN:' as info,
  email,
  status,
  user_role,
  email_verified,
  approved_at
FROM user_approvals
WHERE status = 'approved' AND user_role = 'owner'
ORDER BY created_at DESC;

-- 4. Contar quantos usuários estão aprovados vs pending
SELECT 
  '📊 ESTATÍSTICAS:' as info,
  status,
  user_role,
  COUNT(*) as total
FROM user_approvals
GROUP BY status, user_role
ORDER BY status, user_role;

-- 5. Ver especificamente se smartcellinova está bloqueado
SELECT 
  '⚠️ DIAGNÓSTICO SMARTCELLINOVA:' as info,
  email,
  status,
  user_role,
  email_verified,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' 
    THEN '✅ DEVE APARECER NO ADMIN'
    WHEN status != 'approved'
    THEN '❌ NÃO APROVADO (status: ' || status || ')'
    WHEN user_role != 'owner'
    THEN '❌ ROLE INCORRETO (role: ' || COALESCE(user_role, 'NULL') || ')'
    ELSE '❓ MOTIVO DESCONHECIDO'
  END as diagnostico
FROM user_approvals
WHERE email = 'smartcellinova@gmail.com';
