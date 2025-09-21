-- ========================================
-- 🚨 DIAGNÓSTICO SIMPLIFICADO E COMPATÍVEL
-- Investigar vazamento de dados - versão corrigida
-- ========================================

-- 1. VERIFICAR USUÁRIO ATUAL DA SESSÃO
SELECT 
    '👤 USUÁRIO ATUAL' as info,
    auth.uid() as current_user_id,
    auth.email() as current_email,
    CASE 
        WHEN auth.uid() IS NULL THEN '❌ NÃO AUTENTICADO'
        ELSE '✅ AUTENTICADO'
    END as auth_status;

-- 2. VERIFICAR STATUS RLS DE CADA TABELA
SELECT 
    '🔍 STATUS RLS' as info,
    tablename,
    CASE WHEN rowsecurity THEN '✅ ATIVO' ELSE '❌ INATIVO' END as rls_status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
ORDER BY tablename;

-- 3. VERIFICAR POLÍTICAS ATIVAS
SELECT 
    '🔑 POLÍTICAS' as info,
    tablename,
    policyname,
    cmd as operacao
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('produtos', 'clientes', 'vendas', 'vendas_itens', 'caixa', 'movimentacoes_caixa', 'ordens_servico')
ORDER BY tablename, policyname;

-- 4. CONTAR REGISTROS TOTAIS vs VISÍVEIS
SELECT 'PRODUTOS - TOTAL NA TABELA' as teste, COUNT(*) as total FROM produtos;
SELECT 'CLIENTES - TOTAL NA TABELA' as teste, COUNT(*) as total FROM clientes;
SELECT 'VENDAS - TOTAL NA TABELA' as teste, COUNT(*) as total FROM vendas;

-- 5. VERIFICAR DISTRIBUIÇÃO POR USER_ID
SELECT 
    '📦 PRODUTOS POR USER_ID' as info,
    CASE 
        WHEN user_id IS NULL THEN 'SEM DONO'
        WHEN user_id = auth.uid() THEN 'MEU'
        ELSE 'OUTRO USUÁRIO'
    END as ownership,
    COUNT(*) as quantidade
FROM produtos 
GROUP BY 
    CASE 
        WHEN user_id IS NULL THEN 'SEM DONO'
        WHEN user_id = auth.uid() THEN 'MEU'
        ELSE 'OUTRO USUÁRIO'
    END
ORDER BY quantidade DESC;

SELECT 
    '👥 CLIENTES POR USER_ID' as info,
    CASE 
        WHEN user_id IS NULL THEN 'SEM DONO'
        WHEN user_id = auth.uid() THEN 'MEU'
        ELSE 'OUTRO USUÁRIO'
    END as ownership,
    COUNT(*) as quantidade
FROM clientes 
GROUP BY 
    CASE 
        WHEN user_id IS NULL THEN 'SEM DONO'
        WHEN user_id = auth.uid() THEN 'MEU'
        ELSE 'OUTRO USUÁRIO'
    END
ORDER BY quantidade DESC;

-- 6. SAMPLE DE REGISTROS COM DETALHES
SELECT 
    '📋 SAMPLE PRODUTOS' as info,
    id,
    nome,
    user_id,
    CASE 
        WHEN user_id = auth.uid() THEN '✅ MEU'
        WHEN user_id IS NULL THEN '❌ SEM DONO'
        ELSE '⚠️ OUTRO USUÁRIO'
    END as status
FROM produtos 
ORDER BY user_id NULLS FIRST
LIMIT 3;

SELECT 
    '📋 SAMPLE CLIENTES' as info,
    id,
    nome,
    user_id,
    CASE 
        WHEN user_id = auth.uid() THEN '✅ MEU'
        WHEN user_id IS NULL THEN '❌ SEM DONO'
        ELSE '⚠️ OUTRO USUÁRIO'
    END as status
FROM clientes 
ORDER BY user_id NULLS FIRST
LIMIT 3;

-- 7. VERIFICAR SE HÁ BYPASS (USUÁRIO ADMIN)
SELECT 
    '🔓 INFO SESSÃO' as info,
    current_user as db_user,
    session_user as session_user;

-- 8. TESTE FINAL - O QUE O FRONTEND ESTÁ VENDO
SELECT 
    '🖥️ TESTE FRONTEND' as info,
    'Produtos visíveis' as tabela,
    COUNT(*) as registros
FROM produtos;

SELECT 
    '🖥️ TESTE FRONTEND' as info,
    'Clientes visíveis' as tabela,
    COUNT(*) as registros
FROM clientes;

SELECT '🚨 DIAGNÓSTICO CONCLUÍDO!' as resultado;