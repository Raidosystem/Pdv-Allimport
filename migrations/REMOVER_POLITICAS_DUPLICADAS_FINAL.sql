-- =============================================
-- REMOVER TODAS AS POLÍTICAS DUPLICADAS - FINAL
-- =============================================

-- 1. Remover TODAS as políticas existentes (duplicadas)
DROP POLICY IF EXISTS clientes_select_policy ON clientes;
DROP POLICY IF EXISTS clientes_insert_policy ON clientes;
DROP POLICY IF EXISTS clientes_update_policy ON clientes;
DROP POLICY IF EXISTS clientes_delete_policy ON clientes;

DROP POLICY IF EXISTS clientes_select_all ON clientes;
DROP POLICY IF EXISTS clientes_insert_all ON clientes;
DROP POLICY IF EXISTS clientes_update_all ON clientes;
DROP POLICY IF EXISTS clientes_delete_all ON clientes;

DROP POLICY IF EXISTS clientes_select_own ON clientes;
DROP POLICY IF EXISTS clientes_insert_own ON clientes;
DROP POLICY IF EXISTS clientes_update_own ON clientes;
DROP POLICY IF EXISTS clientes_delete_own ON clientes;

SELECT '🧹 Todas as políticas antigas removidas!' as status;

-- 2. Criar políticas LIMPAS E DEFINITIVAS
-- Permitir tudo para authenticated e anon
CREATE POLICY clientes_select_all ON clientes
FOR SELECT
TO authenticated, anon
USING (true);

CREATE POLICY clientes_insert_all ON clientes
FOR INSERT
TO authenticated, anon
WITH CHECK (true);

CREATE POLICY clientes_update_all ON clientes
FOR UPDATE
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY clientes_delete_all ON clientes
FOR DELETE
TO authenticated, anon
USING (true);

SELECT '✅ Políticas limpas criadas com sucesso!' as status;

-- 3. Verificar que temos EXATAMENTE 4 políticas
SELECT 
    policyname,
    cmd,
    roles::text[] as roles,
    permissive
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY cmd, policyname;

-- 4. Contar políticas (deve ser 4)
SELECT 
    COUNT(*) as total_policies,
    CASE 
        WHEN COUNT(*) = 4 THEN '✅ Correto: 4 políticas'
        ELSE '❌ Erro: ' || COUNT(*) || ' políticas (deveria ser 4)'
    END as status
FROM pg_policies
WHERE tablename = 'clientes';
