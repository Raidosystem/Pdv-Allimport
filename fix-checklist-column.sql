-- Script para verificar e criar a coluna checklist na tabela ordens_servico
-- Execute este script diretamente no SQL Editor do Supabase Dashboard

-- 1. Verificar se a tabela ordens_servico existe
SELECT 
    table_name,
    table_schema
FROM information_schema.tables 
WHERE table_name = 'ordens_servico'
AND table_schema = 'public';

-- 2. Verificar se a coluna checklist existe
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'ordens_servico' 
AND column_name = 'checklist'
AND table_schema = 'public';

-- 3. Se a coluna não existir, criar ela
DO $$
BEGIN
    -- Check if the column exists
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'ordens_servico' 
        AND column_name = 'checklist'
        AND table_schema = 'public'
    ) THEN
        -- Add the column if it doesn't exist
        ALTER TABLE public.ordens_servico 
        ADD COLUMN checklist JSONB DEFAULT '{}';
        
        -- Add comment
        COMMENT ON COLUMN public.ordens_servico.checklist IS 'Checklist items for the service order stored as JSON';
        
        RAISE NOTICE 'Column checklist added to ordens_servico table';
    ELSE
        RAISE NOTICE 'Column checklist already exists in ordens_servico table';
    END IF;
END $$;

-- 4. Verificar novamente se a coluna foi criada
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'ordens_servico' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 5. Teste de inserção para verificar se tudo funciona
INSERT INTO public.ordens_servico (
    equipamento,
    defeito,
    status,
    checklist
) VALUES (
    'TESTE - Equipamento de teste',
    'TESTE - Defeito de teste',
    'em_analise',
    '{"teste": true, "criado_em": "2025-08-03"}'
) RETURNING id, equipamento, checklist;

-- 6. Limpar o teste (substitua o ID pelo retornado acima)
-- DELETE FROM public.ordens_servico WHERE equipamento = 'TESTE - Equipamento de teste';
