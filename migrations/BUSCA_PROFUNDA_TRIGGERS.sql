-- =============================================
-- BUSCA PROFUNDA POR TRIGGERS E CONSTRAINTS
-- =============================================

-- 1. Ver TODOS os triggers no banco (não só da tabela clientes)
SELECT 
    t.trigger_name,
    t.event_object_table,
    t.event_manipulation,
    t.action_timing,
    t.action_statement,
    p.proname as function_name,
    p.prosrc as function_source
FROM information_schema.triggers t
LEFT JOIN pg_proc p ON t.action_statement LIKE '%' || p.proname || '%'
WHERE t.event_object_schema = 'public'
ORDER BY t.event_object_table, t.trigger_name;

-- 2. Ver todas as foreign keys relacionadas a 'users'
SELECT
    tc.table_name,
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND (ccu.table_name = 'users' OR tc.table_name = 'users');

-- 3. Ver todas as funções que mencionam 'users'
SELECT 
    routine_name,
    routine_type,
    routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND (
        routine_definition ILIKE '%users%'
        OR routine_name ILIKE '%user%'
    )
ORDER BY routine_name;

-- 4. SOLUÇÃO DRÁSTICA: Remover foreign key de user_id se existir
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS clientes_user_id_fkey;
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS fk_user_id;

SELECT '✅ Foreign keys de user_id removidas!' as status;

-- 5. Verificar se ainda há constraints
SELECT 
    tc.constraint_name,
    tc.table_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_name = 'clientes'
ORDER BY tc.constraint_type, tc.constraint_name;
