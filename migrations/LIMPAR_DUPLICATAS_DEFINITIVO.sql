-- =========================================
-- LIMPAR DUPLICATAS DEFINITIVAMENTE
-- =========================================
-- Remove TODAS as duplicatas mantendo apenas 1 registro por funcao_id + permissao_id

-- Passo 1: Ver quantas duplicatas temos
SELECT 
  'Antes da limpeza' as momento,
  f.nome as funcao,
  p.recurso,
  p.acao,
  COUNT(*) as quantidade,
  array_agg(fp.id ORDER BY fp.id) as ids
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
GROUP BY f.nome, p.recurso, p.acao, fp.funcao_id, fp.permissao_id
HAVING COUNT(*) > 1
ORDER BY f.nome, p.recurso, p.acao;

-- Passo 2: Criar uma tabela temporária com apenas os IDs para manter (primeiro de cada grupo)
CREATE TEMP TABLE ids_para_manter AS
SELECT DISTINCT ON (fp.funcao_id, fp.permissao_id, fp.empresa_id) fp.id as id_manter
FROM funcao_permissoes fp
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
ORDER BY fp.funcao_id, fp.permissao_id, fp.empresa_id, fp.created_at;

-- Passo 3: Deletar todos os registros duplicados (mantendo apenas os IDs da tabela temporária)
DELETE FROM funcao_permissoes
WHERE id IN (
  SELECT fp.id
  FROM funcao_permissoes fp
  JOIN permissoes p ON p.id = fp.permissao_id
  WHERE p.categoria = 'configuracoes'
    AND fp.id NOT IN (SELECT id_manter FROM ids_para_manter)
);

-- Passo 4: Verificar se ainda há duplicatas
SELECT 
  'Depois da limpeza' as momento,
  f.nome as funcao,
  p.recurso,
  p.acao,
  COUNT(*) as quantidade
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
GROUP BY f.nome, p.recurso, p.acao, fp.funcao_id, fp.permissao_id
HAVING COUNT(*) > 1
ORDER BY f.nome, p.recurso, p.acao;

-- Passo 5: Resultado final limpo com contagem por função
SELECT 
  f.nome as funcao,
  COUNT(DISTINCT p.id) as total_permissoes_config
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
  AND e.nome = 'Assistência All-Import'
GROUP BY f.nome
ORDER BY f.nome;

-- Passo 6: Ver detalhes das permissões por função (sem duplicatas)
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
