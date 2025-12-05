-- ====================================================================
-- POLICIES RLS ULTRA SIMPLES - APENAS VERIFICAÇÃO POR EMAIL
-- ====================================================================
-- Remove todas as policies complexas e cria uma SIMPLES
-- que só verifica se auth.email() = 'novaradiosystem@outlook.com'
-- ====================================================================

-- 🗑️ REMOVER TODAS AS POLICIES ANTIGAS
DROP POLICY IF EXISTS subscriptions_admin_full_access ON subscriptions;
DROP POLICY IF EXISTS subscriptions_users_own ON subscriptions;
DROP POLICY IF EXISTS user_approvals_admin_full_access ON user_approvals;
DROP POLICY IF EXISTS user_approvals_users_own ON user_approvals;

-- ====================================================================
-- ✅ CRIAR POLICIES ULTRA SIMPLES
-- ====================================================================

-- 📋 SUBSCRIPTIONS: Admin vê TUDO (só email)
CREATE POLICY admin_all_subscriptions ON subscriptions
FOR ALL
TO authenticated
USING (
    auth.email() = 'novaradiosystem@outlook.com'
    OR 
    user_id = auth.uid()
);

-- 👤 USER_APPROVALS: Admin vê TODOS (só email)
CREATE POLICY admin_all_approvals ON user_approvals
FOR ALL
TO authenticated
USING (
    auth.email() = 'novaradiosystem@outlook.com'
    OR 
    user_id = auth.uid()
);

-- 🔄 FORÇAR RELOAD
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- ✅ VERIFICAR
SELECT
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename IN ('subscriptions', 'user_approvals')
ORDER BY tablename, policyname;

-- TESTAR
SELECT COUNT(*) as total_subscriptions FROM subscriptions;
SELECT COUNT(*) as total_approvals FROM user_approvals;

-- ====================================================================
-- 📋 RESULTADO ESPERADO
-- ====================================================================
/*
✅ 2 policies criadas (1 por tabela)
✅ Ambas verificam APENAS auth.email() = 'novaradiosystem@outlook.com'
✅ Não dependem de metadata ou subconsultas
✅ COUNT = 6 para ambas as tabelas

Após executar:
1. NÃO precisa fazer logout
2. Apenas recarregue a página (F5)
3. Deve funcionar imediatamente
*/
