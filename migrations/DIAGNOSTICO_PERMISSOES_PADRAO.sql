-- =====================================================
-- DIAGNÓSTICO: Permissões Padrão das Funções
-- =====================================================

-- 1️⃣ VERIFICAR FUNÇÕES CADASTRADAS
SELECT 
  '1️⃣ FUNÇÕES EXISTENTES' as secao,
  id,
  nome,
  descricao,
  created_at
FROM funcoes
ORDER BY nome;

-- 2️⃣ VERIFICAR PERMISSÕES CADASTRADAS
SELECT 
  '2️⃣ PERMISSÕES POR CATEGORIA' as secao,
  categoria,
  COUNT(*) as total
FROM permissoes
GROUP BY categoria
ORDER BY categoria;

-- 3️⃣ VERIFICAR ASSOCIAÇÕES funcao_permissoes
SELECT 
  '3️⃣ PERMISSÕES ASSOCIADAS POR FUNÇÃO' as secao,
  f.nome as funcao,
  COUNT(fp.id) as total_permissoes
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
GROUP BY f.id, f.nome
ORDER BY f.nome;

-- 4️⃣ DETALHAR PERMISSÕES POR FUNÇÃO
SELECT 
  '4️⃣ DETALHE DAS PERMISSÕES' as secao,
  f.nome as funcao,
  p.categoria,
  p.recurso,
  p.acao
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
LEFT JOIN permissoes p ON fp.permissao_id = p.id
ORDER BY f.nome, p.categoria, p.recurso, p.acao;

-- 5️⃣ VERIFICAR FUNCIONÁRIOS E SUAS FUNÇÕES
SELECT 
  '5️⃣ FUNCIONÁRIOS E FUNÇÕES' as secao,
  func.nome as funcionario,
  func.email,
  f.nome as funcao_atribuida,
  COUNT(fp.id) as permissoes_disponiveis
FROM funcionarios func
LEFT JOIN funcoes f ON func.funcao_id = f.id
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
GROUP BY func.id, func.nome, func.email, f.nome
ORDER BY func.nome;

-- 6️⃣ VERIFICAR EMPRESAS
SELECT 
  '6️⃣ EMPRESAS CADASTRADAS' as secao,
  id,
  nome,
  user_id,
  created_at
FROM empresas
ORDER BY created_at;

-- 7️⃣ VERIFICAR SE funcao_permissoes TEM empresa_id
SELECT 
  '7️⃣ ESTRUTURA funcao_permissoes' as secao,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- 8️⃣ VERIFICAR RLS
SELECT 
  '8️⃣ POLÍTICAS RLS funcao_permissoes' as secao,
  policyname,
  permissive,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'funcao_permissoes';

-- =====================================================
-- 🎯 DIAGNÓSTICO COMPLETO
-- =====================================================

SELECT 
  '🎯 RESUMO DO DIAGNÓSTICO' as titulo,
  (SELECT COUNT(*) FROM funcoes) as total_funcoes,
  (SELECT COUNT(*) FROM permissoes) as total_permissoes,
  (SELECT COUNT(*) FROM funcao_permissoes) as total_associacoes,
  (SELECT COUNT(*) FROM funcionarios) as total_funcionarios,
  (SELECT COUNT(*) FROM empresas) as total_empresas;
