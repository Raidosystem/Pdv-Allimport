-- 🎯 SINCRONIZAÇÃO INTELIGENTE - ADAPTA-SE ÀS COLUNAS REAIS

-- ⚠️ OPÇÃO 1: Se CATEGORIAS não tiver empresa_id
-- Copiar APENAS colunas que existem em ambas

INSERT INTO categorias (id, nome, descricao)
SELECT 
  c.id,
  c.name as nome,
  c.description as descricao
FROM categories c
WHERE c.id NOT IN (SELECT id FROM categorias);

-- ⚠️ OPÇÃO 2: Se CATEGORIES não tiver todos os dados
-- Copiar de categorias para categories (adaptar colunas)

INSERT INTO categories (id, name, description, empresa_id, created_at, updated_at)
SELECT 
  c.id,
  c.nome as name,
  c.descricao as description,
  NULL as empresa_id,  -- Se categorias não tiver empresa_id
  c.criado_em as created_at,
  c.atualizado_em as updated_at
FROM categorias c
WHERE c.id NOT IN (SELECT id FROM categories);

-- ✅ VERIFICAR RESULTADO
SELECT '=== APÓS SINCRONIZAÇÃO ===' as info;
SELECT 'categories' as tabela, COUNT(*) as total FROM categories
UNION ALL
SELECT 'categorias' as tabela, COUNT(*) as total FROM categorias;

-- ✅ VER DADOS NO DROPDOWN (Deve aparecer categorias do usuário)
SELECT id, name, empresa_id 
FROM categories 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY name;
