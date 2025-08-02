-- 🚀 SOLUÇÃO COMPLETA: CRIAR TODAS AS TABELAS NECESSÁRIAS
-- Execute TUDO no Supabase SQL Editor (cole e execute de uma vez)

-- ===== PARTE 1: CORRIGIR CATEGORIAS =====

-- Verificar se tabela categories existe
SELECT 'Tabela categories existe:' as status, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') 
            THEN 'SIM' ELSE 'NÃO' END as resultado;

-- Criar tabela categories se não existir
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Desabilitar RLS em categories
ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;

-- Remover todas as políticas de categories
DROP POLICY IF EXISTS "Todos podem visualizar categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir leitura de categorias para usuários autenticados" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem criar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem editar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem deletar categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir leitura de categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir inserção de categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir edição de categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir exclusão de categorias" ON public.categories;

-- ===== PARTE 2: CRIAR TABELA CLIENTES =====

-- Verificar se tabela clientes existe
SELECT 'Tabela clientes existe:' as status, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'clientes') 
            THEN 'SIM' ELSE 'NÃO' END as resultado;

-- Criar tabela clientes
CREATE TABLE IF NOT EXISTS public.clientes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nome TEXT NOT NULL,
    telefone TEXT NOT NULL,
    cpf_cnpj TEXT,
    email TEXT,
    endereco TEXT,
    tipo TEXT CHECK (tipo IN ('Física', 'Jurídica')) DEFAULT 'Física',
    observacoes TEXT,
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Desabilitar RLS em clientes (igual às categories)
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- Criar índices para clientes
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes(nome);
CREATE INDEX IF NOT EXISTS idx_clientes_telefone ON public.clientes(telefone);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_ativo ON public.clientes(ativo);

-- ===== PARTE 3: INSERIR DADOS DE TESTE =====

-- Inserir categorias de teste (só se não existirem)
INSERT INTO public.categories (name, description) 
SELECT 'Eletrônicos', 'Produtos eletrônicos e tecnologia'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Eletrônicos');

INSERT INTO public.categories (name, description) 
SELECT 'Informática', 'Computadores e periféricos'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Informática');

INSERT INTO public.categories (name, description) 
SELECT 'Casa e Jardim', 'Produtos para casa'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Casa e Jardim');

-- Inserir clientes de teste (só se não existirem)
INSERT INTO public.clientes (nome, telefone, cpf_cnpj, email, endereco, tipo, observacoes) 
SELECT 'João Silva Santos', '11999991234', '123.456.789-00', 'joao@email.com', 'Rua das Flores, 123 - São Paulo/SP', 'Física', 'Cliente preferencial'
WHERE NOT EXISTS (SELECT 1 FROM public.clientes WHERE nome = 'João Silva Santos');

INSERT INTO public.clientes (nome, telefone, cpf_cnpj, email, endereco, tipo, observacoes) 
SELECT 'Maria Oliveira', '11888885678', '987.654.321-00', 'maria@email.com', 'Av. Paulista, 456 - São Paulo/SP', 'Física', 'Compra frequente'
WHERE NOT EXISTS (SELECT 1 FROM public.clientes WHERE nome = 'Maria Oliveira');

INSERT INTO public.clientes (nome, telefone, cpf_cnpj, email, endereco, tipo, observacoes) 
SELECT 'Empresa XYZ Ltda', '11777779999', '12.345.678/0001-90', 'contato@empresaxyz.com', 'Rua Comercial, 789 - São Paulo/SP', 'Jurídica', 'Cliente corporativo'
WHERE NOT EXISTS (SELECT 1 FROM public.clientes WHERE nome = 'Empresa XYZ Ltda');

-- ===== PARTE 4: VERIFICAR SE TUDO FUNCIONOU =====

-- Verificar categories
SELECT 'CATEGORIAS:' as tabela, COUNT(*) as total FROM public.categories;
SELECT * FROM public.categories LIMIT 3;

-- Verificar clientes  
SELECT 'CLIENTES:' as tabela, COUNT(*) as total FROM public.clientes;
SELECT * FROM public.clientes LIMIT 3;

-- Mostrar estrutura das tabelas
SELECT 'ESTRUTURA CATEGORIES:' as info;
SELECT column_name, data_type, is_nullable FROM information_schema.columns 
WHERE table_name = 'categories' ORDER BY ordinal_position;

SELECT 'ESTRUTURA CLIENTES:' as info;
SELECT column_name, data_type, is_nullable FROM information_schema.columns 
WHERE table_name = 'clientes' ORDER BY ordinal_position;
