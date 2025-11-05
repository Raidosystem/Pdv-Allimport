-- ============================================================================
-- FORÇAR REMOÇÃO COMPLETA DA FUNÇÃO fn_calcular_dre
-- ============================================================================
-- EXECUTE LINHA POR LINHA NO SUPABASE SQL EDITOR
-- ============================================================================

-- 1️⃣ LISTAR TODAS AS VERSÕES DA FUNÇÃO (para verificar)
SELECT 
    p.proname AS function_name,
    pg_get_function_identity_arguments(p.oid) AS arguments,
    pg_get_functiondef(p.oid) AS definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'fn_calcular_dre';

-- 2️⃣ REMOVER TODAS AS POSSÍVEIS VERSÕES
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone, uuid) CASCADE;
DROP FUNCTION IF EXISTS fn_calcular_dre(timestamp with time zone, timestamp with time zone) CASCADE;
DROP FUNCTION IF EXISTS fn_calcular_dre CASCADE;

-- 3️⃣ VERIFICAR SE FOI REMOVIDA
SELECT 
    p.proname AS function_name,
    pg_get_function_identity_arguments(p.oid) AS arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'fn_calcular_dre';
-- ⚠️ DEVE RETORNAR VAZIO!

-- 4️⃣ RECRIAR A FUNÇÃO CORRETA
CREATE FUNCTION fn_calcular_dre(
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
  -- RECEITA BRUTA (campo "total" NÃO "total_amount")
  SELECT COALESCE(SUM(v.total), 0)
  INTO v_receita_bruta
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND v.status = 'completed'
    AND (p_user_id IS NULL OR v.user_id = p_user_id);

  -- DESCONTOS (campo "desconto" NÃO "discount_amount")
  SELECT COALESCE(SUM(v.desconto), 0)
  INTO v_descontos
  FROM vendas v
  WHERE v.created_at >= p_data_inicio
    AND v.created_at <= p_data_fim
    AND v.status = 'completed'
    AND (p_user_id IS NULL OR v.user_id = p_user_id);

  -- CMV
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

  -- RESULTADO
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

-- 5️⃣ TESTAR A NOVA FUNÇÃO
SELECT fn_calcular_dre(
  '2025-11-01 00:00:00+00'::timestamp with time zone,
  '2025-11-30 23:59:59+00'::timestamp with time zone,
  NULL
);

-- ✅ DEVE RETORNAR: {"receita_bruta": 54.9, ...}

-- 6️⃣ LIMPAR CACHE DO POSTGREST (MUITO IMPORTANTE!)
NOTIFY pgrst, 'reload schema';

-- ============================================================================
-- INSTRUÇÕES:
-- 1. Execute TODO este script de uma vez no Supabase SQL Editor
-- 2. Aguarde 30 segundos (para cache limpar)
-- 3. Pressione F5 no navegador
-- ============================================================================
