-- =============================================
-- BUSCAR FUNCTION COM array_agg
-- =============================================

-- 1. Buscar functions que usam array_agg
SELECT 
    p.proname as function_name,
    n.nspname as schema_name,
    pg_get_functiondef(p.oid) as function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE pg_get_functiondef(p.oid) ILIKE '%array_agg%'
AND n.nspname = 'public'
ORDER BY p.proname;

-- 2. Listar TODOS os triggers da tabela clientes (simplificado)
SELECT 
    t.tgname as trigger_name,
    p.proname as function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'clientes'
AND NOT t.tgisinternal;

-- 3. Ver definição completa de cada trigger
SELECT 
    t.tgname as trigger_name,
    pg_get_triggerdef(t.oid) as definition
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
WHERE c.relname = 'clientes'
AND NOT t.tgisinternal;
