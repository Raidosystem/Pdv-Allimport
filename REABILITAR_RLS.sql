-- ====================================================================
-- REABILITAR RLS APÓS TESTE
-- ====================================================================
-- Execute este script DEPOIS de confirmar que o admin funciona
-- ====================================================================

-- ✅ REABILITAR RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;

-- 🔄 FORÇAR RELOAD
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- ✅ VERIFICAR
SELECT 
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables 
WHERE tablename IN ('subscriptions', 'user_approvals');

-- Verificar policies ativas
SELECT
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename IN ('subscriptions', 'user_approvals')
ORDER BY tablename, policyname;

-- ====================================================================
-- 📋 RESULTADO ESPERADO
-- ====================================================================
/*
✅ rls_habilitado = true (ambas tabelas)
✅ 4 policies listadas (2 por tabela)

RLS reabilitado com sucesso!
Agora o sistema está seguro novamente.
*/
