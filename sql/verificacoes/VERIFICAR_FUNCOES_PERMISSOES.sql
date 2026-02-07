-- =============================================
-- DIAGNÓSTICO: Verificar funções e suas permissões
-- =============================================

-- 1️⃣ LISTAR TODAS AS FUNÇÕES
SELECT 
  '🔍 FUNÇÕES CADASTRADAS' as info,
  id,
  nome,
  descricao,
  empresa_id,
  created_at
FROM funcoes
ORDER BY nome;

-- 2️⃣ VERIFICAR PERMISSÕES DA FUNÇÃO "TÉCNICO"
SELECT 
  '🔍 PERMISSÕES DA FUNÇÃO TÉCNICO' as info,
  COUNT(*) as total_permissoes
FROM funcao_permissoes fp
INNER JOIN funcoes f ON f.id = fp.funcao_id
WHERE f.nome = 'Técnico';

-- 3️⃣ VERIFICAR TODAS AS PERMISSÕES DISPONÍVEIS
SELECT 
  '📋 PERMISSÕES DISPONÍVEIS NO SISTEMA' as info,
  modulo,
  acao,
  modulo || ':' || acao as permissao_completa
FROM permissoes
ORDER BY modulo, acao;

-- 4️⃣ VERIFICAR FUNCIONÁRIO VICTOR
SELECT 
  '👤 FUNCIONÁRIO VICTOR' as info,
  f.id,
  f.nome,
  f.funcao_id,
  func.nome as funcao_nome,
  f.usuario_ativo,
  f.senha_definida
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.nome = 'Victor';

-- 5️⃣ CONTAR PERMISSÕES POR FUNÇÃO
SELECT 
  '📊 RESUMO PERMISSÕES POR FUNÇÃO' as info,
  f.nome as funcao,
  COUNT(fp.id) as total_permissoes
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
GROUP BY f.id, f.nome
ORDER BY f.nome;

SELECT '✅ Diagnóstico completo!' as resultado;
