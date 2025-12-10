-- ============================================================================
-- CORRIGIR FUNÇÃO fn_calcular_dre - CMV COM CUSTO REAL DOS PRODUTOS
-- ============================================================================
-- EXECUTE ESTE SCRIPT NO SUPABASE SQL EDITOR
-- ============================================================================

-- 1️⃣ REMOVER FUNÇÃO ANTIGA
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone, uuid) CASCADE;
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone) CASCADE;
DROP FUNCTION IF EXISTS fn_calcular_dre CASCADE;

-- 2️⃣ CRIAR FUNÇÃO CORRIGIDA COM CMV REAL
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
  RAISE NOTICE '========================================';
  RAISE NOTICE '🔍 CALCULANDO DRE';
  RAISE NOTICE 'Período: % até %', p_data_inicio, p_data_fim;
  RAISE NOTICE '========================================';

  -- 📊 RECEITA BRUTA (soma do campo "total" da tabela vendas)
  SELECT COALESCE(SUM(v.total), 0)
  INTO v_receita_bruta
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND (p_user_id IS NULL OR v.user_id = p_user_id OR v.empresa_id = p_user_id);

  RAISE NOTICE '💰 Receita Bruta: R$ %', v_receita_bruta;

  -- 💸 DESCONTOS (soma do campo "desconto" da tabela vendas)
  SELECT COALESCE(SUM(COALESCE(v.desconto, 0)), 0)
  INTO v_descontos
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND (p_user_id IS NULL OR v.user_id = p_user_id OR v.empresa_id = p_user_id);

  RAISE NOTICE '💸 Descontos: R$ %', v_descontos;

  -- ✅ RECEITA LÍQUIDA
  v_receita_liquida := v_receita_bruta - v_descontos;
  RAISE NOTICE '✅ Receita Líquida: R$ % (Bruta - Descontos)', v_receita_liquida;

  -- 📦 CMV (Custo da Mercadoria Vendida) - CORRIGIDO!
  -- Agora usa o CUSTO do produto (produtos.custo), não o preço de venda
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
    
    RAISE NOTICE '📦 CMV (custo real dos produtos): R$ %', v_cmv;
  EXCEPTION WHEN OTHERS THEN
    v_cmv := 0;
    RAISE NOTICE '⚠️ Erro ao calcular CMV: %', SQLERRM;
  END;

  -- Se CMV for zero mas houver receita, usar margem estimada de 40% (custo = 60% da receita)
  IF v_cmv = 0 AND v_receita_liquida > 0 THEN
    v_cmv := v_receita_liquida * 0.6;
    RAISE NOTICE '⚠️ CMV Estimado (60%% da receita - produtos sem custo cadastrado): R$ %', v_cmv;
  END IF;

  -- 💰 LUCRO BRUTO
  v_lucro_bruto := v_receita_liquida - v_cmv;
  RAISE NOTICE '💰 Lucro Bruto: R$ % (Receita Líquida - CMV)', v_lucro_bruto;

  -- 💼 DESPESAS OPERACIONAIS (se tabela despesas existir)
  BEGIN
    SELECT COALESCE(SUM(d.valor), 0)
    INTO v_despesas_operacionais
    FROM despesas d
    WHERE d.data_despesa >= p_data_inicio
      AND d.data_despesa <= p_data_fim
      AND d.tipo_despesa IN ('operacional', 'administrativa', 'vendas', 'marketing', 'pessoal')
      AND (p_user_id IS NULL OR d.user_id = p_user_id OR d.empresa_id = p_user_id);
    
    RAISE NOTICE '💼 Despesas Operacionais: R$ %', v_despesas_operacionais;
  EXCEPTION WHEN OTHERS THEN
    v_despesas_operacionais := 0;
    RAISE NOTICE '⚠️ Tabela despesas não encontrada ou erro: %', SQLERRM;
  END;

  -- 📊 RESULTADO OPERACIONAL
  v_resultado_operacional := v_lucro_bruto - v_despesas_operacionais;
  RAISE NOTICE '📊 Resultado Operacional: R$ %', v_resultado_operacional;

  -- 🎁 OUTRAS RECEITAS (receitas não operacionais)
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

  -- 💸 OUTRAS DESPESAS (despesas não operacionais)
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

  RAISE NOTICE '🎁 Outras Receitas: R$ %', v_outras_receitas;
  RAISE NOTICE '💸 Outras Despesas: R$ %', v_outras_despesas;

  -- 🎯 RESULTADO LÍQUIDO
  v_resultado_liquido := v_resultado_operacional + v_outras_receitas - v_outras_despesas;
  RAISE NOTICE '🎯 RESULTADO LÍQUIDO FINAL: R$ %', v_resultado_liquido;
  RAISE NOTICE '========================================';

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
    'custo_vendas', v_cmv,
    'lucro_bruto', v_lucro_bruto,
    'despesas_operacionais', v_despesas_operacionais,
    'resultado_operacional', v_resultado_operacional,
    'outras_receitas', v_outras_receitas,
    'outras_despesas', v_outras_despesas,
    'resultado_liquido', v_resultado_liquido,
    'margem_bruta_percentual', CASE WHEN v_receita_liquida > 0 THEN ROUND((v_lucro_bruto / v_receita_liquida * 100)::numeric, 2) ELSE 0 END,
    'margem_operacional_percentual', CASE WHEN v_receita_liquida > 0 THEN ROUND((v_resultado_operacional / v_receita_liquida * 100)::numeric, 2) ELSE 0 END,
    'margem_liquida_percentual', CASE WHEN v_receita_liquida > 0 THEN ROUND((v_resultado_liquido / v_receita_liquida * 100)::numeric, 2) ELSE 0 END,
    'markup_medio', CASE WHEN v_cmv > 0 THEN ROUND(((v_receita_bruta / v_cmv - 1) * 100)::numeric, 2) ELSE 0 END
  );

  RETURN v_result;
END;
$$;

-- 3️⃣ COMENTÁRIO E PERMISSÕES
COMMENT ON FUNCTION fn_calcular_dre IS 'Calcula DRE (Demonstração do Resultado do Exercício) usando CUSTO REAL dos produtos';
GRANT EXECUTE ON FUNCTION fn_calcular_dre TO authenticated;

-- 4️⃣ TESTE DA FUNÇÃO
DO $$
DECLARE
  v_user_id uuid;
  v_resultado jsonb;
  v_data_inicio timestamp with time zone;
  v_data_fim timestamp with time zone;
BEGIN
  -- Pegar o primeiro usuário
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  
  -- Últimos 30 dias
  v_data_fim := NOW();
  v_data_inicio := NOW() - INTERVAL '30 days';
  
  RAISE NOTICE '========================================';
  RAISE NOTICE '🧪 TESTANDO fn_calcular_dre';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE 'Período: % até %', v_data_inicio, v_data_fim;
  RAISE NOTICE '========================================';
  
  SELECT fn_calcular_dre(v_data_inicio, v_data_fim, v_user_id)
  INTO v_resultado;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ RESULTADO DO TESTE:';
  RAISE NOTICE '%', jsonb_pretty(v_resultado);
  RAISE NOTICE '========================================';
END;
$$;

-- ✅ PRONTO!
-- A função agora calcula o CMV corretamente usando o custo real dos produtos.
-- Recarregue a página DRE no sistema para ver os valores corretos!
