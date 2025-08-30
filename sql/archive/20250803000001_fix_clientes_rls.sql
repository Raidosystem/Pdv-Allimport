-- Migration: Fix clientes table RLS policies
-- Date: 2025-08-03
-- Description: Create clientes table if not exists and fix RLS policies

-- Create clientes table if not exists (Portuguese version of customers)
CREATE TABLE IF NOT EXISTS public.clientes (
  id uuid default gen_random_uuid() primary key,
  nome text not null,
  telefone text,
  cpf_cnpj text,
  email text,
  endereco text,
  -- Detailed address fields
  tipo_logradouro text, -- Ex: Rua, Avenida, Travessa, etc.
  logradouro text,      -- Nome da rua/avenida
  numero text,          -- Número do imóvel
  complemento text,     -- Apartamento, bloco, etc.
  bairro text,          -- Bairro/distrito
  cidade text,          -- Cidade
  estado text,          -- Estado (UF)
  cep text,             -- CEP
  ponto_referencia text, -- Ponto de referência
  tipo text not null default 'Física' check (tipo in ('Física', 'Jurídica')),
  observacoes text,
  ativo boolean default true,
  criado_em timestamp with time zone default now(),
  atualizado_em timestamp with time zone default now()
);

-- Enable RLS on clientes table
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Authenticated users can manage clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;

-- Create comprehensive RLS policies for clientes table
-- Allow authenticated users to view all clientes
CREATE POLICY "Users can view all clientes" 
ON public.clientes FOR SELECT 
USING (auth.role() = 'authenticated');

-- Allow authenticated users to insert new clientes
CREATE POLICY "Users can insert clientes" 
ON public.clientes FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Allow authenticated users to update clientes
CREATE POLICY "Users can update clientes" 
ON public.clientes FOR UPDATE 
USING (auth.role() = 'authenticated');

-- Allow authenticated users to delete clientes
CREATE POLICY "Users can delete clientes" 
ON public.clientes FOR DELETE 
USING (auth.role() = 'authenticated');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes(nome);
CREATE INDEX IF NOT EXISTS idx_clientes_telefone ON public.clientes(telefone);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON public.clientes(email);
CREATE INDEX IF NOT EXISTS idx_clientes_ativo ON public.clientes(ativo);
CREATE INDEX IF NOT EXISTS idx_clientes_tipo ON public.clientes(tipo);
CREATE INDEX IF NOT EXISTS idx_clientes_cidade ON public.clientes(cidade);
CREATE INDEX IF NOT EXISTS idx_clientes_estado ON public.clientes(estado);
CREATE INDEX IF NOT EXISTS idx_clientes_cep ON public.clientes(cep);

-- Create trigger for automatic endereco update
CREATE OR REPLACE FUNCTION update_endereco_completo()
RETURNS TRIGGER AS $$
BEGIN
  -- Only update endereco if any detailed fields are provided
  IF NEW.tipo_logradouro IS NOT NULL OR NEW.logradouro IS NOT NULL OR NEW.numero IS NOT NULL 
     OR NEW.complemento IS NOT NULL OR NEW.bairro IS NOT NULL OR NEW.cidade IS NOT NULL 
     OR NEW.estado IS NOT NULL OR NEW.cep IS NOT NULL THEN
    
    NEW.endereco := TRIM(CONCAT_WS(', ', 
      -- Tipo de logradouro + nome do logradouro
      CASE 
        WHEN NEW.tipo_logradouro IS NOT NULL AND NEW.logradouro IS NOT NULL 
        THEN CONCAT(NEW.tipo_logradouro, ' ', NEW.logradouro)
        WHEN NEW.logradouro IS NOT NULL 
        THEN NEW.logradouro
        ELSE NULL 
      END,
      -- Número
      CASE WHEN NEW.numero IS NOT NULL AND NEW.numero != '' THEN NEW.numero ELSE NULL END,
      -- Complemento
      CASE WHEN NEW.complemento IS NOT NULL AND NEW.complemento != '' THEN NEW.complemento ELSE NULL END,
      -- Bairro
      CASE WHEN NEW.bairro IS NOT NULL AND NEW.bairro != '' THEN NEW.bairro ELSE NULL END,
      -- Cidade + Estado
      CASE 
        WHEN NEW.cidade IS NOT NULL AND NEW.estado IS NOT NULL 
        THEN CONCAT(NEW.cidade, ' - ', NEW.estado)
        WHEN NEW.cidade IS NOT NULL 
        THEN NEW.cidade
        ELSE NULL 
      END,
      -- CEP
      CASE WHEN NEW.cep IS NOT NULL AND NEW.cep != '' THEN CONCAT('CEP: ', NEW.cep) ELSE NULL END
    ));
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for endereco update
DROP TRIGGER IF EXISTS trigger_update_endereco_completo ON public.clientes;
CREATE TRIGGER trigger_update_endereco_completo
  BEFORE INSERT OR UPDATE ON public.clientes
  FOR EACH ROW
  EXECUTE FUNCTION update_endereco_completo();

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION handle_updated_at_clientes()
RETURNS TRIGGER AS $$
BEGIN
  NEW.atualizado_em = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS handle_updated_at_clientes ON public.clientes;
CREATE TRIGGER handle_updated_at_clientes
  BEFORE UPDATE ON public.clientes
  FOR EACH ROW EXECUTE FUNCTION handle_updated_at_clientes();

-- Add comments
COMMENT ON TABLE public.clientes IS 'Tabela de clientes do sistema PDV';
COMMENT ON COLUMN public.clientes.tipo_logradouro IS 'Tipo de logradouro (Rua, Avenida, Travessa, Alameda, etc.)';
COMMENT ON COLUMN public.clientes.logradouro IS 'Nome da rua, avenida ou logradouro';
COMMENT ON COLUMN public.clientes.numero IS 'Número do imóvel/estabelecimento';
COMMENT ON COLUMN public.clientes.complemento IS 'Complemento do endereço (apartamento, bloco, etc.)';
COMMENT ON COLUMN public.clientes.bairro IS 'Bairro ou distrito';
COMMENT ON COLUMN public.clientes.cidade IS 'Cidade';
COMMENT ON COLUMN public.clientes.estado IS 'Estado (UF)';
COMMENT ON COLUMN public.clientes.cep IS 'Código de Endereçamento Postal';
COMMENT ON COLUMN public.clientes.ponto_referencia IS 'Ponto de referência para localização';
