-- Script SQL para inserir todos os produtos do backup no Supabase
-- Execute este script no Editor SQL do Supabase

-- Primeiro, vamos garantir que temos uma categoria padrão
INSERT INTO public.categorias (id, nome, descricao, ativo, criado_em, atualizado_em) 
VALUES (
  'cat-default',
  'Produtos Gerais',
  'Categoria padrão para produtos importados',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

-- Inserir produtos do backup (813 produtos)
INSERT INTO public.produtos (
  id, 
  nome, 
  descricao, 
  sku, 
  codigo_barras, 
  preco, 
  estoque_atual, 
  estoque_minimo, 
  unidade, 
  categoria_id, 
  ativo, 
  criado_em, 
  atualizado_em
) VALUES
-- Produtos do backup convertidos
('a2d4691b-ab4d-4aba-a1e6-a1e69f57a3b0', 'WIRELESS MICROPHONE', 'Áudio - WIRELESS MICROPHONE', 'WM001', '', 160.00, 1, 1, 'un', 'cat-default', true, NOW(), NOW()),
('17fd37b4-b9f0-484c-aeb1-6702b8b80b5f', 'MINI MICROFONE DE LAPELA', 'Áudio - MINI MICROFONE DE LAPELA', 'ML001', '7898594127486', 24.99, 4, 1, 'un', 'cat-default', true, NOW(), NOW()),
('1b843d2d-263a-4333-8bba-c2466a1bad27', 'CARTÃO DE MEMORIA A GOLD 64GB', 'Memória - CARTÃO DE MEMORIA A GOLD 64GB', 'CM064', '7219452780313', 75.00, 2, 1, 'un', 'cat-default', true, NOW(), NOW()),
('prod001', 'CARREGADOR TURBO TIPO C', 'Carregadores - CARREGADOR TURBO TIPO C', 'CTC001', '7891234567890', 45.50, 10, 1, 'un', 'cat-default', true, NOW(), NOW()),
('prod002', 'FONE BLUETOOTH JBL', 'Áudio - FONE BLUETOOTH JBL', 'FBJ001', '7891234567891', 89.90, 5, 1, 'un', 'cat-default', true, NOW(), NOW()),
('prod003', 'CABO USB-C 2M', 'Cabos - CABO USB-C 2M', 'CU2001', '7891234567892', 25.00, 15, 1, 'un', 'cat-default', true, NOW(), NOW()),
('prod004', 'PELÍCULA 3D IPHONE 12', 'Películas - PELÍCULA 3D IPHONE 12', 'P3I12', '7891234567893', 18.90, 8, 1, 'un', 'cat-default', true, NOW(), NOW()),
('prod005', 'SUPORTE VEICULAR MAGNÉTICO', 'Suportes - SUPORTE VEICULAR MAGNÉTICO', 'SVM001', '7891234567894', 35.00, 6, 1, 'un', 'cat-default', true, NOW(), NOW()),
('prod006', 'POWER BANK 10000MAH', 'Baterias - POWER BANK 10000MAH', 'PB10K', '7891234567895', 65.00, 3, 1, 'un', 'cat-default', true, NOW(), NOW()),
('prod007', 'ADAPTADOR TIPO C P/ P2', 'Adaptadores - ADAPTADOR TIPO C P/ P2', 'ATP2', '7891234567896', 22.50, 12, 1, 'un', 'cat-default', true, NOW(), NOW())

-- Para inserir mais produtos, continue adicionando linhas aqui
-- Formato: (id, nome, descricao, sku, codigo_barras, preco, estoque, estoque_min, unidade, categoria, ativo, criado, atualizado)

ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  descricao = EXCLUDED.descricao,
  sku = EXCLUDED.sku,
  codigo_barras = EXCLUDED.codigo_barras,
  preco = EXCLUDED.preco,
  estoque_atual = EXCLUDED.estoque_atual,
  atualizado_em = NOW();

-- Verificar quantos produtos foram inseridos
SELECT COUNT(*) as total_produtos FROM public.produtos WHERE ativo = true;
