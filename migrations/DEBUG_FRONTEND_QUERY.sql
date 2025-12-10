-- 🔍 VERIFICAR SE O PROBLEMA ESTÁ NA QUERY DO FRONTEND

-- O frontend pode estar filtrando os dados com condições específicas
-- Vamos simular possíveis queries que o PDV pode estar fazendo:

-- 1. QUERY BÁSICA (o que o PDV deveria estar fazendo):
SELECT 'QUERY BÁSICA - TODOS ATIVOS:' as teste;
SELECT COUNT(*) as total FROM products WHERE active = true;

-- 2. QUERY COM CATEGORY_ID (pode estar filtrando por categoria):
SELECT 'PRODUTOS SEM CATEGORIA:' as teste;
SELECT COUNT(*) as total FROM products WHERE category_id IS NULL;

-- 3. QUERY COM STOCK > 0 (pode estar escondendo produtos sem estoque):
SELECT 'PRODUTOS COM ESTOQUE:' as teste;
SELECT COUNT(*) as total FROM products WHERE stock_quantity > 0;

-- 4. QUERY COMPLETA QUE O PDV PROVAVELMENTE USA:
SELECT 'PRODUTOS VISÍVEIS NO PDV:' as teste;
SELECT COUNT(*) as total FROM products 
WHERE active = true 
  AND stock_quantity > 0 
  AND category_id IS NOT NULL;

-- 5. VERIFICAR OS PRODUTOS ALLIMPORT ESPECIFICAMENTE:
SELECT 'ALLIMPORT - DETALHES COMPLETOS:' as teste;
SELECT 
    name,
    active,
    stock_quantity,
    category_id,
    price,
    CASE 
        WHEN active = false THEN 'INATIVO'
        WHEN stock_quantity = 0 THEN 'SEM ESTOQUE' 
        WHEN category_id IS NULL THEN 'SEM CATEGORIA'
        WHEN price = 0 THEN 'SEM PREÇO'
        ELSE 'OK'
    END as status_pdv
FROM products 
WHERE name LIKE 'ALLIMPORT%'
ORDER BY name;

-- 6. CONTAR CATEGORIAS ALLIMPORT:
SELECT 'CATEGORIAS ALLIMPORT:' as teste, COUNT(*) as total 
FROM categories WHERE name LIKE 'ALLIMPORT%';

-- ✅ EXECUTE E ME DIGA QUAIS PRODUTOS ALLIMPORT TÊM PROBLEMAS!
