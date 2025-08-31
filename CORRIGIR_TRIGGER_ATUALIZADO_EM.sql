-- 🔧 CORREÇÃO COMPLETA - Trigger + Campos Faltantes
-- Execute este script no Supabase SQL Editor para resolver todos os problemas

-- =====================================================
-- PASSO 1: REMOVER TRIGGER PROBLEMÁTICO (TEMPORARIAMENTE)
-- =====================================================

-- Remover trigger que está causando erro
DROP TRIGGER IF EXISTS trigger_updated_at_produtos ON public.produtos;

-- =====================================================
-- PASSO 2: ADICIONAR TODOS OS CAMPOS FALTANTES
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
-- PASSO 3: ATUALIZAR DADOS EXISTENTES
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
-- PASSO 4: RECRIAR TRIGGER CORRIGIDO
-- =====================================================

-- Criar função para atualizar timestamp (se não existir)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Recriar trigger com nome único
CREATE TRIGGER trigger_updated_at_produtos
    BEFORE UPDATE ON public.produtos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- PASSO 5: VERIFICAR TUDO FUNCIONANDO
-- =====================================================

-- Mostrar estrutura completa
SELECT 'ESTRUTURA FINAL DA TABELA:' as info;
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'produtos'
ORDER BY ordinal_position;

-- Testar trigger funcionando
SELECT 'TESTANDO TRIGGER:' as info;
UPDATE public.produtos 
SET nome = nome 
WHERE id = (SELECT id FROM public.produtos LIMIT 1);

-- Mostrar produtos com todos os campos
SELECT 'PRODUTOS COM CAMPOS COMPLETOS:' as info;
SELECT id, nome, sku, estoque, estoque_minimo, unidade, ativo, created_at, atualizado_em
FROM public.produtos 
LIMIT 3;

-- Contar produtos ativos
SELECT 'RESUMO FINAL:' as info, 
       COUNT(*) as total_produtos,
       COUNT(CASE WHEN ativo = true THEN 1 END) as produtos_ativos
FROM public.produtos;

SELECT 'CORREÇÃO CONCLUÍDA COM SUCESSO! ✅' as resultado;
