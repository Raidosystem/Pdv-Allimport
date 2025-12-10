-- =====================================================
-- ?? CORREÇÃO DEFINITIVA - LIMPAR TABELA funcao_permissoes
-- =====================================================
-- O problema é que Jennifer tem permissões pela TABELA funcao_permissoes
-- e não pelo JSONB. Precisamos limpar a tabela!
-- =====================================================

BEGIN;

-- ============================================
-- 1?? IDENTIFICAR FUNÇÃO VENDEDOR
-- ============================================
DO $$
DECLARE
  v_empresa_id UUID;
  v_funcao_vendedor_id UUID;
  v_permissoes_antigas INT;
  v_permissoes_novas INT;
BEGIN
  -- Buscar empresa da Jennifer
  SELECT empresa_id INTO v_empresa_id
  FROM funcionarios
  WHERE nome = 'Jennifer'
  LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '? Jennifer não encontrada!';
  END IF;
  
  RAISE NOTICE '?? Empresa ID: %', v_empresa_id;
  
  -- Buscar função Vendedor
  SELECT id INTO v_funcao_vendedor_id
  FROM funcoes
  WHERE nome = 'Vendedor'
  AND empresa_id = v_empresa_id;
  
  IF v_funcao_vendedor_id IS NULL THEN
    RAISE EXCEPTION '? Função Vendedor não encontrada!';
  END IF;
  
  RAISE NOTICE '?? Função Vendedor ID: %', v_funcao_vendedor_id;
  
  -- Ver quantas permissões existem ANTES
  SELECT COUNT(*) INTO v_permissoes_antigas
  FROM funcao_permissoes
  WHERE funcao_id = v_funcao_vendedor_id;
  
  RAISE NOTICE '?? Permissões ANTES: %', v_permissoes_antigas;
  
  -- ============================================
  -- 2?? LIMPAR TODAS AS PERMISSÕES ANTIGAS
  -- ============================================
  DELETE FROM funcao_permissoes
  WHERE funcao_id = v_funcao_vendedor_id;
  
  RAISE NOTICE '??? Permissões antigas REMOVIDAS!';
  
  -- ============================================
  -- 3?? ADICIONAR APENAS PERMISSÕES CORRETAS
  -- ============================================
  -- VENDAS: read, create, update (SEM delete, SEM cancel, SEM refund)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'vendas' 
  AND p.acao IN ('read', 'create', 'update')
  ON CONFLICT DO NOTHING;
  
  -- CLIENTES: read, create, update (SEM delete)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'clientes' 
  AND p.acao IN ('read', 'create', 'update')
  ON CONFLICT DO NOTHING;
  
  -- PRODUTOS: read, update (SEM create, SEM delete, SEM manage_stock)
  INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
  SELECT v_funcao_vendedor_id, p.id, v_empresa_id
  FROM permissoes p
  WHERE p.recurso = 'produtos' 
  AND p.acao IN ('read', 'update')
  ON CONFLICT DO NOTHING;
  
  -- Ver quantas permissões foram adicionadas
  SELECT COUNT(*) INTO v_permissoes_novas
  FROM funcao_permissoes
  WHERE funcao_id = v_funcao_vendedor_id;
  
  RAISE NOTICE '? Permissões DEPOIS: %', v_permissoes_novas;
  RAISE NOTICE '?? CORREÇÃO CONCLUÍDA!';
  RAISE NOTICE '   Antes: % permissões', v_permissoes_antigas;
  RAISE NOTICE '   Depois: % permissões', v_permissoes_novas;
  RAISE NOTICE '   ';
  RAISE NOTICE '?? PERMISSÕES ADICIONADAS:';
  RAISE NOTICE '   - vendas: read, create, update';
  RAISE NOTICE '   - clientes: read, create, update';
  RAISE NOTICE '   - produtos: read, update';
  
END $$;

-- ============================================
-- 4?? VERIFICAR PERMISSÕES FINAIS
-- ============================================
SELECT 
  '?? VERIFICAÇÃO FINAL' as info,
  f.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Vendedor'
ORDER BY p.recurso, p.acao;

-- ============================================
-- 5?? CONTAR PERMISSÕES POR FUNÇÃO
-- ============================================
SELECT 
  '?? RESUMO POR FUNÇÃO' as info,
  f.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
WHERE f.nome IN ('Vendedor', 'Administrador', 'Gerente')
GROUP BY f.nome
ORDER BY f.nome;

COMMIT;

-- ============================================
-- ? RESULTADO ESPERADO
-- ============================================
-- 
-- Função Vendedor deve ter APENAS 8 permissões:
-- 1. vendas:read
-- 2. vendas:create
-- 3. vendas:update
-- 4. clientes:read
-- 5. clientes:create
-- 6. clientes:update
-- 7. produtos:read
-- 8. produtos:update
-- 
-- ? NÃO DEVE TER:
-- - caixa:* (nenhuma permissão de caixa)
-- - ordens:* (nenhuma permissão de OS)
-- - relatorios:* (nenhuma permissão de relatórios)
-- - vendas:delete, vendas:cancel, vendas:refund
-- - produtos:create, produtos:delete, produtos:manage_stock
-- - clientes:delete
-- 
-- ============================================
