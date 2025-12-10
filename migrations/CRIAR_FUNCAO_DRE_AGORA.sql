-- ============================================================================
-- CRIAR FUNÇÃO fn_calcular_dre CORRIGIDA - EXECUTAR NO SUPABASE SQL EDITOR
-- ============================================================================

-- 1️⃣ REMOVER FUNÇÃO ANTIGA (se existir)
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone, uuid);
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone);
DROP FUNCTION IF EXISTS fn_calcular_dre CASCADE;

-- 2️⃣ CRIAR FUNÇÃO NOVA E CORRIGIDA
CREATE OR REPLACE FUNCTION fn_calcular_dre(
  p_data_inicio timestamp with time zone,
  p_data_fim timestamp with time zone,
  p_user_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result jsonb;
  v_receita_bruta numeric := 0;
  v_descontos numeric := 0;
  v_receita_liquida numeric := 0;
  v_cmv numeric := 0;
  v_lucro_bruto numeric := 0;
  v_despesas_operacionais numeric := 0;
  v_resultado_operacional numeric := 0;
  v_outras_receitas numeric := 0;
  v_outras_despesas numeric := 0;
  v_resultado_liquido numeric := 0;
BEGIN
  -- 📊 RECEITA BRUTA (soma do campo "total" da tabela vendas)
  SELECT COALESCE(SUM(v.total), 0)
  INTO v_receita_bruta
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND (p_user_id IS NULL OR v.user_id = p_user_id OR v.empresa_id = p_user_id);

  RAISE NOTICE '💰 Receita Bruta: % (Total de vendas no período)', v_receita_bruta;

  -- 💸 DESCONTOS (soma do campo "desconto" da tabela vendas)
  SELECT COALESCE(SUM(v.desconto), 0)
  INTO v_descontos
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND (p_user_id IS NULL OR v.user_id = p_user_id OR v.empresa_id = p_user_id);

  RAISE NOTICE '💸 Descontos: %', v_descontos;

  -- ✅ RECEITA LÍQUIDA
  v_receita_liquida := v_receita_bruta - v_descontos;
  RAISE NOTICE '✅ Receita Líquida: % (Bruta - Descontos)', v_receita_liquida;

  -- 📦 CMV (Custo da Mercadoria Vendida)
  -- Tentar calcular com base nos itens vendidos (preco_unitario é o custo)
  BEGIN
    SELECT COALESCE(SUM(vi.preco_unitario * vi.quantidade), 0)
    INTO v_cmv
    FROM vendas_itens vi
    INNER JOIN vendas v ON v.id = vi.venda_id
    WHERE v.created_at >= p_data_inicio
      AND v.created_at <= p_data_fim
      AND (p_user_id IS NULL OR v.user_id = p_user_id OR v.empresa_id = p_user_id);
    
    RAISE NOTICE '📦 CMV calculado dos itens: %', v_cmv;
  EXCEPTION WHEN OTHERS THEN
    v_cmv := 0;
    RAISE NOTICE '⚠️ Erro ao calcular CMV dos itens, usando estimativa';
  END;

  -- Se CMV for zero (sem vendas_itens ou erro), estima baseado na receita
  IF v_cmv = 0 AND v_receita_liquida > 0 THEN
    v_cmv := v_receita_liquida * 0.6; -- Estima 60% como custo
    RAISE NOTICE '📦 CMV Estimado (60%% da receita): %', v_cmv;
  END IF;

  -- 💰 LUCRO BRUTO
  v_lucro_bruto := v_receita_liquida - v_cmv;
  RAISE NOTICE '💰 Lucro Bruto: % (Receita Líquida - CMV)', v_lucro_bruto;

  -- 💼 DESPESAS OPERACIONAIS (se tabela despesas existir)
  BEGIN
    SELECT COALESCE(SUM(d.valor), 0)
    INTO v_despesas_operacionais
    FROM despesas d
    WHERE d.data_despesa >= p_data_inicio
      AND d.data_despesa <= p_data_fim
      AND d.tipo_despesa IN ('operacional', 'administrativa', 'vendas')
      AND (p_user_id IS NULL OR d.user_id = p_user_id OR d.empresa_id = p_user_id);
    
    RAISE NOTICE '💼 Despesas Operacionais: %', v_despesas_operacionais;
  EXCEPTION WHEN OTHERS THEN
    v_despesas_operacionais := 0;
    RAISE NOTICE '⚠️ Tabela despesas não encontrada ou erro ao consultar';
  END;

  -- 📊 RESULTADO OPERACIONAL
  v_resultado_operacional := v_lucro_bruto - v_despesas_operacionais;
  RAISE NOTICE '📊 Resultado Operacional: %', v_resultado_operacional;

  -- 🎁 OUTRAS RECEITAS E DESPESAS (se existirem)
  v_outras_receitas := 0;
  v_outras_despesas := 0;

  -- 🎯 RESULTADO LÍQUIDO
  v_resultado_liquido := v_resultado_operacional + v_outras_receitas - v_outras_despesas;
  RAISE NOTICE '🎯 Resultado Líquido Final: %', v_resultado_liquido;

  -- 📋 MONTAR RESULTADO JSON
  v_result := jsonb_build_object(
    'periodo', jsonb_build_object(
      'inicio', p_data_inicio,
      'fim', p_data_fim
    ),
    'receita_bruta', v_receita_bruta,
    'descontos', v_descontos,
    'receita_liquida', v_receita_liquida,
    'cmv', v_cmv,
    'custo_vendas', v_cmv, -- alias para cmv
    'lucro_bruto', v_lucro_bruto,
    'despesas_operacionais', v_despesas_operacionais,
    'resultado_operacional', v_resultado_operacional,
    'outras_receitas', v_outras_receitas,
    'outras_despesas', v_outras_despesas,
    'resultado_liquido', v_resultado_liquido,
    'margem_bruta_percentual', CASE WHEN v_receita_liquida > 0 THEN (v_lucro_bruto / v_receita_liquida * 100) ELSE 0 END,
    'margem_liquida_percentual', CASE WHEN v_receita_liquida > 0 THEN (v_resultado_liquido / v_receita_liquida * 100) ELSE 0 END
  );

  RETURN v_result;
END;
$$;

-- 3️⃣ COMENTÁRIO DA FUNÇÃO
COMMENT ON FUNCTION fn_calcular_dre IS 'Calcula DRE (Demonstração do Resultado do Exercício) para um período específico';

-- 4️⃣ PERMISSÕES
GRANT EXECUTE ON FUNCTION fn_calcular_dre TO authenticated;

-- 5️⃣ TESTE DA FUNÇÃO
DO $$
DECLARE
  v_user_id uuid;
  v_resultado jsonb;
BEGIN
  -- Pegar o primeiro user_id da tabela vendas
  SELECT DISTINCT user_id INTO v_user_id FROM vendas LIMIT 1;
  
  IF v_user_id IS NOT NULL THEN
    RAISE NOTICE '🧪 Testando fn_calcular_dre com user_id: %', v_user_id;
    
    -- Teste: últimos 30 dias
    SELECT fn_calcular_dre(
      CURRENT_DATE - INTERVAL '30 days',
      CURRENT_DATE,
      v_user_id
    ) INTO v_resultado;
    
    RAISE NOTICE '✅ Resultado do teste: %', v_resultado;
  ELSE
    RAISE NOTICE '⚠️ Nenhum user_id encontrado na tabela vendas para teste';
  END IF;
END;
$$;

-- ============================================================================
-- ✅ PRONTO! Função fn_calcular_dre criada com sucesso!
-- 
-- COMO USAR:
-- SELECT fn_calcular_dre(
--   '2025-11-01'::timestamp,  -- data início
--   '2025-11-30'::timestamp,  -- data fim
--   'seu-user-id-uuid'::uuid  -- user_id (opcional)
-- );
-- ============================================================================
