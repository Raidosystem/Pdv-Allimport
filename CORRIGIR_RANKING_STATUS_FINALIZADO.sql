-- ============================================================================
-- CORRIGIR FUNÇÕES DE RANKING PARA CONSIDERAR APENAS STATUS "Finalizado"
-- ============================================================================
-- Problema: Rankings estão contando todas as ordens, incluindo em aberto
-- Solução: Adicionar filtro WHERE status = 'Finalizado'
-- ============================================================================

-- ⚠️ REMOVER FUNÇÕES ANTIGAS PRIMEIRO
DROP FUNCTION IF EXISTS fn_ranking_clientes_reparos(timestamp with time zone, timestamp with time zone);
DROP FUNCTION IF EXISTS fn_ranking_clientes_reparos(timestamp with time zone, timestamp with time zone, uuid, integer);
DROP FUNCTION IF EXISTS fn_ranking_clientes_gastos(timestamp with time zone, timestamp with time zone);
DROP FUNCTION IF EXISTS fn_ranking_clientes_gastos(timestamp with time zone, timestamp with time zone, uuid, integer);
DROP FUNCTION IF EXISTS fn_ranking_equipamentos(timestamp with time zone, timestamp with time zone);
DROP FUNCTION IF EXISTS fn_ranking_equipamentos(timestamp with time zone, timestamp with time zone, uuid, integer);

