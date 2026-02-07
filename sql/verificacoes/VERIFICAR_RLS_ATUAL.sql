-- =====================================================
-- 🔒 VERIFICAR STATUS RLS ATUAL DE TODAS AS TABELAS
-- =====================================================
-- Execute este SQL no Supabase SQL Editor para ver
-- quais tabelas têm RLS ativo ou desabilitado
-- =====================================================

SELECT 
    schemaname,
    tablename,
    rowsecurity AS rls_habilitado,
    CASE 
        WHEN rowsecurity THEN '✅ SEGURO (RLS Ativo)'
        ELSE '🚨 VULNERÁVEL (RLS Desabilitado)'
    END AS status
FROM pg_tables
WHERE schemaname IN ('public', 'storage')
    AND tablename IN (
        'clientes', 'produtos', 'vendas', 'vendas_itens', 'itens_venda',
        'caixa', 'movimentacoes_caixa', 'ordens_servico', 'fornecedores',
        'categorias', 'configuracoes', 'user_settings', 'empresas',
        'funcionarios', 'login_funcionarios', 'user_approvals',
        'funcoes', 'permissoes', 'funcao_permissoes',
        'backups', 'subscriptions', 'contas_pagar', 'contas_receber',
        'lojas_online', 'objects'
    )
ORDER BY 
    CASE WHEN rowsecurity THEN 1 ELSE 0 END ASC,
    tablename;

-- =====================================================
-- 🔍 VERIFICAR POLÍTICAS RLS EXISTENTES
-- =====================================================

SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual AS using_expression,
    with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- =====================================================
-- ⚠️ TABELAS CRÍTICAS QUE DEVEM TER RLS
-- =====================================================

SELECT 
    tablename,
    CASE 
        WHEN rowsecurity THEN '✅ OK'
        ELSE '🚨 CRÍTICO - HABILITAR RLS URGENTE!'
    END AS status_seguranca
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN (
        'clientes', 'produtos', 'vendas', 'caixa', 
        'ordens_servico', 'fornecedores', 'contas_pagar'
    )
    AND rowsecurity = false;
