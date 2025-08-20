-- 🚨 PROBLEMA ENCONTRADO! PDV BUSCA NA TABELA ERRADA

-- O frontend busca em 'produtos' (português) mas inserimos em 'products' (inglês)

-- VERIFICAR QUAIS TABELAS EXISTEM:
SELECT 'TABELAS EXISTENTES:' as info;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('products', 'produtos', 'categories', 'categorias', 'clients', 'clientes');

-- VERIFICAR DADOS NA TABELA 'produtos' (que o PDV usa):
SELECT 'DADOS NA TABELA PRODUTOS:' as info, COUNT(*) as total FROM produtos;

-- VERIFICAR DADOS NA TABELA 'products' (onde inserimos):
SELECT 'DADOS NA TABELA PRODUCTS:' as info, COUNT(*) as total FROM products;

-- SOLUÇÃO 1: COPIAR DADOS DE 'products' PARA 'produtos'
-- (Execute apenas se a tabela 'produtos' existir)

-- INSERT INTO produtos (id, nome, descricao, preco, estoque)
-- SELECT id, name, description, price, stock_quantity 
-- FROM products WHERE name LIKE 'ALLIMPORT%';

-- SOLUÇÃO 2: VERIFICAR ESTRUTURA DA TABELA 'produtos'
SELECT 'ESTRUTURA DA TABELA PRODUTOS:' as info;
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'produtos' 
ORDER BY ordinal_position;

-- ✅ EXECUTE ESTE SQL E ME DIGA QUAL TABELA EXISTE!
