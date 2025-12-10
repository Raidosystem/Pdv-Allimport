-- =====================================================
-- DIAGNÓSTICO: PERMISSÕES DA JENNIFER
-- =====================================================

-- 1. VER DADOS DA JENNIFER
SELECT 
  '?? DADOS DA JENNIFER' as info,
  id,
  nome,
  email,
  funcao_id,
  empresa_id,
  tipo_admin
FROM funcionarios
WHERE nome = 'Jennifer';

-- 2. VER FUNÇÃO ATRIBUÍDA À JENNIFER
SELECT 
  '?? FUNÇÃO DA JENNIFER' as info,
  f.nome as funcao_nome,
  f.id as funcao_id,
  f.descricao,
  f.empresa_id
FROM funcionarios func
JOIN funcoes f ON func.funcao_id = f.id
WHERE func.nome = 'Jennifer';

-- 3. VER PERMISSÕES DA FUNÇÃO "VENDEDOR"
SELECT 
  '?? PERMISSÕES DA FUNÇÃO VENDEDOR' as info,
  COUNT(*) as total_permissoes,
  STRING_AGG(p.recurso || ':' || p.acao, ', ' ORDER BY p.recurso) as lista_permissoes
FROM funcoes f
JOIN funcao_permissoes fp ON f.id = fp.funcao_id
JOIN permissoes p ON fp.permissao_id = p.id
WHERE f.nome = 'Vendedor'
AND f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE nome = 'Jennifer' LIMIT 1);

-- 4. DETALHES DAS PERMISSÕES
SELECT 
  '?? DETALHES DAS PERMISSÕES' as info,
  p.recurso,
  p.acao,
  p.descricao,
  p.categoria
FROM funcoes f
JOIN funcao_permissoes fp ON f.id = fp.funcao_id
JOIN permissoes p ON fp.permissao_id = p.id
WHERE f.nome = 'Vendedor'
AND f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE nome = 'Jennifer' LIMIT 1)
ORDER BY p.recurso, p.acao;

-- 5. VERIFICAR SE HÁ MÚLTIPLAS FUNÇÕES PARA A JENNIFER
SELECT 
  '?? FUNÇÕES ASSOCIADAS' as info,
  f.nome as funcao,
  f.id as funcao_id,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcionarios func
JOIN funcionario_funcoes ff ON func.id = ff.funcionario_id
JOIN funcoes f ON ff.funcao_id = f.id
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
WHERE func.nome = 'Jennifer'
GROUP BY f.nome, f.id;

-- 6. COMPARAR COM FUNÇÃO CORRETA
-- Mostrar o que DEVERIA ter a função Vendedor
SELECT 
  '? O QUE A FUNÇÃO VENDEDOR DEVERIA TER' as info,
  p.recurso,
  p.acao,
  p.descricao
FROM permissoes p
WHERE 
  -- Vendas (create, read, update)
  (p.recurso = 'vendas' AND p.acao IN ('create', 'read', 'update'))
  -- Clientes (create, read, update)
  OR (p.recurso = 'clientes' AND p.acao IN ('create', 'read', 'update'))
  -- Produtos (create, read, update)
  OR (p.recurso = 'produtos' AND p.acao IN ('create', 'read', 'update'))
  -- Ordens de Serviço (create, read, update)
  OR (p.recurso = 'ordens' AND p.acao IN ('create', 'read', 'update'))
  -- Relatórios (somente read)
  OR (p.recurso = 'relatorios' AND p.acao = 'read')
  -- Caixa (somente read - sem sangria/suprimento)
  OR (p.recurso = 'caixa' AND p.acao = 'read')
  -- Configurações de impressora
  OR (p.recurso = 'configuracoes' AND p.acao IN ('print_settings'))
  -- Configurações de aparência
  OR (p.recurso = 'configuracoes' AND p.acao IN ('appearance'))
ORDER BY p.recurso, p.acao;

-- 7. COMPARAR O QUE TEM vs O QUE DEVERIA TER
WITH permissoes_atuais AS (
  SELECT p.recurso, p.acao
  FROM funcoes f
  JOIN funcao_permissoes fp ON f.id = fp.funcao_id
  JOIN permissoes p ON fp.permissao_id = p.id
  WHERE f.nome = 'Vendedor'
  AND f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE nome = 'Jennifer' LIMIT 1)
),
permissoes_corretas AS (
  SELECT p.recurso, p.acao
  FROM permissoes p
  WHERE 
    (p.recurso = 'vendas' AND p.acao IN ('create', 'read', 'update'))
    OR (p.recurso = 'clientes' AND p.acao IN ('create', 'read', 'update'))
    OR (p.recurso = 'produtos' AND p.acao IN ('create', 'read', 'update'))
    OR (p.recurso = 'ordens' AND p.acao IN ('create', 'read', 'update'))
    OR (p.recurso = 'relatorios' AND p.acao = 'read')
    OR (p.recurso = 'caixa' AND p.acao = 'read')
    OR (p.recurso = 'configuracoes' AND p.acao IN ('print_settings', 'appearance'))
)
SELECT 
  '?? COMPARAÇÃO' as info,
  COALESCE(pa.recurso, pc.recurso) as recurso,
  COALESCE(pa.acao, pc.acao) as acao,
  CASE 
    WHEN pa.recurso IS NOT NULL AND pc.recurso IS NOT NULL THEN '? CORRETO'
    WHEN pa.recurso IS NOT NULL AND pc.recurso IS NULL THEN '? EXTRA (não deveria ter)'
    WHEN pa.recurso IS NULL AND pc.recurso IS NOT NULL THEN '?? FALTANDO'
  END as status
FROM permissoes_atuais pa
FULL OUTER JOIN permissoes_corretas pc 
  ON pa.recurso = pc.recurso AND pa.acao = pc.acao
ORDER BY status, recurso, acao;

-- 8. RESUMO FINAL
SELECT 
  '?? RESUMO' as info,
  (SELECT COUNT(*) FROM funcao_permissoes fp 
   JOIN funcoes f ON fp.funcao_id = f.id 
   WHERE f.nome = 'Vendedor' 
   AND f.empresa_id = (SELECT empresa_id FROM funcionarios WHERE nome = 'Jennifer' LIMIT 1)
  ) as permissoes_atuais,
  (SELECT COUNT(*) FROM permissoes p
   WHERE 
     (p.recurso = 'vendas' AND p.acao IN ('create', 'read', 'update'))
     OR (p.recurso = 'clientes' AND p.acao IN ('create', 'read', 'update'))
     OR (p.recurso = 'produtos' AND p.acao IN ('create', 'read', 'update'))
     OR (p.recurso = 'ordens' AND p.acao IN ('create', 'read', 'update'))
     OR (p.recurso = 'relatorios' AND p.acao = 'read')
     OR (p.recurso = 'caixa' AND p.acao = 'read')
     OR (p.recurso = 'configuracoes' AND p.acao IN ('print_settings', 'appearance'))
  ) as permissoes_esperadas;
