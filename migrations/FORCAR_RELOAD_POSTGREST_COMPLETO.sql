-- ====================================================================
-- FORÇAR RELOAD COMPLETO DO POSTGREST + CORRIGIR POLICIES
-- ====================================================================
-- O PostgREST não está reconhecendo as policies RLS
-- Este script força reload e recria policies com nomes únicos
-- ====================================================================

-- 🔄 PASSO 1: RECARREGAR CACHE DO POSTGREST
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- ====================================================================
-- 🗑️ PASSO 2: REMOVER TODAS AS POLICIES ANTIGAS
-- ====================================================================

-- Subscriptions
DROP POLICY IF EXISTS admin_full_access_subscriptions ON subscriptions;
DROP POLICY IF EXISTS users_own_subscription ON subscriptions;
DROP POLICY IF EXISTS admin_all_subscriptions ON subscriptions;
DROP POLICY IF EXISTS users_own_subscriptions ON subscriptions;
DROP POLICY IF EXISTS subscriptions_select_policy ON subscriptions;
DROP POLICY IF EXISTS subscriptions_insert_policy ON subscriptions;
DROP POLICY IF EXISTS subscriptions_update_policy ON subscriptions;
DROP POLICY IF EXISTS subscriptions_delete_policy ON subscriptions;

-- User Approvals
DROP POLICY IF EXISTS admin_full_access_approvals ON user_approvals;
DROP POLICY IF EXISTS admins_insert_approvals ON user_approvals;
DROP POLICY IF EXISTS admins_update_approvals ON user_approvals;
DROP POLICY IF EXISTS users_own_approval ON user_approvals;
DROP POLICY IF EXISTS admin_all_approvals ON user_approvals;
DROP POLICY IF EXISTS user_approvals_select_policy ON user_approvals;
DROP POLICY IF EXISTS user_approvals_insert_policy ON user_approvals;
DROP POLICY IF EXISTS user_approvals_update_policy ON user_approvals;
DROP POLICY IF EXISTS user_approvals_delete_policy ON user_approvals;

-- ====================================================================
-- ✅ PASSO 3: CRIAR POLICIES SIMPLES E PERMISSIVAS
-- ====================================================================

-- 📋 SUBSCRIPTIONS: Admins veem TUDO
CREATE POLICY subscriptions_admin_full_access ON subscriptions
FOR ALL
TO authenticated
USING (
    -- Admin por email
    auth.email() = 'novaradiosystem@outlook.com'
    OR
    -- Admin por metadata
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
    OR
    -- Admin por user_approvals (se existir registro)
    EXISTS (
        SELECT 1 FROM user_approvals
        WHERE user_id = auth.uid()
        AND user_role = 'admin'
    )
)
WITH CHECK (
    auth.email() = 'novaradiosystem@outlook.com'
    OR
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- 📋 SUBSCRIPTIONS: Usuários veem apenas a própria
CREATE POLICY subscriptions_users_own ON subscriptions
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- 👤 USER_APPROVALS: Admins veem TODOS
CREATE POLICY user_approvals_admin_full_access ON user_approvals
FOR ALL
TO authenticated
USING (
    auth.email() = 'novaradiosystem@outlook.com'
    OR
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
    OR
    user_role = 'admin'
)
WITH CHECK (
    auth.email() = 'novaradiosystem@outlook.com'
    OR
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- 👤 USER_APPROVALS: Usuários veem apenas o próprio registro
CREATE POLICY user_approvals_users_own ON user_approvals
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- ====================================================================
-- 🔄 PASSO 4: FORÇAR RELOAD FINAL
-- ====================================================================

NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- ====================================================================
-- 🧪 PASSO 5: TESTAR SE FUNCIONA
-- ====================================================================

-- Verificar policies criadas
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename IN ('subscriptions', 'user_approvals')
ORDER BY tablename, policyname;

-- Testar acesso como admin
SELECT COUNT(*) as total_subscriptions FROM subscriptions;
SELECT COUNT(*) as total_approvals FROM user_approvals;

-- ====================================================================
-- 📋 RESULTADO ESPERADO
-- ====================================================================
/*
✅ 4 policies em subscriptions
✅ 4 policies em user_approvals
✅ COUNT retorna 6 subscriptions
✅ COUNT retorna 6 user_approvals

Se isso funcionar no SQL Editor mas continuar 403 no frontend:
➡️ REINICIE O SERVIDOR SUPABASE (Settings → API → Restart)
*/
