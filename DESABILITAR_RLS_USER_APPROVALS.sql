-- ====================================================================
-- DESABILITAR RLS APENAS EM USER_APPROVALS (TEMPORÁRIO)
-- ====================================================================
-- Mantém RLS em subscriptions, remove apenas de user_approvals
-- ====================================================================

-- 🔓 DESABILITAR RLS APENAS EM USER_APPROVALS
ALTER TABLE user_approvals DISABLE ROW LEVEL SECURITY;

-- 🔄 FORÇAR RELOAD
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- ✅ VERIFICAR STATUS
SELECT 
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables 
WHERE tablename IN ('subscriptions', 'user_approvals');

-- Testar query problemática
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
-- 📋 RESULTADO ESPERADO
-- ====================================================================
/*
✅ subscriptions: rls_habilitado = true (mantém segurança)
✅ user_approvals: rls_habilitado = false (sem segurança temporariamente)
✅ Query retorna 6 registros

Após executar:
1. Recarregue a página (F5)
2. Admin deve funcionar 100%
3. Depois reabilite com outro script
*/
