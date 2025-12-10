-- TESTE: Verificar status atual da assinatura assistenciaallimport10@gmail.com
-- Execute este SQL no Supabase Dashboard para verificar o problema

-- 1. VERIFICAR SE A ASSINATURA EXISTE NA TABELA
SELECT 
  email,
  status,
  subscription_end_date,
  payment_status,
  payment_id,
  EXTRACT(DAY FROM subscription_end_date - NOW()) as dias_restantes,
  created_at,
  updated_at
FROM public.subscriptions 
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. VERIFICAR SE O PAGAMENTO FOI PROCESSADO
SELECT 
  payment_id,
  processed_at
FROM public.payments_processed 
WHERE payment_id = '126096480102';

-- 3. TESTAR A FUNÇÃO RPC check_subscription_status ATUAL
SELECT check_subscription_status('assistenciaallimport10@gmail.com');

-- 4. SE A FUNÇÃO NÃO EXISTIR OU ESTIVER QUEBRADA, RECRIAR
CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  current_time TIMESTAMPTZ := NOW();
BEGIN
  -- Buscar assinatura por EMAIL (não por user_id)
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false
    );
  END IF;
  
  -- Verificar se está em período de teste
  IF subscription_record.status = 'trial' THEN
    IF current_time <= subscription_record.trial_end_date THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'trial_end_date', subscription_record.trial_end_date,
        'days_remaining', EXTRACT(DAY FROM subscription_record.trial_end_date - current_time)
      );
    ELSE
      -- Trial expirado, atualizar status
      UPDATE public.subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = subscription_record.id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'trial_end_date', subscription_record.trial_end_date
      );
    END IF;
  END IF;
  
  -- Verificar se tem assinatura ativa
  IF subscription_record.status = 'active' THEN
    IF current_time <= subscription_record.subscription_end_date THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'active',
        'access_allowed', true,
        'subscription_end_date', subscription_record.subscription_end_date,
        'days_remaining', EXTRACT(DAY FROM subscription_record.subscription_end_date - current_time)
      );
    ELSE
      -- Assinatura expirada, atualizar status
      UPDATE public.subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = subscription_record.id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'subscription_end_date', subscription_record.subscription_end_date,
        'days_remaining', 0
      );
    END IF;
  END IF;
  
  -- Status expirado ou outros - calcular dias restantes mesmo assim
  RETURN json_build_object(
    'has_subscription', true,
    'status', subscription_record.status,
    'access_allowed', false,
    'subscription_end_date', subscription_record.subscription_end_date,
    'days_remaining', CASE 
      WHEN subscription_record.subscription_end_date > current_time 
      THEN EXTRACT(DAY FROM subscription_record.subscription_end_date - current_time)
      ELSE 0 
    END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. TESTAR NOVAMENTE APÓS RECRIAR A FUNÇÃO
SELECT check_subscription_status('assistenciaallimport10@gmail.com');

-- 6. COMENTÁRIOS
SELECT 'TESTE CONCLUÍDO! Verifique se os dados estão corretos e se a função retorna dias_remaining atualizado.' as resultado;