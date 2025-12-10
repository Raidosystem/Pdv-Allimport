-- ====================================================================
-- CORREÇÃO: REMOVER POLÍTICAS DUPLICADAS E CONFLITANTES
-- ====================================================================
-- Problema: vendas_itens tem políticas duplicadas
-- Algumas usam user_id, outras usam empresa_id (que pode não existir)
-- ====================================================================

-- 1️⃣ VERIFICAR SE COLUNA empresa_id EXISTE
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'vendas_itens' 
AND column_name = 'empresa_id';

-- 2️⃣ REMOVER TODAS AS POLÍTICAS ANTIGAS
DROP POLICY IF EXISTS "vendas_itens_select" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_select_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_insert" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_insert_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_update" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_update_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_delete" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_delete_policy" ON vendas_itens;

-- 3️⃣ CRIAR POLÍTICAS SIMPLES E FUNCIONAIS

-- SELECT: Ver itens de suas próprias vendas
CREATE POLICY "vendas_itens_select_final"
ON vendas_itens
FOR SELECT
USING (
    user_id = auth.uid()
    OR
    EXISTS (
        SELECT 1 FROM vendas v
        WHERE v.id = vendas_itens.venda_id
        AND v.user_id = auth.uid()
    )
);

-- INSERT: Inserir apenas com seu user_id
CREATE POLICY "vendas_itens_insert_final"
ON vendas_itens
FOR INSERT
WITH CHECK (
    user_id = auth.uid()
    OR
    EXISTS (
        SELECT 1 FROM vendas v
        WHERE v.id = vendas_itens.venda_id
        AND v.user_id = auth.uid()
    )
);

-- UPDATE: Atualizar apenas seus próprios itens
CREATE POLICY "vendas_itens_update_final"
ON vendas_itens
FOR UPDATE
USING (
    user_id = auth.uid()
    OR
    EXISTS (
        SELECT 1 FROM vendas v
        WHERE v.id = vendas_itens.venda_id
        AND v.user_id = auth.uid()
    )
);

-- DELETE: Deletar apenas seus próprios itens
CREATE POLICY "vendas_itens_delete_final"
ON vendas_itens
FOR DELETE
USING (
    user_id = auth.uid()
    OR
    EXISTS (
        SELECT 1 FROM vendas v
        WHERE v.id = vendas_itens.venda_id
        AND v.user_id = auth.uid()
    )
);

-- 4️⃣ RECARREGAR CACHE DO POSTGREST
NOTIFY pgrst, 'reload schema';

-- 5️⃣ VERIFICAR POLÍTICAS APLICADAS
SELECT 
    policyname,
    cmd,
    qual
FROM pg_policies
WHERE tablename = 'vendas_itens'
ORDER BY cmd, policyname;

-- 6️⃣ TESTAR SE AGORA FUNCIONA
SELECT 
    COUNT(*) as total_itens_visiveis
FROM vendas_itens
WHERE user_id = auth.uid();

-- 7️⃣ TESTAR QUERY COM JOIN
SELECT 
    vi.id,
    vi.venda_id,
    vi.produto_id,
    vi.quantidade,
    vi.subtotal,
    p.nome AS produto_nome
FROM vendas_itens vi
LEFT JOIN produtos p ON p.id = vi.produto_id
WHERE vi.user_id = auth.uid()
LIMIT 5;

-- ====================================================================
-- RESULTADO ESPERADO
-- ====================================================================

/*
✅ APÓS EXECUTAR:

1. Políticas duplicadas removidas
2. 4 políticas novas criadas (SELECT, INSERT, UPDATE, DELETE)
3. Políticas permitem acesso por user_id OU por venda_id
4. Query 6 deve retornar o número de itens
5. Query 7 deve retornar itens com nome do produto

TESTE NO FRONTEND:
- Aguardar 10 segundos
- Recarregar página (F5)
- Ir em Relatórios
- Verificar se totais aparecem

⚠️ SE AINDA NÃO FUNCIONAR:
Dashboard → Settings → API → Restart
*/
