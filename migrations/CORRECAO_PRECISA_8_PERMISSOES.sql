-- =====================================================
-- ?? CORREÇÃO PRECISA - APENAS 8 PERMISSÕES ESPECÍFICAS
-- =====================================================
-- Vamos ser MUITO específicos sobre quais permissões adicionar
-- =====================================================

BEGIN;

DO $$
DECLARE
  v_empresa_id UUID;
  v_funcao_vendedor_id UUID;
  v_count INT;
BEGIN
  -- Buscar empresa da Jennifer
  SELECT empresa_id INTO v_empresa_id
  FROM funcionarios
  WHERE nome = 'Jennifer'
  LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '? Jennifer não encontrada!';
  END IF;
  
  -- Buscar função Vendedor
  SELECT id INTO v_funcao_vendedor_id
  FROM funcoes
  WHERE nome = 'Vendedor'
  AND empresa_id = v_empresa_id;
  
  IF v_funcao_vendedor_id IS NULL THEN
    RAISE EXCEPTION '? Função Vendedor não encontrada!';
  END IF;
  
  RAISE NOTICE '?? Empresa: %, Função: %', v_empresa_id, v_funcao_vendedor_id;
  
  -- ============================================
  -- 1?? DELETAR TUDO PRIMEIRO
  -- ============================================
  DELETE FROM funcao_permissoes
  WHERE funcao_id = v_funcao_vendedor_id;
  
  RAISE NOTICE '??? Todas permissões removidas';
  
  -- ============================================
  -- 2?? ADICIONAR APENAS AS 8 PERMISSÕES EXATAS
  -- ============================================
  
  -- 1. vendas:read
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'vendas' AND p.acao = 'read'
  LIMIT 1
  ON CONFLICT DO NOTHING;
  
  -- 2. vendas:create
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'vendas' AND p.acao = 'create'
  LIMIT 1
  ON CONFLICT DO NOTHING;
  
  -- 3. vendas:update
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'vendas' AND p.acao = 'update'
  LIMIT 1
  ON CONFLICT DO NOTHING;
  
  -- 4. clientes:read
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'clientes' AND p.acao = 'read'
  LIMIT 1
  ON CONFLICT DO NOTHING;
  
  -- 5. clientes:create
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'clientes' AND p.acao = 'create'
  LIMIT 1
  ON CONFLICT DO NOTHING;
  
  -- 6. clientes:update
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'clientes' AND p.acao = 'update'
  LIMIT 1
  ON CONFLICT DO NOTHING;
  
  -- 7. produtos:read
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'produtos' AND p.acao = 'read'
  LIMIT 1
  ON CONFLICT DO NOTHING;
  
  -- 8. produtos:update
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'produtos' AND p.acao = 'update'
  LIMIT 1
  ON CONFLICT DO NOTHING;
  
  -- Verificar total
  SELECT COUNT(*) INTO v_count
  FROM funcao_permissoes
  WHERE funcao_id = v_funcao_vendedor_id;
  
  RAISE NOTICE '? Total de permissões adicionadas: %', v_count;
  
  IF v_count <> 8 THEN
    RAISE WARNING '?? ATENÇÃO: Esperava 8 permissões, mas foram adicionadas %!', v_count;
    RAISE WARNING '?? Algumas permissões podem não existir na tabela permissoes';
  ELSE
    RAISE NOTICE '?? PERFEITO! 8 permissões adicionadas corretamente!';
  END IF;
  
END $$;

-- ============================================
-- 3?? VERIFICAR RESULTADO
-- ============================================
SELECT 
  '? VERIFICAÇÃO FINAL' as info,
  f.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Vendedor'
ORDER BY p.recurso, p.acao;

-- Contar total
SELECT 
  '?? TOTAL DE PERMISSÕES' as info,
  COUNT(*) as total
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
WHERE f.nome = 'Vendedor';

COMMIT;

-- ============================================
-- ?? SE AINDA NÃO FOR 8 PERMISSÕES
-- ============================================
-- Execute o DIAGNOSTICO_PERMISSOES_VENDEDOR.sql
-- para ver quais permissões estão sendo adicionadas
-- e quais estão faltando na tabela permissoes
-- ============================================
