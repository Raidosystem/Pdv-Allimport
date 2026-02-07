-- ============================================================================
-- BUSCAR TODOS OS 7 USUÁRIOS (incluindo o que está faltando)
-- ============================================================================

-- 1️⃣ Ver TODOS os usuários aprovados (sem limite)
SELECT 
  '📋 TODOS OS APROVADOS:' as info,
  email,
  full_name,
  company_name,
  status,
  user_role,
  created_at
FROM user_approvals
WHERE status = 'approved'
ORDER BY created_at DESC;

-- 2️⃣ Contar total de aprovados
SELECT 
  '📊 TOTAL APROVADOS:' as info,
  COUNT(*) as total
FROM user_approvals
WHERE status = 'approved';

-- 3️⃣ Ver se tem algum com user_role diferente de 'owner'
SELECT 
  '⚠️ APROVADOS MAS NÃO OWNER:' as info,
  email,
  status,
  user_role,
  created_at
FROM user_approvals
WHERE status = 'approved' AND (user_role != 'owner' OR user_role IS NULL);

-- 4️⃣ Verificar se smartcellinova existe com qualquer status
SELECT 
  '🔍 SMARTCELLINOVA (todos os status):' as info,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at
FROM user_approvals
WHERE email ILIKE '%smartcell%';

-- 5️⃣ Ver últimos 10 cadastros
SELECT 
  '📅 ÚLTIMOS 10 CADASTROS:' as info,
  email,
  status,
  user_role,
  created_at
FROM user_approvals
ORDER BY created_at DESC
LIMIT 10;
