-- ========================================
-- VERIFICAR ESTRUTURA DA TABELA USER_APPROVALS
-- ========================================

-- 1. Ver todas as colunas da tabela
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_approvals'
ORDER BY ordinal_position;

-- 2. Ver dados atuais
SELECT *
FROM user_approvals
LIMIT 10;
