-- ========================================
-- 🔧 SOLUÇÃO SIMPLES - VERIFICAÇÃO DE ISOLAMENTO
-- Versão sem funções complexas
-- ========================================

-- 1. VERIFICAR DISTRIBUIÇÃO REAL DOS DADOS
SELECT 
    '📊 DISTRIBUIÇÃO REAL' as info,
    u.email as usuario,
    COUNT(p.id) as produtos,
    COUNT(c.id) as clientes,
    COUNT(v.id) as vendas
FROM auth.users u
LEFT JOIN produtos p ON u.id = p.user_id
LEFT JOIN clientes c ON u.id = c.user_id
LEFT JOIN vendas v ON u.id = v.user_id
GROUP BY u.id, u.email
ORDER BY COUNT(p.id) DESC;

-- 2. TESTE ESPECÍFICO POR USUÁRIO
-- novaradiosystem deveria ter 0 de tudo
SELECT 
    'TESTE novaradiosystem' as teste,
    COUNT(p.id) as produtos,
    COUNT(c.id) as clientes
FROM auth.users u
LEFT JOIN produtos p ON u.id = p.user_id AND u.email = 'novaradiosystem@outlook.com'
LEFT JOIN clientes c ON u.id = c.user_id AND u.email = 'novaradiosystem@outlook.com'
WHERE u.email = 'novaradiosystem@outlook.com';

-- assistenciaallimport10 deveria ter 809 produtos, 131 clientes
SELECT 
    'TESTE assistenciaallimport10' as teste,
    COUNT(p.id) as produtos,
    COUNT(c.id) as clientes
FROM auth.users u
LEFT JOIN produtos p ON u.id = p.user_id AND u.email = 'assistenciaallimport10@gmail.com'
LEFT JOIN clientes c ON u.id = c.user_id AND u.email = 'assistenciaallimport10@gmail.com'
WHERE u.email = 'assistenciaallimport10@gmail.com';

-- 3. SIMULAÇÃO DO QUE CADA USUÁRIO DEVERIA VER NO FRONTEND
-- Produtos filtrados por usuário específico
SELECT 
    '🔍 SIMULAÇÃO FRONTEND' as tipo,
    'novaradiosystem produtos' as item,
    COUNT(*) as quantidade
FROM produtos p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'novaradiosystem@outlook.com';

SELECT 
    '🔍 SIMULAÇÃO FRONTEND' as tipo,
    'assistenciaallimport10 produtos' as item,
    COUNT(*) as quantidade
FROM produtos p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'assistenciaallimport10@gmail.com';

SELECT 
    '🔍 SIMULAÇÃO FRONTEND' as tipo,
    'novaradiosystem clientes' as item,
    COUNT(*) as quantidade
FROM clientes c
JOIN auth.users u ON c.user_id = u.id
WHERE u.email = 'novaradiosystem@outlook.com';

SELECT 
    '🔍 SIMULAÇÃO FRONTEND' as tipo,
    'assistenciaallimport10 clientes' as item,
    COUNT(*) as quantidade
FROM clientes c
JOIN auth.users u ON c.user_id = u.id
WHERE u.email = 'assistenciaallimport10@gmail.com';

-- 4. CONFIRMAÇÃO FINAL
SELECT 
    '✅ CONFIRMAÇÃO' as resultado,
    'Se no frontend cada usuário vir apenas seus dados, RLS está funcionando!' as mensagem;