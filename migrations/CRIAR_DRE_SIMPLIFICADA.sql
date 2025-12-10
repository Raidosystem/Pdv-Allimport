-- ============================================================================
-- FUNÇÃO DRE SIMPLIFICADA - SÓ USA TABELA VENDAS
-- Execute esta se a versão completa der erro
-- ============================================================================

-- 1️⃣ REMOVER FUNÇÃO ANTIGA
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone, uuid) CASCADE;
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone) CASCADE;
DROP FUNCTION IF EXISTS fn_calcular_dre CASCADE;

-- 2️⃣ CRIAR FUNÇÃO SIMPLIFICADA
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
  v_resultado_liquido numeric := 0;
BEGIN
  -- 📊 RECEITA BRUTA (soma do campo "total")
  SELECT COALESCE(SUM(total), 0)
  INTO v_receita_bruta
  FROM vendas
  WHERE created_at >= p_data_inicio
    AND created_at <= p_data_fim
    AND (p_user_id IS NULL OR user_id = p_user_id OR empresa_id = p_user_id);

  RAISE NOTICE '💰 Receita Bruta: %', v_receita_bruta;

  -- 💸 DESCONTOS
  SELECT COALESCE(SUM(desconto), 0)
  INTO v_descontos
  FROM vendas
  WHERE created_at >= p_data_inicio
    AND created_at <= p_data_fim
    AND (p_user_id IS NULL OR user_id = p_user_id OR empresa_id = p_user_id);

  RAISE NOTICE '💸 Descontos: %', v_descontos;

  -- ✅ RECEITA LÍQUIDA
  v_receita_liquida := v_receita_bruta - v_descontos;
  RAISE NOTICE '✅ Receita Líquida: %', v_receita_liquida;

  -- 📦 CMV - ESTIMADO em 60% da receita (padrão para varejo)
  v_cmv := v_receita_liquida * 0.60;
  RAISE NOTICE '📦 CMV Estimado (60%%): %', v_cmv;

  -- 💰 LUCRO BRUTO (40% de margem)
  v_lucro_bruto := v_receita_liquida - v_cmv;
  RAISE NOTICE '💰 Lucro Bruto (40%% margem): %', v_lucro_bruto;

  -- 🎯 RESULTADO LÍQUIDO = LUCRO BRUTO (sem despesas operacionais)
  v_resultado_liquido := v_lucro_bruto;
  RAISE NOTICE '🎯 Resultado Líquido: %', v_resultado_liquido;

  -- 📋 RETORNAR JSON
  v_result := jsonb_build_object(
    'periodo', jsonb_build_object(
      'inicio', p_data_inicio,
      'fim', p_data_fim
    ),
    'receita_bruta', v_receita_bruta,
    'descontos', v_descontos,
    'receita_liquida', v_receita_liquida,
    'cmv', v_cmv,
    'custo_vendas', v_cmv,
    'lucro_bruto', v_lucro_bruto,
    'despesas_operacionais', 0,
    'resultado_operacional', v_lucro_bruto,
    'outras_receitas', 0,
    'outras_despesas', 0,
    'resultado_liquido', v_resultado_liquido,
    'margem_bruta_percentual', 40.0,  -- 40% fixo
    'margem_liquida_percentual', CASE WHEN v_receita_liquida > 0 THEN (v_resultado_liquido / v_receita_liquida * 100) ELSE 0 END
  );

  RETURN v_result;
END;
$$;

-- 3️⃣ PERMISSÕES
GRANT EXECUTE ON FUNCTION fn_calcular_dre TO authenticated;

-- 4️⃣ TESTE
DO $$
DECLARE
  v_user_id uuid;
  v_resultado jsonb;
BEGIN
  SELECT DISTINCT user_id INTO v_user_id FROM vendas LIMIT 1;
  
  IF v_user_id IS NOT NULL THEN
    RAISE NOTICE '🧪 Testando fn_calcular_dre SIMPLIFICADA com user_id: %', v_user_id;
    
    SELECT fn_calcular_dre(
      CURRENT_DATE - INTERVAL '30 days',
      CURRENT_DATE,
      v_user_id
    ) INTO v_resultado;
    
    RAISE NOTICE '✅ Resultado: %', v_resultado;
  END IF;
END;
$$;

-- ============================================================================
-- ✅ FUNÇÃO SIMPLIFICADA CRIADA!
-- 
-- CARACTERÍSTICAS:
-- - ✅ Só usa tabela VENDAS (não depende de vendas_itens)
-- - ✅ CMV estimado em 60% (padrão varejo)
-- - ✅ Margem bruta de 40%
-- - ✅ Sem despesas operacionais
-- - ✅ Mais rápida e confiável
-- 
-- USAR SE:
-- - vendas_itens estiver vazia
-- - Colunas de custo não existirem
-- - Quiser uma DRE básica e funcional
-- ============================================================================
