-- ============================================================================
-- DIAGNÓSTICO: POR QUE ÚLTIMO CADASTRO NÃO APARECE NO PAINEL ADMIN
-- ============================================================================

-- 1️⃣ VER ÚLTIMO CADASTRO NA TABELA user_approvals
SELECT 
  'ÚLTIMO CADASTRO EM user_approvals:' as info,
  user_id,
  email,
  full_name,
  status,
  user_role,
  email_verified,
  approved_at,
  created_at,
  CASE 
    WHEN status = 'approved' AND user_role = 'owner' THEN '✅ DEVE APARECER NO ADMIN'
    WHEN status = 'pending' THEN '❌ PENDENTE - não aparece no admin'
    WHEN user_role != 'owner' THEN '❌ NÃO É OWNER - não aparece no admin'
    ELSE '⚠️ VERIFICAR MOTIVO'
  END as motivo
FROM user_approvals
ORDER BY created_at DESC
LIMIT 5;

-- 2️⃣ VERIFICAR SE FUNÇÃO get_admin_subscribers RETORNA O USUÁRIO
-- Esta é a MESMA query que o painel admin usa
SELECT 
  'RESULTADO DA FUNÇÃO get_admin_subscribers():' as info,
  user_id,
  email,
  full_name,
  company_name,
  created_at,
  status,
  user_role
FROM user_approvals ua
WHERE ua.status = 'approved'
  AND ua.user_role = 'owner'
ORDER BY ua.created_at DESC
LIMIT 5;

-- 3️⃣ CONTAR TOTAIS POR STATUS E ROLE
SELECT 
  'TOTAIS:' as info,
  status,
  user_role,
  COUNT(*) as quantidade
FROM user_approvals
GROUP BY status, user_role
ORDER BY status, user_role;

-- 4️⃣ VERIFICAR SE HÁ USUÁRIOS PENDENTES QUE VERIFICARAM EMAIL
SELECT 
  '⚠️ USUÁRIOS QUE VERIFICARAM EMAIL MAS AINDA ESTÃO PENDENTES:' as alerta,
  email,
  full_name,
  status,
  email_verified,
  approved_at,
  created_at
FROM user_approvals
WHERE status = 'pending' 
  AND email_verified = TRUE
ORDER BY created_at DESC;

-- 5️⃣ VERIFICAR SE HÁ ASSINATURA CRIADA PARA O ÚLTIMO USUÁRIO
SELECT 
  'ASSINATURA DO ÚLTIMO USUÁRIO:' as info,
  s.email,
  s.status,
  s.plan_type,
  s.trial_end_date,
  EXTRACT(DAY FROM (s.trial_end_date - NOW()))::INTEGER as dias_restantes,
  s.created_at
FROM subscriptions s
ORDER BY s.created_at DESC
LIMIT 3;

-- 6️⃣ IDENTIFICAR O PROBLEMA ESPECÍFICO DO ÚLTIMO CADASTRO
WITH ultimo_usuario AS (
  SELECT * FROM user_approvals ORDER BY created_at DESC LIMIT 1
)
SELECT 
  '🔍 DIAGNÓSTICO DO ÚLTIMO USUÁRIO:' as diagnostico,
  u.email,
  u.status as status_approval,
  u.user_role,
  u.email_verified,
  u.approved_at,
  CASE 
    WHEN u.status != 'approved' THEN '❌ PROBLEMA: Status não é "approved" - precisa ser aprovado'
    WHEN u.user_role != 'owner' THEN '❌ PROBLEMA: user_role não é "owner" - deve ser owner'
    WHEN u.email_verified != TRUE THEN '⚠️ Email não verificado ainda'
    ELSE '✅ Deveria aparecer no admin - verificar função RPC'
  END as problema_identificado,
  CASE 
    WHEN u.status != 'approved' THEN 'Execute: UPDATE user_approvals SET status = ''approved'', approved_at = NOW() WHERE email = ''' || u.email || ''';'
    WHEN u.user_role != 'owner' THEN 'Execute: UPDATE user_approvals SET user_role = ''owner'' WHERE email = ''' || u.email || ''';'
    ELSE 'Usuário OK - deve aparecer no admin'
  END as solucao
FROM ultimo_usuario u;

-- 7️⃣ TESTAR MANUALMENTE A FUNÇÃO RPC (como super admin)
-- ⚠️ Substitua 'novaradiosystem@outlook.com' pelo email do super admin
SELECT 
  '🧪 TESTE DA FUNÇÃO get_admin_subscribers:' as teste,
  * 
FROM get_admin_subscribers()
ORDER BY created_at DESC
LIMIT 5;
