-- ============================================
-- DIAGNOSTICAR FUNCIONÁRIOS COM PERMISSÕES DE OWNER
-- ============================================

-- PASSO 1: Ver TODOS os registros de user_approvals
SELECT 
  '📋 TODOS os user_approvals' as info,
  ua.email,
  ua.full_name,
  ua.user_role,
  ua.status,
  ua.created_at
FROM user_approvals ua
ORDER BY ua.created_at DESC;

-- PASSO 2: Verificar funcionários que estão em user_approvals
SELECT 
  '🔍 Funcionários cadastrados' as info,
  f.nome,
  f.email,
  f.user_id,
  f.empresa_id,
  au.email as email_auth,
  ua.user_role as role_em_approvals,
  ua.status as status_approval
FROM funcionarios f
LEFT JOIN auth.users au ON au.id = f.user_id
LEFT JOIN user_approvals ua ON ua.user_id = f.user_id
ORDER BY f.created_at DESC;

-- PASSO 3: Ver quem está marcado como OWNER em user_approvals
SELECT 
  '👑 Usuários marcados como OWNER' as info,
  ua.email,
  ua.full_name,
  ua.user_role,
  ua.status,
  CASE 
    WHEN EXISTS (SELECT 1 FROM funcionarios f WHERE f.user_id = ua.user_id) 
    THEN '⚠️ É FUNCIONÁRIO (ERRO!)'
    ELSE '✅ Não é funcionário'
  END as tipo_usuario
FROM user_approvals ua
WHERE ua.user_role = 'owner';

-- PASSO 4: Ver funcionários que NÃO deveriam ter user_role = 'owner'
SELECT 
  '🚨 FUNCIONÁRIOS MARCADOS COMO OWNER (ERRO CRÍTICO)' as alerta,
  f.nome,
  f.email,
  f.user_id,
  ua.user_role,
  e.nome as empresa
FROM funcionarios f
INNER JOIN user_approvals ua ON ua.user_id = f.user_id
LEFT JOIN empresas e ON e.id = f.empresa_id
WHERE ua.user_role = 'owner';

-- PASSO 5: Corrigir automaticamente (comentado por segurança)
-- DESCOMENTE APENAS SE CONFIRMAR QUE HÁ FUNCIONÁRIOS MARCADOS COMO OWNER

/*
UPDATE user_approvals ua
SET user_role = 'employee'
WHERE ua.user_role = 'owner'
  AND EXISTS (
    SELECT 1 FROM funcionarios f 
    WHERE f.user_id = ua.user_id
  );

SELECT '✅ Funcionários corrigidos para employee' as resultado;
*/
