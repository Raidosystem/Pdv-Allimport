-- ============================================================================
-- FUNÇÕES DE RANKING COM MÚLTIPLOS STATUS DE CONCLUSÃO
-- ============================================================================
-- Solução: Aceitar "fechada", "Finalizado", "Finalizada", "Entregue", "Concluído"
-- Importante: NÃO quebrar a seção de Ordens de Serviço do sistema
-- ============================================================================

-- ⚠️ REMOVER FUNÇÕES ANTIGAS
DROP FUNCTION IF EXISTS fn_ranking_clientes_reparos(timestamp with time zone, timestamp with time zone);
DROP FUNCTION IF EXISTS fn_ranking_clientes_reparos(timestamp with time zone, timestamp with time zone, uuid, integer);
DROP FUNCTION IF EXISTS fn_ranking_clientes_gastos(timestamp with time zone, timestamp with time zone);
DROP FUNCTION IF EXISTS fn_ranking_clientes_gastos(timestamp with time zone, timestamp with time zone, uuid, integer);
DROP FUNCTION IF EXISTS fn_ranking_equipamentos(timestamp with time zone, timestamp with time zone);
DROP FUNCTION IF EXISTS fn_ranking_equipamentos(timestamp with time zone, timestamp with time zone, uuid, integer);

-- 1️⃣ RANKING DE CLIENTES POR REPAROS (ACEITA MÚLTIPLOS STATUS)
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
      COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as valor_total,
      COALESCE(AVG(os.valor_final), AVG(os.valor_orcamento), AVG(os.valor), 0) as valor_medio,
      MAX(os.data_entrada) as ultima_ordem
    FROM ordens_servico os
    LEFT JOIN clientes c ON c.id = os.cliente_id
    WHERE os.data_entrada >= p_data_inicio 
      AND os.data_entrada <= p_data_fim
      -- ✅ ACEITAR MÚLTIPLOS STATUS DE CONCLUSÃO (backup + sistema atual)
      AND LOWER(os.status) IN ('fechada', 'finalizado', 'finalizada', 'entregue', 'concluído', 'concluida')
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

-- 2️⃣ RANKING DE CLIENTES POR GASTOS (ACEITA MÚLTIPLOS STATUS)
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
      COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as gasto_total,
      COALESCE(AVG(os.valor_final), AVG(os.valor_orcamento), AVG(os.valor), 0) as ticket_medio
    FROM ordens_servico os
    LEFT JOIN clientes c ON c.id = os.cliente_id
    WHERE os.data_entrada >= p_data_inicio 
      AND os.data_entrada <= p_data_fim
      -- ✅ ACEITAR MÚLTIPLOS STATUS DE CONCLUSÃO
      AND LOWER(os.status) IN ('fechada', 'finalizado', 'finalizada', 'entregue', 'concluído', 'concluida')
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

-- 3️⃣ RANKING DE EQUIPAMENTOS (ACEITA MÚLTIPLOS STATUS)
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
      -- ✅ ACEITAR MÚLTIPLOS STATUS DE CONCLUSÃO
      AND LOWER(status) IN ('fechada', 'finalizado', 'finalizada', 'entregue', 'concluído', 'concluida')
      AND (p_user_id IS NULL OR user_id = p_user_id)
  ),
  ranking_data AS (
    SELECT 
      -- ✅ PRIORIZAR O TIPO (celular, notebook, game) AO INVÉS DE MARCA/MODELO
      COALESCE(
        NULLIF(TRIM(os.tipo), ''),
        'Tipo não especificado'
      ) as equipamento,
      COUNT(os.id) as total_reparos,
      COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as receita_total,
      COALESCE(AVG(os.valor_final), AVG(os.valor_orcamento), AVG(os.valor), 0) as receita_media
    FROM ordens_servico os
    WHERE os.data_entrada >= p_data_inicio 
      AND os.data_entrada <= p_data_fim
      -- ✅ ACEITAR MÚLTIPLOS STATUS DE CONCLUSÃO
      AND LOWER(os.status) IN ('fechada', 'finalizado', 'finalizada', 'entregue', 'concluído', 'concluida')
      AND (p_user_id IS NULL OR os.user_id = p_user_id)
    GROUP BY os.tipo
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
  RAISE NOTICE '✅ Funções corrigidas para aceitar múltiplos status de conclusão';
  RAISE NOTICE '✅ Status aceitos: fechada, Finalizado, Finalizada, Entregue, Concluído';
  RAISE NOTICE '✅ Compatível com backup (fechada) E sistema atual (Finalizado)';
  RAISE NOTICE '⚠️ Não afeta a seção Ordens de Serviço do sistema';
END $$;
