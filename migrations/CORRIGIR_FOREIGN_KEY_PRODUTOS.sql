-- ====================================================================
-- CORREÇÃO: FOREIGN KEY ENTRE vendas_itens E produtos
-- ====================================================================
-- Erro: "Could not find a relationship between 'vendas_itens' and 'produtos'"
-- Solução: Recriar Foreign Key e recarregar cache do PostgREST
-- ====================================================================

-- 1️⃣ VERIFICAR SE A FOREIGN KEY EXISTE
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'vendas_itens'
    AND tc.constraint_type = 'FOREIGN KEY'
    AND ccu.table_name = 'produtos';

-- 2️⃣ REMOVER FOREIGN KEY ANTIGA (se existir)
ALTER TABLE vendas_itens
DROP CONSTRAINT IF EXISTS vendas_itens_produto_id_fkey;

ALTER TABLE vendas_itens
DROP CONSTRAINT IF EXISTS fk_vendas_itens_produtos;

ALTER TABLE vendas_itens
DROP CONSTRAINT IF EXISTS vendas_itens_produto_fkey;

-- 3️⃣ CRIAR FOREIGN KEY CORRETA
ALTER TABLE vendas_itens
ADD CONSTRAINT vendas_itens_produto_id_fkey
FOREIGN KEY (produto_id)
REFERENCES produtos(id)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- 4️⃣ RECARREGAR CACHE DO POSTGREST (CRÍTICO!)
-- Isso força o Supabase a recarregar o schema
NOTIFY pgrst, 'reload schema';

-- 5️⃣ VERIFICAR SE FOI CRIADA
SELECT
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table,
    ccu.column_name AS foreign_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'vendas_itens'
    AND tc.constraint_type = 'FOREIGN KEY'
    AND ccu.table_name = 'produtos';

-- 6️⃣ TESTAR QUERY COM JOIN (deve funcionar agora)
SELECT 
    vi.id,
    vi.produto_id,
    vi.quantidade,
    vi.subtotal,
    p.nome AS produto_nome
FROM vendas_itens vi
LEFT JOIN produtos p ON p.id = vi.produto_id
WHERE vi.user_id = auth.uid()
LIMIT 5;

-- ====================================================================
-- ALTERNATIVA: Se o problema persistir, também criar FK para venda_id
-- ====================================================================

-- Verificar FK de venda_id
SELECT
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'vendas_itens'
    AND tc.constraint_type = 'FOREIGN KEY'
    AND ccu.table_name = 'vendas';

-- Recriar FK de venda_id (se necessário)
ALTER TABLE vendas_itens
DROP CONSTRAINT IF EXISTS vendas_itens_venda_id_fkey;

ALTER TABLE vendas_itens
ADD CONSTRAINT vendas_itens_venda_id_fkey
FOREIGN KEY (venda_id)
REFERENCES vendas(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- ====================================================================
-- RECARREGAR CACHE NOVAMENTE (IMPORTANTE!)
-- ====================================================================
NOTIFY pgrst, 'reload schema';

-- ====================================================================
-- RESULTADO ESPERADO
-- ====================================================================

/*
✅ APÓS EXECUTAR:

1. Foreign Key vendas_itens → produtos recriada
2. Foreign Key vendas_itens → vendas recriada (se necessário)
3. Cache do PostgREST recarregado
4. Frontend deve conseguir fazer JOIN via API REST

TESTE NO FRONTEND:
- Recarregar página (F5)
- Ir em Relatórios
- Verificar se erro 400 desapareceu
- Verificar se totais aparecem (R$ 174,90)

⚠️ IMPORTANTE:
Se mesmo após executar este script o erro persistir,
vá no Dashboard do Supabase → Settings → API
e clique em "Restart" para forçar o reload completo.
*/
