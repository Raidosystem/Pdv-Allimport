-- =============================================
-- SOLUÇÃO DEFINITIVA: RLS PERMISSIVO TOTAL
-- =============================================

-- 1. REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS clientes_select_policy ON clientes;
DROP POLICY IF EXISTS clientes_insert_policy ON clientes;
DROP POLICY IF EXISTS clientes_update_policy ON clientes;
DROP POLICY IF EXISTS clientes_delete_policy ON clientes;

-- 2. CRIAR POLÍTICAS ULTRA-PERMISSIVAS
-- Permitir SELECT para todos os usuários autenticados
CREATE POLICY clientes_select_all ON clientes
FOR SELECT
TO authenticated
USING (true);

-- Permitir INSERT para todos os usuários autenticados
CREATE POLICY clientes_insert_all ON clientes
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Permitir UPDATE para todos os usuários autenticados
CREATE POLICY clientes_update_all ON clientes
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Permitir DELETE para todos os usuários autenticados
CREATE POLICY clientes_delete_all ON clientes
FOR DELETE
TO authenticated
USING (true);

-- 3. GARANTIR QUE RLS ESTÁ HABILITADO
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- 4. VERIFICAR POLÍTICAS CRIADAS
SELECT 
    policyname,
    cmd,
    roles,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY cmd, policyname;

-- 5. TESTE DE INSERT (descomente para testar)
-- INSERT INTO clientes (nome, telefone, cpf_cnpj, cpf_digits, tipo, ativo)
-- VALUES ('Teste Final', '999999999', '111.111.111-11', '11111111111', 'fisica', true)
-- RETURNING *;

SELECT '✅ Políticas RLS ultra-permissivas criadas com sucesso!' as status;
