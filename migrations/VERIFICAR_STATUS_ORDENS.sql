-- ============================================================================
-- VERIFICAR STATUS DAS ORDENS DE SERVIÇO
-- ============================================================================
-- Objetivo: Descobrir quais valores de status existem na tabela ordens_servico
-- ============================================================================

-- 1️⃣ LISTAR TODOS OS STATUS ÚNICOS
SELECT 
  status,
  COUNT(*) as quantidade,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual
FROM ordens_servico
GROUP BY status
ORDER BY quantidade DESC;

-- 2️⃣ VERIFICAR ORDENS COM VALORES
SELECT 
  status,
  COUNT(*) as quantidade,
  COUNT(CASE WHEN valor IS NOT NULL AND valor > 0 THEN 1 END) as com_valor,
  COUNT(CASE WHEN valor_final IS NOT NULL AND valor_final > 0 THEN 1 END) as com_valor_final,
  COUNT(CASE WHEN valor_orcamento IS NOT NULL AND valor_orcamento > 0 THEN 1 END) as com_valor_orcamento
FROM ordens_servico
GROUP BY status
ORDER BY quantidade DESC;

-- 3️⃣ VERIFICAR ORDENS DOS ÚLTIMOS 30 DIAS
SELECT 
  status,
  COUNT(*) as quantidade_ultimos_30_dias
FROM ordens_servico
WHERE data_entrada >= NOW() - INTERVAL '30 days'
GROUP BY status
ORDER BY quantidade_ultimos_30_dias DESC;

-- 4️⃣ AMOSTRA DE ORDENS COM DIFERENTES STATUS
SELECT 
  id,
  status,
  cliente_id,
  valor,
  valor_orcamento,
  valor_final,
  data_entrada,
  created_at
FROM ordens_servico
ORDER BY data_entrada DESC
LIMIT 20;
