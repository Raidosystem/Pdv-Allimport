-- ============================================
-- VERIFICAR ESTRUTURA DA TABELA funcao_permissoes
-- ============================================

-- Ver todas as colunas da tabela
SELECT 
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- Ver dados de exemplo
SELECT * FROM funcao_permissoes LIMIT 5;
