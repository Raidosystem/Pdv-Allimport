-- ========================================
-- VERIFICAR SE FUNCIONÁRIO FOI REALMENTE CRIADO
-- ========================================

-- Ver todos os funcionários criados recentemente
SELECT 
  id,
  empresa_id,
  nome,
  email,
  status,
  tipo_admin,
  created_at
FROM funcionarios
WHERE tipo_admin = 'funcionario'
ORDER BY created_at DESC
LIMIT 10;

-- Ver logins de funcionários
SELECT 
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  lf.created_at,
  f.nome
FROM login_funcionarios lf
LEFT JOIN funcionarios f ON f.id = lf.funcionario_id
ORDER BY lf.created_at DESC
LIMIT 10;

-- Ver funcionários COM login (JOIN completo)
SELECT 
  f.id,
  f.nome,
  f.empresa_id,
  f.status,
  f.tipo_admin,
  lf.usuario,
  lf.ativo as login_ativo,
  f.created_at
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.tipo_admin = 'funcionario'
ORDER BY f.created_at DESC;
