-- 🔍 DIAGNOSTICAR PROBLEMA DE FOREIGN KEY
-- Verificar qual tabela de categorias está sendo usada

-- 1. Verificar se ambas as tabelas existem
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name IN ('categories', 'categorias')
ORDER BY table_name, ordinal_position;

-- 2. Verificar constraints de foreign key na tabela produtos
SELECT
  constraint_name,
  table_name,
  column_name,
  foreign_table_name,
  foreign_column_name
FROM information_schema.referential_constraints
JOIN information_schema.constraint_column_usage USING (constraint_catalog, constraint_schema, constraint_name)
WHERE table_name = 'produtos'
ORDER BY constraint_name;

-- 3. Ver qual tabela tem dados
SELECT 'categories' as tabela, COUNT(*) as total FROM categories
UNION ALL
SELECT 'categorias' as tabela, COUNT(*) as total FROM categorias;

-- 4. Verificar a categoria específica em ambas as tabelas
SELECT 'categories' as tabela, id, name FROM categories 
WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514'
UNION ALL
SELECT 'categorias' as tabela, id, nome FROM categorias 
WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';

-- 5. Ver qual é a coluna que a constraint usa (categories vs categorias)
SELECT
  constraint_name,
  table_name,
  column_name,
  foreign_table_name
FROM information_schema.referential_constraints
WHERE table_name = 'produtos' AND column_name LIKE '%categoria%';
