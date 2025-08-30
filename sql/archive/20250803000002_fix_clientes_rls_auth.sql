-- Migration: Fix clientes RLS policies with correct authentication check
-- Date: 2025-08-03
-- Description: Update RLS policies to use auth.uid() instead of auth.role()

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;

-- Create new policies using auth.uid() to check if user is authenticated
-- Allow authenticated users to view all clientes
CREATE POLICY "Authenticated users can view clientes" 
ON public.clientes FOR SELECT 
USING (auth.uid() IS NOT NULL);

-- Allow authenticated users to insert new clientes
CREATE POLICY "Authenticated users can insert clientes" 
ON public.clientes FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

-- Allow authenticated users to update clientes
CREATE POLICY "Authenticated users can update clientes" 
ON public.clientes FOR UPDATE 
USING (auth.uid() IS NOT NULL);

-- Allow authenticated users to delete clientes
CREATE POLICY "Authenticated users can delete clientes" 
ON public.clientes FOR DELETE 
USING (auth.uid() IS NOT NULL);
