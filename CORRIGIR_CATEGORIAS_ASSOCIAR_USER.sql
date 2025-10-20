-- 🔧 CORRIGIR CATEGORIAS - ASSOCIAR AO USUÁRIO CORRETO

-- 1. Encontrar o UUID do usuário assistenciaallimport10@gmail.com
-- Execute isso primeiro para obter o UUID
SELECT id as user_id, email 
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com'
LIMIT 1;

-- 2. DEPOIS de copiar o UUID acima, execute este comando para ATUALIZAR as categorias
-- Substitua 'SEU_UUID_AQUI' pelo UUID obtido acima
-- UPDATE categories 
-- SET empresa_id = 'SEU_UUID_AQUI'
-- WHERE empresa_id IS NULL;

-- 3. Verificar o resultado
-- SELECT COUNT(*) as total_categorias FROM categories WHERE empresa_id IS NOT NULL;
-- SELECT empresa_id, COUNT(*) as total FROM categories GROUP BY empresa_id;
