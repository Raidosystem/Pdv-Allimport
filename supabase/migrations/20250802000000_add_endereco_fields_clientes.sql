-- Migration: Add endereco fields to clientes table
-- Date: 2025-08-02
-- Description: Add detailed address fields (rua, numero, bairro, cidade, cep) to clientes table

-- Add new specific address columns to clientes table
ALTER TABLE public.clientes 
ADD COLUMN IF NOT EXISTS tipo_logradouro text, -- Ex: Rua, Avenida, Travessa, etc.
ADD COLUMN IF NOT EXISTS logradouro text,      -- Nome da rua/avenida
ADD COLUMN IF NOT EXISTS numero text,          -- Número do imóvel
ADD COLUMN IF NOT EXISTS complemento text,     -- Apartamento, bloco, etc.
ADD COLUMN IF NOT EXISTS bairro text,          -- Bairro/distrito
ADD COLUMN IF NOT EXISTS cidade text,          -- Cidade
ADD COLUMN IF NOT EXISTS estado text,          -- Estado (UF)
ADD COLUMN IF NOT EXISTS cep text,             -- CEP
ADD COLUMN IF NOT EXISTS ponto_referencia text; -- Ponto de referência

-- Create function to automatically update endereco field based on detailed address components
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

-- Create trigger to automatically update endereco when address components change
DROP TRIGGER IF EXISTS trigger_update_endereco_completo ON public.clientes;
CREATE TRIGGER trigger_update_endereco_completo
  BEFORE INSERT OR UPDATE ON public.clientes
  FOR EACH ROW
  EXECUTE FUNCTION update_endereco_completo();

-- Create indexes for better performance on address searches
CREATE INDEX IF NOT EXISTS idx_clientes_tipo_logradouro ON public.clientes(tipo_logradouro);
CREATE INDEX IF NOT EXISTS idx_clientes_logradouro ON public.clientes(logradouro);
CREATE INDEX IF NOT EXISTS idx_clientes_bairro ON public.clientes(bairro);
CREATE INDEX IF NOT EXISTS idx_clientes_cidade ON public.clientes(cidade);
CREATE INDEX IF NOT EXISTS idx_clientes_estado ON public.clientes(estado);
CREATE INDEX IF NOT EXISTS idx_clientes_cep ON public.clientes(cep);

-- Add comments to document the new fields
COMMENT ON COLUMN public.clientes.tipo_logradouro IS 'Tipo de logradouro (Rua, Avenida, Travessa, Alameda, etc.)';
COMMENT ON COLUMN public.clientes.logradouro IS 'Nome da rua, avenida ou logradouro';
COMMENT ON COLUMN public.clientes.numero IS 'Número do imóvel/estabelecimento';
COMMENT ON COLUMN public.clientes.complemento IS 'Complemento do endereço (apartamento, bloco, sala, etc.)';
COMMENT ON COLUMN public.clientes.bairro IS 'Bairro ou distrito do cliente';
COMMENT ON COLUMN public.clientes.cidade IS 'Cidade do cliente';
COMMENT ON COLUMN public.clientes.estado IS 'Estado (UF) do cliente';
COMMENT ON COLUMN public.clientes.cep IS 'CEP do cliente (formato: 00000-000)';
COMMENT ON COLUMN public.clientes.ponto_referencia IS 'Ponto de referência para localização';
