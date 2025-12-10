-- =====================================================
-- REMOVER POLÍTICAS ANTIGAS CONFLITANTES
-- =====================================================
-- As políticas antigas 'rls_policy' estão causando
-- conflito porque tentam verificar user_id em tabelas
-- onde essa coluna não existe (vendas_itens)
-- =====================================================

-- 1. REMOVER política antiga da tabela 'vendas'
-- =====================================================

DROP POLICY IF EXISTS "rls_policy" ON vendas;

-- 2. REMOVER política antiga da tabela 'vendas_itens'
-- =====================================================

DROP POLICY IF EXISTS "rls_policy" ON vendas_itens;

-- 3. Verificar se as políticas antigas foram removidas
-- =====================================================

SELECT 
    tablename,
    policyname,
    cmd,
    roles
FROM pg_policies 
WHERE tablename IN ('vendas', 'vendas_itens')
ORDER BY tablename, policyname;

-- =====================================================
-- RESULTADO ESPERADO:
-- Você deve ver APENAS as políticas novas:
-- - Usuários autenticados podem criar vendas
-- - Usuários autenticados podem ver vendas
-- - Usuários autenticados podem atualizar vendas
-- - Usuários autenticados podem criar itens de venda
-- - Usuários autenticados podem ver itens de venda
-- - Usuários autenticados podem atualizar itens de venda
--
-- NÃO deve aparecer mais: rls_policy
-- =====================================================

-- 4. EXPLICAÇÃO DO PROBLEMA
-- =====================================================
-- A política antiga 'rls_policy' tinha:
--   WHERE (auth.uid() = user_id)
--
-- Problema na tabela 'vendas_itens':
--   ❌ A coluna 'user_id' NÃO EXISTE nesta tabela
--   ❌ Isso causava erro 403 ao tentar inserir itens
--
-- Solução:
--   ✅ Removemos a política antiga
--   ✅ Mantemos apenas as novas políticas permissivas
--   ✅ Agora vendas_itens aceita INSERT sem problemas
-- =====================================================

-- 5. TESTE FINAL (OPCIONAL)
-- =====================================================
-- Teste se consegue inserir um item de venda:

/*
-- Primeiro, pegue uma venda existente
SELECT id FROM vendas ORDER BY created_at DESC LIMIT 1;

-- Depois tente inserir um item (use o ID acima)
INSERT INTO vendas_itens (
    venda_id,
    product_id,
    product_name,
    quantity,
    unit_price,
    total_price
) VALUES (
    'COLE_O_ID_DA_VENDA_AQUI',
    NULL,
    'Teste de Item',
    1,
    10.00,
    10.00
);

-- Se funcionou, delete o teste:
DELETE FROM vendas_itens WHERE product_name = 'Teste de Item';
*/

-- =====================================================
-- INSTRUÇÕES:
-- =====================================================
-- 1. Copie este script
-- 2. Cole no SQL Editor do Supabase
-- 3. Clique em RUN
-- 4. Verifique que 'rls_policy' não aparece mais
-- 5. Teste fazer uma venda no sistema
-- =====================================================
