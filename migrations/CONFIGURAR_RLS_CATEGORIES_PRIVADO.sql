-- 🔒 VERIFICAR E CORRIGIR RLS POLICIES PARA CATEGORIAS
-- Garantir que cada usuário vê APENAS suas categorias

-- 1. Desabilitar RLS temporariamente para fazer ajustes
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;

-- 2. Remover policies antigas (se existirem)
DROP POLICY IF EXISTS "categories_read_own" ON categories;
DROP POLICY IF EXISTS "categories_insert_own" ON categories;
DROP POLICY IF EXISTS "categories_update_own" ON categories;
DROP POLICY IF EXISTS "categories_delete_own" ON categories;

-- 3. Re-habilitar RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- 4. Criar nova policy: SELECT apenas as categorias da própria empresa
CREATE POLICY "categories_select_own"
ON categories
FOR SELECT
TO authenticated
USING (empresa_id = auth.uid());

-- 5. Criar nova policy: INSERT próprias categorias
CREATE POLICY "categories_insert_own"
ON categories
FOR INSERT
TO authenticated
WITH CHECK (empresa_id = auth.uid());

-- 6. Criar nova policy: UPDATE próprias categorias
CREATE POLICY "categories_update_own"
ON categories
FOR UPDATE
TO authenticated
USING (empresa_id = auth.uid())
WITH CHECK (empresa_id = auth.uid());

-- 7. Criar nova policy: DELETE próprias categorias
CREATE POLICY "categories_delete_own"
ON categories
FOR DELETE
TO authenticated
USING (empresa_id = auth.uid());

-- ✅ Verificar policies criadas
SELECT schemaname, tablename, policyname, permissive, roles, qual, with_check
FROM pg_policies
WHERE tablename = 'categories'
ORDER BY policyname;
