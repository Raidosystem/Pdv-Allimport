-- ================================================
-- SUPABASE RLS FIX - PDV ALLIMPORT
-- Execute este script no SQL Editor do Supabase
-- ================================================

-- 1. DESABILITAR RLS DAS TABELAS PRINCIPAIS
-- (Para permitir acesso durante desenvolvimento)

ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE categorias DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE itens_venda DISABLE ROW LEVEL SECURITY;
ALTER TABLE caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- 2. VERIFICAR SE AS TABELAS EXISTEM E TÊM DADOS
SELECT 'produtos' as tabela, COUNT(*) as total FROM produtos
UNION ALL
SELECT 'clientes' as tabela, COUNT(*) as total FROM clientes
UNION ALL
SELECT 'categorias' as tabela, COUNT(*) as total FROM categorias;

-- 3. SE NÃO HOUVER PRODUTOS, INSERIR ALGUNS DE TESTE
INSERT INTO produtos (nome, descricao, preco, estoque, codigo_barras, categoria_id)
SELECT 
  'Produto Teste ' || generate_series,
  'Descrição do produto teste ' || generate_series,
  (random() * 100 + 10)::numeric(10,2),
  (random() * 100 + 10)::integer,
  '123456789' || generate_series,
  NULL
FROM generate_series(1, 5)
WHERE NOT EXISTS (SELECT 1 FROM produtos LIMIT 1);

-- 4. SE NÃO HOUVER CATEGORIAS, INSERIR ALGUMAS DE TESTE
INSERT INTO categorias (nome, descricao)
SELECT 
  categoria_nome,
  'Descrição da categoria ' || categoria_nome
FROM (VALUES 
  ('Eletrônicos'),
  ('Roupas'),
  ('Casa e Jardim'),
  ('Esportes'),
  ('Livros')
) AS cat(categoria_nome)
WHERE NOT EXISTS (SELECT 1 FROM categorias LIMIT 1);

-- 5. VERIFICAR NOVAMENTE OS DADOS
SELECT 'produtos' as tabela, COUNT(*) as total FROM produtos
UNION ALL
SELECT 'clientes' as tabela, COUNT(*) as total FROM clientes
UNION ALL
SELECT 'categorias' as tabela, COUNT(*) as total FROM categorias;

-- 6. EXIBIR ALGUNS PRODUTOS PARA CONFIRMAÇÃO
SELECT id, nome, preco, estoque, codigo_barras 
FROM produtos 
LIMIT 5;

-- ================================================
-- SUCESSO! 🎉
-- Agora o PDV deve conseguir acessar os produtos!
-- ================================================
