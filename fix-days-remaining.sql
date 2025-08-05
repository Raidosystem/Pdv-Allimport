-- CORREÇÃO: Adicionar days_remaining para assinaturas ativas
-- Esta correção resolve o problema do contador mostrando 0 dias

CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  current_timestamp TIMESTAMPTZ := NOW();
  days_left INTEGER;
BEGIN
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object('has_subscription', false, 'status', 'no_subscription', 'access_allowed', false);
  END IF;
  
  IF subscription_record.status = 'trial' THEN
    IF current_timestamp <= subscription_record.trial_end_date THEN
      days_left := EXTRACT(DAY FROM subscription_record.trial_end_date - current_timestamp)::INTEGER;
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'trial_end_date', subscription_record.trial_end_date,
        'days_remaining', days_left
      );
    ELSE
      UPDATE public.subscriptions SET status = 'expired', updated_at = NOW() WHERE id = subscription_record.id;
      RETURN json_build_object('has_subscription', true, 'status', 'expired', 'access_allowed', false, 'days_remaining', 0);
    END IF;
  END IF;
  
  IF subscription_record.status = 'active' THEN
    IF current_timestamp <= subscription_record.subscription_end_date THEN
      -- CORREÇÃO: Calcular dias restantes para assinatura ativa
      days_left := EXTRACT(DAY FROM subscription_record.subscription_end_date - current_timestamp)::INTEGER;
      RETURN json_build_object(
        'has_subscription', true, 
        'status', 'active', 
        'access_allowed', true,
        'subscription_end_date', subscription_record.subscription_end_date,
        'days_remaining', days_left
      );
    ELSE
      UPDATE public.subscriptions SET status = 'expired', updated_at = NOW() WHERE id = subscription_record.id;
      RETURN json_build_object('has_subscription', true, 'status', 'expired', 'access_allowed', false, 'days_remaining', 0);
    END IF;
  END IF;
  
  RETURN json_build_object('has_subscription', true, 'status', subscription_record.status, 'access_allowed', false, 'days_remaining', 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
