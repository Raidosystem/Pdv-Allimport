-- 🔧 CÓPIA SEGURA PARA TABELA 'produtos' (SEM COLUNA 'ativo')

-- 1. PRIMEIRO: Verificar estrutura da tabela 'produtos'
SELECT 'ESTRUTURA DA TABELA PRODUTOS:' as info;
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'produtos' 
ORDER BY ordinal_position;

-- 2. TENTAR CÓPIA SEM A COLUNA 'ativo'
INSERT INTO produtos (id, nome, descricao, preco, estoque)
SELECT 
    id,
    name as nome,
    description as descricao, 
    price as preco,
    stock_quantity as estoque
FROM products 
WHERE name LIKE 'ALLIMPORT%';

-- 3. VERIFICAR SE FUNCIONOU
SELECT 'PRODUTOS ALLIMPORT COPIADOS:' as resultado, COUNT(*) as total 
FROM produtos WHERE nome LIKE 'ALLIMPORT%';

-- 4. LISTAR ALGUNS PRODUTOS COPIADOS
SELECT 'PRODUTOS NA TABELA PRODUTOS:' as info;
SELECT nome, preco, estoque FROM produtos WHERE nome LIKE 'ALLIMPORT%' LIMIT 10;

-- ✅ AGORA OS PRODUTOS DEVEM APARECER NO PDV!
-- Se ainda der erro, me mande a estrutura da tabela 'produtos' primeiro
