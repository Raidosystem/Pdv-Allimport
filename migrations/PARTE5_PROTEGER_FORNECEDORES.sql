-- =====================================================
-- 🔒 PARTE 5 - PROTEGER FORNECEDORES E OUTRAS TABELAS
-- =====================================================
-- URGENTE: Proteger TODAS as tabelas faltantes
-- =====================================================

-- =====================================================
-- 1️⃣ ADICIONAR EMPRESA_ID EM FORNECEDORES
-- =====================================================

ALTER TABLE fornecedores 
  ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id);
CREATE INDEX IF NOT EXISTS idx_fornecedores_empresa_id ON fornecedores(empresa_id);

-- Preencher empresa_id nos fornecedores existentes
-- (Como fornecedores não tem user_id, atribuir à primeira empresa válida)
UPDATE fornecedores f
SET empresa_id = (
  SELECT id FROM empresas 
  WHERE user_id IS NOT NULL 
  LIMIT 1
)
WHERE f.empresa_id IS NULL;

-- =====================================================
-- 2️⃣ TRIGGER PARA FORNECEDORES
-- =====================================================

DROP TRIGGER IF EXISTS trigger_auto_empresa_id_fornecedores ON fornecedores;
CREATE TRIGGER trigger_auto_empresa_id_fornecedores
  BEFORE INSERT ON fornecedores
  FOR EACH ROW EXECUTE FUNCTION auto_set_empresa_id();

-- =====================================================
-- 3️⃣ POLÍTICAS RLS PARA FORNECEDORES
-- =====================================================

DROP POLICY IF EXISTS fornecedores_select_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_insert_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_update_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_delete_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_all_simple ON fornecedores;
DROP POLICY IF EXISTS fornecedores_select_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_insert_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_update_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_delete_own_empresa ON fornecedores;

ALTER TABLE fornecedores ENABLE ROW LEVEL SECURITY;

CREATE POLICY fornecedores_select_own_empresa ON fornecedores
  FOR SELECT TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY fornecedores_insert_own_empresa ON fornecedores
  FOR INSERT TO authenticated
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY fornecedores_update_own_empresa ON fornecedores
  FOR UPDATE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()))
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY fornecedores_delete_own_empresa ON fornecedores
  FOR DELETE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

-- =====================================================
-- 4️⃣ PROTEGER OUTRAS TABELAS RELACIONADAS
-- =====================================================

-- ITENS_VENDA (se existir)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'itens_venda') THEN
    ALTER TABLE itens_venda ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id);
    CREATE INDEX IF NOT EXISTS idx_itens_venda_empresa_id ON itens_venda(empresa_id);
    
    UPDATE itens_venda iv
    SET empresa_id = v.empresa_id
    FROM vendas v
    WHERE iv.empresa_id IS NULL
      AND iv.venda_id = v.id;
      
    DROP TRIGGER IF EXISTS trigger_auto_empresa_id_itens_venda ON itens_venda;
    CREATE TRIGGER trigger_auto_empresa_id_itens_venda
      BEFORE INSERT ON itens_venda
      FOR EACH ROW EXECUTE FUNCTION auto_set_empresa_id();
      
    ALTER TABLE itens_venda ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS itens_venda_select_own_empresa ON itens_venda;
    DROP POLICY IF EXISTS itens_venda_insert_own_empresa ON itens_venda;
    DROP POLICY IF EXISTS itens_venda_update_own_empresa ON itens_venda;
    DROP POLICY IF EXISTS itens_venda_delete_own_empresa ON itens_venda;
    
    CREATE POLICY itens_venda_select_own_empresa ON itens_venda
      FOR SELECT TO authenticated
      USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));
      
    CREATE POLICY itens_venda_insert_own_empresa ON itens_venda
      FOR INSERT TO authenticated
      WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));
      
    CREATE POLICY itens_venda_update_own_empresa ON itens_venda
      FOR UPDATE TO authenticated
      USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()))
      WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));
      
    CREATE POLICY itens_venda_delete_own_empresa ON itens_venda
      FOR DELETE TO authenticated
      USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));
  END IF;
END $$;

-- =====================================================
-- 5️⃣ VERIFICAÇÃO FINAL COMPLETA
-- =====================================================

SELECT 
  tablename,
  COUNT(*) as total_politicas
FROM pg_policies
WHERE tablename IN ('clientes', 'ordens_servico', 'produtos', 'vendas', 'caixa', 'fornecedores', 'itens_venda')
GROUP BY tablename
ORDER BY tablename;

-- Ver fornecedores por empresa
SELECT 
  e.nome as empresa,
  au.email,
  COUNT(f.id) as total_fornecedores
FROM empresas e
INNER JOIN auth.users au ON au.id = e.user_id
LEFT JOIN fornecedores f ON f.empresa_id = e.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
GROUP BY e.id, e.nome, au.email
ORDER BY e.nome;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ fornecedores: 4 políticas
-- ✅ itens_venda: 4 políticas (se existir)
-- ✅ Cada empresa vê APENAS seus fornecedores
-- ✅ Isolamento TOTAL garantido
-- =====================================================
