-- 🎯 SOLUÇÃO: USAR AMBAS AS TABELAS E SINCRONIZÁ-LAS

-- Passo 1: Copiar dados de categories para categorias (se faltarem)
INSERT INTO categorias (id, nome, descricao, empresa_id, criado_em, atualizado_em)
SELECT 
  c.id,
  c.name as nome,
  c.description as descricao,
  c.empresa_id,
  c.created_at as criado_em,
  c.updated_at as atualizado_em
FROM categories c
WHERE c.id NOT IN (SELECT id FROM categorias)
  AND c.empresa_id IS NOT NULL;

-- Passo 2: Copiar dados de categorias para categories (se faltarem)
INSERT INTO categories (id, name, description, empresa_id, created_at, updated_at)
SELECT 
  c.id,
  c.nome as name,
  c.descricao as description,
  c.empresa_id,
  c.criado_em as created_at,
  c.atualizado_em as updated_at
FROM categorias c
WHERE c.id NOT IN (SELECT id FROM categories)
  AND c.empresa_id IS NOT NULL;

-- Passo 3: Verificar o resultado
SELECT '=== APÓS SINCRONIZAÇÃO ===' as info;
SELECT 'categories' as tabela, COUNT(*) as total FROM categories
UNION ALL
SELECT 'categorias' as tabela, COUNT(*) as total FROM categorias;

-- Passo 4: Verificar qual tabela a constraint usa
SELECT
  constraint_name,
  foreign_table_name
FROM information_schema.referential_constraints
WHERE table_name = 'produtos' AND column_name LIKE '%categoria%';

-- Passo 5: Ver categorias do usuário APÓS sincronização
SELECT id, name as nome, empresa_id 
FROM categories 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY name
LIMIT 10;
