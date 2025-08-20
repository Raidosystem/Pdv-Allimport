-- 🛠️ CÓPIA COM QUALQUER USER_ID EXISTENTE

-- O usuário específico não foi encontrado, vamos usar qualquer usuário

-- 1. ENCONTRAR QUALQUER USER_ID EXISTENTE
SELECT 'USUÁRIOS DISPONÍVEIS:' as info;
SELECT id, email FROM profiles LIMIT 5;

-- 2. CÓPIA COM PRIMEIRO USER_ID DISPONÍVEL
INSERT INTO produtos (id, nome, preco, user_id)
SELECT 
    id,
    name as nome,
    price as preco,
    (SELECT id FROM profiles ORDER BY created_at DESC LIMIT 1) as user_id
FROM products 
WHERE name LIKE 'ALLIMPORT%'
  AND price IS NOT NULL
LIMIT 5;

-- 3. VERIFICAR SE FUNCIONOU
SELECT 'PRODUTOS COPIADOS:' as resultado, COUNT(*) as total 
FROM produtos WHERE nome LIKE 'ALLIMPORT%';

-- 4. VER OS PRODUTOS COPIADOS
SELECT 'PRODUTOS NA TABELA PRODUTOS:' as info;
SELECT nome, preco FROM produtos WHERE nome LIKE 'ALLIMPORT%';

-- 5. SE FUNCIONOU, COPIAR TODOS (execute depois):
-- INSERT INTO produtos (id, nome, preco, user_id)
-- SELECT 
--     id,
--     name as nome, 
--     price as preco,
--     (SELECT id FROM profiles ORDER BY created_at DESC LIMIT 1) as user_id
-- FROM products 
-- WHERE name LIKE 'ALLIMPORT%'
--   AND price IS NOT NULL
--   AND id NOT IN (SELECT id FROM produtos WHERE nome LIKE 'ALLIMPORT%');

-- ✅ AGORA DEVE FUNCIONAR COM QUALQUER USUÁRIO!
