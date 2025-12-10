-- =====================================================
-- 🧹 LIMPAR TODAS AS POLICIES DUPLICADAS
-- =====================================================
-- Remover policies antigas e manter apenas as _simple
-- =====================================================

-- =====================================================
-- 1️⃣ LIMPAR: funcionario_funcoes (5 policies → 1)
-- =====================================================

DROP POLICY IF EXISTS "funcionario_funcoes_delete_policy" ON funcionario_funcoes;
DROP POLICY IF EXISTS "funcionario_funcoes_insert_policy" ON funcionario_funcoes;
DROP POLICY IF EXISTS "funcionario_funcoes_select_policy" ON funcionario_funcoes;
DROP POLICY IF EXISTS "funcionario_funcoes_update_policy" ON funcionario_funcoes;

-- Manter apenas: funcionario_funcoes_all_simple

-- =====================================================
-- 2️⃣ LIMPAR: funcionarios (6 policies → 1)
-- =====================================================

DROP POLICY IF EXISTS "funcionarios_empresa_policy" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_delete_by_empresa" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_insert_by_empresa" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_select_by_empresa" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_update_by_empresa" ON funcionarios;

-- Manter apenas: funcionarios_all_simple

-- =====================================================
-- 3️⃣ LIMPAR: login_funcionarios (6 policies → 1)
-- =====================================================

DROP POLICY IF EXISTS "login_funcionarios_empresa_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_delete_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_insert_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_select_policy" ON login_funcionarios;
DROP POLICY IF EXISTS "login_funcionarios_update_policy" ON login_funcionarios;

-- Manter apenas: login_funcionarios_all_simple

-- =====================================================
-- 4️⃣ VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
  tablename,
  COUNT(*) as total_policies,
  STRING_AGG(policyname, ', ') as policies
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('empresas', 'funcionarios', 'funcoes', 'funcionario_funcoes', 'login_funcionarios')
GROUP BY tablename
ORDER BY tablename;

-- =====================================================
-- 5️⃣ VER POLICIES DETALHADAS
-- =====================================================

SELECT 
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('empresas', 'funcionarios', 'funcoes', 'funcionario_funcoes', 'login_funcionarios')
ORDER BY tablename, cmd;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ empresas: 4 policies (delete/insert/select/update_own_company)
-- ✅ funcionarios: 1 policy (funcionarios_all_simple)
-- ✅ funcoes: 4 policies (funcoes_delete/insert/select/update_simple)
-- ✅ funcionario_funcoes: 1 policy (funcionario_funcoes_all_simple)
-- ✅ login_funcionarios: 1 policy (login_funcionarios_all_simple)
-- 
-- TOTAL: 11 policies (ao invés de 25)
-- =====================================================
