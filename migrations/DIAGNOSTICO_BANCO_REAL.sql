-- =========================================
-- DIAGNÓSTICO COMPLETO: Verificar estrutura real do banco
-- Execute este SQL para ver TUDO que existe no Supabase
-- =========================================

-- ========================================
-- 1. LISTAR TODAS AS FUNÇÕES/RPCs
-- ========================================
SELECT 
    n.nspname as schema,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    pg_get_function_result(p.oid) as return_type,
    l.lanname as language,
    CASE 
        WHEN p.provolatile = 'i' THEN 'IMMUTABLE'
        WHEN p.provolatile = 's' THEN 'STABLE'
        WHEN p.provolatile = 'v' THEN 'VOLATILE'
    END as volatility,
    CASE 
        WHEN p.prosecdef THEN 'SECURITY DEFINER'
        ELSE 'SECURITY INVOKER'
    END as security
FROM pg_proc p
LEFT JOIN pg_namespace n ON p.pronamespace = n.oid
LEFT JOIN pg_language l ON p.prolang = l.oid
WHERE n.nspname = 'public'
AND p.prokind = 'f'  -- Apenas funções (não procedures)
ORDER BY p.proname;

-- ========================================
-- 2. LISTAR TODAS AS TABELAS
-- ========================================
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- ========================================
-- 3. VERIFICAR POLÍTICAS RLS
-- ========================================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual as using_expression,
    with_check as with_check_expression
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ========================================
-- 4. VERIFICAR TABELAS COM RLS ATIVADO
-- ========================================
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- ========================================
-- 5. LISTAR TRIGGERS
-- ========================================
SELECT 
    event_object_table as table_name,
    trigger_name,
    event_manipulation as event,
    action_timing as timing,
    action_statement as function_called
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- ========================================
-- 6. VERIFICAR EXTENSÕES INSTALADAS
-- ========================================
SELECT 
    extname as extension_name,
    extversion as version
FROM pg_extension
ORDER BY extname;

-- ========================================
-- 7. ESTRUTURA DA TABELA funcionarios
-- ========================================
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'funcionarios'
ORDER BY ordinal_position;

-- ========================================
-- 8. ESTRUTURA DA TABELA login_funcionarios
-- ========================================
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'login_funcionarios'
ORDER BY ordinal_position;

-- ========================================
-- 9. ESTRUTURA DA TABELA produtos
-- ========================================
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'produtos'
ORDER BY ordinal_position;

-- ========================================
-- 10. VERIFICAR SE FUNÇÕES CRÍTICAS EXISTEM
-- ========================================
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'check_subscription_status') 
        THEN '✅ check_subscription_status'
        ELSE '❌ check_subscription_status NÃO EXISTE'
    END as status
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'atualizar_senha_funcionario') 
        THEN '✅ atualizar_senha_funcionario'
        ELSE '❌ atualizar_senha_funcionario NÃO EXISTE'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validar_senha_local') 
        THEN '✅ validar_senha_local'
        ELSE '❌ validar_senha_local NÃO EXISTE'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_all_empresas_admin') 
        THEN '✅ get_all_empresas_admin'
        ELSE '❌ get_all_empresas_admin NÃO EXISTE'
    END
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'admin_add_subscription_days') 
        THEN '✅ admin_add_subscription_days'
        ELSE '❌ admin_add_subscription_days NÃO EXISTE'
    END;

-- ========================================
-- RESULTADO FINAL
-- ========================================
SELECT '✅ DIAGNÓSTICO COMPLETO - Revise os resultados acima' as status;
