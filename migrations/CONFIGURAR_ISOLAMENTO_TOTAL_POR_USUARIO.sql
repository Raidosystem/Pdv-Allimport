-- 🔒 GARANTIR ISOLAMENTO TOTAL DE DADOS POR USUÁRIO/EMPRESA
-- Cada usuário vê APENAS seus próprios dados

-- ============================================
-- 1. PRODUTOS - Isolamento por empresa_id
-- ============================================
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "produtos_select_own" ON produtos;
DROP POLICY IF EXISTS "produtos_insert_own" ON produtos;
DROP POLICY IF EXISTS "produtos_update_own" ON produtos;
DROP POLICY IF EXISTS "produtos_delete_own" ON produtos;

ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "produtos_select_own"
ON produtos FOR SELECT TO authenticated
USING (empresa_id = auth.uid());

CREATE POLICY "produtos_insert_own"
ON produtos FOR INSERT TO authenticated
WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "produtos_update_own"
ON produtos FOR UPDATE TO authenticated
USING (empresa_id = auth.uid())
WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "produtos_delete_own"
ON produtos FOR DELETE TO authenticated
USING (empresa_id = auth.uid());

-- ============================================
-- 2. CLIENTES - Isolamento por empresa_id
-- ============================================
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "clientes_select_own" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_own" ON clientes;
DROP POLICY IF EXISTS "clientes_update_own" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_own" ON clientes;

ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "clientes_select_own"
ON clientes FOR SELECT TO authenticated
USING (empresa_id = auth.uid());

CREATE POLICY "clientes_insert_own"
ON clientes FOR INSERT TO authenticated
WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "clientes_update_own"
ON clientes FOR UPDATE TO authenticated
USING (empresa_id = auth.uid())
WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "clientes_delete_own"
ON clientes FOR DELETE TO authenticated
USING (empresa_id = auth.uid());

-- ============================================
-- 3. VENDAS - Isolamento por empresa_id
-- ============================================
ALTER TABLE vendas DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "vendas_select_own" ON vendas;
DROP POLICY IF EXISTS "vendas_insert_own" ON vendas;
DROP POLICY IF EXISTS "vendas_update_own" ON vendas;
DROP POLICY IF EXISTS "vendas_delete_own" ON vendas;

ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "vendas_select_own"
ON vendas FOR SELECT TO authenticated
USING (empresa_id = auth.uid());

CREATE POLICY "vendas_insert_own"
ON vendas FOR INSERT TO authenticated
WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "vendas_update_own"
ON vendas FOR UPDATE TO authenticated
USING (empresa_id = auth.uid())
WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "vendas_delete_own"
ON vendas FOR DELETE TO authenticated
USING (empresa_id = auth.uid());

-- ============================================
-- 4. ITENS_VENDAS - Isolamento via FK
-- ============================================
ALTER TABLE itens_vendas DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "itens_vendas_select_own" ON itens_vendas;
DROP POLICY IF EXISTS "itens_vendas_insert_own" ON itens_vendas;
DROP POLICY IF EXISTS "itens_vendas_update_own" ON itens_vendas;
DROP POLICY IF EXISTS "itens_vendas_delete_own" ON itens_vendas;

ALTER TABLE itens_vendas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "itens_vendas_select_own"
ON itens_vendas FOR SELECT TO authenticated
USING (
  venda_id IN (
    SELECT id FROM vendas WHERE empresa_id = auth.uid()
  )
);

CREATE POLICY "itens_vendas_insert_own"
ON itens_vendas FOR INSERT TO authenticated
WITH CHECK (
  venda_id IN (
    SELECT id FROM vendas WHERE empresa_id = auth.uid()
  )
);

CREATE POLICY "itens_vendas_update_own"
ON itens_vendas FOR UPDATE TO authenticated
USING (
  venda_id IN (
    SELECT id FROM vendas WHERE empresa_id = auth.uid()
  )
)
WITH CHECK (
  venda_id IN (
    SELECT id FROM vendas WHERE empresa_id = auth.uid()
  )
);

CREATE POLICY "itens_vendas_delete_own"
ON itens_vendas FOR DELETE TO authenticated
USING (
  venda_id IN (
    SELECT id FROM vendas WHERE empresa_id = auth.uid()
  )
);

-- ============================================
-- 5. ORDENS_SERVICO - Isolamento por empresa_id
-- ============================================
ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "ordens_servico_select_own" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_insert_own" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_update_own" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_delete_own" ON ordens_servico;

ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ordens_servico_select_own"
ON ordens_servico FOR SELECT TO authenticated
USING (empresa_id = auth.uid());

CREATE POLICY "ordens_servico_insert_own"
ON ordens_servico FOR INSERT TO authenticated
WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "ordens_servico_update_own"
ON ordens_servico FOR UPDATE TO authenticated
USING (empresa_id = auth.uid())
WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "ordens_servico_delete_own"
ON ordens_servico FOR DELETE TO authenticated
USING (empresa_id = auth.uid());

-- ============================================
-- ✅ Resultado Final
-- ============================================
-- Cada usuário vê APENAS seus dados
-- Isolamento total garantido por RLS
-- Privacidade completa do sistema

SELECT 'RLS Policies configuradas com sucesso!' as status;
