-- =====================================================
-- VERIFICAR ESTRUTURA DA TABELA FUNCOES
-- =====================================================

-- Ver todas as colunas da tabela funcoes
SELECT 
  column_name,
  data_type,
  column_default,
  is_nullable,
  character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'funcoes'
ORDER BY ordinal_position;

-- Ver dados de exemplo
SELECT * FROM funcoes LIMIT 5;
