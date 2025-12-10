-- =========================================
-- REMOVER DUPLICATAS DE PERMISSÕES DE CONFIGURAÇÕES
-- =========================================
-- Este script remove registros duplicados na tabela funcao_permissoes
-- mantendo apenas uma entrada por combinação funcao_id + permissao_id

-- Primeiro, vamos ver quantas duplicatas existem
SELECT 
  f.nome as funcao,
  p.recurso,
  p.acao,
  COUNT(*) as quantidade
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
GROUP BY f.nome, p.recurso, p.acao
HAVING COUNT(*) > 1
ORDER BY f.nome, p.recurso, p.acao;

-- Agora vamos remover as duplicatas, mantendo apenas o registro com o menor ID
DELETE FROM funcao_permissoes
WHERE id IN (
  SELECT fp2.id
  FROM funcao_permissoes fp1
  JOIN funcao_permissoes fp2 
    ON fp1.funcao_id = fp2.funcao_id 
    AND fp1.permissao_id = fp2.permissao_id
    AND fp1.empresa_id = fp2.empresa_id
    AND fp1.id < fp2.id  -- Mantém o registro com menor ID
  JOIN permissoes p ON p.id = fp1.permissao_id
  WHERE p.categoria = 'configuracoes'
);

-- Verificar se ainda existem duplicatas
SELECT 
  f.nome as funcao,
  p.recurso,
  p.acao,
  COUNT(*) as quantidade
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
GROUP BY f.nome, p.recurso, p.acao
HAVING COUNT(*) > 1
ORDER BY f.nome, p.recurso, p.acao;

-- Ver resultado final limpo
SELECT 
  f.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
  AND e.nome = 'Assistência All-Import'
ORDER BY f.nome, p.recurso, p.acao;
