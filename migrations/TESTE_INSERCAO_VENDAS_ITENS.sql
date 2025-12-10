-- =====================================================
-- TESTE DE INSERÇÃO: vendas_itens
-- =====================================================
-- Baseado no erro 400 ocorrido
-- =====================================================

-- 1️⃣ TESTE 1: Inserir com todos os campos (igual aos registros existentes)
INSERT INTO vendas_itens (
    venda_id,
    produto_id,
    quantidade,
    preco_unitario,
    subtotal,
    user_id
) VALUES (
    '17465a00-1793-4b5a-9c54-0419799c3b40', -- Venda existente
    NULL, -- produto_id NULL (igual aos registros que funcionaram)
    1,
    20.00,
    20.00,
    'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' -- user_id atual
)
RETURNING *;

-- Se o teste acima funcionar, o problema é no FRONTEND/RLS

-- 2️⃣ TESTE 2: Inserir SEM user_id (deixar trigger preencher)
INSERT INTO vendas_itens (
    venda_id,
    produto_id,
    quantidade,
    preco_unitario,
    subtotal
) VALUES (
    '17465a00-1793-4b5a-9c54-0419799c3b40',
    NULL,
    1,
    15.00,
    15.00
)
RETURNING *;

-- Se TESTE 2 falhar, o problema é no TRIGGER

-- =====================================================
-- 🔍 VERIFICAR POLÍTICAS RLS ESPECÍFICAS
-- =====================================================

-- Ver política de INSERT
SELECT 
    policyname,
    cmd,
    permissive,
    qual::text as usando_where,
    with_check::text as com_check
FROM pg_policies 
WHERE tablename = 'vendas_itens'
AND cmd = 'INSERT';

-- =====================================================
-- 🔧 CORREÇÃO PROVÁVEL: RLS COM WITH CHECK MUITO RESTRITIVO
-- =====================================================

-- Ver se a política WITH CHECK está bloqueando
-- Exemplo de política problemática:
/*
CREATE POLICY "vendas_itens_insert" ON vendas_itens
FOR INSERT 
USING (user_id = auth.uid())  -- ❌ ERRADO! USING não funciona em INSERT
WITH CHECK (user_id = auth.uid()); -- ✅ Mas user_id está NULL no momento da validação
*/

-- SOLUÇÃO: Política que permite INSERT e deixa trigger preencher user_id
DROP POLICY IF EXISTS "vendas_itens_insert_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_policy" ON vendas_itens;
DROP POLICY IF EXISTS "Usuários podem inserir itens de venda" ON vendas_itens;

-- Criar política permissiva CORRETA
CREATE POLICY "vendas_itens_insert_authenticated" 
ON vendas_itens 
FOR INSERT 
TO authenticated
WITH CHECK (
    -- Verifica se a venda pertence ao usuário logado
    venda_id IN (
        SELECT id FROM vendas WHERE user_id = auth.uid()
    )
);

-- OU ainda mais permissiva (se preferir validar depois):
/*
CREATE POLICY "vendas_itens_insert_authenticated" 
ON vendas_itens 
FOR INSERT 
TO authenticated
WITH CHECK (true);
*/

-- =====================================================
-- 📊 DIAGNÓSTICO ADICIONAL
-- =====================================================

-- Verificar se a venda do log existe
SELECT 
    id, 
    user_id, 
    total, 
    status,
    created_at
FROM vendas 
WHERE id = '17465a00-1793-4b5a-9c54-0419799c3b40';

-- Verificar políticas de todas as operações
SELECT 
    cmd as operacao,
    policyname as nome_politica,
    permissive,
    CASE 
        WHEN qual IS NOT NULL THEN 'Sim' 
        ELSE 'Não' 
    END as tem_using,
    CASE 
        WHEN with_check IS NOT NULL THEN 'Sim' 
        ELSE 'Não' 
    END as tem_with_check
FROM pg_policies 
WHERE tablename = 'vendas_itens'
ORDER BY cmd;
