-- Script para verificar e corrigir a estrutura da tabela ordens_servico
-- Execute este script no SQL Editor do Supabase Dashboard

-- 1. Verificar estrutura atual da tabela
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'ordens_servico' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Adicionar colunas que faltam baseadas no código TypeScript
DO $$
BEGIN
    -- Adicionar colunas que o código espera mas não existem
    
    -- tipo (TipoEquipamento)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'tipo') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN tipo TEXT;
        RAISE NOTICE 'Coluna tipo adicionada';
    END IF;
    
    -- marca (já existe)
    
    -- modelo (já existe)
    
    -- cor
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'cor') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN cor TEXT;
        RAISE NOTICE 'Coluna cor adicionada';
    END IF;
    
    -- defeito_relatado (ao invés de descricao_problema)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'defeito_relatado') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN defeito_relatado TEXT;
        RAISE NOTICE 'Coluna defeito_relatado adicionada';
    END IF;
    
    -- data_entrada (renomear se necessário)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'data_entrada') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'data_entrada') THEN
            -- Já existe, não fazer nada
            RAISE NOTICE 'Coluna data_entrada já existe';
        ELSE
            ALTER TABLE public.ordens_servico ADD COLUMN data_entrada TIMESTAMP WITH TIME ZONE DEFAULT NOW();
            RAISE NOTICE 'Coluna data_entrada adicionada';
        END IF;
    END IF;
    
    -- data_previsao (já existe como data_previsao)
    
    -- data_entrega (ao invés de data_finalizacao)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'data_entrega') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN data_entrega TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Coluna data_entrega adicionada';
    END IF;
    
    -- valor_orcamento (ao invés de valor)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'valor_orcamento') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN valor_orcamento DECIMAL(10,2);
        RAISE NOTICE 'Coluna valor_orcamento adicionada';
    END IF;
    
    -- valor_final
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'valor_final') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN valor_final DECIMAL(10,2);
        RAISE NOTICE 'Coluna valor_final adicionada';
    END IF;
    
    -- garantia_meses
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'garantia_meses') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN garantia_meses INTEGER;
        RAISE NOTICE 'Coluna garantia_meses adicionada';
    END IF;
    
    -- data_fim_garantia
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'data_fim_garantia') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN data_fim_garantia TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Coluna data_fim_garantia adicionada';
    END IF;
    
    -- checklist (já foi adicionado)
    
END $$;

-- 3. Verificar estrutura final
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'ordens_servico' 
AND table_schema = 'public'
ORDER BY ordinal_position;
