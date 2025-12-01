-- ============================================================================
-- DIAGNÓSTICO: Verificar status e dados das vendas
-- Execute no Supabase SQL Editor para entender por que DRE está zerado
-- ============================================================================

-- 1️⃣ Ver quantas vendas existem e seus status
SELECT 
  status,
  COUNT(*) as quantidade,
  SUM(total) as total_vendas,
  SUM(desconto) as total_descontos,
  MIN(created_at) as primeira_venda,
  MAX(created_at) as ultima_venda
FROM vendas
GROUP BY status;

-- 2️⃣ Ver as últimas 10 vendas com detalhes
SELECT 
  id,
  total,
  desconto,
  status,
  created_at,
  user_id,
  empresa_id,
  DATE(created_at) as data_venda
FROM vendas
ORDER BY created_at DESC
LIMIT 10;

-- 3️⃣ Verificar se vendas_itens tem dados
SELECT 
  COUNT(*) as total_itens,
  COUNT(DISTINCT venda_id) as vendas_com_itens,
  SUM(quantidade) as quantidade_total,
  SUM(custo_medio_na_venda * quantidade) as cmv_total
FROM vendas_itens;

-- 4️⃣ Ver vendas de novembro de 2025
SELECT 
  COUNT(*) as vendas_novembro,
  SUM(total) as total_novembro,
  SUM(desconto) as descontos_novembro
FROM vendas
WHERE created_at >= '2025-11-01'::timestamp
  AND created_at < '2025-12-01'::timestamp;

-- 5️⃣ Verificar se existe campo status com valores diferentes
SELECT DISTINCT status, COUNT(*) 
FROM vendas 
GROUP BY status;

-- 6️⃣ Ver se há vendas SEM status definido
SELECT COUNT(*) as vendas_sem_status
FROM vendas
WHERE status IS NULL;

-- ============================================================================
-- 📊 RESULTADO ESPERADO:
-- - Se status for NULL ou diferente de 'completed', a DRE não vai pegar
-- - Se created_at não estiver em novembro 2025, não vai aparecer
-- - Se vendas_itens estiver vazio, CMV será estimado em 60%
-- ============================================================================
