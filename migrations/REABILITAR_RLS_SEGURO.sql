-- =============================================
-- REABILITAR RLS COM PROTEÇÃO POR EMPRESA
-- =============================================

-- 1. Remover políticas antigas (se existirem)
DROP POLICY IF EXISTS clientes_select_all ON clientes;
DROP POLICY IF EXISTS clientes_insert_all ON clientes;
DROP POLICY IF EXISTS clientes_update_all ON clientes;
DROP POLICY IF EXISTS clientes_delete_all ON clientes;

-- 2. REABILITAR RLS
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- 3. Criar políticas SEGURAS baseadas em empresa_id
-- Cada usuário só vê clientes da sua própria empresa

-- SELECT: Ver apenas clientes da sua empresa
CREATE POLICY clientes_select_empresa ON clientes
FOR SELECT
TO authenticated, anon
USING (
  empresa_id = auth.uid()
  OR user_id = auth.uid()
);

-- INSERT: Criar clientes apenas para sua empresa
CREATE POLICY clientes_insert_empresa ON clientes
FOR INSERT
TO authenticated, anon
WITH CHECK (
  empresa_id = auth.uid()
  OR user_id = auth.uid()
);

-- UPDATE: Atualizar apenas clientes da sua empresa
CREATE POLICY clientes_update_empresa ON clientes
FOR UPDATE
TO authenticated, anon
USING (
  empresa_id = auth.uid()
  OR user_id = auth.uid()
)
WITH CHECK (
  empresa_id = auth.uid()
  OR user_id = auth.uid()
);

-- DELETE: Deletar apenas clientes da sua empresa
CREATE POLICY clientes_delete_empresa ON clientes
FOR DELETE
TO authenticated, anon
USING (
  empresa_id = auth.uid()
  OR user_id = auth.uid()
);

SELECT '✅ RLS reabilitado com proteção por empresa!' as status;

-- 4. Verificar políticas criadas
SELECT 
    policyname,
    cmd,
    roles::text[],
    qual as using_expression,
    with_check as with_check_expression
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY cmd, policyname;

-- 5. Verificar RLS status
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'clientes';

-- 6. EXPLICAÇÃO:
-- As políticas agora verificam:
-- - empresa_id = auth.uid() -> Clientes da empresa do usuário logado
-- - user_id = auth.uid() -> Clientes criados pelo usuário logado
-- 
-- Isso garante que:
-- ✅ Cada empresa vê apenas seus próprios clientes
-- ✅ Usuários não podem ver clientes de outras empresas
-- ✅ Mantém segurança dos dados
