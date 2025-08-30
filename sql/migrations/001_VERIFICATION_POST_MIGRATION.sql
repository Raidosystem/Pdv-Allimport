-- ===================================================
-- 🔍 VERIFICAÇÃO PÓS-MIGRAÇÃO
-- ===================================================
-- Execute este script APÓS rodar 000_MASTER_MIGRATION.sql
-- para verificar se tudo foi criado corretamente
-- ===================================================

-- 1. VERIFICAR TABELAS PRINCIPAIS
-- ===================================================
SELECT
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN (
        'profiles', 'categories', 'products', 'customers',
        'cash_registers', 'sales', 'sale_items', 'service_orders',
        'stock_movements', 'ordens_servico', 'caixa', 'movimentacoes_caixa'
    )
ORDER BY tablename;

-- 2. VERIFICAR COLUNAS DAS TABELAS PRINCIPAIS
-- ===================================================
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
    AND table_name IN ('products', 'customers', 'sales')
ORDER BY table_name, ordinal_position;

-- 3. VERIFICAR POLÍTICAS RLS
-- ===================================================
SELECT
    schemaname,
    tablename,
    rowsecurity as rls_enabled,
    polname as policy_name,
    polcmd as command,
    polroles as roles
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, polname;

-- 4. CONTAR REGISTROS NAS TABELAS PRINCIPAIS
-- ===================================================
SELECT
    'products' as table_name, COUNT(*) as total_records FROM products
UNION ALL
SELECT
    'customers' as table_name, COUNT(*) as total_records FROM customers
UNION ALL
SELECT
    'categories' as table_name, COUNT(*) as total_records FROM categories
UNION ALL
SELECT
    'sales' as table_name, COUNT(*) as total_records FROM sales
UNION ALL
SELECT
    'service_orders' as table_name, COUNT(*) as total_records FROM service_orders
ORDER BY table_name;

-- 5. VERIFICAR ÍNDICES
-- ===================================================
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename IN ('products', 'customers', 'sales', 'service_orders')
ORDER BY tablename, indexname;

-- 6. VERIFICAR TRIGGERS
-- ===================================================
SELECT
    event_object_schema,
    event_object_table,
    trigger_name,
    event_manipulation,
    action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- ===================================================
-- ✅ VERIFICAÇÃO CONCLUÍDA
-- ===================================================
-- Se tudo estiver OK, o banco está pronto para uso!
-- Status esperado: Todas as tabelas criadas, RLS configurado,
-- índices criados, e dados iniciais inseridos.
-- ===================================================
