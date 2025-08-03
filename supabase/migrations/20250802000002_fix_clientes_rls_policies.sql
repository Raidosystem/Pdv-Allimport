-- Migration: Fix clientes RLS policies
-- Date: 2025-08-02
-- Description: Fix RLS policies for clientes table to allow authenticated users to create clients

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;

-- Create new RLS policies using auth.uid() instead of auth.role()
-- Allow authenticated users to view all clientes
CREATE POLICY "authenticated_users_can_view_clientes" 
ON public.clientes FOR SELECT 
USING (auth.uid() IS NOT NULL);

-- Allow authenticated users to insert new clientes
CREATE POLICY "authenticated_users_can_insert_clientes" 
ON public.clientes FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

-- Allow authenticated users to update clientes
CREATE POLICY "authenticated_users_can_update_clientes" 
ON public.clientes FOR UPDATE 
USING (auth.uid() IS NOT NULL)
WITH CHECK (auth.uid() IS NOT NULL);

-- Allow authenticated users to delete clientes
CREATE POLICY "authenticated_users_can_delete_clientes" 
ON public.clientes FOR DELETE 
USING (auth.uid() IS NOT NULL);
