-- =====================================================
-- 🔒 PARTE 4 - PROTEGER PRODUTOS, VENDAS E CAIXA
-- =====================================================
-- Execute para completar 100% da proteção
-- =====================================================

-- =====================================================
-- PRODUTOS - RLS
-- =====================================================

DROP POLICY IF EXISTS produtos_select_policy ON produtos;
DROP POLICY IF EXISTS produtos_insert_policy ON produtos;
DROP POLICY IF EXISTS produtos_update_policy ON produtos;
DROP POLICY IF EXISTS produtos_delete_policy ON produtos;
DROP POLICY IF EXISTS produtos_all_simple ON produtos;
DROP POLICY IF EXISTS produtos_select_own_empresa ON produtos;
DROP POLICY IF EXISTS produtos_insert_own_empresa ON produtos;
DROP POLICY IF EXISTS produtos_update_own_empresa ON produtos;
DROP POLICY IF EXISTS produtos_delete_own_empresa ON produtos;

ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

CREATE POLICY produtos_select_own_empresa ON produtos
  FOR SELECT TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY produtos_insert_own_empresa ON produtos
  FOR INSERT TO authenticated
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY produtos_update_own_empresa ON produtos
  FOR UPDATE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()))
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY produtos_delete_own_empresa ON produtos
  FOR DELETE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

-- =====================================================
-- VENDAS - RLS
-- =====================================================

DROP POLICY IF EXISTS vendas_select_policy ON vendas;
DROP POLICY IF EXISTS vendas_insert_policy ON vendas;
DROP POLICY IF EXISTS vendas_update_policy ON vendas;
DROP POLICY IF EXISTS vendas_delete_policy ON vendas;
DROP POLICY IF EXISTS vendas_all_simple ON vendas;
DROP POLICY IF EXISTS vendas_select_own_empresa ON vendas;
DROP POLICY IF EXISTS vendas_insert_own_empresa ON vendas;
DROP POLICY IF EXISTS vendas_update_own_empresa ON vendas;
DROP POLICY IF EXISTS vendas_delete_own_empresa ON vendas;

ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;

CREATE POLICY vendas_select_own_empresa ON vendas
  FOR SELECT TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY vendas_insert_own_empresa ON vendas
  FOR INSERT TO authenticated
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY vendas_update_own_empresa ON vendas
  FOR UPDATE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()))
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY vendas_delete_own_empresa ON vendas
  FOR DELETE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

-- =====================================================
-- CAIXA - RLS
-- =====================================================

DROP POLICY IF EXISTS caixa_select_policy ON caixa;
DROP POLICY IF EXISTS caixa_insert_policy ON caixa;
DROP POLICY IF EXISTS caixa_update_policy ON caixa;
DROP POLICY IF EXISTS caixa_delete_policy ON caixa;
DROP POLICY IF EXISTS caixa_all_simple ON caixa;
DROP POLICY IF EXISTS caixa_select_own_empresa ON caixa;
DROP POLICY IF EXISTS caixa_insert_own_empresa ON caixa;
DROP POLICY IF EXISTS caixa_update_own_empresa ON caixa;
DROP POLICY IF EXISTS caixa_delete_own_empresa ON caixa;

ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;

CREATE POLICY caixa_select_own_empresa ON caixa
  FOR SELECT TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY caixa_insert_own_empresa ON caixa
  FOR INSERT TO authenticated
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY caixa_update_own_empresa ON caixa
  FOR UPDATE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()))
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY caixa_delete_own_empresa ON caixa
  FOR DELETE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

-- =====================================================
-- VERIFICAÇÃO FINAL - TODAS AS TABELAS
-- =====================================================

SELECT 
  tablename,
  COUNT(*) as total_politicas
FROM pg_policies
WHERE tablename IN ('clientes', 'ordens_servico', 'produtos', 'vendas', 'caixa')
GROUP BY tablename
ORDER BY tablename;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- clientes: 4 políticas
-- ordens_servico: 4 políticas
-- produtos: 4 políticas ⭐ NOVO
-- vendas: 4 políticas ⭐ NOVO
-- caixa: 4 políticas ⭐ NOVO
-- =====================================================
-- ✅ SISTEMA 100% PROTEGIDO!
-- =====================================================
