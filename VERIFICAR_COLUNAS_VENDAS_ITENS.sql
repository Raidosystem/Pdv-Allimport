-- ============================================================================
-- VERIFICAR ESTRUTURA DA TABELA vendas_itens
-- Execute para ver quais colunas existem
-- ============================================================================

-- Ver todas as colunas da tabela vendas_itens
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'vendas_itens'
ORDER BY ordinal_position;

-- Ver dados de exemplo (primeiras 5 linhas)
SELECT * FROM vendas_itens LIMIT 5;

-- Contar total de registros
SELECT COUNT(*) as total_itens FROM vendas_itens;

-- ============================================================================
-- 📝 COLUNAS ESPERADAS:
-- - venda_id (UUID)
-- - produto_id (UUID)
-- - quantidade (numeric)
-- - preco_unitario (numeric) ← Preço de venda
-- - subtotal (numeric) ← quantidade * preco_unitario
-- - custo_unitario (numeric) ← Custo do produto (pode não existir)
-- - custo_medio_na_venda (numeric) ← Custo médio (pode não existir)
-- ============================================================================
