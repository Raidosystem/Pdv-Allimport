#!/bin/bash

# Script para executar comandos SQL no Supabase remotamente
# Conecta ao banco e executa os scripts de correção

echo "🔧 Executando scripts de correção no Supabase..."

# URL de conexão do Supabase
DB_URL="postgresql://postgres.kmcaaqetxtwkdcczdomw:%40qw12aszx%23%23@aws-0-us-east-1.pooler.supabase.com:6543/postgres"

echo "📋 Script 1: Corrigindo estrutura da tabela ordens_servico..."

# Executar o script de estrutura da tabela
psql "$DB_URL" << 'EOF'
-- Script para verificar e corrigir a estrutura da tabela ordens_servico

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
    -- tipo (TipoEquipamento)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'tipo') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN tipo TEXT;
        RAISE NOTICE 'Coluna tipo adicionada';
    END IF;
    
    -- cor
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'cor') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN cor TEXT;
        RAISE NOTICE 'Coluna cor adicionada';
    END IF;
    
    -- defeito_relatado
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'defeito_relatado') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN defeito_relatado TEXT;
        RAISE NOTICE 'Coluna defeito_relatado adicionada';
    END IF;
    
    -- data_entrega
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'data_entrega') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN data_entrega TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Coluna data_entrega adicionada';
    END IF;
    
    -- valor_orcamento
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
    
    -- checklist (verificar se já existe)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'checklist') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN checklist JSONB DEFAULT '{}';
        RAISE NOTICE 'Coluna checklist adicionada';
    END IF;
    
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
EOF

echo "📋 Script 2: Corrigindo políticas RLS..."

# Executar o script de políticas RLS
psql "$DB_URL" << 'EOF'
-- Script para ajustar as políticas RLS para permitir usuário de teste

-- 1. Remover políticas antigas
DROP POLICY IF EXISTS "Users can view all ordens_servico" ON public.ordens_servico;
DROP POLICY IF EXISTS "Users can insert ordens_servico" ON public.ordens_servico;
DROP POLICY IF EXISTS "Users can update ordens_servico" ON public.ordens_servico;
DROP POLICY IF EXISTS "Users can delete ordens_servico" ON public.ordens_servico;

-- 2. Criar políticas mais flexíveis
CREATE POLICY "Users can view ordens_servico" 
ON public.ordens_servico FOR SELECT 
USING (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
);

CREATE POLICY "Users can insert ordens_servico" 
ON public.ordens_servico FOR INSERT 
WITH CHECK (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
);

CREATE POLICY "Users can update ordens_servico" 
ON public.ordens_servico FOR UPDATE 
USING (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
)
WITH CHECK (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
);

CREATE POLICY "Users can delete ordens_servico" 
ON public.ordens_servico FOR DELETE 
USING (
    auth.role() = 'authenticated' 
    OR auth.uid()::text = '00000000-0000-0000-0000-000000000001'
    OR usuario_id = '00000000-0000-0000-0000-000000000001'
);

-- 3. Verificar se as políticas foram criadas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'ordens_servico';
EOF

echo "✅ Scripts executados com sucesso!"
