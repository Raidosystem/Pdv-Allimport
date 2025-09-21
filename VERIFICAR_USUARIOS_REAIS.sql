-- ========================================
-- 🔍 VERIFICAR USUÁRIOS REAIS DO SISTEMA
-- Antes de atribuir dados, vamos ver quem existe
-- ========================================

-- 1. LISTAR TODOS OS USUÁRIOS CADASTRADOS
SELECT 
    '👥 USUÁRIOS CADASTRADOS' as info,
    id,
    email,
    created_at,
    last_sign_in_at,
    CASE 
        WHEN last_sign_in_at IS NULL THEN '❌ NUNCA FEZ LOGIN'
        WHEN last_sign_in_at < NOW() - INTERVAL '30 days' THEN '⚠️ INATIVO HÁ 30+ DIAS'
        ELSE '✅ USUÁRIO ATIVO'
    END as status
FROM auth.users 
ORDER BY created_at;

-- 2. VERIFICAR DISTRIBUIÇÃO REAL DOS DADOS
SELECT 
    '📊 DISTRIBUIÇÃO REAL - PRODUTOS' as tipo,
    user_id,
    COUNT(*) as quantidade,
    (SELECT email FROM auth.users WHERE id = user_id) as email_usuario
FROM produtos 
WHERE user_id IS NOT NULL
GROUP BY user_id
ORDER BY quantidade DESC;

SELECT 
    '📊 DISTRIBUIÇÃO REAL - CLIENTES' as tipo,
    user_id,
    COUNT(*) as quantidade,
    (SELECT email FROM auth.users WHERE id = user_id) as email_usuario
FROM clientes 
WHERE user_id IS NOT NULL
GROUP BY user_id
ORDER BY quantidade DESC;

SELECT 
    '📊 DISTRIBUIÇÃO REAL - VENDAS' as tipo,
    user_id,
    COUNT(*) as quantidade,
    SUM(total) as valor_total,
    (SELECT email FROM auth.users WHERE id = user_id) as email_usuario
FROM vendas 
WHERE user_id IS NOT NULL
GROUP BY user_id
ORDER BY quantidade DESC;

-- 3. VERIFICAR DADOS ÓRFÃOS (SEM DONO)
SELECT 'PRODUTOS SEM DONO' as tipo, COUNT(*) as quantidade FROM produtos WHERE user_id IS NULL;
SELECT 'CLIENTES SEM DONO' as tipo, COUNT(*) as quantidade FROM clientes WHERE user_id IS NULL;
SELECT 'VENDAS SEM DONO' as tipo, COUNT(*) as quantidade FROM vendas WHERE user_id IS NULL;

SELECT '🔍 ANÁLISE DE USUÁRIOS CONCLUÍDA!' as resultado;