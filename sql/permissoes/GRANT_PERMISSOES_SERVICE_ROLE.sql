-- ================================================================
-- GRANT DE PERMISSÕES PARA SERVICE_ROLE (BACKUP COMPLETO)
-- ================================================================
-- Este script dá permissões de SELECT para service_role em todas
-- as tabelas críticas do sistema. Necessário para backups.
-- 
-- EXECUTAR NO: Supabase SQL Editor
-- ================================================================

-- Dar permissões SELECT para service_role em todas as tabelas
GRANT SELECT ON user_approvals TO service_role;
GRANT SELECT ON empresas TO service_role;
GRANT SELECT ON funcionarios TO service_role;
GRANT SELECT ON subscriptions TO service_role;
GRANT SELECT ON produtos TO service_role;
GRANT SELECT ON clientes TO service_role;
GRANT SELECT ON vendas TO service_role;
GRANT SELECT ON vendas_itens TO service_role;
GRANT SELECT ON caixa TO service_role;
GRANT SELECT ON ordens_servico TO service_role;
GRANT SELECT ON categorias TO service_role;
GRANT SELECT ON fornecedores TO service_role;
GRANT SELECT ON despesas TO service_role;

-- Se precisar de backup completo com INSERT/UPDATE/DELETE, use:
-- GRANT ALL ON [tabela] TO service_role;

-- Verificar permissões aplicadas
SELECT 
    schemaname,
    tablename,
    pg_catalog.has_table_privilege('service_role', schemaname||'.'||tablename, 'SELECT') as can_select,
    pg_catalog.has_table_privilege('service_role', schemaname||'.'||tablename, 'INSERT') as can_insert,
    pg_catalog.has_table_privilege('service_role', schemaname||'.'||tablename, 'UPDATE') as can_update,
    pg_catalog.has_table_privilege('service_role', schemaname||'.'||tablename, 'DELETE') as can_delete
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN (
        'user_approvals', 'empresas', 'funcionarios', 'subscriptions',
        'produtos', 'clientes', 'vendas', 'vendas_itens',
        'caixa', 'ordens_servico', 'categorias', 'fornecedores', 'despesas'
    )
ORDER BY tablename;
