-- ====================================================================
-- DESABILITAR RLS TEMPORARIAMENTE PARA ADMIN ACESSAR
-- ====================================================================
-- ATENÇÃO: Isto remove a segurança RLS temporariamente
-- Use apenas para testar o acesso admin
-- Depois reabilite com REABILITAR_RLS.sql
-- ====================================================================

-- 🔓 DESABILITAR RLS NAS TABELAS CRÍTICAS
ALTER TABLE subscriptions DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_approvals DISABLE ROW LEVEL SECURITY;

-- 🔄 FORÇAR RELOAD DO POSTGREST
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';

-- ✅ VERIFICAR SE DESABILITOU
SELECT 
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables 
WHERE tablename IN ('subscriptions', 'user_approvals');

-- Contar registros
SELECT COUNT(*) as total_subscriptions FROM subscriptions;
SELECT COUNT(*) as total_approvals FROM user_approvals;

-- ====================================================================
-- 📋 RESULTADO ESPERADO
-- ====================================================================
/*
✅ rls_habilitado = false (para ambas as tabelas)
✅ total_subscriptions = 6
✅ total_approvals = 6

PRÓXIMOS PASSOS:
1. Recarregue a página do frontend (F5)
2. Acesse /admin
3. DEVE FUNCIONAR sem erro 403 agora

⚠️ IMPORTANTE: Após confirmar que funciona, REABILITE O RLS executando:
   REABILITAR_RLS.sql
*/
