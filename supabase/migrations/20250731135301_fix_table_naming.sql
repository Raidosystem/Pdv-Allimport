-- Migration: Fix table naming inconsistency
-- Date: 2025-08-02
-- Description: Rename customers to clientes for consistency

-- Drop the customers table if it exists (since we'll use clientes)
DROP TABLE IF EXISTS public.customers CASCADE;

-- Create the clientes table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.clientes (
  id uuid default gen_random_uuid() primary key,
  nome text not null,
  telefone text,
  cpf_cnpj text,
  email text,
  endereco text,
  tipo text not null default 'Física' check (tipo in ('Física', 'Jurídica')),
  observacoes text,
  ativo boolean default true,
  criado_em timestamp with time zone default now(),
  atualizado_em timestamp with time zone default now()
);

-- Enable RLS on clientes table
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for clientes table
CREATE POLICY "Users can view all clientes" 
ON public.clientes FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert clientes" 
ON public.clientes FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update clientes" 
ON public.clientes FOR UPDATE 
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can delete clientes" 
ON public.clientes FOR DELETE 
USING (auth.role() = 'authenticated');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes(nome);
CREATE INDEX IF NOT EXISTS idx_clientes_telefone ON public.clientes(telefone);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON public.clientes(email);
CREATE INDEX IF NOT EXISTS idx_clientes_tipo ON public.clientes(tipo);
CREATE INDEX IF NOT EXISTS idx_clientes_ativo ON public.clientes(ativo);

-- Create trigger for updating the updated_at column
CREATE OR REPLACE FUNCTION public.handle_updated_at_clientes()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_updated_at_clientes
    BEFORE UPDATE ON public.clientes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at_clientes();
