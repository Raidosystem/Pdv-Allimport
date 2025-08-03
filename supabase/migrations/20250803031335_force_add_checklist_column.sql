-- Force add checklist column to ordens_servico table if it doesn't exist
DO $$
BEGIN
    -- Check if the column exists
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'ordens_servico' 
        AND column_name = 'checklist'
    ) THEN
        -- Add the column if it doesn't exist
        ALTER TABLE ordens_servico 
        ADD COLUMN checklist JSONB DEFAULT '{}';
        
        -- Add comment
        COMMENT ON COLUMN ordens_servico.checklist IS 'Checklist items for the service order stored as JSON';
        
        RAISE NOTICE 'Column checklist added to ordens_servico table';
    ELSE
        RAISE NOTICE 'Column checklist already exists in ordens_servico table';
    END IF;
END $$;