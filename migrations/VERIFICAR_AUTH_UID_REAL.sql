-- 🔍 DESCOBRIR o que auth.uid() retorna no SQL Editor vs Frontend

-- ✅ 1. Verificar auth.uid() atual (SQL Editor)
SELECT 
  '🔍 SQL EDITOR' as contexto,
  auth.uid() as meu_auth_uid,
  'Este é o ID do usuário logado no SQL Editor' as descricao;

-- ✅ 2. Verificar se existe na tabela empresas
SELECT 
  '🔍 EXISTE EM EMPRESAS?' as teste,
  e.id as empresa_id,
  e.email,
  e.nome,
  CASE 
    WHEN e.id = auth.uid() THEN '✅ SIM - auth.uid() é empresa_id'
    ELSE '❌ NÃO - auth.uid() não é empresa_id'
  END as resultado
FROM empresas e
WHERE e.id = auth.uid();

-- ✅ 3. Verificar se existe na tabela funcionarios
SELECT 
  '🔍 EXISTE EM FUNCIONARIOS?' as teste,
  f.id as funcionario_id,
  f.user_id,
  f.nome,
  f.empresa_id,
  CASE 
    WHEN f.user_id = auth.uid() THEN '✅ SIM - auth.uid() é user_id de funcionário'
    WHEN f.id = auth.uid() THEN '✅ SIM - auth.uid() é id de funcionário'
    ELSE '❌ NÃO - auth.uid() não está em funcionarios'
  END as resultado
FROM funcionarios f
WHERE f.user_id = auth.uid() OR f.id = auth.uid();

-- ✅ 4. Verificar o que get_funcionario_empresa_id() retorna
SELECT 
  '🔍 GET_FUNCIONARIO_EMPRESA_ID()' as teste,
  get_funcionario_empresa_id(auth.uid()) as empresa_id_retornado;

-- ✅ 5. Ver TODOS os funcionários e suas relações
SELECT 
  '📋 TODOS OS FUNCIONARIOS' as status,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.empresa_id,
  f.user_id,
  f.tipo_admin,
  CASE 
    WHEN f.id = auth.uid() THEN '⭐ Este é você (por id)'
    WHEN f.user_id = auth.uid() THEN '⭐ Este é você (por user_id)'
    WHEN f.empresa_id = auth.uid() THEN '⭐ Você é a empresa dele'
    ELSE ''
  END as relacao_com_voce
FROM funcionarios f
ORDER BY f.created_at DESC;

-- ✅ 6. Ver TODAS as empresas
SELECT 
  '📋 TODAS AS EMPRESAS' as status,
  e.id as empresa_id,
  e.nome,
  e.email,
  CASE 
    WHEN e.id = auth.uid() THEN '⭐ Esta é você'
    ELSE ''
  END as relacao_com_voce
FROM empresas e
ORDER BY e.created_at DESC;

-- 📊 RESUMO FINAL
SELECT 
  '📊 RESUMO' as titulo,
  auth.uid() as seu_auth_uid,
  get_funcionario_empresa_id(auth.uid()) as sua_empresa_id,
  CASE 
    WHEN EXISTS (SELECT 1 FROM empresas WHERE id = auth.uid()) 
    THEN '✅ Você é ADMIN EMPRESA (auth.uid() = empresa_id)'
    WHEN EXISTS (SELECT 1 FROM funcionarios WHERE user_id = auth.uid())
    THEN '✅ Você é FUNCIONÁRIO (auth.uid() = user_id)'
    ELSE '⚠️ Situação desconhecida'
  END as seu_tipo;
