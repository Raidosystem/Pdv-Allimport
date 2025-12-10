-- 🔍 DEBUG COMPLETO - Por que Maria Silva não aparece?

-- ✅ Passo 1: Verificar se Maria Silva existe no banco
SELECT 
  '1️⃣ MARIA SILVA NO BANCO:' as verificacao,
  f.id,
  f.empresa_id,
  f.nome,
  f.tipo_admin,
  f.status,
  f.created_at
FROM funcionarios f
WHERE f.nome ILIKE '%maria%'
ORDER BY f.created_at DESC;

-- ✅ Passo 2: Verificar o login dela
SELECT 
  '2️⃣ LOGIN DA MARIA SILVA:' as verificacao,
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  lf.created_at
FROM login_funcionarios lf
INNER JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.nome ILIKE '%maria%';

-- ✅ Passo 3: Verificar a empresa do admin logado
SELECT 
  '3️⃣ EMPRESA DO ADMIN LOGADO:' as verificacao,
  id as empresa_id,
  email,
  nome
FROM empresas
WHERE email = 'assistenciaallimport10@gmail.com';

-- ✅ Passo 4: Simular a query do frontend (EXATAMENTE como está no código)
-- ATENÇÃO: Esta query vai ser filtrada pelo RLS!
SELECT 
  '4️⃣ QUERY DO FRONTEND (com RLS):' as verificacao,
  f.id,
  f.nome,
  f.status,
  f.ultimo_acesso,
  f.tipo_admin,
  f.empresa_id,
  (SELECT json_agg(json_build_object('usuario', lf2.usuario))
   FROM login_funcionarios lf2 
   WHERE lf2.funcionario_id = f.id) as login_funcionarios
FROM funcionarios f
WHERE f.empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00' -- SEU empresa_id
  AND f.tipo_admin != 'admin_empresa'
ORDER BY f.nome;

-- ✅ Passo 5: Verificar TODOS os funcionários (sem filtro)
SELECT 
  '5️⃣ TODOS OS FUNCIONARIOS:' as verificacao,
  f.id,
  f.nome,
  f.empresa_id,
  f.tipo_admin,
  f.status,
  lf.usuario
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.tipo_admin != 'admin_empresa' OR f.tipo_admin IS NULL
ORDER BY f.created_at DESC
LIMIT 10;

-- ✅ Passo 6: Verificar as políticas RLS
SELECT 
  '6️⃣ POLÍTICAS RLS ATIVAS:' as verificacao,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('funcionarios', 'login_funcionarios')
ORDER BY tablename, policyname;
