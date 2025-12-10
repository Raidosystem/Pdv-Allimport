-- ============================================
-- DESCOBRIR ESTRUTURA DA TABELA LOGIN_FUNCIONARIOS
-- ============================================

-- 1. Ver todas as colunas da tabela login_funcionarios
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable,
    character_maximum_length
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name = 'login_funcionarios' 
ORDER BY ordinal_position;

-- 2. Ver dados existentes (se houver)
SELECT *
FROM login_funcionarios
LIMIT 5;

-- 3. Ver estrutura de todas as tabelas relacionadas
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND (
    table_name = 'login_funcionarios' 
    OR table_name = 'funcionarios'
  )
ORDER BY table_name, ordinal_position;

-- ============================================
-- Execute este script para ver as colunas corretas
-- ============================================
