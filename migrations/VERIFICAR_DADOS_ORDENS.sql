-- ============================================
-- VERIFICAR DADOS DAS ORDENS RESTAURADAS
-- ============================================

-- 1. Ver exemplo de ordens com TODOS os campos importantes
SELECT 
  numero_os,
  data_entrada,
  data_previsao,
  data_finalizacao,
  data_entrega,
  data_fim_garantia,
  garantia_meses,
  garantia_dias,
  status,
  valor,
  valor_orcamento,
  valor_final
FROM ordens_servico
ORDER BY data_entrada DESC
LIMIT 10;

-- 2. Contar quantos campos estão preenchidos
SELECT 
  COUNT(*) as total_ordens,
  COUNT(data_entrada) as tem_data_entrada,
  COUNT(data_previsao) as tem_data_previsao,
  COUNT(data_finalizacao) as tem_data_finalizacao,
  COUNT(data_entrega) as tem_data_entrega,
  COUNT(data_fim_garantia) as tem_data_fim_garantia,
  COUNT(garantia_meses) as tem_garantia_meses,
  COUNT(garantia_dias) as tem_garantia_dias,
  COUNT(valor) as tem_valor,
  COUNT(valor_final) as tem_valor_final
FROM ordens_servico;

-- 3. Ver dados completos de 3 ordens específicas
SELECT *
FROM ordens_servico
WHERE numero_os IN ('OS-2025-06-17-001', 'OS-2025-06-17-002', 'OS-2025-06-17-003')
ORDER BY numero_os;

-- ============================================
-- Resultado esperado:
-- - Query 1: Mostra se datas e garantias estão NULL
-- - Query 2: Conta quantos registros têm cada campo
-- - Query 3: Mostra TODOS os dados de 3 ordens
-- ============================================
