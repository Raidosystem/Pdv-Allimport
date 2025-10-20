-- 🔧 ATUALIZAR CATEGORIAS COM O UUID CORRETO

-- UUID do usuário: f7fdf4cf-7101-45ab-86db-5248a7ac58c1
-- Email: assistenciaallimport10@gmail.com

-- Atualizar todas as categorias que estão com empresa_id = NULL
UPDATE categories 
SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE empresa_id IS NULL;

-- Verificar o resultado
SELECT COUNT(*) as total_categorias 
FROM categories 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Listar todas as categorias agora associadas
SELECT id, name, empresa_id, created_at 
FROM categories 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY name;
