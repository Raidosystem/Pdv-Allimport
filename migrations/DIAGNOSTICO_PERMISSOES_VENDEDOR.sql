-- =====================================================
-- ?? DIAGNÓSTICO - VER TODAS AS 26 PERMISSÕES DO VENDEDOR
-- =====================================================

-- Ver TODAS as permissões atuais do Vendedor
SELECT 
  '?? PERMISSÕES ATUAIS DO VENDEDOR' as info,
  f.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Vendedor'
ORDER BY p.recurso, p.acao;

-- Contar por recurso
SELECT 
  '?? PERMISSÕES POR RECURSO' as info,
  p.recurso,
  COUNT(*) as total
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Vendedor'
GROUP BY p.recurso
ORDER BY p.recurso;

-- Ver TODAS as ações disponíveis na tabela permissoes
SELECT 
  '?? AÇÕES DISPONÍVEIS POR RECURSO' as info,
  recurso,
  acao,
  descricao
FROM permissoes
WHERE recurso IN ('vendas', 'clientes', 'produtos')
ORDER BY recurso, acao;
