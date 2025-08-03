-- Add checklist column to ordens_servico table
ALTER TABLE ordens_servico 
ADD COLUMN IF NOT EXISTS checklist JSONB DEFAULT '{}';

-- Add comment to document the column purpose
COMMENT ON COLUMN ordens_servico.checklist IS 'Checklist items for the service order stored as JSON';
