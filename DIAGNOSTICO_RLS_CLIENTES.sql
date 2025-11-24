-- ============================================
-- DIAGNÓSTICO COMPLETO - POLÍTICAS RLS CLIENTES
-- ============================================

-- 1. Ver todas as políticas RLS da tabela CLIENTES
SELECT 
    '📋 POLÍTICAS RLS - CLIENTES' as info,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY cmd, policyname;

-- 2. Verificar se RLS está ativado
SELECT 
    '🔒 RLS ATIVADO?' as info,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename = 'clientes';

-- 3. Testar consulta simples (deve retornar clientes da sua empresa)
SELECT 
    '🧪 TESTE DE CONSULTA' as info,
    COUNT(*) as total_clientes,
    empresa_id
FROM clientes
GROUP BY empresa_id;

-- 4. Verificar estrutura da tabela clientes
SELECT 
    '📊 ESTRUTURA CLIENTES' as info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'clientes'
AND table_schema = 'public'
ORDER BY ordinal_position;
