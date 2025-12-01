-- ============================================================================
-- VERIFICAR E CORRIGIR ORDENS DE SERVIÇO ANTIGAS DO BACKUP
-- ============================================================================

-- 1️⃣ VERIFICAR ORDENS COM VALORES ZERADOS
SELECT 
  id,
  cliente_id,
  marca,
  modelo,
  tipo,
  data_entrada,
  valor_orcamento,
  valor_final,
  status,
  CASE 
    WHEN valor_orcamento IS NULL AND valor_final IS NULL THEN '❌ SEM VALOR'
    WHEN valor_orcamento = 0 AND valor_final = 0 THEN '⚠️ ZERADO'
    ELSE '✅ OK'
  END as status_valor,
  CASE
    WHEN marca IS NULL AND modelo IS NULL THEN '❌ SEM EQUIPAMENTO'
    WHEN TRIM(marca) = '' AND TRIM(modelo) = '' THEN '⚠️ VAZIO'
    ELSE '✅ OK'
  END as status_equipamento
FROM ordens_servico
WHERE data_entrada < '2025-11-01'  -- Ordens antigas
ORDER BY data_entrada DESC;

-- 2️⃣ CONTAR PROBLEMAS
SELECT 
  COUNT(*) as total_ordens,
  COUNT(CASE WHEN valor_orcamento IS NULL AND valor_final IS NULL THEN 1 END) as sem_valor,
  COUNT(CASE WHEN COALESCE(valor_orcamento, 0) = 0 AND COALESCE(valor_final, 0) = 0 THEN 1 END) as valor_zero,
  COUNT(CASE WHEN marca IS NULL OR TRIM(marca) = '' THEN 1 END) as sem_marca,
  COUNT(CASE WHEN modelo IS NULL OR TRIM(modelo) = '' THEN 1 END) as sem_modelo
FROM ordens_servico
WHERE data_entrada < '2025-11-01';

-- 3️⃣ VER TODAS AS COLUNAS DAS ORDENS ANTIGAS
SELECT *
FROM ordens_servico
WHERE data_entrada < '2025-11-01'
ORDER BY data_entrada DESC
LIMIT 10;

-- ============================================================================
-- 💡 ANÁLISE:
-- Execute essas queries para ver:
-- 1. Quais ordens têm valores zerados
-- 2. Quais ordens não têm informação de equipamento
-- 3. Dados completos das ordens antigas para entender a estrutura
-- ============================================================================
