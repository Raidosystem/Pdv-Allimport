-- ============================================================================
-- FUNÇÕES DE RANKING COMPLETO - Clientes e Equipamentos
-- ============================================================================

-- 1️⃣ FUNÇÃO: Ranking de Clientes que Mais Arrumaram
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
        COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), 0) as valor_total,
        MAX(os.data_entrada) as ultima_ordem
      FROM ordens_servico os
      WHERE os.data_entrada >= p_data_inicio
        AND os.data_entrada <= p_data_fim
        -- Removido filtro de user_id para mostrar TODOS os clientes
      GROUP BY os.cliente_id
      ORDER BY total_ordens DESC
      LIMIT p_limite
    ) ranking
    LEFT JOIN clientes c ON c.id = ranking.cliente_id
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', id,
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

-- 2️⃣ FUNÇÃO: Ranking de Equipamentos Mais Reparados
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
  -- Calcular total de reparos primeiro
  SELECT COUNT(*)
  INTO v_total_reparos
  FROM ordens_servico
  WHERE data_entrada >= p_data_inicio
    AND data_entrada <= p_data_fim;
    -- Removido filtro de user_id para mostrar TODOS os equipamentos

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
        COALESCE(
          NULLIF(TRIM(marca || ' ' || modelo), ' '),
          NULLIF(TRIM(tipo), ''),
          'Equipamento não especificado'
        ) as equipamento,
        COUNT(*) as total_reparos,
        COALESCE(SUM(valor_final), SUM(valor_orcamento), 0) as receita_total
      FROM ordens_servico
      WHERE data_entrada >= p_data_inicio
        AND data_entrada <= p_data_fim
        -- Removido filtro de user_id para mostrar TODOS os equipamentos
      GROUP BY marca, modelo, tipo
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

-- 3️⃣ FUNÇÃO: Ranking de Clientes por Gasto Total
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
        COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), 0) as gasto_total
      FROM ordens_servico os
      WHERE os.data_entrada >= p_data_inicio
        AND os.data_entrada <= p_data_fim
        -- Removido filtro de user_id para mostrar TODOS os clientes
      GROUP BY os.cliente_id
      ORDER BY gasto_total DESC
      LIMIT p_limite
    ) ranking
    LEFT JOIN clientes c ON c.id = ranking.cliente_id
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', id,
      'cliente_nome', cliente_nome,
      'cliente_telefone', cliente_telefone,
      'gasto_total', gasto_total,
      'total_ordens', total_ordens,
      'ticket_medio', ticket_medio
    )
  )
  INTO v_result
  FROM ranked_data;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

-- 4️⃣ PERMISSÕES
GRANT EXECUTE ON FUNCTION fn_ranking_clientes_reparos TO authenticated;
GRANT EXECUTE ON FUNCTION fn_ranking_equipamentos TO authenticated;
GRANT EXECUTE ON FUNCTION fn_ranking_clientes_gastos TO authenticated;

-- 5️⃣ TESTE DAS FUNÇÕES
DO $$
DECLARE
  v_user_id uuid;
  v_clientes jsonb;
  v_equipamentos jsonb;
  v_gastos jsonb;
BEGIN
  -- Pegar user_id da tabela vendas ou ordens_servico
  SELECT DISTINCT COALESCE(
    (SELECT user_id FROM ordens_servico LIMIT 1),
    (SELECT user_id FROM vendas LIMIT 1)
  ) INTO v_user_id;
  
  IF v_user_id IS NOT NULL THEN
    RAISE NOTICE '🧪 Testando funções de ranking com user_id: %', v_user_id;
    
    -- Teste ranking de clientes
    SELECT fn_ranking_clientes_reparos(
      CURRENT_DATE - INTERVAL '30 days',
      CURRENT_DATE,
      v_user_id,
      5
    ) INTO v_clientes;
    RAISE NOTICE '👥 Top 5 Clientes: %', v_clientes;
    
    -- Teste ranking de equipamentos
    SELECT fn_ranking_equipamentos(
      CURRENT_DATE - INTERVAL '30 days',
      CURRENT_DATE,
      v_user_id,
      5
    ) INTO v_equipamentos;
    RAISE NOTICE '🔧 Top 5 Equipamentos: %', v_equipamentos;
    
    -- Teste ranking de gastos
    SELECT fn_ranking_clientes_gastos(
      CURRENT_DATE - INTERVAL '30 days',
      CURRENT_DATE,
      v_user_id,
      5
    ) INTO v_gastos;
    RAISE NOTICE '💰 Top 5 Gastadores: %', v_gastos;
    
  ELSE
    RAISE NOTICE '⚠️ Nenhum user_id encontrado para teste';
  END IF;
END;
$$;

-- ============================================================================
-- ✅ FUNÇÕES DE RANKING CRIADAS!
-- 
-- COMO USAR:
-- 
-- 1. Ranking de clientes que mais arrumaram:
--    SELECT fn_ranking_clientes_reparos('2025-11-01', '2025-11-30', 'uuid', 10);
--
-- 2. Ranking de equipamentos mais reparados:
--    SELECT fn_ranking_equipamentos('2025-11-01', '2025-11-30', 'uuid', 10);
--
-- 3. Ranking de clientes por gasto:
--    SELECT fn_ranking_clientes_gastos('2025-11-01', '2025-11-30', 'uuid', 10);
-- ============================================================================
