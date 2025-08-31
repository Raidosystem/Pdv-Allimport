-- CORRIGIR RLS CLIENTES - PERMITIR ACESSO LOCAL E DESENVOLVIMENTO
-- Este script corrige as políticas RLS para permitir acesso durante desenvolvimento

-- 1. Remover políticas restritivas existentes
DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;

-- 2. Criar políticas mais permissivas para desenvolvimento
-- IMPORTANTE: Estas políticas permitem acesso completo - ajustar para produção

-- Política para SELECT (visualização)
CREATE POLICY "Allow all select on clientes" 
ON public.clientes FOR SELECT 
USING (true);

-- Política para INSERT (criação)
CREATE POLICY "Allow all insert on clientes" 
ON public.clientes FOR INSERT 
WITH CHECK (true);

-- Política para UPDATE (atualização)
CREATE POLICY "Allow all update on clientes" 
ON public.clientes FOR UPDATE 
USING (true)
WITH CHECK (true);

-- Política para DELETE (exclusão)
CREATE POLICY "Allow all delete on clientes" 
ON public.clientes FOR DELETE 
USING (true);

-- 3. Verificar se as políticas foram aplicadas
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename = 'clientes';

-- 4. Testar acesso aos dados
SELECT COUNT(*) as total_clientes FROM public.clientes;
SELECT id, nome, telefone, ativo FROM public.clientes WHERE ativo = true LIMIT 3;
