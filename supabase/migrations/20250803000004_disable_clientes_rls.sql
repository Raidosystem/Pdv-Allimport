-- Migration: Temporary disable RLS for clientes table
-- Date: 2025-08-03
-- Description: Disable RLS temporarily to allow client creation while we debug the issue

-- Remove all existing policies
DROP POLICY IF EXISTS "clientes_select_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON public.clientes;
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
DROP POLICY IF EXISTS "authenticated_users_can_view_clientes" ON public.clientes;
DROP POLICY IF EXISTS "authenticated_users_can_insert_clientes" ON public.clientes;
DROP POLICY IF EXISTS "authenticated_users_can_update_clientes" ON public.clientes;
DROP POLICY IF EXISTS "authenticated_users_can_delete_clientes" ON public.clientes;

-- Disable RLS completely for clientes table (same as categories table)
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- Grant access to authenticated and anon users
GRANT ALL ON public.clientes TO authenticated;
GRANT ALL ON public.clientes TO anon;
GRANT ALL ON public.clientes TO service_role;

-- Grant sequence access
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;
