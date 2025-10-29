-- =====================================================
-- 🧹 LIMPAR POLICIES DUPLICADAS DA TABELA EMPRESAS
-- =====================================================
-- Remover policies antigas e deixar apenas as necessárias
-- =====================================================

-- =====================================================
-- 1️⃣ REMOVER TODAS AS POLICIES ANTIGAS
-- =====================================================

-- Remover policies duplicadas de DELETE
DROP POLICY IF EXISTS "empresas_delete_own" ON empresas;

-- Remover policies duplicadas de INSERT
DROP POLICY IF EXISTS "empresas_insert_own" ON empresas;
DROP POLICY IF EXISTS "empresas_insert_authenticated" ON empresas;

-- Remover policies duplicadas de SELECT
DROP POLICY IF EXISTS "empresas_allow_authenticated_select" ON empresas;
DROP POLICY IF EXISTS "empresas_allow_service_select" ON empresas;
DROP POLICY IF EXISTS "empresas_select_own" ON empresas;

-- Remover policies duplicadas de UPDATE
DROP POLICY IF EXISTS "empresas_update_own" ON empresas;

-- =====================================================
-- 2️⃣ MANTER APENAS AS POLICIES CORRETAS
-- =====================================================
-- Já existem e estão corretas:
-- ✅ select_own_company (SELECT)
-- ✅ insert_own_company (INSERT)
-- ✅ update_own_company (UPDATE)

-- =====================================================
-- 3️⃣ ADICIONAR POLICY DE DELETE (FALTAVA)
-- =====================================================

-- Remover policy antiga se existir
DROP POLICY IF EXISTS "delete_own_company" ON empresas;

-- Criar policy para DELETE
CREATE POLICY "delete_own_company"
ON empresas
FOR DELETE
TO authenticated
USING (
  user_id = auth.uid()
);

-- =====================================================
-- 4️⃣ VERIFICAÇÃO FINAL
-- =====================================================

-- Ver policies ativas (deve ter apenas 4)
SELECT 
  policyname,
  cmd,
  CASE cmd
    WHEN 'SELECT' THEN '✅ Permitir leitura da própria empresa'
    WHEN 'INSERT' THEN '✅ Permitir criar empresa'
    WHEN 'UPDATE' THEN '✅ Permitir editar empresa'
    WHEN 'DELETE' THEN '✅ Permitir excluir empresa'
  END as descricao
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'empresas'
ORDER BY cmd;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- Deve mostrar apenas 4 policies:
-- ✅ delete_own_company (DELETE)
-- ✅ insert_own_company (INSERT)
-- ✅ select_own_company (SELECT)
-- ✅ update_own_company (UPDATE)
-- =====================================================
