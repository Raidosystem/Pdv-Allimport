-- =====================================================
-- CORREÇÃO DE PERMISSÕES PARA VENDAS E ITENS DE VENDA
-- =====================================================
-- Este script corrige as políticas RLS para permitir
-- inserção de vendas e itens de venda corretamente
-- =====================================================

-- 1. Verificar e recriar políticas para tabela 'vendas'
-- =====================================================

-- Remover políticas existentes se houver conflito
DROP POLICY IF EXISTS "Usuários autenticados podem inserir vendas" ON vendas;
DROP POLICY IF EXISTS "Usuários podem inserir suas vendas" ON vendas;
DROP POLICY IF EXISTS "Permitir INSERT de vendas para usuários autenticados" ON vendas;

-- Criar política de INSERT para vendas (mais permissiva)
CREATE POLICY "Usuários autenticados podem criar vendas"
ON vendas
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política de SELECT para vendas
DROP POLICY IF EXISTS "Usuários autenticados podem ver vendas" ON vendas;
CREATE POLICY "Usuários autenticados podem ver vendas"
ON vendas
FOR SELECT
TO authenticated
USING (true);

-- Política de UPDATE para vendas
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar vendas" ON vendas;
CREATE POLICY "Usuários autenticados podem atualizar vendas"
ON vendas
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- 2. Verificar e recriar políticas para tabela 'vendas_itens'
-- =====================================================

-- Remover políticas existentes se houver conflito
DROP POLICY IF EXISTS "Usuários autenticados podem inserir itens de venda" ON vendas_itens;
DROP POLICY IF EXISTS "Usuários podem inserir itens de suas vendas" ON vendas_itens;
DROP POLICY IF EXISTS "Permitir INSERT de itens para usuários autenticados" ON vendas_itens;

-- Criar política de INSERT para vendas_itens (mais permissiva)
CREATE POLICY "Usuários autenticados podem criar itens de venda"
ON vendas_itens
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Política de SELECT para vendas_itens
DROP POLICY IF EXISTS "Usuários autenticados podem ver itens de venda" ON vendas_itens;
CREATE POLICY "Usuários autenticados podem ver itens de venda"
ON vendas_itens
FOR SELECT
TO authenticated
USING (true);

-- Política de UPDATE para vendas_itens
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar itens de venda" ON vendas_itens;
CREATE POLICY "Usuários autenticados podem atualizar itens de venda"
ON vendas_itens
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- 3. Garantir que RLS está habilitado nas tabelas
-- =====================================================

ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens ENABLE ROW LEVEL SECURITY;

-- 4. Verificar as políticas criadas
-- =====================================================

SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename IN ('vendas', 'vendas_itens')
ORDER BY tablename, policyname;

-- =====================================================
-- RESULTADO ESPERADO:
-- Você deve ver políticas para INSERT, SELECT e UPDATE
-- em ambas as tabelas (vendas e vendas_itens)
-- =====================================================

-- 5. Testar as permissões (OPCIONAL - para debug)
-- =====================================================

-- Verificar se consegue inserir uma venda de teste
-- DESCOMENTE PARA TESTAR:

/*
-- Teste de INSERT em vendas
INSERT INTO vendas (
    user_id,
    customer_id,
    cash_register_id,
    total_amount,
    discount_amount,
    payment_method,
    status
) VALUES (
    auth.uid(),
    NULL,
    (SELECT id FROM caixas WHERE status = 'aberto' LIMIT 1),
    100.00,
    0,
    'cash',
    'completed'
) RETURNING id;

-- Teste de INSERT em vendas_itens (use o ID retornado acima)
INSERT INTO vendas_itens (
    venda_id,
    product_id,
    product_name,
    quantity,
    unit_price,
    total_price
) VALUES (
    'COLE_AQUI_O_ID_DA_VENDA',
    (SELECT id FROM produtos LIMIT 1),
    'Produto Teste',
    1,
    100.00,
    100.00
);
*/

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Copie todo este script
-- 2. Vá em: https://supabase.com/dashboard/project/[SEU_PROJETO]/editor/sql
-- 3. Cole o script e clique em "RUN"
-- 4. Verifique os resultados
-- 5. Teste fazer uma venda no sistema
-- =====================================================
