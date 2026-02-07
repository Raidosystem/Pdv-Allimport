-- ============================================
-- CORRIGIR FUNCIONÁRIOS MARCADOS COMO OWNER
-- ============================================
-- PROBLEMA: Victor, Jennifer e Cristiano estão como 'owner' 
-- mas são FUNCIONÁRIOS e devem ser 'employee'

BEGIN;

-- PASSO 1: Corrigir os 3 funcionários para 'employee'
UPDATE user_approvals
SET 
  user_role = 'employee',
  updated_at = NOW()
WHERE user_id IN (
  -- Victor
  '23be9919-4f06-48bc-8fb6-fbb46fac8280',
  -- Jennifer
  '06b9519a-9516-4044-adf8-bdcb5d089191',
  -- Cristiano (funcionário, não o dono)
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
)
AND user_role = 'owner';

-- PASSO 2: Verificar correção
SELECT 
  '✅ CORREÇÃO APLICADA' as resultado,
  ua.email,
  f.nome as nome_funcionario,
  ua.user_role as role_corrigida,
  func.nome as funcao,
  CASE 
    WHEN ua.user_role = 'employee' THEN '✅ CORRETO'
    ELSE '❌ AINDA INCORRETO'
  END as validacao
FROM user_approvals ua
LEFT JOIN funcionarios f ON f.user_id = ua.user_id
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE ua.user_id IN (
  '23be9919-4f06-48bc-8fb6-fbb46fac8280',
  '06b9519a-9516-4044-adf8-bdcb5d089191',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
)
ORDER BY f.nome;

-- PASSO 3: Confirmar que apenas o DONO é owner
SELECT 
  '👑 VERIFICAR OWNER VERDADEIRO' as info,
  au.email,
  ua.user_role,
  e.nome as empresa,
  CASE 
    WHEN au.email = 'assistenciaallimport10@gmail.com' AND ua.user_role = 'owner' 
    THEN '✅ CORRETO - É O DONO'
    WHEN au.email != 'assistenciaallimport10@gmail.com' AND ua.user_role = 'owner'
    THEN '❌ ERRO - FUNCIONÁRIO COMO OWNER'
    ELSE '✅ OK'
  END as validacao
FROM user_approvals ua
JOIN auth.users au ON au.id = ua.user_id
LEFT JOIN empresas e ON e.user_id = ua.user_id
WHERE ua.user_role = 'owner'
  AND e.email LIKE '%allimport%'
ORDER BY au.email;

COMMIT;

-- ============================================
-- RESULTADO ESPERADO:
-- ============================================
-- ✅ Victor: employee (Técnico)
-- ✅ Jennifer: employee (Vendedor)
-- ✅ Cristiano: employee (Administrador - função, não dono)
-- ✅ assistenciaallimport10@gmail.com: owner (ÚNICO)
-- ============================================

-- 🧪 TESTE NO SISTEMA:
-- 1. Logout completo
-- 2. Login: assistenciaallimport10@gmail.com
-- 3. Selecionar: Jennifer
-- 4. Verificar console: deve mostrar permissões limitadas (Vendedor)
-- 5. Selecionar: Victor
-- 6. Verificar console: deve mostrar permissões de Técnico
-- 7. Selecionar: Cristiano
-- 8. Verificar console: deve mostrar permissões de Administrador (função)
