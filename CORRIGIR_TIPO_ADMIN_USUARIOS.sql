-- ============================================
-- CORRIGIR TIPO_ADMIN PARA ADMIN_EMPRESA
-- ============================================
-- Todos os funcionários com função "Administrador" devem ser admin_empresa

-- 1. Atualizar tipo_admin para admin_empresa
UPDATE funcionarios f
SET tipo_admin = 'admin_empresa'
FROM funcionario_funcoes ff
JOIN funcoes func ON func.id = ff.funcao_id
WHERE ff.funcionario_id = f.id
  AND func.nome = 'Administrador'
  AND f.tipo_admin != 'admin_empresa';

-- 2. Verificar resultado
SELECT 
  u.email,
  f.nome as funcionario_nome,
  f.tipo_admin,
  func.nome as funcao_nome,
  CASE 
    WHEN f.tipo_admin = 'admin_empresa' THEN '✅ ADMIN EMPRESA'
    WHEN f.tipo_admin = 'super_admin' THEN '👑 SUPER ADMIN'
    ELSE '⚠️ FUNCIONÁRIO'
  END as status
FROM funcionarios f
JOIN auth.users u ON u.id = f.user_id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
ORDER BY u.email;

-- 3. Contar por tipo
SELECT 
  tipo_admin,
  COUNT(*) as total,
  CASE 
    WHEN tipo_admin = 'admin_empresa' THEN '✅ Admin da Empresa'
    WHEN tipo_admin = 'super_admin' THEN '👑 Super Admin'
    ELSE '👤 Funcionário'
  END as descricao
FROM funcionarios
GROUP BY tipo_admin
ORDER BY tipo_admin;
