-- ============================================================================
-- EXECUTAR ESTE SQL NO SUPABASE SQL EDITOR AGORA!
-- ============================================================================

-- 1️⃣ REMOVER A FUNÇÃO ANTIGA COM TODOS OS PARÂMETROS POSSÍVEIS
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone, uuid);
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone);

-- 2️⃣ RECRIAR A FUNÇÃO CORRIGIDA
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

  -- CMV (Custo da Mercadoria Vendida)
  SELECT COALESCE(SUM(vi.custo_medio_na_venda * vi.quantidade), 0)
  INTO v_cmv
  FROM vendas_itens vi
  INNER JOIN vendas v ON v.id = vi.venda_id
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND v.status = 'completed'
    AND (p_user_id IS NULL OR v.user_id = p_user_id);

  -- DESPESAS OPERACIONAIS
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

-- 3️⃣ TESTAR A FUNÇÃO
SELECT fn_calcular_dre(
  '2025-11-01 00:00:00+00'::timestamp with time zone,
  '2025-11-30 23:59:59+00'::timestamp with time zone,
  NULL
);

-- ✅ Se retornar um JSON com receita_bruta = 54.90, está funcionando!
