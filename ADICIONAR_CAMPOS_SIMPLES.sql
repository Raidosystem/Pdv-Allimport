-- 🔧 CORREÇÃO SIMPLES E SEGURA - Execute no Supabase SQL Editor
-- Este script adiciona os campos faltantes sem conflitos

-- =====================================================
-- PASSO 1: ADICIONAR CAMPOS FALTANTES
-- =====================================================

-- Adicionar campos essenciais que o código espera
ALTER TABLE public.produtos 
ADD COLUMN IF NOT EXISTS sku TEXT,
ADD COLUMN IF NOT EXISTS estoque_minimo INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS unidade TEXT DEFAULT 'un',
ADD COLUMN IF NOT EXISTS ativo BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS preco_custo DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- =====================================================
-- PASSO 2: ATUALIZAR DADOS EXISTENTES
-- =====================================================

-- Gerar SKUs únicos para produtos existentes
UPDATE public.produtos 
SET sku = 'PDV-' || SUBSTRING(id::text, 1, 8)
WHERE sku IS NULL OR sku = '';

-- Ativar todos os produtos existentes
UPDATE public.produtos 
SET ativo = true 
WHERE ativo IS NULL;

-- Definir unidade padrão
UPDATE public.produtos 
SET unidade = 'un' 
WHERE unidade IS NULL OR unidade = '';

-- Definir estoque mínimo
UPDATE public.produtos 
SET estoque_minimo = 1 
WHERE estoque_minimo IS NULL;

-- Definir data de atualização
UPDATE public.produtos 
SET atualizado_em = created_at 
WHERE atualizado_em IS NULL;

-- =====================================================
-- PASSO 3: VERIFICAR RESULTADO
-- =====================================================

-- Mostrar estrutura atualizada
SELECT 'ESTRUTURA ATUALIZADA:' as info;
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'produtos'
ORDER BY ordinal_position;

-- Mostrar alguns produtos com novos campos
SELECT 'PRODUTOS COM NOVOS CAMPOS:' as info;
SELECT id, nome, sku, estoque, estoque_minimo, unidade, ativo 
FROM public.produtos 
LIMIT 5;

-- Contar produtos ativos
SELECT 'TOTAL PRODUTOS ATIVOS:' as info, COUNT(*) as total
FROM public.produtos WHERE ativo = true;
