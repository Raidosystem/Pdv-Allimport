-- Verificar se a função de renovação está correta no banco
-- Execute este script no SQL Editor do Supabase para verificar

-- 1. Verificar se a função existe
SELECT 
  proname as function_name,
  prosrc as function_body
FROM pg_proc 
WHERE proname = 'activate_subscription_after_payment';

-- 2. Verificar a assinatura atual do usuário
SELECT 
  id,
  email,
  status,
  subscription_start_date,
  subscription_end_date,
  payment_method,
  payment_status,
  created_at,
  updated_at
FROM public.subscriptions 
ORDER BY updated_at DESC 
LIMIT 5;

-- 3. Testar a função manualmente (substitua o email pelo seu)
-- SELECT activate_subscription_after_payment('seu-email@exemplo.com', 'test-payment-123', 'pix');