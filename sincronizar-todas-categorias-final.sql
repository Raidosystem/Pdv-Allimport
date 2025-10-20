-- Sincronizar TODAS as categorias de 'categories' para 'categorias'
-- Script final - sincronização em lote

-- 1. Contar categorias ANTES
SELECT COUNT(*) as "categorias_antes" FROM categorias;

-- 2. Sincronizar todas as categorias que não existem
INSERT INTO categorias (id, nome, descricao)
SELECT id, name, description
FROM categories
WHERE NOT EXISTS (
  SELECT 1 FROM categorias WHERE categorias.id = categories.id
);

-- 3. Contar categorias DEPOIS
SELECT COUNT(*) as "categorias_depois" FROM categorias;

-- 4. Verificar se todas as 127+ categorias do user foram sincronizadas
SELECT COUNT(*) as "total_sincronizadas"
FROM categorias c
WHERE c.id IN (SELECT id FROM categories WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1');
