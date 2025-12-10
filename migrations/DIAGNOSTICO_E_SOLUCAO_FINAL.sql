-- =========================================
-- DIAGNÓSTICO E SOLUÇÃO DEFINITIVA
-- =========================================

-- Passo 1: Ver estrutura da tabela funcao_permissoes
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- Passo 2: Ver todas as constraints existentes
SELECT 
  conname as constraint_name,
  contype as constraint_type
FROM pg_constraint
WHERE conrelid = 'funcao_permissoes'::regclass;

-- Passo 3: Contar total de registros de configurações
SELECT COUNT(*) as total_config
FROM funcao_permissoes fp
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes';

-- Passo 4: Ver quantos registros ÚNICOS deveríamos ter
SELECT COUNT(*) as total_unicos
FROM (
  SELECT DISTINCT funcao_id, permissao_id, empresa_id
  FROM funcao_permissoes fp
  JOIN permissoes p ON p.id = fp.permissao_id
  WHERE p.categoria = 'configuracoes'
) sub;

-- Passo 5: DELETAR DIRETO usando subquery (sem tabela temporária)
DELETE FROM funcao_permissoes fp
USING permissoes p
WHERE fp.permissao_id = p.id
  AND p.categoria = 'configuracoes'
  AND fp.id NOT IN (
    SELECT DISTINCT ON (fp2.funcao_id, fp2.permissao_id, fp2.empresa_id) fp2.id
    FROM funcao_permissoes fp2
    JOIN permissoes p2 ON p2.id = fp2.permissao_id
    WHERE p2.categoria = 'configuracoes'
    ORDER BY fp2.funcao_id, fp2.permissao_id, fp2.empresa_id, fp2.created_at
  );

-- Passo 6: Adicionar constraint única (se não existir)
DO $$
BEGIN
  -- Remove se existir
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'funcao_permissoes_unique'
  ) THEN
    ALTER TABLE funcao_permissoes DROP CONSTRAINT funcao_permissoes_unique;
  END IF;
  
  -- Adiciona novamente
  ALTER TABLE funcao_permissoes 
  ADD CONSTRAINT funcao_permissoes_unique 
  UNIQUE (funcao_id, permissao_id, empresa_id);
END $$;

-- Passo 7: Contar novamente após limpeza
SELECT COUNT(*) as total_config_apos_limpeza
FROM funcao_permissoes fp
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'configuracoes';

-- Passo 8: Verificar se ainda há duplicatas (NÃO deve retornar nada)
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

-- Passo 9: Resultado final limpo
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

-- Passo 10: Contagem por função
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
