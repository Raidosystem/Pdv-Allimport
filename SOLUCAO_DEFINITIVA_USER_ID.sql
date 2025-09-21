-- ========================================
-- 🔧 SOLUÇÃO DEFINITIVA: ADICIONAR COLUNAS USER_ID
-- Se as colunas user_id não existem, vamos criá-las!
-- ========================================

-- 1. PRIMEIRO VERIFICAR QUAIS COLUNAS EXISTEM
SELECT 
    '🔍 COLUNAS EXISTENTES' as info,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name IN ('produtos', 'clientes', 'vendas', 'itens_venda', 'caixa', 'movimentacoes_caixa')
  AND (column_name LIKE '%user%' OR column_name LIKE '%usuario%')
ORDER BY table_name, column_name;

-- 2. ADICIONAR COLUNA user_id SE NÃO EXISTIR
-- Para produtos
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE produtos ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela produtos';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela produtos';
    END IF;
END $$;

-- Para clientes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'clientes' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE clientes ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela clientes';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela clientes';
    END IF;
END $$;

-- Para vendas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendas' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE vendas ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela vendas';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela vendas';
    END IF;
END $$;

-- Para itens_venda
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'itens_venda' AND column_name = 'user_id' AND table_schema = 'public') THEN
        ALTER TABLE itens_venda ADD COLUMN user_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna user_id adicionada à tabela itens_venda';
    ELSE
        RAISE NOTICE '⚠️ Coluna user_id já existe na tabela itens_venda';
    END IF;
END $$;

-- Para caixa (usando usuario_id que é o padrão dessa tabela)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'caixa' AND column_name = 'usuario_id' AND table_schema = 'public') THEN
        ALTER TABLE caixa ADD COLUMN usuario_id UUID REFERENCES auth.users(id);
        RAISE NOTICE '✅ Coluna usuario_id adicionada à tabela caixa';
    ELSE
        RAISE NOTICE '⚠️ Coluna usuario_id já existe na tabela caixa';
    END IF;
END $$;

-- 3. CRIAR TRIGGERS PARA POPULAR user_id AUTOMATICAMENTE
-- Trigger para produtos
CREATE OR REPLACE FUNCTION set_user_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_id IS NULL THEN
        NEW.user_id = auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger em produtos
DROP TRIGGER IF EXISTS trigger_set_user_id_produtos ON produtos;
CREATE TRIGGER trigger_set_user_id_produtos
    BEFORE INSERT ON produtos
    FOR EACH ROW
    EXECUTE FUNCTION set_user_id();

-- Aplicar trigger em clientes  
DROP TRIGGER IF EXISTS trigger_set_user_id_clientes ON clientes;
CREATE TRIGGER trigger_set_user_id_clientes
    BEFORE INSERT ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION set_user_id();

-- Aplicar trigger em vendas
DROP TRIGGER IF EXISTS trigger_set_user_id_vendas ON vendas;
CREATE TRIGGER trigger_set_user_id_vendas
    BEFORE INSERT ON vendas
    FOR EACH ROW
    EXECUTE FUNCTION set_user_id();

-- 4. POPULAR user_id EM REGISTROS EXISTENTES COM O PRIMEIRO USUÁRIO
-- (Para dados existentes que não têm user_id)
UPDATE produtos 
SET user_id = (SELECT id FROM auth.users LIMIT 1)
WHERE user_id IS NULL;

UPDATE clientes 
SET user_id = (SELECT id FROM auth.users LIMIT 1)
WHERE user_id IS NULL;

UPDATE vendas 
SET user_id = (SELECT id FROM auth.users LIMIT 1)
WHERE user_id IS NULL;

-- 5. REABILITAR RLS E CRIAR POLÍTICAS
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE itens_venda ENABLE ROW LEVEL SECURITY;

-- Políticas corretas
DROP POLICY IF EXISTS "produtos_user_policy" ON produtos;
CREATE POLICY "produtos_user_policy" ON produtos
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "clientes_user_policy" ON clientes;
CREATE POLICY "clientes_user_policy" ON clientes
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "vendas_user_policy" ON vendas;
CREATE POLICY "vendas_user_policy" ON vendas
    FOR ALL
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "itens_venda_user_policy" ON itens_venda;
CREATE POLICY "itens_venda_user_policy" ON itens_venda
    FOR ALL
    USING (auth.uid() = user_id);

-- 6. VERIFICAÇÃO FINAL
SELECT 
    '🔍 COLUNAS APÓS CORREÇÃO' as info,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name IN ('produtos', 'clientes', 'vendas', 'itens_venda')
  AND column_name = 'user_id'
ORDER BY table_name;

SELECT 
    '🧪 TESTE FINAL' as info,
    'Produtos visíveis' as descricao,
    COUNT(*) as quantidade
FROM produtos;

SELECT '✅ SOLUÇÃO DEFINITIVA APLICADA - COLUNAS user_id CRIADAS E POPULADAS' as resultado;