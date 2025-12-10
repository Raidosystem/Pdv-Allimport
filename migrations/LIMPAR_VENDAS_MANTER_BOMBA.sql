-- =====================================================
-- LIMPAR VENDAS - MANTER APENAS BOMBA ELÉTRICA
-- =====================================================
-- Este script deleta todas as vendas EXCETO a que contém
-- "BOMBA ELETRICA PARA GALÃO DE ÁGUA LEHMOX LEY-57"
-- =====================================================

-- 1. Primeiro, vamos identificar a venda que queremos manter
DO $$
DECLARE
  v_venda_id UUID;
  v_count_before_items INT;
  v_count_before_vendas INT;
  v_count_after_items INT;
  v_count_after_vendas INT;
  rec RECORD;
BEGIN
  
  RAISE NOTICE '========================================';
  RAISE NOTICE '🔍 IDENTIFICANDO VENDA DA BOMBA...';
  RAISE NOTICE '========================================';
  
  -- Contar vendas e itens antes
  SELECT COUNT(*) INTO v_count_before_vendas FROM vendas;
  SELECT COUNT(*) INTO v_count_before_items FROM vendas_itens;
  
  RAISE NOTICE '📊 Situação ANTES da limpeza:';
  RAISE NOTICE '   - Total de vendas: %', v_count_before_vendas;
  RAISE NOTICE '   - Total de itens: %', v_count_before_items;
  RAISE NOTICE '';
  
  -- Encontrar a venda que contém a bomba
  SELECT vi.venda_id INTO v_venda_id
  FROM vendas_itens vi
  JOIN produtos p ON p.id = vi.produto_id
  WHERE UPPER(p.nome) LIKE '%BOMBA%ELETRICA%GALAO%AGUA%LEHMOX%'
     OR UPPER(p.nome) LIKE '%BOMBA ELETRICA%'
  LIMIT 1;
  
  IF v_venda_id IS NULL THEN
    RAISE NOTICE '❌ ERRO: Não encontrei a venda da bomba!';
    RAISE NOTICE '⚠️  Buscando por nome similar...';
    
    -- Tentar busca mais ampla
    SELECT vi.venda_id INTO v_venda_id
    FROM vendas_itens vi
    JOIN produtos p ON p.id = vi.produto_id
    WHERE UPPER(p.nome) LIKE '%BOMBA%'
    LIMIT 1;
    
    IF v_venda_id IS NULL THEN
      RAISE EXCEPTION '❌ Não foi possível encontrar a venda da bomba. Abortando operação.';
    END IF;
  END IF;
  
  RAISE NOTICE '✅ Venda da bomba encontrada: %', v_venda_id;
  RAISE NOTICE '';
  
  -- Mostrar detalhes da venda que será mantida
  RAISE NOTICE '📦 Detalhes da venda que será MANTIDA:';
  FOR rec IN (
    SELECT 
      v.id,
      v.created_at,
      v.total,
      p.nome as produto,
      vi.quantidade,
      vi.preco_unitario
    FROM vendas v
    JOIN vendas_itens vi ON vi.venda_id = v.id
    JOIN produtos p ON p.id = vi.produto_id
    WHERE v.id = v_venda_id
  ) LOOP
    RAISE NOTICE '   ID: %', rec.id;
    RAISE NOTICE '   Data: %', rec.created_at;
    RAISE NOTICE '   Total: R$ %', rec.total;
    RAISE NOTICE '   Produto: %', rec.produto;
    RAISE NOTICE '   Quantidade: %', rec.quantidade;
    RAISE NOTICE '   Preço Unitário: R$ %', rec.preco_unitario;
  END LOOP;
  RAISE NOTICE '';
  
  RAISE NOTICE '========================================';
  RAISE NOTICE '🗑️  DELETANDO VENDAS INCOMPLETAS...';
  RAISE NOTICE '========================================';
  
  -- Deletar itens de vendas que NÃO são a bomba
  DELETE FROM vendas_itens
  WHERE venda_id != v_venda_id;
  
  GET DIAGNOSTICS v_count_after_items = ROW_COUNT;
  RAISE NOTICE '✅ Deletados % itens de vendas incompletas', v_count_after_items;
  
  -- Deletar vendas que NÃO são a bomba
  DELETE FROM vendas
  WHERE id != v_venda_id;
  
  GET DIAGNOSTICS v_count_after_vendas = ROW_COUNT;
  RAISE NOTICE '✅ Deletadas % vendas incompletas', v_count_after_vendas;
  RAISE NOTICE '';
  
  -- Contar o que sobrou
  SELECT COUNT(*) INTO v_count_after_vendas FROM vendas;
  SELECT COUNT(*) INTO v_count_after_items FROM vendas_itens;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE '📊 RESULTADO FINAL:';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ Vendas restantes: % (deve ser 1)', v_count_after_vendas;
  RAISE NOTICE '✅ Itens restantes: % (deve ser 1)', v_count_after_items;
  RAISE NOTICE '';
  
  IF v_count_after_vendas = 1 AND v_count_after_items = 1 THEN
    RAISE NOTICE '🎉 SUCESSO! Mantida apenas a venda da BOMBA ELÉTRICA';
  ELSE
    RAISE NOTICE '⚠️  ATENÇÃO: Resultado inesperado!';
  END IF;
  
  RAISE NOTICE '========================================';
  
END $$;

-- 2. Verificar o que ficou no banco
SELECT 
  v.id as venda_id,
  v.created_at as data_venda,
  v.total as valor_total,
  p.nome as produto,
  vi.quantidade,
  vi.preco_unitario,
  (vi.quantidade * vi.preco_unitario) as subtotal
FROM vendas v
JOIN vendas_itens vi ON vi.venda_id = v.id
JOIN produtos p ON p.id = vi.produto_id
ORDER BY v.created_at DESC;
