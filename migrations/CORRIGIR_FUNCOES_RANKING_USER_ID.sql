-- ============================================================================
-- 🔧 CORREÇÃO CRÍTICA: Adicionar filtro user_id nas funções de ranking
-- ============================================================================
-- 
-- PROBLEMA: Funções de ranking mostram dados de TODOS os usuários
-- CAUSA: Filtro "WHERE user_id = p_user_id" estava comentado/removido
-- SOLUÇÃO: Adicionar validação de user_id em TODAS as queries
-- 
-- ⚠️ EXECUTE NO SUPABASE SQL EDITOR: https://supabase.com/dashboard
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1️⃣ FUNÇÃO: Ranking de Clientes que Mais Arrumaram
-- ============================================================================

DROP FUNCTION IF EXISTS fn_ranking_clientes_reparos(timestamp with time zone, timestamp with time zone, uuid, integer);

CREATE OR REPLACE FUNCTION fn_ranking_clientes_reparos(
  p_data_inicio timestamp with time zone,
  p_data_fim timestamp with time zone,
  p_user_id uuid DEFAULT NULL,
  p_limite int DEFAULT 10
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result jsonb;
BEGIN
  WITH ranked_data AS (
    SELECT 
      ROW_NUMBER() OVER (ORDER BY total_ordens DESC) as id,
      COALESCE(c.nome, c.telefone, 'Cliente não identificado') as cliente_nome,
      c.telefone as cliente_telefone,
      total_ordens,
      valor_total,
      CASE WHEN total_ordens > 0 THEN valor_total / total_ordens ELSE 0 END as valor_medio,
      ultima_ordem
    FROM (
      SELECT 
        os.cliente_id,
        COUNT(os.id) as total_ordens,
        COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as valor_total,
        MAX(os.data_entrada) as ultima_ordem
      FROM ordens_servico os
      WHERE os.data_entrada >= p_data_inicio
        AND os.data_entrada <= p_data_fim
        AND (p_user_id IS NULL OR os.user_id = p_user_id) -- ✅ FILTRO POR USER_ID
      GROUP BY os.cliente_id
      ORDER BY total_ordens DESC
      LIMIT p_limite
    ) ranking
    LEFT JOIN clientes c ON c.id = ranking.cliente_id
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', id,
      'cliente_id', ranking.cliente_id,
      'cliente_nome', cliente_nome,
      'cliente_telefone', cliente_telefone,
      'total_ordens', total_ordens,
      'valor_total', valor_total,
      'valor_medio', valor_medio,
      'ultima_ordem', ultima_ordem
    )
  )
  INTO v_result
  FROM ranked_data;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- ============================================================================
-- 2️⃣ FUNÇÃO: Ranking de Clientes que Mais Gastaram
-- ============================================================================

DROP FUNCTION IF EXISTS fn_ranking_clientes_gastos(timestamp with time zone, timestamp with time zone, uuid, integer);

CREATE OR REPLACE FUNCTION fn_ranking_clientes_gastos(
  p_data_inicio timestamp with time zone,
  p_data_fim timestamp with time zone,
  p_user_id uuid DEFAULT NULL,
  p_limite int DEFAULT 10
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result jsonb;
BEGIN
  WITH ranked_data AS (
    SELECT 
      ROW_NUMBER() OVER (ORDER BY gasto_total DESC) as id,
      COALESCE(c.nome, c.telefone, 'Cliente não identificado') as cliente_nome,
      c.telefone as cliente_telefone,
      gasto_total,
      total_ordens,
      CASE WHEN total_ordens > 0 THEN gasto_total / total_ordens ELSE 0 END as ticket_medio
    FROM (
      SELECT 
        os.cliente_id,
        COUNT(os.id) as total_ordens,
        COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as gasto_total
      FROM ordens_servico os
      WHERE os.data_entrada >= p_data_inicio
        AND os.data_entrada <= p_data_fim
        AND (p_user_id IS NULL OR os.user_id = p_user_id) -- ✅ FILTRO POR USER_ID
      GROUP BY os.cliente_id
      ORDER BY gasto_total DESC
      LIMIT p_limite
    ) ranking
    LEFT JOIN clientes c ON c.id = ranking.cliente_id
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', id,
      'cliente_id', ranking.cliente_id,
      'cliente_nome', cliente_nome,
      'cliente_telefone', cliente_telefone,
      'segmento', 'Varejo',
      'total_ordens', total_ordens,
      'gasto_total', gasto_total,
      'ticket_medio', ticket_medio
    )
  )
  INTO v_result
  FROM ranked_data;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- ============================================================================
