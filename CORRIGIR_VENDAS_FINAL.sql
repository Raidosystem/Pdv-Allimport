-- ============================================
-- CORREÇÃO FINAL - TABELA VENDAS
-- ============================================

-- 1️⃣ Verificar estrutura atual
SELECT 
    '📋 COLUNAS DA TABELA VENDAS' as info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'vendas'
ORDER BY ordinal_position;

-- 2️⃣ Adicionar colunas faltantes (se não existirem)
DO $$
BEGIN
    -- Adicionar empresa_id se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE vendas ADD COLUMN empresa_id UUID REFERENCES empresas(id);
        RAISE NOTICE '✅ Coluna empresa_id adicionada à tabela vendas';
    ELSE
        RAISE NOTICE '⚠️ Coluna empresa_id já existe na tabela vendas';
    END IF;

    -- Adicionar caixa_id se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' AND column_name = 'caixa_id'
    ) THEN
        ALTER TABLE vendas ADD COLUMN caixa_id UUID REFERENCES caixa(id);
        RAISE NOTICE '✅ Coluna caixa_id adicionada à tabela vendas';
    ELSE
        RAISE NOTICE '⚠️ Coluna caixa_id já existe na tabela vendas';
    END IF;

    -- Adicionar detalhes_pagamento se não existir (para JSON)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'vendas' AND column_name = 'detalhes_pagamento'
    ) THEN
        ALTER TABLE vendas ADD COLUMN detalhes_pagamento JSONB;
        RAISE NOTICE '✅ Coluna detalhes_pagamento adicionada à tabela vendas';
    ELSE
        RAISE NOTICE '⚠️ Coluna detalhes_pagamento já existe na tabela vendas';
    END IF;
END $$;

-- 3️⃣ Verificar trigger auto_fill em vendas
SELECT 
    '⚡ TRIGGERS NA TABELA VENDAS' as info,
    trigger_name,
    event_manipulation,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'vendas';

-- 4️⃣ Recriar trigger se não existir
DROP TRIGGER IF EXISTS auto_fill_vendas_empresa_user ON vendas;

CREATE TRIGGER auto_fill_vendas_empresa_user
    BEFORE INSERT ON vendas
    FOR EACH ROW
    EXECUTE FUNCTION auto_fill_empresa_user_id();

-- 5️⃣ Testar INSERT mínimo (descomente para testar)
/*
DO $$
DECLARE
    venda_teste_id UUID;
BEGIN
    INSERT INTO vendas (
        total,
        desconto,
        status,
        metodo_pagamento
    ) VALUES (
        100.00,
        0,
        'completed',
        'cash'
    )
    RETURNING id INTO venda_teste_id;
    
    RAISE NOTICE '✅ Venda teste criada com ID: %', venda_teste_id;
    
    -- Ver a venda criada
    PERFORM * FROM vendas WHERE id = venda_teste_id;
    
    -- Deletar venda teste
    DELETE FROM vendas WHERE id = venda_teste_id;
    RAISE NOTICE '🗑️ Venda teste deletada';
END $$;
*/

SELECT '✅ CORREÇÃO APLICADA! Teste a venda novamente no sistema.' as resultado;
