-- 🔍 VERIFICAR E CORRIGIR TABELA PRODUTOS PARA LOJA ONLINE

-- 1. Verificar estrutura atual da tabela produtos
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'produtos'
ORDER BY ordinal_position;

-- 2. Verificar se empresa_id existe (necessário para RLS da loja)
SELECT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'produtos' 
    AND column_name = 'empresa_id'
) as coluna_empresa_id_existe;

-- 3. Verificar se quantidade existe (usado na loja)
SELECT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'produtos' 
    AND column_name = 'quantidade'
) as coluna_quantidade_existe;

-- 4. CORRIGIR: Adicionar colunas faltantes se necessário
DO $$
BEGIN
    -- Adicionar empresa_id se não existir (mapear de user_id)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'produtos' AND column_name = 'empresa_id'
    ) THEN
        ALTER TABLE produtos ADD COLUMN empresa_id UUID REFERENCES auth.users(id);
        
        -- Copiar user_id para empresa_id
        UPDATE produtos SET empresa_id = user_id WHERE empresa_id IS NULL;
        
        RAISE NOTICE '✅ Coluna empresa_id adicionada e populada';
    ELSE
        RAISE NOTICE '✅ Coluna empresa_id já existe';
    END IF;

    -- Adicionar quantidade se não existir (mapear de estoque)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'produtos' AND column_name = 'quantidade'
    ) THEN
        ALTER TABLE produtos ADD COLUMN quantidade INTEGER DEFAULT 0;
        
        -- Copiar estoque para quantidade
        UPDATE produtos SET quantidade = estoque WHERE quantidade IS NULL OR quantidade = 0;
        
        RAISE NOTICE '✅ Coluna quantidade adicionada e populada';
    ELSE
        RAISE NOTICE '✅ Coluna quantidade já existe';
    END IF;

    -- Adicionar descricao se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'produtos' AND column_name = 'descricao'
    ) THEN
        ALTER TABLE produtos ADD COLUMN descricao TEXT;
        RAISE NOTICE '✅ Coluna descricao adicionada';
    ELSE
        RAISE NOTICE '✅ Coluna descricao já existe';
    END IF;
END $$;

-- 5. Verificar função RPC listar_produtos_loja
SELECT 
    routine_name,
    routine_type,
    data_type as return_type
FROM information_schema.routines
WHERE routine_name = 'listar_produtos_loja'
AND routine_schema = 'public';

-- 6. Testar a função com o slug da loja
SELECT public.listar_produtos_loja('loja-allimport');

-- 7. Ver alguns produtos para debug
SELECT 
    id,
    nome,
    preco,
    COALESCE(quantidade, estoque, 0) as qtd,
    ativo,
    user_id,
    empresa_id
FROM produtos
WHERE ativo = true
LIMIT 5;
