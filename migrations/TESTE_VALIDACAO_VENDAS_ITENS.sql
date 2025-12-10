-- ====================================================================
-- TESTE FINAL: VALIDAR SE O ERRO 400 FOI RESOLVIDO
-- ====================================================================

-- 1️⃣ Verificar políticas RLS ativas
SELECT 
    policyname,
    cmd,
    CASE 
        WHEN cmd = 'SELECT' THEN '🔍 Leitura'
        WHEN cmd = 'INSERT' THEN '➕ Inserção'
        WHEN cmd = 'UPDATE' THEN '✏️ Atualização'
        WHEN cmd = 'DELETE' THEN '🗑️ Exclusão'
    END as tipo
FROM pg_policies
WHERE tablename = 'vendas_itens'
ORDER BY cmd;

-- 2️⃣ Testar query exatamente como o frontend faz
-- Esta é a query que estava dando erro 400
SELECT 
    vi.produto_id,
    vi.quantidade,
    vi.subtotal,
    p.nome
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

-- 3️⃣ Verificar totais das vendas
WITH vendas_com_itens AS (
    SELECT 
        v.id,
        v.created_at::date as data_venda,
        v.total as total_venda,
        COUNT(vi.id) as qtd_itens,
        COALESCE(SUM(vi.subtotal), 0) as total_calculado_itens
    FROM vendas v
    LEFT JOIN vendas_itens vi ON vi.venda_id = v.id
    WHERE v.created_at >= '2025-11-01'
    AND v.created_at < '2025-12-01'
    AND v.user_id = auth.uid()
    GROUP BY v.id, v.created_at, v.total
)
SELECT 
    COUNT(*) as total_vendas,
    SUM(total_venda) as soma_total_vendas,
    SUM(total_calculado_itens) as soma_total_itens,
    SUM(qtd_itens) as total_itens
FROM vendas_com_itens;

-- 4️⃣ Ranking de produtos mais vendidos
SELECT 
    p.nome as produto,
    COUNT(vi.id) as qtd_vendas,
    SUM(vi.quantidade) as qtd_total,
    SUM(vi.subtotal) as total_vendido
FROM vendas_itens vi
JOIN produtos p ON p.id = vi.produto_id
JOIN vendas v ON v.id = vi.venda_id
WHERE v.created_at >= '2025-11-01'
AND v.created_at < '2025-12-01'
AND vi.user_id = auth.uid()
GROUP BY p.id, p.nome
ORDER BY total_vendido DESC
LIMIT 10;

-- 5️⃣ Verificar estrutura final
SELECT 
    '✅ Coluna user_id existe' as status,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'vendas_itens'
AND column_name = 'user_id';

-- 6️⃣ Verificar índices criados
SELECT 
    indexname as indice,
    indexdef as definicao
FROM pg_indexes
WHERE tablename = 'vendas_itens'
AND indexname LIKE 'idx_%';

-- ====================================================================
-- RESULTADO ESPERADO
-- ====================================================================

/*
✅ SE TUDO ESTIVER CORRETO:

Query 1: Deve mostrar 4 políticas (SELECT, INSERT, UPDATE, DELETE)
Query 2: Deve retornar os itens das vendas (sem erro 400)
Query 3: Deve mostrar:
  - total_vendas: 6
  - soma_total_vendas: 174.90
  - soma_total_itens: 174.90
  - total_itens: 6+ (ou mais)

Query 4: Deve mostrar ranking de produtos
Query 5: Deve confirmar coluna user_id (uuid, nullable)
Query 6: Deve mostrar 3 índices criados

🎯 PRÓXIMO PASSO:
Abrir o frontend e verificar se:
- Console não mostra mais erro 400
- Relatórios carregam corretamente
- Total das vendas = R$ 174,90 (não mais R$ 0,00)
*/
