-- 🔍 Verificar a categoria específica que está causando erro

SELECT 
  id, 
  name, 
  empresa_id,
  created_at
FROM categories
WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';

-- Se não aparecer nada acima, ela foi deletada. 
-- Então vamos listar as categorias disponíveis para selecionar uma válida:

SELECT 
  id, 
  name, 
  empresa_id
FROM categories
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
LIMIT 10;
