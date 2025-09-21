-- ========================================
-- 🚨 DIAGNÓSTICO CRÍTICO - POR QUE RLS NÃO FUNCIONA
-- O RLS ainda não está isolando os dados
-- ========================================

-- 1. VERIFICAR SE VOCÊ ESTÁ EXECUTANDO COMO ADMINISTRADOR
SELECT 
    '🔍 CONTEXTO DE EXECUÇÃO' as info,
    current_user as database_user,
    session_user as session_user,
    current_setting('is_superuser') as is_superuser,
    current_setting('session_authorization') as session_auth,
    CASE 
        WHEN current_user = 'postgres' THEN '❌ CRÍTICO: EXECUTANDO COMO POSTGRES (BYPASS TOTAL)'
        WHEN current_user LIKE '%service_role%' THEN '❌ CRÍTICO: EXECUTANDO COMO SERVICE ROLE (BYPASS TOTAL)'
        WHEN current_setting('is_superuser') = 'on' THEN '❌ CRÍTICO: SUPERUSER (BYPASS TOTAL)'
        ELSE '✅ USUÁRIO NORMAL'
    END as status;

-- 2. VERIFICAR AUTENTICAÇÃO SUPABASE
SELECT 
    '👤 AUTENTICAÇÃO SUPABASE' as info,
    auth.uid() as user_id,
    auth.email() as email,
    auth.role() as role,
    CASE 
        WHEN auth.uid() IS NULL THEN '❌ CRÍTICO: SEM AUTENTICAÇÃO SUPABASE'
        ELSE '✅ AUTENTICADO'
    END as auth_status;

-- 3. VERIFICAR SE RLS ESTÁ REALMENTE ATIVO
SELECT 
    '🔒 STATUS RLS POR TABELA' as info,
    tablename,
    CASE WHEN rowsecurity THEN '✅ ATIVO' ELSE '❌ INATIVO' END as rls_status,
    (SELECT COUNT(*) FROM pg_policies WHERE pg_policies.tablename = pg_tables.tablename AND schemaname = 'public') as total_policies
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
ORDER BY tablename;

-- 4. VERIFICAR POLÍTICAS ESPECÍFICAS
SELECT 
    '🔑 POLÍTICAS ATIVAS' as info,
    tablename,
    policyname,
    cmd as operacao,
    qual as condicao,
    CASE 
        WHEN qual LIKE '%auth.uid()%' THEN '✅ USA auth.uid()'
        ELSE '❌ NÃO USA auth.uid()'
    END as usa_auth_uid
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
ORDER BY tablename, policyname;

-- 5. TESTE DIRETO DE CONDIÇÃO auth.uid()
SELECT 
    '🧪 TESTE auth.uid()' as info,
    auth.uid() as valor_auth_uid,
    CASE 
        WHEN auth.uid() IS NULL THEN '❌ auth.uid() É NULL'
        ELSE '✅ auth.uid() TEM VALOR'
    END as status;

-- 6. VERIFICAR SE HÁ REGISTROS COM user_id IGUAL AO SEU
SELECT 
    '📊 PRODUTOS DO SEU USER_ID' as info,
    COUNT(*) as quantidade,
    CASE 
        WHEN COUNT(*) = 0 THEN '❌ NENHUM PRODUTO SEU'
        ELSE '✅ TEM PRODUTOS SEUS'
    END as status
FROM produtos 
WHERE user_id = auth.uid();

-- 7. COMPARAR user_id DOS REGISTROS COM SEU auth.uid()
SELECT 
    '🔍 ANÁLISE DE OWNERSHIP' as info,
    'Seu auth.uid()' as tipo,
    auth.uid()::text as valor
    
UNION ALL

SELECT 
    '🔍 ANÁLISE DE OWNERSHIP' as info,
    'user_id dos produtos' as tipo,
    STRING_AGG(DISTINCT user_id::text, ', ') as valor
FROM produtos 
LIMIT 10;

-- 8. TESTE EXTREMO - VERIFICAR SE A POLÍTICA FUNCIONA MANUALMENTE
SELECT 
    '🧪 TESTE MANUAL DE POLÍTICA' as info,
    COUNT(*) as total_produtos,
    COUNT(CASE WHEN user_id = auth.uid() THEN 1 END) as produtos_meus,
    COUNT(CASE WHEN user_id != auth.uid() OR user_id IS NULL THEN 1 END) as produtos_outros
FROM produtos;

-- 9. VERIFICAR SE EXISTE ALGUM ROLE/PERMISSION ESPECIAL
SELECT 
    '🔓 PERMISSÕES ESPECIAIS' as info,
    has_table_privilege(current_user, 'produtos', 'SELECT') as pode_select,
    pg_has_role(current_user, 'rds_superuser', 'MEMBER') as is_rds_superuser;

-- 10. VERIFICAR CONFIGURAÇÕES DE SEGURANÇA
SHOW row_security;

SELECT '🚨 DIAGNÓSTICO CRÍTICO COMPLETO!' as resultado;