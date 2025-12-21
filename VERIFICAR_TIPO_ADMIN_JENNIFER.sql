-- ===================================================================
-- VERIFICAR TIPO_ADMIN QUE ESTÁ DANDO ACESSO TOTAL PARA JENNIFER
-- ===================================================================
-- PROBLEMA: Jennifer tem 35 permissões corretas, mas está conseguindo
-- acessar 100% do sistema porque tipo_admin='admin_empresa' dá bypass
-- no sistema de permissões (linha 708 do usePermissions.tsx)
--
-- EXECUTAR NO SQL EDITOR DO SUPABASE
-- ===================================================================

-- 1. Verificar tipo_admin atual
SELECT 
  f.nome,
  f.email,
  f.tipo_admin,
  u.user_role,
  CASE 
    WHEN f.tipo_admin = 'admin_empresa' THEN '❌ TEM ACESSO TOTAL (tipo_admin=admin_empresa)'
    WHEN f.tipo_admin = 'funcionario' THEN '✅ CORRETO (tipo_admin=funcionario)'
    ELSE '⚠️ VALOR DESCONHECIDO'
  END as status,
  CASE 
    WHEN f.tipo_admin = 'admin_empresa' THEN 'is_admin_empresa=TRUE → ACESSO TOTAL no can()'
    WHEN f.tipo_admin = 'funcionario' THEN 'is_admin_empresa=FALSE → Usa array de permissões'
    ELSE 'ERRO: Valor inesperado'
  END as comportamento_sistema
FROM funcionarios f
LEFT JOIN user_approvals u ON u.user_id = f.auth_user_id
WHERE f.empresa_id = 'a51f37c4-4e39-4cc3-a4dd-3c1f8ccef8c7'
AND f.email IN ('jennifer@allimport.com.br', 'cristiano@allimport.com.br', 'victor@allimport.com.br')
ORDER BY f.created_at;

-- 2. Ver quem é o primeiro funcionário (único que pode ter admin_empresa)
SELECT 
  nome,
  email,
  tipo_admin,
  created_at,
  CASE 
    WHEN created_at = (SELECT MIN(created_at) FROM funcionarios WHERE empresa_id = 'a51f37c4-4e39-4cc3-a4dd-3c1f8ccef8c7') 
    THEN '👑 PRIMEIRO FUNCIONÁRIO (pode ter admin_empresa)'
    ELSE '👤 Funcionário normal (deve ter tipo_admin=funcionario)'
  END as status
FROM funcionarios
WHERE empresa_id = 'a51f37c4-4e39-4cc3-a4dd-3c1f8ccef8c7'
ORDER BY created_at;
