-- 🔍 DIAGNÓSTICO DE CATEGORIAS

-- 1. Encontrar o UUID do usuário assistenciaallimport10@gmail.com
SELECT id as user_id, email 
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. Contar categorias para este usuário
-- (Substitua o UUID abaixo pelo resultado do comando anterior)
-- SELECT COUNT(*) FROM categories WHERE empresa_id = '<USER_ID>';

-- 3. Listar todas as categorias para este usuário (se existirem)
-- SELECT id, name, empresa_id, created_at FROM categories WHERE empresa_id = '<USER_ID>';

-- 4. Ver distribuição de categorias por empresa_id
SELECT empresa_id, COUNT(*) as total
FROM categories
GROUP BY empresa_id
ORDER BY total DESC;

-- 5. Ver TODAS as categorias (para verificar se há alguma)
SELECT id, name, empresa_id, created_at 
FROM categories 
ORDER BY created_at DESC 
LIMIT 50;
