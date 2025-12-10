-- ========================================
-- CORREÇÃO RÁPIDA: DAR 15 DIAS PARA USUÁRIO ATUAL
-- ========================================
-- Execute no Supabase SQL Editor

-- 1. PRIMEIRO: Ver seu usuário atual
SELECT 
  email,
  status,
  email_verified,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes,
  subscription_start_date,
  subscription_end_date
FROM public.subscriptions
ORDER BY created_at DESC
LIMIT 5;

-- 2. CORRIGIR: Substituir 'SEU-EMAIL@AQUI.COM' pelo seu email
UPDATE public.subscriptions
SET 
  status = 'trial',
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '15 days',
  trial_start_date = NOW(),
  trial_end_date = NOW() + INTERVAL '15 days',
  email_verified = TRUE,
  updated_at = NOW()
WHERE email = 'SEU-EMAIL@AQUI.COM';

-- 3. VERIFICAR: Confirmar que deu certo
SELECT 
  email,
  status,
  email_verified,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes,
  subscription_start_date,
  subscription_end_date
FROM public.subscriptions
WHERE email = 'SEU-EMAIL@AQUI.COM';

-- Resultado esperado:
-- status: 'trial'
-- dias_restantes: 15
-- email_verified: true
