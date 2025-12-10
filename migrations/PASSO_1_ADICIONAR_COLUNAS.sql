-- ========================================
-- PASSO 1: ADICIONAR COLUNAS FALTANTES NA TABELA SUBSCRIPTIONS
-- ========================================
-- Execute PRIMEIRO este SQL antes do outro

-- Verificar estrutura atual da tabela
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'subscriptions'
ORDER BY ordinal_position;

-- Adicionar colunas que podem estar faltando
ALTER TABLE public.subscriptions 
ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS trial_start_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS trial_end_date TIMESTAMPTZ;

-- Verificar se as colunas foram adicionadas
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'subscriptions'
  AND column_name IN ('email_verified', 'trial_start_date', 'trial_end_date');

-- ✅ Sucesso! Agora você pode executar o outro SQL (CORRIGIR_15_DIAS_GRATIS.sql)
