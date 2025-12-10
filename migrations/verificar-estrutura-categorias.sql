-- 🔍 VERIFICAR ESTRUTURA DE AMBAS AS TABELAS

-- 1. COLUNAS DA TABELA CATEGORIES (INGLÊS)
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'categories'
ORDER BY ordinal_position;

-- 2. COLUNAS DA TABELA CATEGORIAS (PORTUGUÊS)
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'categorias'
ORDER BY ordinal_position;

-- 3. QUANTOS DADOS EM CADA UMA
SELECT 'categories' as tabela, COUNT(*) as total FROM categories
UNION ALL
SELECT 'categorias' as tabela, COUNT(*) as total FROM categorias;

-- 4. ALGUNS EXEMPLOS
SELECT '==== CATEGORIES (primeiras 5) ====' as info;
SELECT * FROM categories LIMIT 5;

SELECT '==== CATEGORIAS (primeiras 5) ====' as info;
SELECT * FROM categorias LIMIT 5;

-- 5. QUAL TABELA TEM DADOS DO USUÁRIO
SELECT 'categories com empresa_id' as info, COUNT(*) as total
FROM categories
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Tentar categories sem filtro empresa_id
SELECT 'categories (todas)' as info, COUNT(*) as total FROM categories;
