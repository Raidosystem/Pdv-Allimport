-- ============================================================================
-- CORRIGIR FUNÇÕES DE RANKING PARA USAR COLUNA 'valor' DO BACKUP
-- ============================================================================
-- Problema: Ordens antigas usam coluna 'valor', mas funções buscam 'valor_orcamento' e 'valor_final'
-- Solução: Adicionar COALESCE com 'valor' como fallback
-- ============================================================================

-- 1️⃣ FUNÇÃO: RANKING DE CLIENTES POR REPAROS
CREATE OR REPLACE FUNCTION fn_ranking_clientes_reparos(
  p_data_inicio TIMESTAMP WITH TIME ZONE,
  p_data_fim TIMESTAMP WITH TIME ZONE
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
      MAX(os.data_entrada) as ultima_ordem,
      ROW_NUMBER() OVER (ORDER BY COUNT(os.id) DESC) as ranking
    FROM ordens_servico os
    LEFT JOIN clientes c ON c.id = os.cliente_id
    WHERE os.data_entrada >= p_data_inicio 
      AND os.data_entrada <= p_data_fim
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
  LIMIT 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2️⃣ FUNÇÃO: RANKING DE EQUIPAMENTOS
CREATE OR REPLACE FUNCTION fn_ranking_equipamentos(
  p_data_inicio TIMESTAMP WITH TIME ZONE,
  p_data_fim TIMESTAMP WITH TIME ZONE
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
      THEN ROUND((rd.total_reparos::NUMERIC / (SELECT v_total_reparos FROM total_reparos)::NUMERIC) * 100, 2)
      ELSE 0
    END as percentual
  FROM ranking_data rd
  ORDER BY rd.total_reparos DESC, rd.receita_total DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3️⃣ FUNÇÃO: RANKING DE CLIENTES POR GASTOS
CREATE OR REPLACE FUNCTION fn_ranking_clientes_gastos(
  p_data_inicio TIMESTAMP WITH TIME ZONE,
  p_data_fim TIMESTAMP WITH TIME ZONE
)
RETURNS TABLE (
  cliente_id UUID,
  cliente_nome TEXT,
  gasto_total NUMERIC,
  total_ordens BIGINT,
  ticket_medio NUMERIC,
  ultima_compra TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  WITH ranking_data AS (
    SELECT 
      os.cliente_id,
      c.nome as cliente_nome,
      -- ✅ USAR 'valor' COMO FALLBACK
      COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) as gasto_total,
      COUNT(os.id) as total_ordens,
      COALESCE(AVG(os.valor_final), AVG(os.valor_orcamento), AVG(os.valor), 0) as ticket_medio,
      MAX(os.data_entrada) as ultima_compra,
      ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(os.valor_final), SUM(os.valor_orcamento), SUM(os.valor), 0) DESC) as ranking
    FROM ordens_servico os
    LEFT JOIN clientes c ON c.id = os.cliente_id
    WHERE os.data_entrada >= p_data_inicio 
      AND os.data_entrada <= p_data_fim
    GROUP BY os.cliente_id, c.nome
  )
  SELECT 
    rd.cliente_id,
    rd.cliente_nome,
    rd.gasto_total,
    rd.total_ordens,
    rd.ticket_medio,
    rd.ultima_compra
  FROM ranking_data rd
  ORDER BY rd.gasto_total DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- ✅ EXECUTAR NO SUPABASE SQL EDITOR
-- ============================================================================
-- Estas funções agora incluem:
-- 1. COALESCE(valor_final, valor_orcamento, valor, 0) - busca em todas colunas
-- 2. COALESCE(equipamento, marca+modelo, tipo) - usa campo 'equipamento' se existir
-- 
-- Isso resolve:
-- ✅ R$ 0,00 nas ordens antigas (agora usa coluna 'valor')
-- ✅ "Equipamento não especificado" (agora tenta coluna 'equipamento' primeiro)
-- ============================================================================
