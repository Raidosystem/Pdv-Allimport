-- ============================================================================
-- INVESTIGAR CADASTRO DE HOJE QUE NÃO APARECEU
-- ============================================================================

-- ============================================================================
-- 1️⃣ VER CADASTROS DE HOJE
-- ============================================================================

SELECT 
  '📅 CADASTROS DE HOJE:' as info,
  email,
  full_name,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' THEN '✅ Deveria aparecer no admin'
    WHEN status = 'pending' THEN '❌ PROBLEMA: Ainda está PENDING'
    WHEN status = 'approved' AND user_role != 'owner' THEN '❌ PROBLEMA: user_role errado (' || COALESCE(user_role, 'NULL') || ')'
    ELSE '⚠️ Situação inesperada'
  END as situacao
FROM user_approvals
WHERE DATE(created_at) = CURRENT_DATE
ORDER BY created_at DESC;

-- ============================================================================
-- 2️⃣ VER ÚLTIMO CADASTRO (MAIS RECENTE)
-- ============================================================================

SELECT 
  '🔍 ÚLTIMO CADASTRO (MAIS RECENTE):' as info,
  email,
  full_name,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at,
  AGE(NOW(), created_at) as tempo_desde_cadastro
FROM user_approvals
ORDER BY created_at DESC
LIMIT 1;

-- ============================================================================
-- 3️⃣ VERIFICAR SE TEM ASSINATURA CRIADA PARA O ÚLTIMO CADASTRO
-- ============================================================================

WITH ultimo_usuario AS (
  SELECT email FROM user_approvals ORDER BY created_at DESC LIMIT 1
)
SELECT 
  '💳 ASSINATURA DO ÚLTIMO CADASTRO:' as info,
  s.email,
  s.status,
  s.plan_type,
  s.trial_end_date,
  EXTRACT(DAY FROM (s.trial_end_date - NOW()))::INTEGER as dias_restantes,
  s.created_at,
  CASE 
    WHEN s.email IS NULL THEN '❌ ASSINATURA NÃO CRIADA!'
    ELSE '✅ Assinatura existe'
  END as situacao
FROM ultimo_usuario u
LEFT JOIN subscriptions s ON s.email = u.email;

-- ============================================================================
-- 4️⃣ DIAGNÓSTICO COMPLETO DO ÚLTIMO CADASTRO
-- ============================================================================

WITH ultimo AS (
  SELECT * FROM user_approvals ORDER BY created_at DESC LIMIT 1
)
SELECT 
  '🔍 DIAGNÓSTICO DETALHADO:' as diagnostico,
  u.email,
  u.full_name,
  u.status as status_approval,
  u.user_role,
  u.email_verified,
  u.approved_at,
  u.created_at,
  AGE(NOW(), u.created_at) as tempo_desde_cadastro,
  -- Verificar problemas
  CASE 
    WHEN u.status = 'pending' THEN 
      '❌ PROBLEMA 1: Status ainda é PENDING (não foi aprovado após verificar email)'
    WHEN u.status = 'approved' AND u.user_role IS NULL THEN
      '❌ PROBLEMA 2: user_role é NULL (deveria ser owner)'
    WHEN u.status = 'approved' AND u.user_role != 'owner' THEN
      '❌ PROBLEMA 3: user_role = "' || u.user_role || '" (deveria ser owner)'
    WHEN u.email_verified IS NULL OR u.email_verified = FALSE THEN
      '⚠️ Email não foi marcado como verificado'
    WHEN u.approved_at IS NULL THEN
      '⚠️ approved_at é NULL (não tem data de aprovação)'
    ELSE '✅ Dados parecem corretos'
  END as problema_identificado,
  -- Solução
  CASE 
    WHEN u.status = 'pending' THEN 
      'UPDATE user_approvals SET status = ''approved'', user_role = ''owner'', approved_at = NOW(), email_verified = TRUE WHERE email = ''' || u.email || ''';'
    WHEN u.user_role IS NULL OR u.user_role != 'owner' THEN
      'UPDATE user_approvals SET user_role = ''owner'' WHERE email = ''' || u.email || ''';'
    ELSE 'Nenhuma correção necessária'
  END as solucao_sql
FROM ultimo u;

-- ============================================================================
-- 5️⃣ VER SE O USUÁRIO ESTÁ NA TABELA auth.users
-- ============================================================================

WITH ultimo AS (
  SELECT * FROM user_approvals ORDER BY created_at DESC LIMIT 1
)
SELECT 
  '🔐 VERIFICAR SE EXISTE EM auth.users:' as info,
  u.email,
  au.id as user_id_auth,
  au.email as email_auth,
  au.email_confirmed_at,
  au.created_at as criado_em_auth,
  CASE 
    WHEN au.id IS NULL THEN '❌ NÃO EXISTE em auth.users!'
    WHEN au.email_confirmed_at IS NULL THEN '⚠️ Email não confirmado em auth.users'
    ELSE '✅ Existe e email confirmado'
  END as situacao
FROM ultimo u
LEFT JOIN auth.users au ON au.email = u.email;

-- ============================================================================
-- 6️⃣ COMPARAR: Quem aparece no admin vs último cadastro
-- ============================================================================

-- Lista quem aparece no admin
SELECT 
  '✅ USUÁRIOS QUE APARECEM NO ADMIN:' as info,
  email,
  full_name,
  created_at
FROM user_approvals
WHERE status = 'approved' 
  AND user_role = 'owner'
ORDER BY created_at DESC;

-- ============================================================================
-- 7️⃣ ESTATÍSTICAS DO DIA
-- ============================================================================

SELECT 
  '📊 ESTATÍSTICAS DE HOJE:' as info,
  COUNT(*) as total_cadastros_hoje,
  COUNT(CASE WHEN status = 'approved' THEN 1 END) as aprovados,
  COUNT(CASE WHEN status = 'pending' THEN 1 END) as pendentes,
  COUNT(CASE WHEN status = 'approved' AND user_role = 'owner' THEN 1 END) as aparecem_no_admin
FROM user_approvals
WHERE DATE(created_at) = CURRENT_DATE;
