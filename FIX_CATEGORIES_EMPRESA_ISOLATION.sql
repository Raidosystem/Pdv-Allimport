-- ==============================================================================
-- Fix Categories Isolation by Empresa (Company)
-- ==============================================================================
-- This migration adds empresa_id column to categories table and implements
-- proper RLS policies to ensure each user only sees their company's categories.
-- ==============================================================================

-- Step 1: Add empresa_id column to categories if it doesn't exist
ALTER TABLE public.categories 
ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES auth.users(id);

-- Step 2: Create index on empresa_id for better query performance
CREATE INDEX IF NOT EXISTS idx_categories_empresa_id ON public.categories(empresa_id);

-- Step 3: Create composite index for queries filtering by both empresa_id and name
CREATE INDEX IF NOT EXISTS idx_categories_empresa_name ON public.categories(empresa_id, name);

-- Step 4: Drop existing RLS policies on categories to replace them
DROP POLICY IF EXISTS "Authenticated users can view categories" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem criar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem editar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem deletar categorias" ON public.categories;
DROP POLICY IF EXISTS "Users can only see own categories" ON public.categories;
DROP POLICY IF EXISTS "super_access_categories" ON public.categories;
DROP POLICY IF EXISTS "assistencia_full_access_categories" ON public.categories;
DROP POLICY IF EXISTS "Permitir leitura de categorias para usuários autenticados" ON public.categories;

-- Step 5: Ensure RLS is enabled on categories table
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Step 6: Create new RLS policies with empresa_id isolation

-- Policy for SELECT (read): Users can only see categories from their empresa
CREATE POLICY "categories_select_own_empresa" ON public.categories
  FOR SELECT
  TO authenticated
  USING (empresa_id = auth.uid());

-- Policy for INSERT (create): Users can only create categories for their empresa
CREATE POLICY "categories_insert_own_empresa" ON public.categories
  FOR INSERT
  TO authenticated
  WITH CHECK (empresa_id = auth.uid());

-- Policy for UPDATE (edit): Users can only edit categories from their empresa
CREATE POLICY "categories_update_own_empresa" ON public.categories
  FOR UPDATE
  TO authenticated
  USING (empresa_id = auth.uid())
  WITH CHECK (empresa_id = auth.uid());

-- Policy for DELETE (delete): Users can only delete categories from their empresa
CREATE POLICY "categories_delete_own_empresa" ON public.categories
  FOR DELETE
  TO authenticated
  USING (empresa_id = auth.uid());

-- Step 7: Update existing categories without empresa_id (optional - assign to current auth user)
-- WARNING: This will only work if you know which user "owns" each category
-- For now, we'll leave them as NULL - they won't be visible to anyone until manually assigned
-- Uncomment below if you have a specific user to assign to:
-- UPDATE public.categories SET empresa_id = 'YOUR_USER_ID_HERE' WHERE empresa_id IS NULL;

-- Step 8: Add NOT NULL constraint (after data migration is complete)
-- ALTER TABLE public.categories ALTER COLUMN empresa_id SET NOT NULL;

-- Step 9: Grant necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.categories TO authenticated;

-- ==============================================================================
-- Verification Queries
-- ==============================================================================
-- Run these queries to verify the changes:

-- 1. Check that the column exists and is indexed:
-- SELECT column_name, data_type FROM information_schema.columns 
-- WHERE table_name = 'categories' AND column_name = 'empresa_id';

-- 2. Check that indexes exist:
-- SELECT indexname FROM pg_indexes WHERE tablename = 'categories';

-- 3. Check that RLS policies are in place:
-- SELECT polname, poltype FROM pg_policy WHERE polrelid = 'public.categories'::regclass;

-- 4. Check that RLS is enabled:
-- SELECT relname, relrowsecurity FROM pg_class WHERE relname = 'categories';
