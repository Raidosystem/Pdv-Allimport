-- ========================================
-- 🚨 DIAGNÓSTICO ESPECÍFICO POR USUÁRIO
-- Investigar por que dados ainda aparecem para todos
-- ========================================

-- 1. VERIFICAR TODOS OS USUÁRIOS CADASTRADOS
SELECT 
    '👥 USUÁRIOS CADASTRADOS' as info,
    id,
    email,
    email_confirmed_at,
    created_at,
    last_sign_in_at
FROM auth.users 
ORDER BY created_at;

-- 2. VERIFICAR USUÁRIO ATUAL DA SESSÃO
SELECT 
    '👤 USUÁRIO ATUAL DA SESSÃO' as info,
    auth.uid() as current_user_id,
    auth.email() as current_email,
    auth.role() as current_role;

-- 3. VERIFICAR STATUS RLS REAL
SELECT 
    '🔍 STATUS RLS DETALHADO' as info,
    schemaname,
    tablename,
    CASE WHEN rowsecurity THEN '✅ RLS ATIVO' ELSE '❌ RLS INATIVO' END as rls_status,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
ORDER BY tablename;

-- 4. VERIFICAR DADOS COM user_id PARA CADA TABELA
-- Produtos
SELECT 
    '📦 PRODUTOS - DISTRIBUIÇÃO POR USER_ID' as info,
    user_id,
    COUNT(*) as quantidade,
    STRING_AGG(DISTINCT nome, ', ' ORDER BY nome) as exemplos_nomes
FROM produtos 
GROUP BY user_id
ORDER BY user_id;

-- Clientes
SELECT 
    '👥 CLIENTES - DISTRIBUIÇÃO POR USER_ID' as info,
    user_id,
    COUNT(*) as quantidade,
    STRING_AGG(DISTINCT nome, ', ' ORDER BY nome) as exemplos_nomes
FROM clientes 
GROUP BY user_id
ORDER BY user_id;

-- Vendas
SELECT 
    '💰 VENDAS - DISTRIBUIÇÃO POR USER_ID' as info,
    user_id,
    COUNT(*) as quantidade,
    SUM(total) as valor_total
FROM vendas 
GROUP BY user_id
ORDER BY user_id;

-- 5. VERIFICAR POLÍTICAS DETALHADAMENTE
SELECT 
    '🔑 POLÍTICAS DETALHADAS' as info,
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual as condition_select,
    with_check as condition_insert_update
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
ORDER BY tablename, policyname;

-- 6. TESTE DIRETO DE ACESSO COM DIFERENTES CONTEXTOS
-- Ver quantos registros cada query retorna
SELECT 'TESTE SELECT PRODUTOS SEM FILTRO' as teste, COUNT(*) as total FROM produtos;
SELECT 'TESTE SELECT CLIENTES SEM FILTRO' as teste, COUNT(*) as total FROM clientes;
SELECT 'TESTE SELECT VENDAS SEM FILTRO' as teste, COUNT(*) as total FROM vendas;

-- 7. VERIFICAR SE HÁ BYPASS DE RLS (ROLES DE ADMIN)
SELECT 
    '🔓 VERIFICAR BYPASS RLS' as info,
    current_user as current_database_user,
    session_user as session_database_user,
    current_setting('role') as current_role_setting;

-- 8. TESTE ESPECÍFICO DE POLÍTICA
-- Tentar ver se a condição auth.uid() = user_id está funcionando
SELECT 
    '🧪 TESTE CONDIÇÃO POLÍTICA' as info,
    'auth.uid()' as funcao,
    auth.uid() as valor_retornado,
    CASE 
        WHEN auth.uid() IS NULL THEN '❌ NULL - SEM AUTENTICAÇÃO'
        ELSE '✅ AUTENTICADO'
    END as status;

-- 9. VERIFICAR REGISTROS COM user_id NULL
SELECT 'PRODUTOS SEM USER_ID' as problema, COUNT(*) as quantidade FROM produtos WHERE user_id IS NULL;
SELECT 'CLIENTES SEM USER_ID' as problema, COUNT(*) as quantidade FROM clientes WHERE user_id IS NULL;
SELECT 'VENDAS SEM USER_ID' as problema, COUNT(*) as quantidade FROM vendas WHERE user_id IS NULL;

-- 10. SAMPLE DE DADOS REAIS COM USER_ID
SELECT 
    '📋 SAMPLE PRODUTOS COM USER_ID' as info,
    id,
    nome,
    user_id,
    CASE 
        WHEN user_id = auth.uid() THEN '✅ MEU'
        WHEN user_id IS NULL THEN '❌ SEM DONO'
        ELSE '⚠️ DE OUTRO USUÁRIO'
    END as ownership
FROM produtos 
LIMIT 5;

SELECT 
    '📋 SAMPLE CLIENTES COM USER_ID' as info,
    id,
    nome,
    user_id,
    CASE 
        WHEN user_id = auth.uid() THEN '✅ MEU'
        WHEN user_id IS NULL THEN '❌ SEM DONO'
        ELSE '⚠️ DE OUTRO USUÁRIO'
    END as ownership
FROM clientes 
LIMIT 5;

-- 11. VERIFICAR SE O PROBLEMA É NO FRONTEND
-- Simular query que o frontend faz
SELECT 
    '🖥️ SIMULAÇÃO QUERY FRONTEND - PRODUTOS' as info,
    COUNT(*) as registros_retornados
FROM produtos;

SELECT 
    '🖥️ SIMULAÇÃO QUERY FRONTEND - CLIENTES' as info,
    COUNT(*) as registros_retornados
FROM clientes;

SELECT '🚨 DIAGNÓSTICO POR USUÁRIO COMPLETO!' as resultado;