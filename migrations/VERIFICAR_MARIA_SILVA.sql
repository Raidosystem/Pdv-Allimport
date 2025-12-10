-- 🔍 VERIFICAR SE MARIA SILVA FOI CRIADA CORRETAMENTE

-- 1️⃣ Verificar na tabela funcionarios
SELECT 
  id,
  empresa_id,
  nome,
  email,
  status,
  tipo_admin,
  created_at,
  user_id
FROM funcionarios
WHERE nome ILIKE '%maria%'
ORDER BY created_at DESC;

-- 2️⃣ Verificar na tabela login_funcionarios
SELECT 
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  lf.ultimo_acesso,
  lf.created_at,
  f.nome,
  f.empresa_id,
  f.tipo_admin
FROM login_funcionarios lf
LEFT JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.nome ILIKE '%maria%'
ORDER BY lf.created_at DESC;

-- 3️⃣ Verificar a empresa logada (assistenciaallimport10@gmail.com)
SELECT 
  id,
  email,
  nome_fantasia,
  created_at
FROM empresas
WHERE email = 'assistenciaallimport10@gmail.com';

-- 4️⃣ Verificar TODOS os funcionários (qualquer empresa) para debug
SELECT 
  f.id,
  f.empresa_id,
  f.nome,
  f.tipo_admin,
  f.status,
  lf.usuario,
  e.email as empresa_email
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
LEFT JOIN empresas e ON e.id = f.empresa_id
WHERE f.tipo_admin != 'admin_empresa' OR f.tipo_admin IS NULL
ORDER BY f.created_at DESC
LIMIT 20;

-- 5️⃣ Contar funcionários por empresa
SELECT 
  e.email as empresa_email,
  e.nome_fantasia,
  COUNT(f.id) as total_funcionarios
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id AND (f.tipo_admin != 'admin_empresa' OR f.tipo_admin IS NULL)
GROUP BY e.id, e.email, e.nome_fantasia
ORDER BY total_funcionarios DESC;
