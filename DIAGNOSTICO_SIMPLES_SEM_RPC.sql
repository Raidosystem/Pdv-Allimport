-- ============================================================================
-- DIAGNÓSTICO SIMPLIFICADO - SEM USAR FUNÇÃO RPC
-- ============================================================================
-- Este script NÃO usa get_admin_subscribers() que requer super admin
-- Usa queries diretas para diagnosticar o problema
-- ============================================================================

-- ✅ VERIFICAÇÃO 1: Ver qual email está logado no Supabase
SELECT 
  '🔐 USUÁRIO ATUAL:' as info,
  auth.uid() as user_id_logado,
  u.email as email_logado
FROM auth.users u
WHERE u.id = auth.uid();

-- ✅ VERIFICAÇÃO 2: Últimos cadastros na tabela user_approvals
SELECT 
  '📋 ÚLTIMOS 5 CADASTROS:' as info,
  email,
  full_name,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' THEN '✅ OK - deve aparecer'
    WHEN status = 'pending' THEN '❌ PENDENTE'
    WHEN user_role != 'owner' THEN '❌ NÃO É OWNER'
    ELSE '⚠️ VERIFICAR'
  END as situacao
FROM user_approvals
ORDER BY created_at DESC
LIMIT 5;

-- ✅ VERIFICAÇÃO 3: Quantos usuários por status
SELECT 
  '📊 TOTAIS POR STATUS:' as info,
  status,
  user_role,
  COUNT(*) as quantidade
FROM user_approvals
GROUP BY status, user_role
ORDER BY status, user_role;

-- ✅ VERIFICAÇÃO 4: Usuários que verificaram email mas estão pendentes
SELECT 
  '⚠️ PROBLEMA: Verificaram email mas ainda PENDENTES:' as alerta,
  email,
  full_name,
  status,
  email_verified,
  created_at
FROM user_approvals
WHERE status = 'pending' 
  AND (email_verified = TRUE OR email_verified IS NULL)
ORDER BY created_at DESC;

-- ✅ VERIFICAÇÃO 5: Último cadastro - diagnóstico completo
WITH ultimo AS (
  SELECT * FROM user_approvals ORDER BY created_at DESC LIMIT 1
)
SELECT 
  '🔍 ÚLTIMO CADASTRO:' as diagnostico,
  email,
  full_name,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at,
  CASE 
    WHEN status = 'pending' THEN 
      '❌ PROBLEMA: Status = pending (deveria ser approved após verificar email)'
    WHEN user_role != 'owner' THEN 
      '❌ PROBLEMA: user_role = ' || user_role || ' (deveria ser owner)'
    WHEN status = 'approved' AND user_role = 'owner' THEN 
      '✅ OK - Deveria aparecer no admin'
    ELSE '⚠️ Situação inesperada'
  END as problema,
  CASE 
    WHEN status = 'pending' THEN 
      'UPDATE user_approvals SET status = ''approved'', approved_at = NOW(), email_verified = TRUE WHERE email = ''' || email || ''';'
    ELSE 'Nenhuma ação necessária'
  END as solucao_sql
FROM ultimo;

-- ✅ VERIFICAÇÃO 6: Assinaturas criadas recentemente
SELECT 
  '📅 ÚLTIMAS ASSINATURAS CRIADAS:' as info,
  email,
  status,
  plan_type,
  trial_end_date,
  EXTRACT(DAY FROM (trial_end_date - NOW()))::INTEGER as dias_restantes,
  created_at
FROM subscriptions
ORDER BY created_at DESC
LIMIT 5;

-- ✅ VERIFICAÇÃO 7: Usuários APROVADOS (que aparecem no admin)
SELECT 
  '✅ USUÁRIOS QUE APARECEM NO ADMIN:' as info,
  email,
  full_name,
  status,
  user_role,
  approved_at,
  created_at
FROM user_approvals
WHERE status = 'approved' 
  AND user_role = 'owner'
ORDER BY created_at DESC
LIMIT 5;

-- ============================================================================
-- 📊 RESUMO DO PROBLEMA
-- ============================================================================

SELECT 
  '📊 RESUMO:' as tipo,
  (SELECT COUNT(*) FROM user_approvals) as total_usuarios,
  (SELECT COUNT(*) FROM user_approvals WHERE status = 'approved') as aprovados,
  (SELECT COUNT(*) FROM user_approvals WHERE status = 'pending') as pendentes,
  (SELECT COUNT(*) FROM user_approvals WHERE status = 'approved' AND user_role = 'owner') as aparecem_no_admin;
