-- Script para criar tabelas faltantes no Supabase
-- Execute este SQL no Supabase Dashboard > SQL Editor

-- =============================================
-- CRIAR TABELA CATEGORIAS
-- =============================================
CREATE TABLE IF NOT EXISTS public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CRIAR TABELA PRODUTOS
-- =============================================
CREATE TABLE IF NOT EXISTS public.produtos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    categoria_id UUID REFERENCES categorias(id),
    estoque INTEGER DEFAULT 0,
    codigo_barras VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CRIAR TABELA VENDAS
-- =============================================
CREATE TABLE IF NOT EXISTS public.vendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES clientes(id),
    total DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'finalizada',
    metodo_pagamento VARCHAR(50),
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CRIAR TABELA ITENS_VENDA
-- =============================================
CREATE TABLE IF NOT EXISTS public.itens_venda (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venda_id UUID REFERENCES vendas(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES produtos(id),
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- INSERIR DADOS INICIAIS
-- =============================================

-- Categorias padrão
INSERT INTO categorias (nome, descricao) VALUES 
('Eletrônicos', 'Produtos eletrônicos diversos'),
('Informática', 'Equipamentos de informática'),
('Celulares', 'Smartphones e acessórios'),
('Games', 'Consoles e jogos'),
('Casa', 'Produtos para casa'),
('Acessórios', 'Acessórios diversos')
ON CONFLICT DO NOTHING;

-- Produtos de exemplo (vamos inserir usando UUIDs das categorias criadas)
DO $$
DECLARE
    cat_eletronicos UUID;
    cat_informatica UUID;
    cat_celulares UUID;
    cat_games UUID;
    cat_acessorios UUID;
BEGIN
    -- Buscar IDs das categorias
    SELECT id INTO cat_eletronicos FROM categorias WHERE nome = 'Eletrônicos';
    SELECT id INTO cat_informatica FROM categorias WHERE nome = 'Informática';
    SELECT id INTO cat_celulares FROM categorias WHERE nome = 'Celulares';
    SELECT id INTO cat_games FROM categorias WHERE nome = 'Games';
    SELECT id INTO cat_acessorios FROM categorias WHERE nome = 'Acessórios';
    
    -- Inserir produtos com as categorias corretas
    INSERT INTO produtos (nome, descricao, preco, categoria_id, estoque, codigo_barras) VALUES 
    ('Smartphone Samsung Galaxy', 'Smartphone Android premium', 1299.99, cat_celulares, 10, '7891234567890'),
    ('Notebook Dell Inspiron', 'Notebook para uso geral', 2499.99, cat_informatica, 5, '7891234567891'),
    ('Mouse Gamer RGB', 'Mouse gamer com iluminação RGB', 89.99, cat_informatica, 25, '7891234567892'),
    ('Carregador Universal', 'Carregador para múltiplos dispositivos', 49.99, cat_acessorios, 30, '7891234567893'),
    ('Console PlayStation 5', 'Console de videogame última geração', 4999.99, cat_games, 2, '7891234567894')
    ON CONFLICT DO NOTHING;
END $$;

-- =============================================
-- CONFIGURAR PERMISSÕES (DADOS COMPARTILHADOS)
-- =============================================

-- Desabilitar RLS para compartilhar dados entre todas as contas
ALTER TABLE public.categorias DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_venda DISABLE ROW LEVEL SECURITY;

-- Conceder permissões para usuários autenticados e anônimos
GRANT ALL ON public.categorias TO authenticated, anon;
GRANT ALL ON public.produtos TO authenticated, anon;
GRANT ALL ON public.vendas TO authenticated, anon;
GRANT ALL ON public.itens_venda TO authenticated, anon;

-- Nota: Com UUID não precisamos de permissões em sequences

-- =============================================
-- SCRIPT CONCLUÍDO
-- =============================================
SELECT 'Tabelas criadas com sucesso! Dados serão compartilhados entre todas as contas.' as resultado;
