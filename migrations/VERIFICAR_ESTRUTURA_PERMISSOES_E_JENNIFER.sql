-- ============================================
-- VERIFICAR ESTRUTURA DA TABELA permissoes
-- ============================================

-- Ver todas as colunas da tabela permissoes
SELECT 
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'permissoes'
ORDER BY ordinal_position;

-- Ver dados de exemplo
SELECT * FROM permissoes LIMIT 10;

-- Ver funcionario jennifer
SELECT * FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%';
