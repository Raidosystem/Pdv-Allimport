-- 🧪 TESTAR ESTRUTURA DE PERMISSÕES DA JENNIFER

-- Esta é a query SQL equivalente ao que o código TypeScript faz

SELECT 
  f.id as funcionario_id,
  f.nome as funcionario_nome,
  f.tipo_admin,
  f.funcao_id,
  
  -- Dados da função
  func.id as funcao_id,
  func.nome as funcao_nome,
  func.escopo_lojas,
  
  -- Permissões da função
  p.id as permissao_id,
  p.recurso,
  p.acao,
  p.descricao,
  
  -- Concatenar recurso:acao (formato usado no código)
  CONCAT(p.recurso, ':', p.acao) as permissao_completa
  
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Jennifer Sousa'
ORDER BY p.recurso, p.acao;

-- ====================================
-- RESUMO DAS PERMISSÕES DE JENNIFER
-- ====================================
SELECT 
  '📊 RESUMO' as info,
  f.nome,
  f.tipo_admin,
  func.nome as funcao,
  COUNT(DISTINCT p.id) as total_permissoes,
  STRING_AGG(DISTINCT CONCAT(p.recurso, ':', p.acao), ', ' ORDER BY CONCAT(p.recurso, ':', p.acao)) as lista_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Jennifer Sousa'
GROUP BY f.id, f.nome, f.tipo_admin, func.nome;
