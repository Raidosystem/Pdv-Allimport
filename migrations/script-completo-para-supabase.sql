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

-- ===== PARTE 4: CRIAR TABELAS DO MÓDULO CAIXA =====

-- Verificar se tabela caixa existe
SELECT 'Tabela caixa existe:' as status, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa') 
            THEN 'SIM' ELSE 'NÃO' END as resultado;

-- Criar tabela caixa
CREATE TABLE IF NOT EXISTS public.caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES auth.users(id),
    valor_inicial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    valor_final DECIMAL(10,2) DEFAULT NULL,
    data_abertura TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    data_fechamento TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    status TEXT CHECK (status IN ('aberto', 'fechado')) DEFAULT 'aberto',
    diferenca DECIMAL(10,2) DEFAULT NULL,
    observacoes TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Verificar se tabela movimentacoes_caixa existe
SELECT 'Tabela movimentacoes_caixa existe:' as status, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa') 
            THEN 'SIM' ELSE 'NÃO' END as resultado;

-- Criar tabela movimentacoes_caixa
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caixa_id UUID NOT NULL REFERENCES public.caixa(id) ON DELETE CASCADE,
    tipo TEXT CHECK (tipo IN ('entrada', 'saida')) NOT NULL,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    usuario_id UUID NOT NULL REFERENCES auth.users(id),
    venda_id UUID DEFAULT NULL,
    data TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Desabilitar RLS em ambas as tabelas do caixa
ALTER TABLE public.caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- Criar índices para caixa
CREATE INDEX IF NOT EXISTS idx_caixa_usuario ON public.caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_caixa_usuario_status ON public.caixa(usuario_id, status);

-- Criar índices para movimentacoes_caixa
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_tipo ON public.movimentacoes_caixa(tipo);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_usuario ON public.movimentacoes_caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON public.movimentacoes_caixa(data);

-- Criar função para calcular saldo do caixa
CREATE OR REPLACE FUNCTION calcular_saldo_caixa(caixa_uuid UUID)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
    valor_inicial DECIMAL(10,2);
    total_entradas DECIMAL(10,2);
    total_saidas DECIMAL(10,2);
    saldo_atual DECIMAL(10,2);
BEGIN
    -- Buscar valor inicial
    SELECT c.valor_inicial INTO valor_inicial
    FROM public.caixa c
    WHERE c.id = caixa_uuid;
    
    -- Se não encontrar o caixa, retorna 0
    IF valor_inicial IS NULL THEN
        RETURN 0.00;
    END IF;
    
    -- Calcular total de entradas
    SELECT COALESCE(SUM(valor), 0.00) INTO total_entradas
    FROM public.movimentacoes_caixa
    WHERE caixa_id = caixa_uuid AND tipo = 'entrada';
    
    -- Calcular total de saídas
    SELECT COALESCE(SUM(valor), 0.00) INTO total_saidas
    FROM public.movimentacoes_caixa
    WHERE caixa_id = caixa_uuid AND tipo = 'saida';
    
    -- Calcular saldo atual
    saldo_atual := valor_inicial + total_entradas - total_saidas;
    
    RETURN saldo_atual;
END;
$$;

-- ===== PARTE 5: VERIFICAR SE TUDO FUNCIONOU =====

-- Verificar categories
SELECT 'CATEGORIAS:' as tabela, COUNT(*) as total FROM public.categories;
SELECT * FROM public.categories LIMIT 3;

-- Verificar clientes  
SELECT 'CLIENTES:' as tabela, COUNT(*) as total FROM public.clientes;
SELECT * FROM public.clientes LIMIT 3;

-- Verificar caixa
SELECT 'TABELA CAIXA:' as tabela, COUNT(*) as total FROM public.caixa;

-- Verificar movimentações do caixa
SELECT 'TABELA MOVIMENTAÇÕES CAIXA:' as tabela, COUNT(*) as total FROM public.movimentacoes_caixa;

-- Mostrar estrutura das tabelas
SELECT 'ESTRUTURA CATEGORIES:' as info;
SELECT column_name, data_type, is_nullable FROM information_schema.columns 
WHERE table_name = 'categories' ORDER BY ordinal_position;

SELECT 'ESTRUTURA CLIENTES:' as info;
SELECT column_name, data_type, is_nullable FROM information_schema.columns 
WHERE table_name = 'clientes' ORDER BY ordinal_position;

SELECT 'ESTRUTURA CAIXA:' as info;
SELECT column_name, data_type, is_nullable FROM information_schema.columns 
WHERE table_name = 'caixa' ORDER BY ordinal_position;

SELECT 'ESTRUTURA MOVIMENTAÇÕES CAIXA:' as info;
SELECT column_name, data_type, is_nullable FROM information_schema.columns 
WHERE table_name = 'movimentacoes_caixa' ORDER BY ordinal_position;

-- Resultado final
SELECT '✅ TODAS AS TABELAS CRIADAS COM SUCESSO!' as resultado;
