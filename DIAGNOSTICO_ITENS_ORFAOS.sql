-- ====================================================================
-- DIAGNÓSTICO: ENCONTRAR ITENS ÓRFÃOS OU PERDIDOS
-- ====================================================================

-- 1️⃣ Verificar se há itens SEM FILTRO de user_id (bypass RLS)
-- Execute como admin para ver TODOS os itens
SELECT 
    COUNT(*) as total_geral_itens
FROM vendas_itens;

-- 2️⃣ Verificar itens das 6 vendas específicas (sem filtro user_id)
SELECT 
    vi.id,
    vi.venda_id,
    vi.produto_id,
    vi.quantidade,
    vi.subtotal,
    vi.user_id,
    v.user_id as venda_user_id,
    CASE 
        WHEN vi.user_id = v.user_id THEN '✅ IDs batem'
        ELSE '❌ IDs diferentes'
    END as status_user_id
FROM vendas_itens vi
LEFT JOIN vendas v ON v.id = vi.venda_id
WHERE vi.venda_id IN (
    '002a33d0-4634-4ab5-9acc-c6223dd5e680',
    'e24c3c73-1e1c-4b10-8846-c1d4ac4e7902',
    'f5c01a10-1a04-4c2f-8814-7cd13ce12934',
    '43832b40-880d-4d6e-bfb4-7f939ef31fcb',
    '7c424b87-24f3-450d-b959-de5cab748b86',
    '34bc2c18-90e8-4c41-8fe1-3945e0fc2862'
);

-- 3️⃣ Verificar quantos itens existem por venda (sem filtro)
SELECT 
    v.id as venda_id,
    v.total as total_venda,
    v.user_id as venda_user_id,
    COUNT(vi.id) as qtd_itens,
    SUM(vi.subtotal) as total_itens_calculado
FROM vendas v
LEFT JOIN vendas_itens vi ON vi.venda_id = v.id
WHERE v.created_at >= '2025-11-01'
AND v.created_at < '2025-12-01'
GROUP BY v.id, v.total, v.user_id
ORDER BY v.created_at DESC;

-- 4️⃣ Comparar user_id entre vendas e vendas_itens
SELECT 
    'Vendas' as tabela,
    user_id,
    COUNT(*) as quantidade
FROM vendas
WHERE created_at >= '2025-11-01'
AND created_at < '2025-12-01'
GROUP BY user_id

UNION ALL

SELECT 
    'Vendas Itens' as tabela,
    user_id,
    COUNT(*) as quantidade
FROM vendas_itens
WHERE venda_id IN (
    SELECT id FROM vendas 
    WHERE created_at >= '2025-11-01'
    AND created_at < '2025-12-01'
)
GROUP BY user_id;

-- 5️⃣ Verificar políticas RLS que podem estar bloqueando
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE tablename IN ('vendas', 'vendas_itens')
ORDER BY tablename, cmd;

-- ====================================================================
-- RESULTADO ESPERADO
-- ====================================================================

/*
Query 1: Deve mostrar quantos itens existem NO TOTAL
Query 2: Deve mostrar os itens das 6 vendas (se existirem)
Query 3: Deve mostrar quantos itens cada venda tem
Query 4: Deve mostrar se user_id é diferente entre tabelas
Query 5: Deve mostrar as políticas RLS ativas

🎯 POSSÍVEIS CENÁRIOS:

Cenário A: total_geral_itens = 0
→ As vendas realmente não têm itens
→ Solução: Recriar os itens manualmente

Cenário B: total_geral_itens > 0 mas Query 2 retorna 0
→ user_id está diferente entre vendas e vendas_itens
→ Solução: Atualizar user_id dos itens

Cenário C: Query 2 retorna itens
→ Política RLS está bloqueando quando usa auth.uid()
→ Solução: Ajustar políticas RLS
*/
