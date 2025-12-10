-- ====================================================================
-- TESTE: VERIFICAR SE QUERY REST FUNCIONA AGORA
-- ====================================================================

-- 1️⃣ Testar query SQL direta com JOIN
SELECT 
    vi.id,
    vi.venda_id,
    vi.produto_id,
    vi.quantidade,
    vi.subtotal,
    vi.user_id,
    p.id as produto_real_id,
    p.nome AS produto_nome
FROM vendas_itens vi
LEFT JOIN produtos p ON p.id = vi.produto_id
WHERE vi.venda_id IN (
    '002a33d0-4634-4ab5-9acc-c6223dd5e680',
    'e24c3c73-1e1c-4b10-8846-c1d4ac4e7902',
    'f5c01a10-1a04-4c2f-8814-7cd13ce12934',
    '43832b40-880d-4d6e-bfb4-7f939ef31fcb',
    '7c424b87-24f3-450d-b959-de5cab748b86',
    '34bc2c18-90e8-4c41-8fe1-3945e0fc2862'
)
AND vi.user_id = auth.uid();

-- 2️⃣ Verificar se há itens com produto_id NULL
SELECT 
    COUNT(*) as total_itens,
    COUNT(produto_id) as itens_com_produto,
    COUNT(*) - COUNT(produto_id) as itens_sem_produto
FROM vendas_itens
WHERE user_id = auth.uid();

-- 3️⃣ Verificar totais por venda
SELECT 
    v.id as venda_id,
    v.total as total_venda,
    COUNT(vi.id) as qtd_itens,
    SUM(vi.subtotal) as total_itens,
    v.total - COALESCE(SUM(vi.subtotal), 0) as diferenca
FROM vendas v
LEFT JOIN vendas_itens vi ON vi.venda_id = v.id
WHERE v.created_at >= '2025-11-01'
AND v.created_at < '2025-12-01'
AND v.user_id = auth.uid()
GROUP BY v.id, v.total
ORDER BY v.created_at DESC;

-- 4️⃣ Listar todos os itens das 6 vendas
SELECT 
    vi.venda_id,
    vi.produto_id,
    vi.quantidade,
    vi.preco_unitario,
    vi.subtotal,
    p.nome as produto_nome
FROM vendas_itens vi
LEFT JOIN produtos p ON p.id = vi.produto_id
WHERE vi.venda_id IN (
    SELECT id FROM vendas 
    WHERE created_at >= '2025-11-01'
    AND created_at < '2025-12-01'
    AND user_id = auth.uid()
)
ORDER BY vi.venda_id, vi.id;

-- ====================================================================
-- RESULTADO ESPERADO
-- ====================================================================

/*
Query 1: Deve retornar os itens com nome do produto
Query 2: Deve mostrar quantos itens têm produto_id preenchido
Query 3: Deve mostrar se o total da venda bate com a soma dos itens
Query 4: Deve listar TODOS os itens das 6 vendas

Se Query 1 funcionar aqui mas não no frontend, o problema é:
- Cache do PostgREST ainda não recarregou
- Precisa reiniciar a API do Supabase

🔧 SOLUÇÃO:
Settings → API → Restart
*/
