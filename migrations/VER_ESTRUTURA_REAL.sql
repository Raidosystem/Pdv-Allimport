-- ============================================
-- VERIFICAR ESTRUTURA REAL DA TABELA
-- ============================================

SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
ORDER BY ordinal_position;
