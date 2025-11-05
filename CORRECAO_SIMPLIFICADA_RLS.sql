-- =====================================================
-- 🚨 CORREÇÃO SIMPLIFICADA - RLS FORNECEDORES
-- =====================================================
-- Removendo políticas manualmente por problemas de sintaxe
-- =====================================================

-- 1️⃣ DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE fornecedores DISABLE ROW LEVEL SECURITY;

-- 2️⃣ REMOVER POLÍTICAS MANUALMENTE (TODAS AS POSSÍVEIS VARIAÇÕES)
DROP POLICY IF EXISTS fornecedores_select_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_insert_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_update_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_delete_policy ON fornecedores;
DROP POLICY IF EXISTS fornecedores_all_simple ON fornecedores;
DROP POLICY IF EXISTS fornecedores_select_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_insert_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_update_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_delete_own_empresa ON fornecedores;
DROP POLICY IF EXISTS fornecedores_strict_select ON fornecedores;
DROP POLICY IF EXISTS fornecedores_strict_insert ON fornecedores;
DROP POLICY IF EXISTS fornecedores_strict_update ON fornecedores;
DROP POLICY IF EXISTS fornecedores_strict_delete ON fornecedores;

-- Remover políticas com nomes problemáticos (com espaços)
DROP POLICY IF EXISTS "Permitir SELECT fornecedores" ON fornecedores;
DROP POLICY IF EXISTS "Permitir INSERT fornecedores" ON fornecedores;
DROP POLICY IF EXISTS "Permitir UPDATE fornecedores" ON fornecedores;
DROP POLICY IF EXISTS "Permitir DELETE fornecedores" ON fornecedores;

-- 3️⃣ REABILITAR RLS
ALTER TABLE fornecedores ENABLE ROW LEVEL SECURITY;

-- 4️⃣ CRIAR POLÍTICAS ULTRA RESTRITIVAS E SIMPLES
CREATE POLICY fornecedores_only_own_company ON fornecedores
  FOR ALL TO authenticated
  USING (empresa_id = (SELECT id FROM empresas WHERE user_id = auth.uid()))
  WITH CHECK (empresa_id = (SELECT id FROM empresas WHERE user_id = auth.uid()));

-- 5️⃣ TESTE IMEDIATO
SELECT 
  'TESTE_IMEDIATO' as teste,
  COUNT(*) as fornecedores_visiveis
FROM fornecedores;

-- 6️⃣ VERIFICAR MINHA EMPRESA
SELECT 
  'MINHA_EMPRESA' as teste,
  id as empresa_id,
  nome as empresa_nome
FROM empresas 
WHERE user_id = auth.uid();

-- 7️⃣ VERIFICAR POLÍTICAS CRIADAS
SELECT 
  policyname,
  cmd
FROM pg_policies 
WHERE tablename = 'fornecedores';

-- 8️⃣ TESTE FINAL - DEVE ESTAR VAZIO PARA VOCÊ
SELECT 
  f.nome as fornecedor,
  f.empresa_id,
  e.nome as empresa_dona
FROM fornecedores f
LEFT JOIN empresas e ON e.id = f.empresa_id;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ fornecedores_visiveis = 0 para cris-ramos30@hotmail.com
-- ✅ 1 política criada
-- ✅ Teste final deve retornar vazio
-- =====================================================