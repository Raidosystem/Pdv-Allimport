-- ================================
-- 🔄 ATUALIZAR PREÇO PARA R$ 59,90
-- Execute este SQL no Supabase Dashboard SQL Editor
-- Data: 04/08/2025 
-- ================================

-- ATUALIZAR VALOR PADRÃO NA TABELA
ALTER TABLE public.subscriptions 
ALTER COLUMN payment_amount SET DEFAULT 59.90;

-- ATUALIZAR REGISTROS EXISTENTES (opcional)
UPDATE public.subscriptions 
SET payment_amount = 59.90, updated_at = NOW()
WHERE payment_amount = 29.90;

-- VERIFICAR ALTERAÇÃO
SELECT 'Preço atualizado para R$ 59,90!' as resultado;
SELECT id, email, payment_amount, status, updated_at 
FROM public.subscriptions 
WHERE email = 'novaradiosystem@outlook.com';
