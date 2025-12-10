-- Script para debugar o problema da renovação da assinatura
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar se a função existe e qual é sua definição
SELECT 
  proname as function_name,
  pg_get_functiondef(pg_proc.oid) as function_definition
FROM pg_proc 
WHERE proname = 'activate_subscription_after_payment';

-- 2. Ver o estado atual da assinatura
SELECT 
  id,
  email,
  status,
  subscription_start_date,
  subscription_end_date,
  payment_method,
  payment_status,
  payment_id,
  created_at,
  updated_at,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as days_remaining
FROM public.subscriptions 
WHERE email = 'seu-email@aqui.com'  -- SUBSTITUA pelo seu email
ORDER BY updated_at DESC;

-- 3. Verificar logs de pagamentos recentes (se existir tabela)
SELECT * FROM public.payments 
ORDER BY created_at DESC 
LIMIT 5;

-- 4. Testar a função manualmente (CUIDADO - vai modificar dados reais)
-- Descomente e execute apenas se necessário:
-- SELECT activate_subscription_after_payment('seu-email@aqui.com', 'test-payment-debug', 'pix');

-- 5. Ver registros de auditoria se existirem
SELECT table_name, column_name 
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND column_name LIKE '%payment%' 
OR column_name LIKE '%subscription%';