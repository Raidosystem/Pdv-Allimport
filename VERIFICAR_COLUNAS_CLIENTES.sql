-- =============================================
-- VERIFICAR TODAS AS COLUNAS DA TABELA CLIENTES
-- =============================================

-- 1. Ver TODAS as colunas da tabela clientes
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    ordinal_position
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- 2. Verificar se existe coluna usuario_id E user_id
SELECT 
    COUNT(*) FILTER (WHERE column_name = 'usuario_id') as tem_usuario_id,
    COUNT(*) FILTER (WHERE column_name = 'user_id') as tem_user_id
FROM information_schema.columns
WHERE table_name = 'clientes';

-- 3. Se usuario_id existir, REMOVÊ-LA
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'clientes' 
        AND column_name = 'usuario_id'
    ) THEN
        ALTER TABLE clientes DROP COLUMN usuario_id CASCADE;
        RAISE NOTICE '✅ Coluna usuario_id removida!';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna usuario_id não existe';
    END IF;
END $$;

-- 4. Verificar colunas finais
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'clientes'
    AND column_name LIKE '%user%'
ORDER BY column_name;
