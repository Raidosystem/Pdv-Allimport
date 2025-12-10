-- 🔍 DEBUG SIMPLES - Verificar Maria Silva

-- ✅ Passo 1: Maria Silva existe?
SELECT 
  id,
  empresa_id,
  nome,
  tipo_admin,
  status,
  email,
  created_at
FROM funcionarios
WHERE nome ILIKE '%maria%'
ORDER BY created_at DESC;

-- ✅ Passo 2: Login da Maria existe?
SELECT 
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  f.nome,
  f.empresa_id
FROM login_funcionarios lf
INNER JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.nome ILIKE '%maria%';

-- ✅ Passo 3: Qual é o empresa_id correto?
SELECT 
  id as empresa_id,
  email
FROM auth.users
WHERE email = 'assistenciaallimport10@gmail.com';

-- ✅ Passo 4: Todos os funcionários (sem filtro de empresa)
SELECT 
  f.id,
  f.nome,
  f.empresa_id,
  f.tipo_admin,
  f.status,
  lf.usuario,
  lf.ativo
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.tipo_admin = 'funcionario'
ORDER BY f.created_at DESC
LIMIT 20;
