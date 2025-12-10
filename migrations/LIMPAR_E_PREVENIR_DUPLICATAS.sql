-- =========================================
-- LIMPAR E PREVENIR DUPLICATAS (SOLUÇÃO DEFINITIVA)
-- =========================================

-- Passo 1: Ver quantas duplicatas temos
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

-- Passo 2: Deletar usando CTE (Common Table Expression) - Mantém o primeiro registro
WITH duplicatas AS (
  SELECT 
    fp.id,
    ROW_NUMBER() OVER (
      PARTITION BY fp.funcao_id, fp.permissao_id, fp.empresa_id 
      ORDER BY fp.created_at
    ) as row_num
  FROM funcao_permissoes fp
  JOIN permissoes p ON p.id = fp.permissao_id
  WHERE p.categoria = 'configuracoes'
)
DELETE FROM funcao_permissoes
WHERE id IN (
  SELECT id FROM duplicatas WHERE row_num > 1
);

-- Passo 3: Verificar se limpou
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

-- Passo 4: Criar constraint única para PREVENIR duplicatas futuras
-- Primeiro, verifica se a constraint já existe e a remove
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'funcao_permissoes_unique'
  ) THEN
    ALTER TABLE funcao_permissoes DROP CONSTRAINT funcao_permissoes_unique;
  END IF;
END $$;

-- Agora cria a constraint única
ALTER TABLE funcao_permissoes 
ADD CONSTRAINT funcao_permissoes_unique 
UNIQUE (funcao_id, permissao_id, empresa_id);

-- Passo 5: Contagem final por função
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

-- Passo 6: Ver detalhes finais (SEM duplicatas)
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