-- 1️⃣ FUNÇÃO: RANKING DE CLIENTES POR REPAROS (APENAS FINALIZADOS)
CREATE OR REPLACE FUNCTION fn_ranking_clientes_reparos(
  p_data_inicio TIMESTAMP WITH TIME ZONE,
  p_data_fim TIMESTAMP WITH TIME ZONE,
  p_user_id UUID DEFAULT NULL,
  p_limite INTEGER DEFAULT 10
)
RETURNS TABLE (
  cliente_id UUID,
  cliente_nome TEXT,
  total_ordens BIGINT,
  valor_total NUMERIC,
  valor_medio NUMERIC,
  ultima_ordem TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  WITH ranking_data AS (
    SELECT 
      os.cliente_id,
      c.nome as cliente_nome,
      COUNT(os.id) as total_ordens,
      -- ✅ USAR 'valor' COMO FALLBACK
      COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as valor_total,
      COALESCE(AVG(os.valor_final), AVG(os.valor_orcamento), AVG(os.valor), 0) as valor_medio,
      MAX(os.data_entrada) as ultima_ordem
    FROM ordens_servico os
    LEFT JOIN clientes c ON c.id = os.cliente_id
    WHERE os.data_entrada >= p_data_inicio 
      AND os.data_entrada <= p_data_fim
      AND os.status = 'Finalizado' -- ✅ APENAS FINALIZADAS
      AND (p_user_id IS NULL OR os.user_id = p_user_id)
    GROUP BY os.cliente_id, c.nome
  )
  SELECT 
    rd.cliente_id,
    rd.cliente_nome,
    rd.total_ordens,
    rd.valor_total,
    rd.valor_medio,
    rd.ultima_ordem
  FROM ranking_data rd
  ORDER BY rd.total_ordens DESC, rd.valor_total DESC
  LIMIT p_limite;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2️⃣ FUNÇÃO: RANKING DE CLIENTES POR GASTOS (APENAS FINALIZADOS)
CREATE OR REPLACE FUNCTION fn_ranking_clientes_gastos(
  p_data_inicio TIMESTAMP WITH TIME ZONE,
  p_data_fim TIMESTAMP WITH TIME ZONE,
  p_user_id UUID DEFAULT NULL,
  p_limite INTEGER DEFAULT 10
)
RETURNS TABLE (
  cliente_id UUID,
  cliente_nome TEXT,
  segmento TEXT,
  total_ordens BIGINT,
  gasto_total NUMERIC,
  ticket_medio NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  WITH ranking_data AS (
    SELECT 
      os.cliente_id,
      c.nome as cliente_nome,
      'Varejo' as segmento,
      COUNT(os.id) as total_ordens,
      -- ✅ USAR 'valor' COMO FALLBACK
      COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as gasto_total,
      COALESCE(AVG(os.valor_final), AVG(os.valor_orcamento), AVG(os.valor), 0) as ticket_medio
    FROM ordens_servico os
    LEFT JOIN clientes c ON c.id = os.cliente_id
    WHERE os.data_entrada >= p_data_inicio 
      AND os.data_entrada <= p_data_fim
      AND os.status = 'Finalizado' -- ✅ APENAS FINALIZADAS
      AND (p_user_id IS NULL OR os.user_id = p_user_id)
    GROUP BY os.cliente_id, c.nome
  )
  SELECT 
    rd.cliente_id,
    rd.cliente_nome,
    rd.segmento,
    rd.total_ordens,
    rd.gasto_total,
    rd.ticket_medio
  FROM ranking_data rd
  ORDER BY rd.gasto_total DESC, rd.total_ordens DESC
  LIMIT p_limite;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3️⃣ FUNÇÃO: RANKING DE EQUIPAMENTOS (APENAS FINALIZADOS)
CREATE OR REPLACE FUNCTION fn_ranking_equipamentos(
  p_data_inicio TIMESTAMP WITH TIME ZONE,
  p_data_fim TIMESTAMP WITH TIME ZONE,
  p_user_id UUID DEFAULT NULL,
  p_limite INTEGER DEFAULT 10
)
RETURNS TABLE (
  equipamento TEXT,
  total_reparos BIGINT,
  receita_total NUMERIC,
  receita_media NUMERIC,
  percentual NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  WITH total_reparos AS (
    SELECT COUNT(*) as v_total_reparos
    FROM ordens_servico
    WHERE data_entrada >= p_data_inicio 
      AND data_entrada <= p_data_fim
      AND status = 'Finalizado' -- ✅ APENAS FINALIZADAS
      AND (p_user_id IS NULL OR user_id = p_user_id)
  ),
  ranking_data AS (
    SELECT 
      -- ✅ USAR 'equipamento' SE EXISTIR, SENÃO CONCAT marca+modelo+tipo
      COALESCE(
        NULLIF(TRIM(os.equipamento), ''),
        NULLIF(TRIM(os.marca || ' ' || os.modelo), ''),
        NULLIF(TRIM(os.tipo), ''),
        'Equipamento não especificado'
      ) as equipamento,
      COUNT(os.id) as total_reparos,
      -- ✅ USAR 'valor' COMO FALLBACK
      COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as receita_total,
      COALESCE(AVG(os.valor_final), AVG(os.valor_orcamento), AVG(os.valor), 0) as receita_media
    FROM ordens_servico os
    WHERE os.data_entrada >= p_data_inicio 
      AND os.data_entrada <= p_data_fim
      AND os.status = 'Finalizado' -- ✅ APENAS FINALIZADAS
      AND (p_user_id IS NULL OR os.user_id = p_user_id)
    GROUP BY 
      os.equipamento,
      os.marca, 
      os.modelo, 
      os.tipo
  )
  SELECT 
    rd.equipamento,
    rd.total_reparos,
    rd.receita_total,
    rd.receita_media,
    CASE 
      WHEN (SELECT v_total_reparos FROM total_reparos) > 0 
      THEN ROUND((rd.total_reparos::NUMERIC / (SELECT v_total_reparos FROM total_reparos)::NUMERIC * 100), 1)
      ELSE 0 
    END as percentual
  FROM ranking_data rd
  ORDER BY rd.total_reparos DESC, rd.receita_total DESC
  LIMIT p_limite;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- CONCEDER PERMISSÕES
-- ============================================================================
GRANT EXECUTE ON FUNCTION fn_ranking_clientes_reparos TO authenticated;
GRANT EXECUTE ON FUNCTION fn_ranking_clientes_gastos TO authenticated;
GRANT EXECUTE ON FUNCTION fn_ranking_equipamentos TO authenticated;

-- ============================================================================
-- ✅ SUCESSO!
-- ============================================================================
DO $$ 
BEGIN 
  RAISE NOTICE '✅ Funções de ranking corrigidas para considerar apenas status "Finalizado"';
  RAISE NOTICE '✅ Todas as funções agora filtram: WHERE status = ''Finalizado''';
  RAISE NOTICE '✅ Rankings mostrarão apenas ordens concluídas com valores reais';
END $$;
