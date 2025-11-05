-- =====================================================
-- 🚨 CORREÇÃO URGENTE - RLS FORNECEDORES NÃO FUNCIONANDO
-- =====================================================
-- O teste mostrou: deveria_ver = false, mas usuário ainda vê
-- Política RLS não está bloqueando corretamente
-- =====================================================

-- 1️⃣ REMOVER TODAS AS POLÍTICAS DEFEITUOSAS
DROP POLICY IF EXISTS fornecedores_select_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_insert_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_update_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_delete_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_all_simple ON fornecedores;
DROP POLICY IF EXISTS fornecedores_select_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_insert_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_update_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_delete_own_empresa ON fornecedores;

-- 2️⃣ GARANTIR QUE RLS ESTÁ ATIVADO
ALTER TABLE fornecedores ENABLE ROW LEVEL SECURITY;

-- 3️⃣ CRIAR POLÍTICAS RLS CORRETAS E RESTRITIVAS
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

-- 4️⃣ TESTE IMEDIATO APÓS CORREÇÃO
SELECT 
  'TESTE_APOS_CORRECAO' as teste,
  COUNT(*) as fornecedores_visiveis_agora
FROM fornecedores;

-- 5️⃣ VERIFICAR SE POLÍTICAS FORAM CRIADAS
SELECT 
  policyname,
  cmd,
  permissive
FROM pg_policies 
WHERE tablename = 'fornecedores'
ORDER BY policyname;

-- 6️⃣ TESTE FINAL DE ISOLAMENTO
SELECT 
  f.nome as fornecedor,
  f.empresa_id,
  e.nome as empresa,
  au.email as dono
FROM fornecedores f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN auth.users au ON au.id = e.user_id;

-- =====================================================
-- 🎯 RESULTADO ESPERADO APÓS CORREÇÃO
-- =====================================================
-- ✅ fornecedores_visiveis_agora deve ser 0 para cris-ramos30@hotmail.com
-- ✅ 4 políticas devem existir
-- ✅ Teste final deve mostrar apenas fornecedores da sua empresa
-- =====================================================