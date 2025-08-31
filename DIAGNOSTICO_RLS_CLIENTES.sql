-- DIAGNÓSTICO DO PROBLEMA RLS - CLIENTES
-- Verificar políticas de segurança que podem estar bloqueando acesso

-- 1. Verificar se RLS está habilitado
SELECT 
    schemaname, 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE tablename = 'clientes' AND schemaname = 'public';

-- 2. Verificar políticas RLS ativas
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
WHERE tablename = 'clientes';

-- 3. Tentar acessar clientes como usuário autenticado
SELECT COUNT(*) as total_clientes FROM public.clientes;

-- 4. Verificar se consegue acessar dados específicos
SELECT id, nome, telefone, ativo 
FROM public.clientes 
WHERE ativo = true 
LIMIT 5;
