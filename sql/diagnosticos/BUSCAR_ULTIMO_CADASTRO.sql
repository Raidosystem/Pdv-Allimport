-- ============================================================================
-- VERIFICAR E APROVAR smartcellinova@gmail.com
-- ============================================================================

-- 1️⃣ Buscar por smartcellinova (pode ter variação no email)
SELECT 
  '🔍 BUSCANDO SMARTCELL*:' as info,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at
FROM user_approvals
WHERE email ILIKE '%smartcell%' OR email ILIKE '%nova%';

-- 2️⃣ Ver TODOS os cadastros de hoje
SELECT 
  '📅 CADASTROS DE HOJE:' as info,
  email,
  status,
  user_role,
  email_verified,
  created_at
FROM user_approvals
WHERE created_at::DATE = CURRENT_DATE
ORDER BY created_at DESC;

-- 3️⃣ Ver últimos 3 cadastros (qualquer data)
SELECT 
  '📋 ÚLTIMOS 3 CADASTROS:' as info,
  email,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at
FROM user_approvals
ORDER BY created_at DESC
LIMIT 3;

-- 4️⃣ Ver quantos pending vs approved
SELECT 
  '📊 ESTATÍSTICAS:' as info,
  status,
  COUNT(*) as total
FROM user_approvals
GROUP BY status;

-- 5️⃣ Ver todos os PENDING (não aprovados ainda)
SELECT 
  '⚠️ USUÁRIOS PENDING (NÃO APROVADOS):' as info,
  email,
  status,
  user_role,
  email_verified,
  created_at
FROM user_approvals
WHERE status = 'pending'
ORDER BY created_at DESC;
