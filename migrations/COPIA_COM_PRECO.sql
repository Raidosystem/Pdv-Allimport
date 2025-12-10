-- 🛠️ CÓPIA COM PREÇO OBRIGATÓRIO

-- O erro mostra que 'preco' é NOT NULL na tabela produtos
-- Vamos copiar incluindo o preço dos produtos ALLIMPORT

-- 1. VERIFICAR PREÇOS DOS PRODUTOS ALLIMPORT
SELECT 'PREÇOS DOS PRODUTOS ALLIMPORT:' as info;
SELECT name, price FROM products WHERE name LIKE 'ALLIMPORT%' LIMIT 5;

-- 2. COPIAR COM PREÇO INCLUÍDO
INSERT INTO produtos (id, nome, preco)
SELECT 
    id,
    name as nome,
    price as preco
FROM products 
WHERE name LIKE 'ALLIMPORT%'
  AND price IS NOT NULL
LIMIT 5; -- Testar com 5 primeiro

-- 3. VERIFICAR SE FUNCIONOU
SELECT 'PRODUTOS COPIADOS COM PREÇO:' as resultado, COUNT(*) as total 
FROM produtos WHERE nome LIKE 'ALLIMPORT%';

-- 4. VER OS PRODUTOS COPIADOS
SELECT 'PRODUTOS NA TABELA PRODUTOS:' as info;
SELECT nome, preco FROM produtos WHERE nome LIKE 'ALLIMPORT%';

-- 5. SE FUNCIONOU, COPIAR O RESTO (execute separadamente):
-- INSERT INTO produtos (id, nome, preco)
-- SELECT id, name as nome, price as preco
-- FROM products 
-- WHERE name LIKE 'ALLIMPORT%'
--   AND price IS NOT NULL
--   AND id NOT IN (SELECT id FROM produtos WHERE nome LIKE 'ALLIMPORT%');

-- ✅ AGORA OS PRODUTOS DEVEM APARECER NO PDV!
