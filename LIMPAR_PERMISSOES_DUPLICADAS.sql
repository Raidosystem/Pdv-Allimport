-- =====================================================
-- LIMPEZA FORÇADA DE PERMISSÕES DUPLICADAS
-- Remove TODAS as permissões sem categoria e recria
-- =====================================================

BEGIN;

-- 1. DELETAR permissões SEM categoria (antigas/órfãs)
DELETE FROM funcao_permissoes
WHERE permissao_id IN (
  SELECT id FROM permissoes WHERE categoria IS NULL
);

DELETE FROM permissoes
WHERE categoria IS NULL;

-- 2. DELETAR permissões duplicadas de DASHBOARD que estão em "Outros"
DELETE FROM funcao_permissoes
WHERE permissao_id IN (
  SELECT id FROM permissoes 
  WHERE recurso = 'dashboard' 
  AND categoria != 'dashboard'
);

DELETE FROM permissoes
WHERE recurso = 'dashboard' 
AND categoria != 'dashboard';

-- 3. DELETAR permissões duplicadas de CAIXA que estão em "Outros"
DELETE FROM funcao_permissoes
WHERE permissao_id IN (
  SELECT id FROM permissoes 
  WHERE recurso = 'caixa' 
  AND categoria != 'financeiro'
);

DELETE FROM permissoes
WHERE recurso = 'caixa' 
AND categoria != 'financeiro';

-- 4. DELETAR permissões duplicadas de ORDENS que estão em "Outros"
DELETE FROM funcao_permissoes
WHERE permissao_id IN (
  SELECT id FROM permissoes 
  WHERE recurso = 'ordens' 
  AND categoria != 'ordens'
);

DELETE FROM permissoes
WHERE recurso = 'ordens' 
AND categoria != 'ordens';

-- 5. Garantir que TODAS as permissões existentes tenham categoria
UPDATE permissoes
SET categoria = CASE
  WHEN recurso = 'dashboard' THEN 'dashboard'
  WHEN recurso = 'vendas' THEN 'vendas'
  WHEN recurso = 'produtos' THEN 'produtos'
  WHEN recurso = 'clientes' THEN 'clientes'
  WHEN recurso IN ('caixa', 'financeiro') THEN 'financeiro'
  WHEN recurso = 'ordens' THEN 'ordens'
  WHEN recurso = 'relatorios' THEN 'relatorios'
  WHEN recurso = 'configuracoes' THEN 'configuracoes'
  WHEN recurso LIKE 'administracao%' THEN 'administracao'
  ELSE 'outros'
END
WHERE categoria IS NULL;

-- 6. RECRIAR associações da função Administrador
DO $$
DECLARE
  v_funcao_id UUID;
  v_permissao_id UUID;
BEGIN
  -- Buscar ID da função Administrador
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE nome = 'Administrador'
  LIMIT 1;

  IF v_funcao_id IS NOT NULL THEN
    -- Remover todas as associações antigas
    DELETE FROM funcao_permissoes WHERE funcao_id = v_funcao_id;
    
    -- Associar TODAS as permissões à função Administrador
    FOR v_permissao_id IN
      SELECT id FROM permissoes
    LOOP
      INSERT INTO funcao_permissoes (funcao_id, permissao_id)
      VALUES (v_funcao_id, v_permissao_id)
      ON CONFLICT DO NOTHING;
    END LOOP;

    RAISE NOTICE 'Permissões atualizadas para função Administrador';
  ELSE
    RAISE NOTICE 'Função Administrador não encontrada';
  END IF;
END $$;

COMMIT;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Ver por categoria
SELECT 
  categoria as "Categoria",
  COUNT(*) as "Total"
FROM permissoes
GROUP BY categoria
ORDER BY 
  CASE categoria
    WHEN 'dashboard' THEN 1
    WHEN 'vendas' THEN 2
    WHEN 'produtos' THEN 3
    WHEN 'clientes' THEN 4
    WHEN 'financeiro' THEN 5
    WHEN 'ordens' THEN 6
    WHEN 'relatorios' THEN 7
    WHEN 'configuracoes' THEN 8
    WHEN 'administracao' THEN 9
    ELSE 10
  END;

-- Verificar se ainda existem duplicatas
SELECT 
  recurso,
  acao,
  COUNT(*) as duplicatas
FROM permissoes
GROUP BY recurso, acao
HAVING COUNT(*) > 1;

-- Verificar se ainda há permissões sem categoria
SELECT COUNT(*) as "Permissões sem categoria"
FROM permissoes
WHERE categoria IS NULL;

-- Total geral
SELECT COUNT(*) as "Total de Permissões" FROM permissoes;
