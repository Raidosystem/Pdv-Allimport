-- Execute este SQL no painel do Supabase para corrigir o erro de RLS
-- Dashboard > SQL Editor > New Query > Cole este código

-- Criar tabela clientes se não existir
CREATE TABLE IF NOT EXISTS public.clientes (
  id uuid default gen_random_uuid() primary key,
  nome text not null,
  telefone text,
  cpf_cnpj text,
  email text,
  endereco text,
  tipo_logradouro text,
  logradouro text,
  numero text,
  complemento text,
  bairro text,
  cidade text,
  estado text,
  cep text,
  ponto_referencia text,
  tipo text not null default 'Física' check (tipo in ('Física', 'Jurídica')),
  observacoes text,
  ativo boolean default true,
  criado_em timestamp with time zone default now(),
  atualizado_em timestamp with time zone default now()
);

-- Habilitar RLS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes
DROP POLICY IF EXISTS "Authenticated users can manage clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;

-- Criar políticas RLS permissivas para usuários autenticados
CREATE POLICY "Users can view all clientes" 
ON public.clientes FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert clientes" 
ON public.clientes FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update clientes" 
ON public.clientes FOR UPDATE 
USING (auth.role() = 'authenticated');

CREATE POLICY "Users can delete clientes" 
ON public.clientes FOR DELETE 
USING (auth.role() = 'authenticated');

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes(nome);
CREATE INDEX IF NOT EXISTS idx_clientes_ativo ON public.clientes(ativo);
CREATE INDEX IF NOT EXISTS idx_clientes_tipo ON public.clientes(tipo);
