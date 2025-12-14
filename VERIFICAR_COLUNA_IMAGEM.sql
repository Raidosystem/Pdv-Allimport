-- 🔍 VERIFICAR SE A COLUNA image_url EXISTE NA TABELA produtos

-- 1. Verificar estrutura da tabela produtos
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'produtos'
ORDER BY ordinal_position;

-- 2. Se a coluna NÃO existir, adicionar
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'produtos' 
        AND column_name = 'image_url'
    ) THEN
        ALTER TABLE produtos ADD COLUMN image_url TEXT;
        RAISE NOTICE '✅ Coluna image_url adicionada à tabela produtos';
    ELSE
        RAISE NOTICE '✅ Coluna image_url já existe na tabela produtos';
    END IF;
END $$;

-- 3. Verificar se há produtos com imagem
SELECT 
    COUNT(*) as total_produtos,
    COUNT(image_url) as produtos_com_imagem,
    COUNT(*) - COUNT(image_url) as produtos_sem_imagem
FROM produtos;

-- 4. Mostrar alguns produtos com suas imagens (se houver)
SELECT 
    id,
    nome,
    image_url,
    LEFT(image_url, 50) as preview_url
FROM produtos
WHERE image_url IS NOT NULL
LIMIT 5;
