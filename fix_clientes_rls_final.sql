-- Script para diagnosticar e corrigir políticas RLS da tabela clientes
-- Execute este script no Supabase Dashboard -> SQL Editor

-- 1. Verificar se a tabela existe e tem RLS habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'clientes';

-- 2. Verificar políticas existentes
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

-- 3. Remover todas as políticas existentes
DROP POLICY IF EXISTS "Authenticated users can view clientes" ON public.clientes;
DROP POLICY IF EXISTS "Authenticated users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Authenticated users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Authenticated users can delete clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;

-- 4. Desabilitar RLS temporariamente
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- 5. Reabilitar RLS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- 6. Criar políticas mais simples e diretas
CREATE POLICY "Enable read access for authenticated users" ON public.clientes
    FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Enable insert for authenticated users" ON public.clientes
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable update for authenticated users" ON public.clientes
    FOR UPDATE USING (auth.uid() IS NOT NULL);

CREATE POLICY "Enable delete for authenticated users" ON public.clientes
    FOR DELETE USING (auth.uid() IS NOT NULL);

-- 7. Verificar se as políticas foram criadas corretamente
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'clientes';

-- 8. Testar inserção (descomente para testar)
-- INSERT INTO public.clientes (nome, telefone, email) 
-- VALUES ('Teste Cliente', '(11) 99999-9999', 'teste@email.com');
