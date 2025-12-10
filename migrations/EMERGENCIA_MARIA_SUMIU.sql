-- 🚨 EMERGÊNCIA: Maria Silva sumiu!

-- ✅ Passo 1: Ela ainda existe no banco?
SELECT 
  '1️⃣ MARIA NO BANCO?' as verificacao,
  id,
  empresa_id,
  nome,
  tipo_admin,
  status,
  created_at
FROM funcionarios
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Passo 2: O login dela ainda existe?
SELECT 
  '2️⃣ LOGIN DA MARIA?' as verificacao,
  id,
  funcionario_id,
  usuario,
  ativo,
  created_at
FROM login_funcionarios
WHERE funcionario_id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Passo 3: Ela aparece na query do frontend?
SELECT 
  '3️⃣ QUERY DO FRONTEND?' as verificacao,
  f.id,
  f.nome,
  f.status,
  f.tipo_admin,
  f.empresa_id
FROM funcionarios f
WHERE f.empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
  AND f.tipo_admin != 'admin_empresa'
ORDER BY f.nome;

-- ✅ Passo 4: Todos os funcionários da sua empresa
SELECT 
  '4️⃣ TODOS DA SUA EMPRESA?' as verificacao,
  id,
  nome,
  tipo_admin,
  status
FROM funcionarios
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY created_at DESC;

-- ✅ Passo 5: A função get_funcionario_empresa_id funciona?
SELECT 
  '5️⃣ FUNÇÃO FUNCIONA?' as verificacao,
  get_funcionario_empresa_id('96c36a45-3cf3-4e76-b291-c3a5475e02aa') as empresa_retornada,
  'f1726fcf-d23b-4cca-8079-39314ae56e00'::uuid as empresa_esperada,
  get_funcionario_empresa_id('96c36a45-3cf3-4e76-b291-c3a5475e02aa') = 'f1726fcf-d23b-4cca-8079-39314ae56e00'::uuid as sao_iguais;

-- ✅ Passo 6: Verificar se RLS está ativo
SELECT 
  '6️⃣ RLS ATIVO?' as verificacao,
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE tablename IN ('funcionarios', 'login_funcionarios')
  AND schemaname = 'public';

-- ✅ Passo 7: Ver as políticas RLS ativas
SELECT 
  '7️⃣ POLÍTICAS RLS?' as verificacao,
  tablename,
  policyname,
  cmd,
  qual as using_expression
FROM pg_policies
WHERE tablename IN ('funcionarios', 'login_funcionarios')
ORDER BY tablename, policyname;
