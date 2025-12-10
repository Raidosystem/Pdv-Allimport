-- ====================================================================
-- FORÇAR RELOAD DO CACHE DO POSTGREST
-- ====================================================================
-- A Foreign Key existe, mas o PostgREST não está reconhecendo
-- Este comando força o reload do schema cache
-- ====================================================================

-- 🔄 RECARREGAR SCHEMA CACHE
NOTIFY pgrst, 'reload schema';

-- ====================================================================
-- ALTERNATIVA: RECRIAR FOREIGN KEY PARA FORÇAR DETECÇÃO
-- ====================================================================

-- Remover e recriar a FK força o PostgREST a detectar
ALTER TABLE vendas_itens
DROP CONSTRAINT vendas_itens_produto_id_fkey;

ALTER TABLE vendas_itens
ADD CONSTRAINT vendas_itens_produto_id_fkey
FOREIGN KEY (produto_id)
REFERENCES produtos(id)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- Recarregar novamente
NOTIFY pgrst, 'reload schema';

-- ====================================================================
-- VERIFICAR RESULTADO
-- ====================================================================

-- Confirmar que FK foi recriada
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

-- ====================================================================
-- SE AINDA NÃO FUNCIONAR
-- ====================================================================

/*
⚠️ Se o erro 400 persistir após executar este script:

1️⃣ Vá no Dashboard do Supabase
2️⃣ Settings → API
3️⃣ Clique em "Restart" para reiniciar a API
4️⃣ Aguarde 30 segundos
5️⃣ Recarregue o frontend (F5)

Isso força um reload completo do PostgREST.
*/
