-- ============================================
-- VERIFICAR SE O DONO FOI CORRIGIDO POR ENGANO
-- ============================================

-- PASSO 1: Ver quem é o dono da empresa Allimport
SELECT 
  '🏢 DONO DA EMPRESA ALLIMPORT' as info,
  e.id as empresa_id,
  e.nome as nome_empresa,
  e.email as email_empresa,
  e.user_id as user_id_dono,
  au.email as email_auth_dono
FROM empresas e
JOIN auth.users au ON au.id = e.user_id
WHERE e.email LIKE '%allimport%';

-- PASSO 2: Ver o user_role do dono em user_approvals
SELECT 
  '👑 STATUS DO DONO EM user_approvals' as info,
  e.email as email_empresa,
  au.email as email_dono,
  ua.user_role as role_atual,
  CASE 
    WHEN ua.user_role = 'owner' THEN '✅ CORRETO'
    WHEN ua.user_role = 'employee' THEN '❌ ERRO - DONO VIROU EMPLOYEE'
    ELSE '⚠️ OUTRO VALOR'
  END as status
FROM empresas e
JOIN auth.users au ON au.id = e.user_id
LEFT JOIN user_approvals ua ON ua.user_id = e.user_id
WHERE e.email LIKE '%allimport%';

-- PASSO 3: Se o dono está como employee, CORRIGIR
UPDATE user_approvals
SET 
  user_role = 'owner',
  updated_at = NOW()
WHERE user_id IN (
  SELECT e.user_id 
  FROM empresas e 
  WHERE e.email LIKE '%allimport%'
)
AND user_role = 'employee';

-- PASSO 4: Verificar correção final
SELECT 
  '✅ VERIFICAÇÃO FINAL' as resultado,
  e.email as email_empresa,
  au.email as email_dono,
  ua.user_role as role_atual,
  CASE 
    WHEN ua.user_role = 'owner' THEN '✅ CORRETO - DONO É OWNER'
    ELSE '❌ AINDA INCORRETO'
  END as validacao
FROM empresas e
JOIN auth.users au ON au.id = e.user_id
LEFT JOIN user_approvals ua ON ua.user_id = e.user_id
WHERE e.email LIKE '%allimport%';
