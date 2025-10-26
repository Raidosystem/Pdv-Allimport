-- ============================================
-- CALCULAR GARANTIA_MESES A PARTIR DE GARANTIA_DIAS
-- ============================================

-- 1. Ver campos de garantia atuais
SELECT 
  numero_os,
  garantia_dias,
  garantia_meses,
  data_fim_garantia
FROM ordens_servico
ORDER BY data_entrada DESC
LIMIT 10;

-- 2. Calcular garantia_meses e data_fim_garantia
UPDATE ordens_servico
SET 
  garantia_meses = ROUND(garantia_dias::numeric / 30, 0)::integer,
  data_fim_garantia = (data_entrega + (garantia_dias || ' days')::interval)::date
WHERE garantia_dias IS NOT NULL;

-- 3. Verificar resultado
SELECT 
  COUNT(*) as total,
  COUNT(garantia_dias) as tem_garantia_dias,
  COUNT(garantia_meses) as tem_garantia_meses,
  COUNT(data_fim_garantia) as tem_data_fim_garantia
FROM ordens_servico;

-- 4. Ver exemplos atualizados
SELECT 
  numero_os,
  garantia_dias,
  garantia_meses,
  data_entrega,
  data_fim_garantia
FROM ordens_servico
WHERE garantia_dias IS NOT NULL
ORDER BY data_entrada DESC
LIMIT 10;

-- ============================================
-- RESULTADO ESPERADO:
-- - 90 dias = 3 meses
-- - 150 dias = 5 meses
-- - 180 dias = 6 meses
-- ============================================
