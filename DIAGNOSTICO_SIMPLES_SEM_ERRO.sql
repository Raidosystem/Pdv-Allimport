-- ========================================
-- 🚨 DIAGNÓSTICO SIMPLES - CAUSA DO VAZAMENTO
-- Versão sem erros
-- ========================================

-- 1. VERIFICAR USUÁRIO E CONTEXTO
SELECT 
    '🔍 CONTEXTO' as tipo,
    current_user as database_user,
    current_setting('is_superuser') as is_superuser,
    CASE 
        WHEN current_user = 'postgres' THEN '❌ POSTGRES (BYPASS TOTAL)'
        WHEN current_user LIKE '%service_role%' THEN '❌ SERVICE ROLE (BYPASS TOTAL)'
        ELSE '✅ USUÁRIO NORMAL'
    END as status_usuario;

-- 2. VERIFICAR AUTENTICAÇÃO SUPABASE
SELECT 
    '👤 AUTH SUPABASE' as tipo,
    auth.uid() as user_id,
    auth.email() as email,
    CASE 
        WHEN auth.uid() IS NULL THEN '❌ SEM AUTH'
        ELSE '✅ AUTENTICADO'
    END as status_auth;

-- 3. STATUS RLS DAS TABELAS
SELECT 
    '🔒 RLS STATUS' as tipo,
    tablename,
    CASE WHEN rowsecurity THEN 'ATIVO' ELSE 'INATIVO' END as rls_status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'vendas')
ORDER BY tablename;

-- 4. POLÍTICAS EXISTENTES
SELECT 
    '🔑 POLÍTICAS' as tipo,
    tablename,
    COUNT(*) as total_policies
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'clientes', 'vendas')
GROUP BY tablename
ORDER BY tablename;

-- 5. TESTE OWNERSHIP
SELECT 
    '📊 OWNERSHIP' as tipo,
    CASE 
        WHEN user_id = auth.uid() THEN 'MEUS'
        WHEN user_id IS NULL THEN 'SEM DONO'
        ELSE 'OUTROS'
    END as categoria,
    COUNT(*) as quantidade
FROM produtos 
GROUP BY 
    CASE 
        WHEN user_id = auth.uid() THEN 'MEUS'
        WHEN user_id IS NULL THEN 'SEM DONO'
        ELSE 'OUTROS'
    END
ORDER BY quantidade DESC;

-- 6. COMPARAÇÃO DE IDs
SELECT 
    '🆔 COMPARAÇÃO' as tipo,
    'MEU auth.uid()' as item,
    COALESCE(auth.uid()::text, 'NULL') as valor
    
UNION ALL

SELECT 
    '🆔 COMPARAÇÃO' as tipo,
    'user_id produtos' as item,
    STRING_AGG(DISTINCT COALESCE(user_id::text, 'NULL'), ', ') as valor
FROM (SELECT user_id FROM produtos LIMIT 5) p;

-- 7. TESTE FINAL
SELECT 
    '🧪 TESTE' as tipo,
    'Total produtos visíveis' as item,
    COUNT(*) as quantidade
FROM produtos;

SELECT '🚨 DIAGNÓSTICO SIMPLES COMPLETO!' as resultado;