-- 3️⃣ FUNÇÃO: Ranking de Equipamentos Mais Reparados
-- ============================================================================

DROP FUNCTION IF EXISTS fn_ranking_equipamentos(timestamp with time zone, timestamp with time zone, uuid, integer);

CREATE OR REPLACE FUNCTION fn_ranking_equipamentos(
  p_data_inicio timestamp with time zone,
  p_data_fim timestamp with time zone,
  p_user_id uuid DEFAULT NULL,
  p_limite int DEFAULT 10
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result jsonb;
  v_total_reparos numeric;
BEGIN
  -- Calcular total de reparos do usuário
  SELECT COUNT(*)
  INTO v_total_reparos
  FROM ordens_servico
  WHERE data_entrada >= p_data_inicio
    AND data_entrada <= p_data_fim
    AND (p_user_id IS NULL OR user_id = p_user_id); -- ✅ FILTRO POR USER_ID

  -- Evitar divisão por zero
  IF v_total_reparos = 0 THEN
    v_total_reparos := 1;
  END IF;

  WITH ranked_data AS (
    SELECT 
      ROW_NUMBER() OVER (ORDER BY total_reparos DESC) as id,
      equipamento,
      total_reparos,
      receita_total,
      CASE WHEN total_reparos > 0 THEN receita_total / total_reparos ELSE 0 END as receita_media,
      ROUND((total_reparos::numeric / v_total_reparos * 100), 1) as percentual
    FROM (
      SELECT 
        COALESCE(os.tipo, 'Não especificado') as equipamento,
        COUNT(os.id) as total_reparos,
        COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as receita_total
      FROM ordens_servico os
      WHERE os.data_entrada >= p_data_inicio
        AND os.data_entrada <= p_data_fim
        AND (p_user_id IS NULL OR os.user_id = p_user_id) -- ✅ FILTRO POR USER_ID
      GROUP BY os.tipo
      ORDER BY total_reparos DESC
      LIMIT p_limite
    ) ranking
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', id,
      'equipamento', equipamento,
      'total_reparos', total_reparos,
      'receita_total', receita_total,
      'receita_media', receita_media,
      'percentual', percentual
    )
  )
  INTO v_result
  FROM ranked_data;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

COMMIT;

-- ============================================================================
-- ✅ VERIFICAÇÃO: Confirmar que funções foram atualizadas
-- ============================================================================

SELECT 
    '✅ Funções de ranking atualizadas com filtro user_id!' as resultado;

-- Listar funções criadas
SELECT 
    routine_name as funcao,
    routine_type as tipo,
    'Aceita p_user_id como parâmetro' as descricao
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'fn_ranking%'
ORDER BY routine_name;

-- ============================================================================
-- 📋 INSTRUÇÕES DE TESTE
-- ============================================================================

-- 1. Execute este script no Supabase SQL Editor
-- 2. Aguarde mensagem "✅ Funções de ranking atualizadas com filtro user_id!"
-- 3. Atualize o PDV (F5)
-- 4. Vá em Relatórios > Ranking
-- 5. Verifique que aparecem APENAS seus dados
-- 6. Resultado esperado: SEM dados de outros usuários

-- ============================================================================
-- 🔍 QUERY DE DIAGNÓSTICO (opcional - para conferir dados)
-- ============================================================================

-- Testar função com seu user_id:
-- SELECT fn_ranking_clientes_reparos(
--   NOW() - INTERVAL '30 days',
--   NOW(),
--   'SEU_USER_ID_AQUI',
--   10
-- );
