-- ====================================================================
-- CORRIGIR POLICY DE USER_APPROVALS - PERMITIR QUERIES COM IN
-- ====================================================================

-- Remover policy antiga
DROP POLICY IF EXISTS admin_all_approvals ON user_approvals;

-- Criar policy mais permissiva para admin
CREATE POLICY admin_all_approvals_v2 ON user_approvals
FOR ALL
TO authenticated
USING (
    -- Admin vê tudo
    auth.email() = 'novaradiosystem@outlook.com'
    OR
    -- Usuário vê apenas o próprio
    user_id = auth.uid()
)
WITH CHECK (
    -- Admin pode modificar tudo
    auth.email() = 'novaradiosystem@outlook.com'
    OR
    -- Usuário pode modificar apenas o próprio
    user_id = auth.uid()
);

-- Recarregar
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- Verificar
SELECT
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'user_approvals';

-- Testar query com IN (igual ao frontend)
SELECT 
    user_id,
    email,
    full_name,
    company_name,
    created_at
FROM user_approvals
WHERE user_id IN (
    'c1215466-180d-4baa-8d32-1017d43f2a91',
    '922d4f20-6c99-4438-a922-e275eb527c0b',
    '69e6a65f-ff2c-4670-96bd-57acf8799d19',
    '6ed345da-d704-4d79-9971-490919d851aa',
    '28230691-00a7-45e7-a6d6-ff79fd0fac89',
    'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
);

-- ====================================================================
-- RESULTADO ESPERADO
-- ====================================================================
/*
✅ Policy admin_all_approvals_v2 criada
✅ Query com IN retorna 6 registros
✅ Sem erros

Após executar, recarregue a página (F5)
*/
