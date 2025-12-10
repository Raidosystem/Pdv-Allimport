-- 🔧 SOLUÇÃO SIMPLES E SEGURA

-- PASSO 1: Ver qual tabela tem dados
SELECT COUNT(*) as total_categories FROM categories;
SELECT COUNT(*) as total_categorias FROM categorias;

-- PASSO 2: Copiar APENAS colunas comuns (sem empresa_id em categorias)
INSERT INTO categories (id, name, description)
SELECT id, nome, descricao
FROM categorias
WHERE id NOT IN (SELECT id FROM categories);

-- PASSO 3: Adicionar empresa_id se a coluna existir
-- Se der erro "column empresa_id does not exist", ignore - significa que categorias não tem essa coluna
UPDATE categories c
SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE empresa_id IS NULL
  AND c.id IN (SELECT id FROM categorias);

-- PASSO 4: Verificar quantas categorias temos para este usuário
SELECT COUNT(*) as categorias_do_usuario FROM categories 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- PASSO 5: Ver algumas categorias
SELECT id, name, empresa_id FROM categories 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY name
LIMIT 10;

-- PASSO 6: Verificar se a categoria do teste existe agora
SELECT id, name FROM categories 
WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';
