-- Sincronizar TODAS as categorias de 'categories' para 'categorias'
-- Sem timestamps que não existem na tabela destino

BEGIN;

-- 1. Contar quantas categorias faltam sincronizar
SELECT 'Categorias em categories' as verificacao, COUNT(*) 
FROM categories;

SELECT 'Categorias em categorias' as verificacao, COUNT(*) 
FROM categorias;

-- 2. Sincronizar todas as categorias que não existem
INSERT INTO categorias (id, nome, descricao)
SELECT id, name, description
FROM categories
WHERE NOT EXISTS (
  SELECT 1 FROM categorias WHERE categorias.id = categories.id
);

-- 3. Verificar resultado
SELECT 'Categorias sincronizadas' as resultado, COUNT(*) 
FROM categorias;

-- 4. Listar as que foram sincronizadas
SELECT 'Categorias recém sincronizadas:' as info;
SELECT id, nome FROM categorias 
WHERE id NOT IN (
  SELECT id FROM categories_original
)
LIMIT 10;

COMMIT;
