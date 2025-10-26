-- =============================================
-- BUSCAR TRIGGERS EM TODAS AS TABELAS
-- =============================================

-- 1. Listar TODOS os triggers de TODAS as tabelas
SELECT 
    c.relname AS table_name,
    t.tgname AS trigger_name,
    t.tgenabled AS enabled,
    t.tgisinternal AS is_internal,
    p.proname AS function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE n.nspname = 'public'
ORDER BY c.relname, t.tgname;

-- 2. Buscar especificamente por triggers que mencionam 'clientes'
SELECT 
    c.relname AS table_name,
    t.tgname AS trigger_name,
    p.proname AS function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE n.nspname = 'public'
    AND (
        t.tgname ILIKE '%cliente%'
        OR p.proname ILIKE '%cliente%'
    );

-- 3. SOLUÇÃO EXTREMA: Remover TODOS os triggers de TODAS as tabelas public
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT c.relname AS table_name, t.tgname AS trigger_name
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE n.nspname = 'public'
            AND t.tgisinternal = false
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I CASCADE', r.trigger_name, r.table_name);
        RAISE NOTICE 'Trigger % removido da tabela %', r.trigger_name, r.table_name;
    END LOOP;
END $$;

SELECT '✅ TODOS os triggers do schema public removidos!' as status;

-- 4. Verificar se ainda há triggers
SELECT 
    c.relname AS table_name,
    COUNT(*) as total_triggers
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
    AND t.tgisinternal = false
GROUP BY c.relname;
