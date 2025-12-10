-- 🏢 CRIAÇÃO DA TABELA CLIENTES PARA PDV IMPORT
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

-- PASSO 2: Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes(nome);
CREATE INDEX IF NOT EXISTS idx_clientes_telefone ON public.clientes(telefone);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_ativo ON public.clientes(ativo);

-- PASSO 3: Desabilitar RLS (para desenvolvimento)
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- PASSO 4: Inserir alguns clientes de exemplo
INSERT INTO public.clientes (nome, telefone, cpf_cnpj, email, endereco, tipo, observacoes) VALUES
('João Silva Santos', '(11) 99999-1234', '123.456.789-00', 'joao@email.com', 'Rua das Flores, 123 - São Paulo/SP', 'Física', 'Cliente preferencial'),
('Maria Oliveira', '(11) 88888-5678', '987.654.321-00', 'maria@email.com', 'Av. Paulista, 456 - São Paulo/SP', 'Física', 'Compra frequente'),
('Empresa XYZ Ltda', '(11) 77777-9999', '12.345.678/0001-90', 'contato@empresaxyz.com', 'Rua Comercial, 789 - São Paulo/SP', 'Jurídica', 'Cliente corporativo'),
('Ana Costa', '(11) 66666-1111', '111.222.333-44', 'ana@email.com', 'Rua das Palmeiras, 321 - São Paulo/SP', 'Física', ''),
('Tech Solutions LTDA', '(11) 55555-2222', '98.765.432/0001-10', 'vendas@techsolutions.com', 'Centro Empresarial, 101 - São Paulo/SP', 'Jurídica', 'Parceiro tecnológico');

-- PASSO 5: Verificar se funcionou
SELECT * FROM public.clientes ORDER BY criado_em DESC;
