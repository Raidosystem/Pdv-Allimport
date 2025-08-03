-- Migration: Add garantia fields to ordens_servico table
-- Date: 2025-08-03
-- Description: Add garantia_meses and data_fim_garantia fields to support warranty functionality

-- Add warranty fields to ordens_servico table
ALTER TABLE public.ordens_servico 
ADD COLUMN IF NOT EXISTS garantia_meses integer,
ADD COLUMN IF NOT EXISTS data_fim_garantia date;

-- Add indexes for warranty fields
CREATE INDEX IF NOT EXISTS idx_ordens_servico_garantia_meses ON public.ordens_servico(garantia_meses);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_data_fim_garantia ON public.ordens_servico(data_fim_garantia);

-- Add comments to warranty fields
COMMENT ON COLUMN public.ordens_servico.garantia_meses IS 'Período de garantia em meses (null = sem garantia)';
COMMENT ON COLUMN public.ordens_servico.data_fim_garantia IS 'Data de fim da garantia calculada automaticamente';

-- Update the updated_at trigger to include new fields
CREATE OR REPLACE FUNCTION update_updated_at_ordens_servico()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Recreate trigger to ensure it includes new fields
DROP TRIGGER IF EXISTS trigger_updated_at_ordens_servico ON public.ordens_servico;
CREATE TRIGGER trigger_updated_at_ordens_servico
    BEFORE UPDATE ON public.ordens_servico
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_ordens_servico();
