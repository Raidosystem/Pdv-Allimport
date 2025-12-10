-- ============================================================================
-- FINALIZAR ORDENS ANTIGAS DO BACKUP QUE JÁ TÊM VALORES
-- ============================================================================
-- Objetivo: Marcar como "Entregue" as ordens antigas que têm valor preenchido
-- Isso permitirá que apareçam nos rankings
-- ============================================================================

-- 1️⃣ VERIFICAR ORDENS QUE SERÃO ATUALIZADAS
SELECT 
  id,
  cliente_id,
  status AS status_atual,
  valor,
  valor_orcamento,
  valor_final,
  data_entrada,
  COALESCE(valor_final, valor_orcamento, valor) as valor_considerado
FROM ordens_servico
WHERE status != 'Entregue'
  AND status != 'entregue'
  AND status != 'Finalizado'
  AND (
    (valor IS NOT NULL AND valor > 0) OR
    (valor_orcamento IS NOT NULL AND valor_orcamento > 0) OR
    (valor_final IS NOT NULL AND valor_final > 0)
  )
  AND data_entrada < '2025-07-01' -- Apenas ordens antigas (antes de julho)
ORDER BY data_entrada DESC
LIMIT 20;

-- 2️⃣ CONTAR QUANTAS ORDENS SERÃO AFETADAS
SELECT 
  COUNT(*) as total_ordens_a_finalizar,
  SUM(COALESCE(valor_final, valor_orcamento, valor, 0)) as valor_total
FROM ordens_servico
WHERE status != 'Entregue'
  AND status != 'entregue'
  AND status != 'Finalizado'
  AND (
    (valor IS NOT NULL AND valor > 0) OR
    (valor_orcamento IS NOT NULL AND valor_orcamento > 0) OR
    (valor_final IS NOT NULL AND valor_final > 0)
  )
  AND data_entrada < '2025-07-01';

-- ============================================================================
-- ⚠️ ATENÇÃO: DESCOMENTE A QUERY ABAIXO APENAS DEPOIS DE VERIFICAR OS RESULTADOS ACIMA
-- ============================================================================

-- 3️⃣ ATUALIZAR STATUS PARA "Entregue" DAS ORDENS ANTIGAS COM VALOR
UPDATE ordens_servico
SET 
  status = 'Entregue',
  updated_at = NOW()
WHERE status != 'Entregue'
  AND status != 'entregue'
  AND status != 'Finalizado'
  AND (
    (valor IS NOT NULL AND valor > 0) OR
    (valor_orcamento IS NOT NULL AND valor_orcamento > 0) OR
    (valor_final IS NOT NULL AND valor_final > 0)
  )
  AND data_entrada < '2025-07-01'; -- Apenas ordens antigas

-- ============================================================================
-- ✅ INSTRUÇÕES
-- ============================================================================
-- 1. Execute PRIMEIRO as queries 1️⃣ e 2️⃣ para VERIFICAR quais ordens serão atualizadas
-- 2. Se estiver tudo OK, DESCOMENTE a query 3️⃣ (remova /* e */)
-- 3. Execute a query 3️⃣ para atualizar os status
-- 4. Atualize a página de Rankings para ver os dados
