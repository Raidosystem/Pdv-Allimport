-- =====================================================
-- 🧹 LIMPAR POLICIES DUPLICADAS - TABELA FUNCOES
-- =====================================================
-- Remover policies antigas e manter apenas as novas (_simple)
-- =====================================================

-- =====================================================
-- 1️⃣ REMOVER POLICIES ANTIGAS (DUPLICADAS)
-- =====================================================

DROP POLICY IF EXISTS "delete_funcoes_empresa" ON funcoes;
DROP POLICY IF EXISTS "insert_funcoes_empresa" ON funcoes;
DROP POLICY IF EXISTS "select_funcoes_empresa" ON funcoes;
DROP POLICY IF EXISTS "update_funcoes_empresa" ON funcoes;

-- =====================================================
-- 2️⃣ VERIFICAR POLICIES RESTANTES (DEVE TER APENAS 4)
-- =====================================================

SELECT 
  '✅ Policies configuradas' as status,
  policyname,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'funcoes'
ORDER BY cmd;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- Deve mostrar apenas 4 policies com sufixo "_simple":
-- ✅ funcoes_delete_simple (DELETE)
-- ✅ funcoes_insert_simple (INSERT)
-- ✅ funcoes_select_simple (SELECT)
-- ✅ funcoes_update_simple (UPDATE)
-- =====================================================
