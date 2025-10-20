-- 🔍 INVESTIGAÇÃO COMPLETA - QUAL TABELA USAR?

-- 1. VER QUANTOS DADOS EM CADA TABELA
SELECT 
  'categories' as tabela,
  COUNT(*) as total,
  COUNT(CASE WHEN empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as do_usuario
FROM categories
UNION ALL
SELECT 
  'categorias' as tabela,
  COUNT(*) as total,
  COUNT(CASE WHEN empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as do_usuario
FROM categorias;

-- 2. VER QUAL CONSTRAINT EXISTE NA TABELA PRODUTOS
SELECT
  constraint_name,
  table_name,
  column_name,
  foreign_table_name,
  foreign_column_name
FROM information_schema.referential_constraints
WHERE table_name = 'produtos'
ORDER BY constraint_name;

-- 3. LISTAR COLUNAS DE CADA TABELA
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name IN ('categories', 'categorias')
ORDER BY table_name, ordinal_position;

-- 4. VERIFICAR CATEGORIA ESPECÍFICA (em ambas)
SELECT 'categories' as tabela, id, name as nome, empresa_id FROM categories 
WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514'
UNION ALL
SELECT 'categorias' as tabela, id, nome, empresa_id FROM categorias 
WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';

-- 5. VER ALGUNS EXEMPLOS DE CADA TABELA
SELECT '=== CATEGORIES (INGLÊS) ===' as info;
SELECT id, name, empresa_id FROM categories WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' LIMIT 3;

SELECT '=== CATEGORIAS (PORTUGUÊS) ===' as info;
SELECT id, nome, empresa_id FROM categorias WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' LIMIT 3;
