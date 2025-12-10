-- ====================================================================
-- FORÇAR RLS A FUNCIONAR SEM REINICIAR O SERVIDOR
-- ====================================================================
-- Desabilita e reabilita RLS para forçar reload do PostgREST
-- ====================================================================

-- 🔄 PASSO 1: DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE subscriptions DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_approvals DISABLE ROW LEVEL SECURITY;

-- ⏱️ Aguardar um momento (PostgreSQL precisa processar)
SELECT pg_sleep(1);

-- ✅ PASSO 2: REABILITAR RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;

-- 🔄 PASSO 3: FORÇAR RELOAD DO POSTGREST
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- ⏱️ Aguardar reload
SELECT pg_sleep(2);

-- 🧪 PASSO 4: VERIFICAR SE FUNCIONOU
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename IN ('subscriptions', 'user_approvals');

-- Verificar policies ativas
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    cmd
FROM pg_policies
WHERE tablename IN ('subscriptions', 'user_approvals')
ORDER BY tablename, policyname;

-- Testar acesso
SELECT COUNT(*) as total_subscriptions FROM subscriptions;
SELECT COUNT(*) as total_approvals FROM user_approvals;

-- ====================================================================
-- 📋 RESULTADO ESPERADO
-- ====================================================================
/*
✅ rls_enabled = true para ambas as tabelas
✅ 4 policies listadas (2 por tabela)
✅ COUNT = 6 para cada tabela

Após executar este script:
1. Aguarde 10 segundos
2. Abra o Console do navegador (F12)
3. Execute: localStorage.clear(); sessionStorage.clear(); window.location.href = '/login';
4. Faça login novamente

Se ainda der 403, o problema é o JWT token antigo no navegador.
*/
