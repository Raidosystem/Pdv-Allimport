-- Migration: Final fix for clientes RLS policies
-- Date: 2025-08-03
-- Description: Complete fix for RLS policies with proper authentication check

-- Remove ALL existing policies to start fresh
DROP POLICY IF EXISTS "Authenticated users can view clientes" ON public.clientes;
DROP POLICY IF EXISTS "Authenticated users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Authenticated users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Authenticated users can delete clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.clientes;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.clientes;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.clientes;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.clientes;

-- Temporarily disable RLS to clean up
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- Re-enable RLS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Create comprehensive policies that work with Supabase Auth
-- Policy for SELECT (read)
CREATE POLICY "clientes_select_policy" ON public.clientes
    FOR SELECT 
    USING (
        auth.uid() IS NOT NULL
    );

-- Policy for INSERT (create)
CREATE POLICY "clientes_insert_policy" ON public.clientes
    FOR INSERT 
    WITH CHECK (
        auth.uid() IS NOT NULL
    );

-- Policy for UPDATE (modify)
CREATE POLICY "clientes_update_policy" ON public.clientes
    FOR UPDATE 
    USING (
        auth.uid() IS NOT NULL
    )
    WITH CHECK (
        auth.uid() IS NOT NULL
    );

-- Policy for DELETE (remove)
CREATE POLICY "clientes_delete_policy" ON public.clientes
    FOR DELETE 
    USING (
        auth.uid() IS NOT NULL
    );

-- Grant necessary permissions to authenticated role
GRANT ALL ON public.clientes TO authenticated;
GRANT ALL ON public.clientes TO service_role;

-- Ensure the sequence is accessible
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;
