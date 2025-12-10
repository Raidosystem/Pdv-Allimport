-- =========================================
-- SOLUÇÃO RADICAL: DELETAR E REINSERIR (SEM DUPLICATAS)
-- =========================================

-- Passo 1: Ver estado atual (com duplicatas)
SELECT 
  f.nome as funcao,
  COUNT(*) as total_permissoes_config
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
  AND e.nome = 'Assistência All-Import'
GROUP BY f.nome
ORDER BY f.nome;

-- Passo 2: Criar tabela temporária com registros únicos (sem duplicatas)
CREATE TEMP TABLE permissoes_unicas AS
SELECT DISTINCT ON (fp.funcao_id, fp.permissao_id, fp.empresa_id)
  fp.funcao_id,
  fp.permissao_id,
  fp.empresa_id,
  fp.created_at
FROM funcao_permissoes fp
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
ORDER BY fp.funcao_id, fp.permissao_id, fp.empresa_id, fp.created_at;

-- Passo 3: Deletar TODAS as permissões de configurações
DELETE FROM funcao_permissoes
WHERE id IN (
  SELECT fp.id
  FROM funcao_permissoes fp
  JOIN permissoes p ON p.id = fp.permissao_id
  WHERE p.categoria = 'configuracoes'
);

-- Passo 4: Reinserir apenas os registros únicos
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id, created_at)
SELECT funcao_id, permissao_id, empresa_id, created_at
FROM permissoes_unicas;

-- Passo 5: Criar constraint única para PREVENIR duplicatas futuras
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'funcao_permissoes_unique'
  ) THEN
    ALTER TABLE funcao_permissoes DROP CONSTRAINT funcao_permissoes_unique;
  END IF;
END $$;

ALTER TABLE funcao_permissoes 
ADD CONSTRAINT funcao_permissoes_unique 
UNIQUE (funcao_id, permissao_id, empresa_id);

-- Passo 6: Verificar estado final (SEM duplicatas)
SELECT 
  f.nome as funcao,
  COUNT(*) as total_permissoes_config
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
JOIN funcao_permissoes fp ON fp.funcao_id = f.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
  AND e.nome = 'Assistência All-Import'
GROUP BY f.nome
ORDER BY f.nome;

-- Passo 7: Ver detalhes finais (cada linha deve aparecer UMA vez)
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

-- Passo 8: Verificação final - Esta query NÃO deve retornar nada
SELECT 
  f.nome as funcao,
  p.recurso,
  p.acao,
  COUNT(*) as quantidade
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes'
GROUP BY f.id, f.nome, p.id, p.recurso, p.acao
HAVING COUNT(*) > 1
ORDER BY f.nome, p.recurso, p.acao;
