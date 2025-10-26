-- =====================================================
-- VERIFICAR ESTRUTURA DA TABELA vendas_itens
-- =====================================================
-- Para descobrir qual campo está causando erro 400
-- =====================================================

-- 1. Ver estrutura completa da tabela
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'vendas_itens'
ORDER BY ordinal_position;

-- 2. Ver constraints (NOT NULL, UNIQUE, etc)
SELECT
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'vendas_itens';

-- 3. Ver últimos registros para comparar estrutura
SELECT * FROM vendas_itens 
ORDER BY created_at DESC 
LIMIT 3;

-- =====================================================
-- INSTRUÇÕES:
-- Execute este script no SQL Editor do Supabase
-- para ver a estrutura exata da tabela
-- =====================================================
