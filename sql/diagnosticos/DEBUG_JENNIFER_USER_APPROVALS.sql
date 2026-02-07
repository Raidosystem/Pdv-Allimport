-- ===================================================================
-- DEBUG: VERIFICAR SE JENNIFER ESTÁ COMO OWNER EM USER_APPROVALS
-- ===================================================================
-- PROBLEMA: Jennifer tem acesso total ao sistema
-- CAUSA PROVÁVEL: user_role='owner' na tabela user_approvals
--
-- EXECUTAR NO SQL EDITOR DO SUPABASE
-- ===================================================================

SELECT 
  f.nome,
  f.email,
  f.auth_user_id,
  u.user_role,
  u.approved_at,
  CASE 
    WHEN u.user_role = 'owner' THEN '🚨 OWNER - TEM ACESSO TOTAL AO SISTEMA!'
    WHEN u.user_role = 'employee' THEN '✅ EMPLOYEE - Usa sistema de permissões'
    ELSE '⚠️ SEM REGISTRO em user_approvals'
  END as status_acesso,
  f.tipo_admin
FROM funcionarios f
LEFT JOIN user_approvals u ON u.user_id = f.auth_user_id
WHERE f.empresa_id = 'a51f37c4-4e39-4cc3-a4dd-3c1f8ccef8c7'
AND f.email IN ('jennifer@allimport.com.br', 'cristiano@allimport.com.br', 'victor@allimport.com.br')
ORDER BY f.created_at;

-- ===================================================================
-- EXPLICAÇÃO DO CÓDIGO (usePermissions.tsx linha 198-222):
-- ===================================================================
-- if (userApproval && userApproval.user_role === 'owner') {
--   // CRIA CONTEXTO COM is_admin_empresa: true
--   // IGNORA TODAS AS PERMISSÕES DA FUNÇÃO
--   // DÁ ACESSO TOTAL AO SISTEMA
-- }
--
-- SOLUÇÃO: Se Jennifer está como 'owner', precisa ser 'employee'
-- ===================================================================
