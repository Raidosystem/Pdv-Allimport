-- =========================================
-- VERIFICAR DUPLICATAS EM FUNÇÕES E PERMISSÕES
-- =========================================

-- 1. VERIFICAR FUNÇÕES DUPLICADAS POR EMPRESA
SELECT 
  empresa_id,
  nome,
  COUNT(*) as quantidade,
  STRING_AGG(id::text, ', ') as ids
FROM funcoes
GROUP BY empresa_id, nome
HAVING COUNT(*) > 1
ORDER BY empresa_id, nome;

-- 2. LISTAR TODAS AS FUNÇÕES DE UMA EMPRESA ESPECÍFICA
-- (Substitua o UUID pela empresa que deseja verificar)
SELECT 
  f.id,
  f.nome,
  f.descricao,
  f.empresa_id,
  e.nome as nome_empresa,
  f.created_at,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcoes f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
GROUP BY f.id, f.nome, f.descricao, f.empresa_id, e.nome, f.created_at
ORDER BY e.nome, f.nome;

-- 3. VERIFICAR PERMISSÕES DUPLICADAS
SELECT 
  recurso,
  acao,
  COUNT(*) as quantidade,
  STRING_AGG(id::text, ', ') as ids
FROM permissoes
GROUP BY recurso, acao
HAVING COUNT(*) > 1
ORDER BY recurso, acao;

-- 4. LISTAR TODAS AS PERMISSÕES
SELECT 
  p.id,
  p.categoria,
  p.recurso,
  p.acao,
  p.descricao,
  COUNT(fp.funcao_id) as usada_em_funcoes
FROM permissoes p
LEFT JOIN funcao_permissoes fp ON fp.permissao_id = p.id
GROUP BY p.id, p.categoria, p.recurso, p.acao, p.descricao
ORDER BY p.categoria, p.recurso, p.acao;

-- 5. VERIFICAR DUPLICATAS NA TABELA FUNCAO_PERMISSOES
SELECT 
  empresa_id,
  funcao_id,
  permissao_id,
  COUNT(*) as quantidade
FROM funcao_permissoes
GROUP BY empresa_id, funcao_id, permissao_id
HAVING COUNT(*) > 1
ORDER BY empresa_id, funcao_id, permissao_id;

-- 6. ESTATÍSTICAS GERAIS
SELECT 
  'Total de Empresas' as metrica,
  COUNT(DISTINCT id) as valor
FROM empresas
UNION ALL
SELECT 
  'Total de Funções' as metrica,
  COUNT(*) as valor
FROM funcoes
UNION ALL
SELECT 
  'Total de Permissões' as metrica,
  COUNT(*) as valor
FROM permissoes
UNION ALL
SELECT 
  'Total de Vínculos Função-Permissão' as metrica,
  COUNT(*) as valor
FROM funcao_permissoes;
