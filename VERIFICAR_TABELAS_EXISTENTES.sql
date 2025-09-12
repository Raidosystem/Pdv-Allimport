-- VERIFICAR TABELAS EXISTENTES
-- Execute este primeiro para ver que tabelas existem

SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name LIKE '%subscription%' OR table_name LIKE '%user%'
ORDER BY table_name;