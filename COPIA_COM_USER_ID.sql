-- 🛠️ CÓPIA FINAL COM USER_ID OBRIGATÓRIO

-- A tabela 'produtos' exige user_id (RLS ativo)
-- Vamos incluir o user_id do usuário atual

-- 1. ENCONTRAR O USER_ID ATUAL
SELECT 'USER_ID ATUAL:' as info, id, email FROM profiles WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. CÓPIA COM USER_ID INCLUÍDO
INSERT INTO produtos (id, nome, preco, user_id)
SELECT 
    id,
    name as nome,
    price as preco,
    (SELECT id FROM profiles WHERE email = 'assistenciaallimport10@gmail.com') as user_id
FROM products 
WHERE name LIKE 'ALLIMPORT%'
  AND price IS NOT NULL
LIMIT 5; -- Testar com 5 primeiro

-- 3. VERIFICAR SE FUNCIONOU
SELECT 'PRODUTOS COPIADOS COM USER_ID:' as resultado, COUNT(*) as total 
FROM produtos WHERE nome LIKE 'ALLIMPORT%';

-- 4. VER OS PRODUTOS COPIADOS
SELECT 'PRODUTOS NA TABELA PRODUTOS:' as info;
SELECT nome, preco, user_id FROM produtos WHERE nome LIKE 'ALLIMPORT%';

-- 5. SE FUNCIONOU, COPIAR TODOS (execute separadamente):
-- INSERT INTO produtos (id, nome, preco, user_id)
-- SELECT 
--     id,
--     name as nome, 
--     price as preco,
--     (SELECT id FROM profiles WHERE email = 'assistenciaallimport10@gmail.com') as user_id
-- FROM products 
-- WHERE name LIKE 'ALLIMPORT%'
--   AND price IS NOT NULL
--   AND id NOT IN (SELECT id FROM produtos WHERE nome LIKE 'ALLIMPORT%');

-- ✅ AGORA COM USER_ID DEVE FUNCIONAR!
