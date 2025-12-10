-- =====================================================
-- 🔒 PARTE 3 - POLÍTICAS RLS PARA ORDENS_SERVICO
-- =====================================================
-- Execute DEPOIS da PARTE 2
-- =====================================================

-- Remover políticas antigas
DROP POLICY IF EXISTS ordens_servico_select_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_insert_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_update_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_delete_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_all_simple ON ordens_servico;
DROP POLICY IF EXISTS ordens_select_own_empresa ON ordens_servico;
DROP POLICY IF EXISTS ordens_insert_own_empresa ON ordens_servico;
DROP POLICY IF EXISTS ordens_update_own_empresa ON ordens_servico;
DROP POLICY IF EXISTS ordens_delete_own_empresa ON ordens_servico;

-- Ativar RLS
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- Políticas novas
CREATE POLICY ordens_select_own_empresa ON ordens_servico
  FOR SELECT TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY ordens_insert_own_empresa ON ordens_servico
  FOR INSERT TO authenticated
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY ordens_update_own_empresa ON ordens_servico
  FOR UPDATE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()))
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY ordens_delete_own_empresa ON ordens_servico
  FOR DELETE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

-- =====================================================
-- VERIFICAÇÃO FINAL (SIMPLES)
-- =====================================================

-- Ver distribuição de ordens por empresa
SELECT 
  e.nome as empresa,
  au.email,
  COUNT(os.id) as total_ordens
FROM empresas e
INNER JOIN auth.users au ON au.id = e.user_id
LEFT JOIN ordens_servico os ON os.empresa_id = e.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
GROUP BY e.id, e.nome, au.email
ORDER BY e.nome;

-- ✅ CONCLUÍDO! Sistema protegido!
