-- ============================================
-- REABILITAR RLS COM POLÍTICAS CORRETAS
-- ============================================
-- ✅ Dados apareceram sem RLS
-- Agora vamos criar políticas corretas e reabilitar
-- ============================================

-- 1. LIMPAR POLÍTICAS ANTIGAS (todas)
DROP POLICY IF EXISTS "clientes_all_user" ON clientes;
DROP POLICY IF EXISTS "clientes_select_autenticados" ON clientes;
DROP POLICY IF EXISTS "clientes_select_all" ON clientes;
DROP POLICY IF EXISTS "Users can view own clients" ON clientes;
DROP POLICY IF EXISTS "Users can insert own clients" ON clientes;
DROP POLICY IF EXISTS "Users can update own clients" ON clientes;
DROP POLICY IF EXISTS "Users can delete own clients" ON clientes;

DROP POLICY IF EXISTS "ordens_servico_select_autenticados" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_select_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_select_all" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_select_own" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_insert_own" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_update_own" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_delete_own" ON ordens_servico;

-- 2. CRIAR POLÍTICAS SIMPLES E PERMISSIVAS (baseadas em produtos que funcionam)

-- Políticas para CLIENTES
CREATE POLICY "clientes_select_policy"
ON clientes
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "clientes_insert_policy"
ON clientes
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "clientes_update_policy"
ON clientes
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "clientes_delete_policy"
ON clientes
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- Políticas para ORDENS_SERVICO
CREATE POLICY "ordens_select_policy"
ON ordens_servico
FOR SELECT
TO authenticated
USING (usuario_id = auth.uid());

CREATE POLICY "ordens_insert_policy"
ON ordens_servico
FOR INSERT
TO authenticated
WITH CHECK (usuario_id = auth.uid());

CREATE POLICY "ordens_update_policy"
ON ordens_servico
FOR UPDATE
TO authenticated
USING (usuario_id = auth.uid())
WITH CHECK (usuario_id = auth.uid());

CREATE POLICY "ordens_delete_policy"
ON ordens_servico
FOR DELETE
TO authenticated
USING (usuario_id = auth.uid());

-- 3. REABILITAR RLS
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 4. VERIFICAR POLÍTICAS CRIADAS
SELECT 
  tablename,
  policyname,
  cmd,
  permissive
FROM pg_policies
WHERE tablename IN ('clientes', 'ordens_servico')
ORDER BY tablename, cmd, policyname;

-- 5. VERIFICAR RLS HABILITADO
SELECT 
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables
WHERE tablename IN ('clientes', 'ordens_servico', 'produtos');

-- ============================================
-- APÓS EXECUTAR:
-- 1. Todas as queries devem retornar políticas criadas
-- 2. RLS deve estar habilitado (true)
-- 3. Recarregue navegador (Ctrl+Shift+R)
-- 4. Dados devem continuar aparecendo!
-- ============================================
