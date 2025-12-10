-- =============================================
-- LIMPAR POLÍTICAS DUPLICADAS DA TABELA CLIENTES
-- =============================================

-- Remover políticas antigas restritivas (_own)
DROP POLICY IF EXISTS "clientes_insert_own" ON clientes;
DROP POLICY IF EXISTS "clientes_select_own" ON clientes;
DROP POLICY IF EXISTS "clientes_update_own" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_own" ON clientes;

-- Verificar políticas restantes (devem ser apenas as _policy)
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY policyname;

-- ✅ Resultado esperado: Apenas 4 políticas permissivas (_policy)
