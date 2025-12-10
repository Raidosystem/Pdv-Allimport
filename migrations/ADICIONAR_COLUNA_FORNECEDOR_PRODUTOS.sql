-- =============================================
-- VERIFICAR E ADICIONAR COLUNA FORNECEDOR
-- =============================================

-- 1. Verificar se a coluna já existe
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'produtos'
AND column_name = 'fornecedor';

-- 2. Adicionar coluna se não existir
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS fornecedor TEXT;

SELECT '✅ Coluna fornecedor verificada/adicionada!' as status;

-- 3. Ver estrutura completa da tabela produtos
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'produtos'
ORDER BY ordinal_position;

-- 4. Ver alguns produtos (apenas colunas básicas)
SELECT 
    id,
    nome,
    fornecedor
FROM produtos
LIMIT 5;
