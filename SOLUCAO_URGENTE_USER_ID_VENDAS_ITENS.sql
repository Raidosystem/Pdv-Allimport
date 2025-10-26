-- =====================================================
-- SOLUÇÃO URGENTE: user_id NULL em vendas_itens
-- =====================================================
-- Problema: Trigger não está preenchendo user_id automaticamente
-- Erro: "null value in column user_id violates not-null constraint"
-- =====================================================

-- 🚨 SOLUÇÃO 1: CRIAR/RECRIAR TRIGGER CORRETO
-- =====================================================

-- Remover trigger antigo se existir
DROP TRIGGER IF EXISTS trigger_set_user_id_vendas_itens ON vendas_itens;
DROP TRIGGER IF EXISTS set_user_id_vendas_itens ON vendas_itens;
DROP TRIGGER IF EXISTS trigger_auto_user_id ON vendas_itens;

-- Remover função antiga
DROP FUNCTION IF EXISTS set_user_id_vendas_itens();
DROP FUNCTION IF EXISTS trigger_set_user_id();

-- Criar função CORRETA
CREATE OR REPLACE FUNCTION auto_set_user_id_vendas_itens()
RETURNS TRIGGER AS $$
BEGIN
  -- Preencher user_id se estiver NULL
  IF NEW.user_id IS NULL THEN
    NEW.user_id := auth.uid();
  END IF;
  
  -- Se ainda for NULL, tentar pegar da venda
  IF NEW.user_id IS NULL THEN
    SELECT user_id INTO NEW.user_id 
    FROM vendas 
    WHERE id = NEW.venda_id 
    LIMIT 1;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger ANTES de inserir
CREATE TRIGGER trigger_auto_user_id_vendas_itens
  BEFORE INSERT ON vendas_itens
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_user_id_vendas_itens();

-- =====================================================
-- 🚨 SOLUÇÃO 2 (ALTERNATIVA): REMOVER CONSTRAINT NOT NULL
-- =====================================================
-- Use apenas se preferir permitir user_id NULL

-- ALTER TABLE vendas_itens 
-- ALTER COLUMN user_id DROP NOT NULL;

-- =====================================================
-- ✅ TESTE APÓS APLICAR A CORREÇÃO
-- =====================================================

-- Teste 1: Inserir SEM user_id (trigger deve preencher)
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

-- Se funcionar, o problema está resolvido! ✅

-- =====================================================
-- 🔧 CORRIGIR RLS TAMBÉM (importante!)
-- =====================================================

-- Remover políticas antigas conflitantes
DROP POLICY IF EXISTS "vendas_itens_insert_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_isolamento_total" ON vendas_itens;
DROP POLICY IF EXISTS "rls_isolamento_vendas_itens" ON vendas_itens;

-- Criar política correta para INSERT
CREATE POLICY "vendas_itens_insert_auth" 
ON vendas_itens 
FOR INSERT 
TO authenticated
WITH CHECK (
    -- Valida pela venda (não pelo user_id do item)
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE vendas.id = vendas_itens.venda_id 
        AND vendas.user_id = auth.uid()
    )
);

-- Política para SELECT
DROP POLICY IF EXISTS "vendas_itens_select_policy" ON vendas_itens;
CREATE POLICY "vendas_itens_select_auth" 
ON vendas_itens 
FOR SELECT 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE vendas.id = vendas_itens.venda_id 
        AND vendas.user_id = auth.uid()
    )
);

-- Política para UPDATE
DROP POLICY IF EXISTS "vendas_itens_update_policy" ON vendas_itens;
CREATE POLICY "vendas_itens_update_auth" 
ON vendas_itens 
FOR UPDATE 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE vendas.id = vendas_itens.venda_id 
        AND vendas.user_id = auth.uid()
    )
);

-- Política para DELETE
DROP POLICY IF EXISTS "vendas_itens_delete_policy" ON vendas_itens;
CREATE POLICY "vendas_itens_delete_auth" 
ON vendas_itens 
FOR DELETE 
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM vendas 
        WHERE vendas.id = vendas_itens.venda_id 
        AND vendas.user_id = auth.uid()
    )
);

-- =====================================================
-- 📊 VERIFICAR SE ESTÁ TUDO OK
-- =====================================================

-- 1. Verificar se o trigger foi criado
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'vendas_itens'
AND trigger_schema = 'public';

-- 2. Verificar se as políticas foram criadas
SELECT 
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'vendas_itens'
ORDER BY cmd;

-- 3. Testar inserção completa
INSERT INTO vendas_itens (
    venda_id,
    produto_id,
    quantidade,
    preco_unitario,
    subtotal
) VALUES (
    '17465a00-1793-4b5a-9c54-0419799c3b40',
    NULL,
    2,
    25.00,
    50.00
)
RETURNING id, venda_id, produto_id, quantidade, preco_unitario, subtotal, user_id;

-- Se user_id vier preenchido, SUCESSO! ✅
