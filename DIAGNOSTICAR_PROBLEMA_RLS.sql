-- DIAGNÓSTICO: POR QUE CLIENTES APARECEM PARA TODOS OS USUÁRIOS
-- Execute este script para identificar o problema

-- 1. Verificar políticas RLS ativas
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename IN ('clientes', 'produtos')
ORDER BY tablename, policyname;

-- 2. Verificar se RLS está habilitado
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_habilitado
FROM pg_tables 
WHERE tablename IN ('clientes', 'produtos')
AND schemaname = 'public';

-- 3. Verificar distribuição de user_id nos clientes
SELECT 
    user_id,
    COUNT(*) as quantidade,
    CASE 
        WHEN user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID THEN 'assistenciaallimport10@gmail.com'
        WHEN user_id IS NULL THEN 'SEM USER_ID'
        ELSE 'OUTRO USUÁRIO'
    END as usuario
FROM public.clientes
GROUP BY user_id
ORDER BY quantidade DESC;

-- 4. Verificar distribuição de user_id nos produtos
SELECT 
    user_id,
    COUNT(*) as quantidade,
    CASE 
        WHEN user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID THEN 'assistenciaallimport10@gmail.com'
        WHEN user_id IS NULL THEN 'SEM USER_ID'  
        ELSE 'OUTRO USUÁRIO'
    END as usuario
FROM public.produtos
GROUP BY user_id
ORDER BY quantidade DESC;

-- 5. Testar acesso direto (simulando frontend)
-- Este SELECT deve retornar APENAS dados do usuário específico
SELECT 'TESTE CLIENTES' as tipo, COUNT(*) as total 
FROM public.clientes
WHERE ativo = true;

-- 6. Teste específico por user_id
SELECT 'CLIENTES COM USER_ID CORRETO' as tipo, COUNT(*) as total
FROM public.clientes  
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'::UUID;

-- 7. Verificar se há dados "órfãos" sem user_id
SELECT 'CLIENTES SEM USER_ID' as tipo, COUNT(*) as total
FROM public.clientes
WHERE user_id IS NULL;
