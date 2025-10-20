-- =====================================================
-- CORRIGIR RLS DA TABELA CLIENTES
-- =====================================================
-- Problema: RLS tentando acessar tabela "users" inexistente
-- Solução: Usar auth.uid() e empresa_id corretamente

-- 1. REMOVER TODAS AS POLÍTICAS ANTIGAS
DROP POLICY IF EXISTS "Clientes visíveis para usuários autenticados" ON clientes;
DROP POLICY IF EXISTS "Clientes podem ser inseridos" ON clientes;
DROP POLICY IF EXISTS "Clientes podem ser atualizados" ON clientes;
DROP POLICY IF EXISTS "Clientes podem ser deletados" ON clientes;
DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON clientes;

-- 2. HABILITAR RLS
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR POLÍTICAS CORRETAS

-- SELECT: Usuário pode ver clientes da sua empresa
CREATE POLICY "clientes_select_policy" ON clientes
FOR SELECT
TO authenticated
USING (
  empresa_id = auth.uid()
);

-- INSERT: Usuário pode criar clientes para sua empresa
CREATE POLICY "clientes_insert_policy" ON clientes
FOR INSERT
TO authenticated
WITH CHECK (
  empresa_id = auth.uid()
);

-- UPDATE: Usuário pode atualizar clientes da sua empresa
CREATE POLICY "clientes_update_policy" ON clientes
FOR UPDATE
TO authenticated
USING (
  empresa_id = auth.uid()
)
WITH CHECK (
  empresa_id = auth.uid()
);

-- DELETE: Usuário pode deletar clientes da sua empresa
CREATE POLICY "clientes_delete_policy" ON clientes
FOR DELETE
TO authenticated
USING (
  empresa_id = auth.uid()
);

-- 4. VERIFICAR POLÍTICAS CRIADAS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual as "using_expression",
  with_check as "with_check_expression"
FROM pg_policies 
WHERE tablename = 'clientes'
ORDER BY policyname;

-- 5. TESTAR SELECT
SELECT COUNT(*) as total_clientes
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- =====================================================
-- RESULTADO ESPERADO:
-- - 4 políticas criadas corretamente
-- - SELECT, INSERT, UPDATE, DELETE funcionando
-- - 138 clientes visíveis
-- =====================================================
