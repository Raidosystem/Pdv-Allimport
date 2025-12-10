-- 🔍 VERIFICAR POR QUE RLS BLOQUEIA login_funcionarios

-- ✅ Passo 1: Verificar a política RLS atual
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual as using_expression,
  with_check
FROM pg_policies
WHERE tablename = 'login_funcionarios'
ORDER BY policyname;

-- ✅ Passo 2: Testar se o JOIN funciona
-- (Esta query vai ser bloqueada pelo RLS se a política estiver errada)
SELECT 
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo
FROM login_funcionarios lf
WHERE lf.funcionario_id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Passo 3: Verificar se o login da Maria existe (como superuser)
SELECT 
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  f.nome,
  f.empresa_id
FROM login_funcionarios lf
INNER JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE lf.funcionario_id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Passo 4: Testar query com IN (como o frontend faz)
SELECT 
  lf.funcionario_id,
  lf.usuario
FROM login_funcionarios lf
WHERE lf.funcionario_id IN ('96c36a45-3cf3-4e76-b291-c3a5475e02aa');
