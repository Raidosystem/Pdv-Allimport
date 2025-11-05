-- ============================================
-- DEBUG: VERIFICAR VENDAS NO BANCO
-- Execute no Supabase SQL Editor
-- ============================================

-- 1. Contar TODAS as vendas
SELECT 
    '📊 TOTAL DE VENDAS' as secao,
    COUNT(*) as total,
    COUNT(CASE WHEN status = 'finalizada' THEN 1 END) as finalizadas,
    COUNT(CASE WHEN status = 'pendente' THEN 1 END) as pendentes,
    COUNT(CASE WHEN status = 'cancelada' THEN 1 END) as canceladas
FROM vendas;

-- 2. Ver últimas 5 vendas com TODOS os campos
SELECT 
    '💰 ÚLTIMAS 5 VENDAS' as secao,
    id,
    user_id,
    cliente_id,
    total,
    desconto,
    metodo_pagamento,
    status,
    observacoes,
    created_at,
    updated_at
FROM vendas
ORDER BY created_at DESC
LIMIT 5;

-- 3. Ver vendas de HOJE
SELECT 
    '📅 VENDAS DE HOJE' as secao,
    id,
    total,
    desconto,
    (total - COALESCE(desconto, 0)) as valor_final,
    metodo_pagamento,
    status,
    created_at::time as hora
FROM vendas
WHERE created_at::date = CURRENT_DATE
ORDER BY created_at DESC;

-- 4. Ver vendas do MÊS ATUAL
SELECT 
    '📅 VENDAS DO MÊS ATUAL' as secao,
    COUNT(*) as quantidade,
    SUM(total) as total_bruto,
    SUM(COALESCE(desconto, 0)) as total_descontos,
    SUM(total - COALESCE(desconto, 0)) as total_liquido
FROM vendas
WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE);

-- 5. Ver itens da última venda
SELECT 
    '📦 ITENS DA ÚLTIMA VENDA' as secao,
    vi.id,
    vi.venda_id,
    vi.produto_id,
    p.nome as produto_nome,
    vi.quantidade,
    vi.preco_unitario,
    vi.subtotal,
    vi.created_at
FROM vendas_itens vi
LEFT JOIN produtos p ON p.id = vi.produto_id
WHERE vi.venda_id = (SELECT id FROM vendas ORDER BY created_at DESC LIMIT 1)
ORDER BY vi.created_at;

-- 6. Verificar RLS - Ver se o user_id está preenchido
SELECT 
    '🔒 VERIFICAR USER_ID (RLS)' as secao,
    COUNT(*) as total_vendas,
    COUNT(user_id) as com_user_id,
    COUNT(*) - COUNT(user_id) as sem_user_id
FROM vendas;

-- 7. Ver estrutura da tabela vendas
SELECT 
    '📋 ESTRUTURA TABELA VENDAS' as secao,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'vendas'
  AND table_schema = 'public'
ORDER BY ordinal_position;
