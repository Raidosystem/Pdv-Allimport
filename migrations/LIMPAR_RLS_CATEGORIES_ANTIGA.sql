-- 🧹 LIMPAR POLICIES ANTIGAS CONFLITANTES

-- Remover a policy antiga que permite ver todas as categorias
DROP POLICY IF EXISTS "Authenticated users can view categories" ON categories;

-- Verificar policies finais
SELECT schemaname, tablename, policyname, permissive, roles
FROM pg_policies
WHERE tablename = 'categories'
ORDER BY policyname;

-- ✅ Resultado esperado: Apenas as 4 policies novas
-- - categories_delete_own
-- - categories_insert_own
-- - categories_select_own
-- - categories_update_own
