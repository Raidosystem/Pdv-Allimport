-- Adicionar campo de estado na tabela de clientes
-- Execute este script no Supabase SQL Editor

DO $$
BEGIN
    -- Adicionar coluna estado na tabela clientes se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'clientes' 
        AND column_name = 'estado'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.clientes 
        ADD COLUMN estado text;
        
        RAISE NOTICE '✅ Coluna estado adicionada na tabela clientes';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna estado já existe na tabela clientes';
    END IF;
    
    -- Adicionar coluna estado na tabela ordens_servico se não existir  
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ordens_servico' 
        AND column_name = 'cliente_estado'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.ordens_servico 
        ADD COLUMN cliente_estado text;
        
        RAISE NOTICE '✅ Coluna cliente_estado adicionada na tabela ordens_servico';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna cliente_estado já existe na tabela ordens_servico';
    END IF;
    
END $$;

-- Comentário sobre o campo
COMMENT ON COLUMN public.clientes.estado IS 'Estado do cliente (SP, MG, RJ, etc.)';
COMMENT ON COLUMN public.ordens_servico.cliente_estado IS 'Estado do cliente na ordem de serviço';
