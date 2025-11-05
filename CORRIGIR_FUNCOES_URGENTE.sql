-- ============================================================================
-- CORREÇÃO URGENTE: Funções SQL com nomes de colunas errados
-- ============================================================================
-- EXECUTE ESTE SCRIPT NO SUPABASE PARA CORRIGIR OS RELATÓRIOS
-- ============================================================================

-- 1️⃣ CORRIGIR FUNÇÃO fn_calcular_dre
-- Problema: Usa "total_amount" mas a coluna é "total"
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_calcular_dre(
  p_data_inicio timestamp with time zone,
  p_data_fim timestamp with time zone,
  p_user_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_result jsonb;
  v_receita_bruta numeric := 0;
  v_descontos numeric := 0;
  v_cmv numeric := 0;
  v_despesas_operacionais numeric := 0;
BEGIN
  -- RECEITA BRUTA (soma do campo "total" da tabela vendas)
  SELECT COALESCE(SUM(v.total), 0)
  INTO v_receita_bruta
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND v.status = 'completed'
    AND (p_user_id IS NULL OR v.user_id = p_user_id);

  -- DESCONTOS (soma do campo "desconto" da tabela vendas)
  SELECT COALESCE(SUM(v.desconto), 0)
  INTO v_descontos
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND v.status = 'completed'
    AND (p_user_id IS NULL OR v.user_id = p_user_id);

  -- CMV (Custo da Mercadoria Vendida) - soma dos custos dos itens vendidos
  SELECT COALESCE(SUM(vi.custo_medio_na_venda * vi.quantidade), 0)
  INTO v_cmv
  FROM vendas_itens vi
  INNER JOIN vendas v ON v.id = vi.venda_id
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND v.status = 'completed'
    AND (p_user_id IS NULL OR v.user_id = p_user_id);

  -- DESPESAS OPERACIONAIS (movimentações de caixa do tipo "saida")
  SELECT COALESCE(SUM(mc.valor), 0)
  INTO v_despesas_operacionais
  FROM movimentacoes_caixa mc
  WHERE mc.created_at >= p_data_inicio
    AND mc.created_at <= p_data_fim
    AND mc.tipo = 'saida'
    AND (p_user_id IS NULL OR mc.user_id = p_user_id);

  -- CÁLCULOS DRE
  v_result := jsonb_build_object(
    'receita_bruta', v_receita_bruta,
    'descontos', v_descontos,
    'receita_liquida', v_receita_bruta - v_descontos,
    'cmv', v_cmv,
    'lucro_bruto', (v_receita_bruta - v_descontos) - v_cmv,
    'despesas_operacionais', v_despesas_operacionais,
    'lucro_liquido', ((v_receita_bruta - v_descontos) - v_cmv) - v_despesas_operacionais,
    'margem_liquida', CASE 
      WHEN (v_receita_bruta - v_descontos) > 0 
      THEN ROUND((((v_receita_bruta - v_descontos) - v_cmv - v_despesas_operacionais) / (v_receita_bruta - v_descontos)) * 100, 2)
      ELSE 0 
    END
  );

  RETURN v_result;
END;
$$;

-- ============================================================================
-- 2️⃣ CORRIGIR FUNÇÃO fn_aplicar_venda
-- Problema: Usa "sale_items" mas a tabela é "vendas_itens"
-- IMPORTANTE: Remover função antiga primeiro para mudar o tipo de retorno
-- ============================================================================

-- Remover a função antiga
DROP FUNCTION IF EXISTS fn_aplicar_venda(uuid);

-- Recriar a função corrigida
CREATE OR REPLACE FUNCTION fn_aplicar_venda(p_venda_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  v_item record;
  v_produto record;
  v_estoque_atual numeric;
  v_custo_medio numeric;
  v_resultado jsonb;
BEGIN
  -- Validar se a venda existe
  IF NOT EXISTS (SELECT 1 FROM vendas WHERE id = p_venda_id) THEN
    RAISE EXCEPTION 'Venda não encontrada: %', p_venda_id;
  END IF;

  -- Processar cada item da venda
  FOR v_item IN 
    SELECT vi.*, p.nome, p.estoque, p.preco_custo
    FROM vendas_itens vi  -- CORRIGIDO: era "sale_items"
    INNER JOIN produtos p ON p.id = vi.produto_id
    WHERE vi.venda_id = p_venda_id
  LOOP
    -- Verificar estoque disponível
    v_estoque_atual := COALESCE(v_item.estoque, 0);
    
    IF v_estoque_atual < v_item.quantidade THEN
      RAISE EXCEPTION 'Estoque insuficiente para o produto % (disponível: %, necessário: %)', 
        v_item.produto_id, v_estoque_atual, v_item.quantidade;
    END IF;

    -- Calcular custo médio
    v_custo_medio := COALESCE(v_item.preco_custo, 0);

    -- Atualizar estoque do produto
    UPDATE produtos
    SET estoque = estoque - v_item.quantidade,
        updated_at = now()
    WHERE id = v_item.produto_id;

    -- Atualizar custo médio no item da venda (para DRE)
    UPDATE vendas_itens  -- CORRIGIDO: era "sale_items"
    SET custo_medio_na_venda = v_custo_medio
    WHERE id = v_item.id;

    RAISE NOTICE 'Produto % atualizado: estoque reduzido em % unidades', v_item.nome, v_item.quantidade;
  END LOOP;

  v_resultado := jsonb_build_object(
    'success', true,
    'venda_id', p_venda_id,
    'message', 'Venda aplicada com sucesso'
  );

  RETURN v_resultado;

EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Erro ao aplicar venda: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 3️⃣ VERIFICAR SE A COLUNA custo_medio_na_venda EXISTE
-- Se não existir, criar
-- ============================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas_itens' 
    AND column_name = 'custo_medio_na_venda'
  ) THEN
    ALTER TABLE vendas_itens 
    ADD COLUMN custo_medio_na_venda numeric(10,2) DEFAULT 0;
    
    RAISE NOTICE '✅ Coluna custo_medio_na_venda criada na tabela vendas_itens';
  ELSE
    RAISE NOTICE '✅ Coluna custo_medio_na_venda já existe';
  END IF;
END $$;

-- ============================================================================
-- 4️⃣ VERIFICAR ESTRUTURA DA TABELA CAIXA
-- ============================================================================

SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'caixa'
ORDER BY ordinal_position;

-- ============================================================================
-- 5️⃣ TESTE RÁPIDO
-- ============================================================================

-- Testar fn_calcular_dre
SELECT fn_calcular_dre(
  '2025-11-01 00:00:00+00'::timestamp with time zone,
  '2025-11-30 23:59:59+00'::timestamp with time zone,
  NULL
);

-- Ver vendas existentes
SELECT 
  id,
  created_at,
  total,
  desconto,
  status,
  metodo_pagamento
FROM vendas
WHERE created_at >= '2025-11-01'
ORDER BY created_at DESC
LIMIT 5;

-- ============================================================================
-- ✅ SUCESSO!
-- ============================================================================
-- Após executar este script:
-- 1. A função DRE vai usar "total" e "desconto" corretamente
-- 2. A função aplicar_venda vai usar "vendas_itens" corretamente
-- 3. Os relatórios vão mostrar os dados
-- ============================================================================
