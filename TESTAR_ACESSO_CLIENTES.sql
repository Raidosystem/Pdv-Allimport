-- Verificar se existe problema de RLS bloqueando acesso aos clientes
-- Teste simples de acesso à tabela clientes

-- 1. Verificar se a tabela existe
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'clientes'
);

-- 2. Contar registros na tabela clientes
SELECT COUNT(*) as total_clientes FROM clientes;

-- 3. Verificar políticas RLS ativas
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'clientes';

-- 4. Verificar se RLS está habilitado
SELECT 
    schemaname, 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE tablename = 'clientes';

-- 5. Tentar buscar alguns clientes
SELECT 
    id,
    nome,
    telefone,
    ativo
FROM clientes
WHERE ativo = true
LIMIT 5;
