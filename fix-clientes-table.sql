-- 🚀 SOLUÇÃO RÁPIDA: CRIAR TABELA CLIENTES
-- Execute no Supabase SQL Editor

-- PASSO 1: Criar tabela clientes
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

-- PASSO 2: Desabilitar RLS (igual às categorias)
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- PASSO 3: Inserir cliente de teste
INSERT INTO public.clientes (nome, telefone, cpf_cnpj, email, tipo, observacoes) VALUES
('João Silva', '11999991234', '123.456.789-00', 'joao@email.com', 'Física', 'Cliente de teste');

-- PASSO 4: Verificar se funcionou
SELECT * FROM public.clientes;
