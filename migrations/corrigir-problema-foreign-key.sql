-- 🔧 CORRIGIR PROBLEMA DE FOREIGN KEY - USAR TABELA CORRETA
-- O código TypeScript consulta 'categories' (inglês)
-- Mas a constraint de foreign key aponta para 'categorias' (português)

-- ⚠️ ANTES DE EXECUTAR: Rode o diagnosticar-tabelas-categorias.sql para ver qual tabela é usada

-- OPÇÃO 1: Se a constraint aponta para CATEGORIAS (português)
-- Precisamos copiar dados de categories para categorias e corrigir o código

-- 1. Verificar qual tabela tem dados
SELECT COUNT(*) as total_em_categories FROM categories;
SELECT COUNT(*) as total_em_categorias FROM categorias;

-- 2. Se categories tem dados e categorias não, copiar para categorias
INSERT INTO categorias (id, nome, descricao, empresa_id, criado_em, atualizado_em)
SELECT id, name as nome, description as descricao, empresa_id, created_at as criado_em, updated_at as atualizado_em
FROM categories
WHERE id NOT IN (SELECT id FROM categorias);

-- 3. Verificar se a categoria problemática agora existe em categorias
SELECT * FROM categorias WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';

-- ===================================================================
-- OPÇÃO 2: Se a constraint aponta para CATEGORIES (inglês)
-- Precisamos usar categories em vez de categorias

-- Ver qual é a constraint exata
SELECT 
  constraint_name,
  table_name,
  column_name,
  foreign_table_name,
  foreign_column_name
FROM information_schema.referential_constraints
WHERE table_name = 'produtos' AND column_name LIKE '%categoria%';

-- ===================================================================
-- SOLUÇÃO DEFINITIVA: Usar a tabela correta em useProducts.ts
-- Se usar 'categorias' (português): trocar .from('categories') por .from('categorias')
-- Se usar 'categories' (inglês): garantir que todos os dados estão em 'categories'
