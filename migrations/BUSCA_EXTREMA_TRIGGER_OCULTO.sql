-- =============================================
-- BUSCA EXTREMA: ENCONTRAR TRIGGER OCULTO
-- =============================================

-- 1. Listar TODOS os triggers de TODAS as tabelas do schema public
SELECT 
    c.relname AS table_name,
    t.tgname AS trigger_name,
    t.tgenabled AS enabled,
    p.proname AS function_name,
    pg_get_functiondef(p.oid) AS function_source
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE n.nspname = 'public'
    AND t.tgisinternal = false
    AND (
        pg_get_functiondef(p.oid) ILIKE '%usuario_id%'
        OR pg_get_functiondef(p.oid) ILIKE '%user_id%'
    )
ORDER BY c.relname, t.tgname;

-- 2. Buscar TODAS as funções que mencionam usuario_id
SELECT 
    p.proname AS function_name,
    n.nspname AS schema_name,
    pg_get_functiondef(p.oid) AS function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE pg_get_functiondef(p.oid) ILIKE '%usuario_id%'
ORDER BY n.nspname, p.proname;

-- 3. SOLUÇÃO EXTREMA: Remover a coluna user_id temporariamente
-- ALTER TABLE clientes DROP COLUMN user_id CASCADE;
-- SELECT '⚠️ Coluna user_id REMOVIDA temporariamente!' as status;

-- 4. Ou: Renomear a coluna user_id para evitar conflitos
-- ALTER TABLE clientes RENAME COLUMN user_id TO user_id_old;
-- SELECT '⚠️ Coluna user_id RENOMEADA!' as status;
