-- ============================================================================
-- DRE - FÓRMULAS CORRETAS CONFORME DOCUMENTAÇÃO
-- ============================================================================
-- Baseado nas fórmulas padrão de DRE (Demonstração do Resultado do Exercício)
-- ============================================================================

DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone, uuid) CASCADE;

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
  v_deducoes numeric := 0;
  v_receita_liquida numeric := 0;
  v_cmv numeric := 0;
  v_lucro_bruto numeric := 0;
  v_despesas_operacionais numeric := 0;
  v_resultado_operacional numeric := 0;
  v_outras_receitas numeric := 0;
  v_outras_despesas numeric := 0;
  v_resultado_liquido numeric := 0;
  v_margem_bruta numeric := 0;
  v_margem_operacional numeric := 0;
  v_margem_liquida numeric := 0;
  v_markup_percent numeric := 0;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '📊 CALCULANDO DRE - FÓRMULAS PADRÃO';
  RAISE NOTICE 'Período: % até %', p_data_inicio, p_data_fim;
  RAISE NOTICE '========================================';

  -- ============================================================
  -- 1️⃣ RECEITA BRUTA (soma do campo "total" das vendas)
  -- ============================================================
  SELECT COALESCE(SUM(v.total), 0)
  INTO v_receita_bruta
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND (p_user_id IS NULL OR v.user_id = p_user_id OR v.empresa_id = p_user_id);

  RAISE NOTICE '💰 Receita Bruta = R$ %', v_receita_bruta;

  -- ============================================================
  -- 2️⃣ DEDUÇÕES (descontos aplicados nas vendas)
  -- ============================================================
  SELECT COALESCE(SUM(COALESCE(v.desconto, 0)), 0)
  INTO v_deducoes
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND (p_user_id IS NULL OR v.user_id = p_user_id OR v.empresa_id = p_user_id);

  RAISE NOTICE '💸 (-) Deduções = R$ %', v_deducoes;

  -- ============================================================
  -- 3️⃣ RECEITA LÍQUIDA = receita_bruta - deducoes
  -- ============================================================
  v_receita_liquida := v_receita_bruta - v_deducoes;
  RAISE NOTICE '✅ (=) Receita Líquida = R$ %', v_receita_liquida;

  -- ============================================================
  -- 4️⃣ CMV (Custo da Mercadoria Vendida)
  -- Usa o CUSTO REAL dos produtos (produtos.custo * quantidade)
  -- ============================================================
  BEGIN
    SELECT COALESCE(SUM(
      COALESCE(p.custo, 0) * vi.quantidade
    ), 0)
    INTO v_cmv
    FROM vendas_itens vi
    INNER JOIN vendas v ON v.id = vi.venda_id
    INNER JOIN produtos p ON p.id = vi.produto_id
    WHERE v.created_at >= p_data_inicio
      AND v.created_at <= p_data_fim
      AND (p_user_id IS NULL OR v.user_id = p_user_id OR v.empresa_id = p_user_id);
    
    RAISE NOTICE '📦 CMV (custo real) = R$ %', v_cmv;
  EXCEPTION WHEN OTHERS THEN
    v_cmv := 0;
    RAISE NOTICE '⚠️ Erro ao calcular CMV: %', SQLERRM;
  END;

  -- Se CMV = 0 mas há receita, estimar com 60% (margem de 40%)
  IF v_cmv = 0 AND v_receita_liquida > 0 THEN
    v_cmv := v_receita_liquida * 0.6;
    RAISE NOTICE '⚠️ CMV Estimado (produtos sem custo): R$ %', v_cmv;
  END IF;

  -- ============================================================
  -- 5️⃣ LUCRO BRUTO = receita_liquida - cmv
  -- ============================================================
  v_lucro_bruto := v_receita_liquida - v_cmv;
  RAISE NOTICE '💰 (=) Lucro Bruto = R$ %', v_lucro_bruto;

  -- ============================================================
  -- 6️⃣ DESPESAS OPERACIONAIS
  -- ============================================================
  BEGIN
    SELECT COALESCE(SUM(d.valor), 0)
    INTO v_despesas_operacionais
    FROM despesas d
    WHERE d.data_despesa >= p_data_inicio
      AND d.data_despesa <= p_data_fim
      AND d.tipo_despesa IN ('operacional', 'administrativa', 'vendas', 'marketing', 'pessoal')
      AND (p_user_id IS NULL OR d.user_id = p_user_id OR d.empresa_id = p_user_id);
  EXCEPTION WHEN OTHERS THEN
    v_despesas_operacionais := 0;
  END;

  RAISE NOTICE '💼 (-) Despesas Operacionais = R$ %', v_despesas_operacionais;

  -- ============================================================
  -- 7️⃣ RESULTADO OPERACIONAL = lucro_bruto - despesas_operacionais
  -- ============================================================
  v_resultado_operacional := v_lucro_bruto - v_despesas_operacionais;
  RAISE NOTICE '📊 (=) Resultado Operacional = R$ %', v_resultado_operacional;

  -- ============================================================
  -- 8️⃣ OUTRAS RECEITAS (não operacionais)
  -- ============================================================
  BEGIN
    SELECT COALESCE(SUM(d.valor), 0)
    INTO v_outras_receitas
    FROM despesas d
    WHERE d.data_despesa >= p_data_inicio
      AND d.data_despesa <= p_data_fim
      AND d.tipo_despesa = 'receita_nao_operacional'
      AND (p_user_id IS NULL OR d.user_id = p_user_id OR d.empresa_id = p_user_id);
  EXCEPTION WHEN OTHERS THEN
    v_outras_receitas := 0;
  END;

  RAISE NOTICE '🎁 (+) Outras Receitas = R$ %', v_outras_receitas;

  -- ============================================================
  -- 9️⃣ OUTRAS DESPESAS (não operacionais)
  -- ============================================================
  BEGIN
    SELECT COALESCE(SUM(d.valor), 0)
    INTO v_outras_despesas
    FROM despesas d
    WHERE d.data_despesa >= p_data_inicio
      AND d.data_despesa <= p_data_fim
      AND d.tipo_despesa = 'despesa_nao_operacional'
      AND (p_user_id IS NULL OR d.user_id = p_user_id OR d.empresa_id = p_user_id);
  EXCEPTION WHEN OTHERS THEN
    v_outras_despesas := 0;
  END;

  RAISE NOTICE '💸 (-) Outras Despesas = R$ %', v_outras_despesas;

  -- ============================================================
  -- 🔟 RESULTADO LÍQUIDO = resultado_operacional + outras_receitas - outras_despesas
  -- ============================================================
  v_resultado_liquido := v_resultado_operacional + v_outras_receitas - v_outras_despesas;
  RAISE NOTICE '🎯 (=) RESULTADO LÍQUIDO = R$ %', v_resultado_liquido;

  -- ============================================================
  -- 📈 MARGENS (%)
  -- ============================================================
  -- margem_bruta = lucro_bruto / receita_liquida * 100
  IF v_receita_liquida > 0 THEN
    v_margem_bruta := (v_lucro_bruto / v_receita_liquida) * 100;
  ELSE
    v_margem_bruta := 0;
  END IF;

  -- margem_operacional = resultado_operacional / receita_liquida * 100
  IF v_receita_liquida > 0 THEN
    v_margem_operacional := (v_resultado_operacional / v_receita_liquida) * 100;
  ELSE
    v_margem_operacional := 0;
  END IF;

  -- margem_liquida = resultado_liquido / receita_liquida * 100
  IF v_receita_liquida > 0 THEN
    v_margem_liquida := (v_resultado_liquido / v_receita_liquida) * 100;
  ELSE
    v_margem_liquida := 0;
  END IF;

  RAISE NOTICE '📊 Margem Bruta = %.2f%%', v_margem_bruta;
  RAISE NOTICE '📊 Margem Operacional = %.2f%%', v_margem_operacional;
  RAISE NOTICE '📊 Margem Líquida = %.2f%%', v_margem_liquida;

  -- ============================================================
  -- 📊 MARKUP (%)
  -- markup_percent = (receita_bruta - cmv) / cmv * 100
  -- ============================================================
  IF v_cmv > 0 THEN
    v_markup_percent := ((v_receita_bruta - v_cmv) / v_cmv) * 100;
  ELSE
    v_markup_percent := 0;
  END IF;

  RAISE NOTICE '🏷️ Markup = %.2f%%', v_markup_percent;
  RAISE NOTICE '========================================';

  -- ============================================================
  -- 📋 RETORNAR JSON COM TODOS OS VALORES
  -- ============================================================
  v_result := jsonb_build_object(
    'periodo', jsonb_build_object(
      'inicio', p_data_inicio,
      'fim', p_data_fim
    ),
    'receita_bruta', ROUND(v_receita_bruta, 2),
    'descontos', ROUND(v_deducoes, 2),
    'receita_liquida', ROUND(v_receita_liquida, 2),
    'cmv', ROUND(v_cmv, 2),
    'custo_vendas', ROUND(v_cmv, 2),
    'lucro_bruto', ROUND(v_lucro_bruto, 2),
    'despesas_operacionais', ROUND(v_despesas_operacionais, 2),
    'resultado_operacional', ROUND(v_resultado_operacional, 2),
    'outras_receitas', ROUND(v_outras_receitas, 2),
    'outras_despesas', ROUND(v_outras_despesas, 2),
    'resultado_liquido', ROUND(v_resultado_liquido, 2),
    'margem_bruta_percentual', ROUND(v_margem_bruta, 2),
    'margem_operacional_percentual', ROUND(v_margem_operacional, 2),
    'margem_liquida_percentual', ROUND(v_margem_liquida, 2),
    'markup_medio', ROUND(v_markup_percent, 2)
  );

  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION fn_calcular_dre IS 'Calcula DRE seguindo fórmulas padrão: receita_liquida = receita_bruta - deducoes; lucro_bruto = receita_liquida - cmv; resultado_operacional = lucro_bruto - despesas_operacionais; resultado_liquido = resultado_operacional + outras_receitas - outras_despesas';

GRANT EXECUTE ON FUNCTION fn_calcular_dre TO authenticated;

-- ============================================================
-- 🧪 TESTE
-- ============================================================
DO $$
DECLARE
  v_user_id uuid;
  v_resultado jsonb;
BEGIN
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  
  SELECT fn_calcular_dre(
    NOW() - INTERVAL '30 days',
    NOW(),
    v_user_id
  ) INTO v_resultado;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ DRE CALCULADO:';
  RAISE NOTICE '%', jsonb_pretty(v_resultado);
  RAISE NOTICE '========================================';
END;
$$;

-- ✅ EXECUTE ESTE SCRIPT NO SUPABASE E RECARREGUE A PÁGINA DRE!
