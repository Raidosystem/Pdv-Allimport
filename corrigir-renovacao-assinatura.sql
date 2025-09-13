-- CORREÇÃO: Adicionar 30 dias à assinatura existente ao invés de resetar

CREATE OR REPLACE FUNCTION activate_subscription_after_payment(
  user_email TEXT,
  payment_id TEXT,
  payment_method TEXT
)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  subscription_end TIMESTAMPTZ;
  current_end_date TIMESTAMPTZ;
  base_date TIMESTAMPTZ;
BEGIN
  -- Buscar assinatura
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Assinatura não encontrada');
  END IF;
  
  -- Pegar a data atual de expiração
  current_end_date := subscription_record.subscription_end_date;
  
  -- Determinar a data base para adicionar 30 dias:
  -- Se a assinatura ainda está válida (data futura), usar a data de expiração atual
  -- Se já expirou, usar a data atual
  IF current_end_date > NOW() THEN
    base_date := current_end_date;
  ELSE
    base_date := NOW();
  END IF;
  
  -- Calcular nova data de expiração (30 dias adicionados à base_date)
  subscription_end := base_date + INTERVAL '30 days';
  
  -- Atualizar assinatura
  UPDATE public.subscriptions 
  SET 
    status = 'active',
    subscription_start_date = CASE 
      WHEN subscription_record.subscription_start_date IS NULL THEN NOW()
      ELSE subscription_record.subscription_start_date
    END,
    subscription_end_date = subscription_end,
    payment_method = payment_method,
    payment_status = 'paid',
    payment_id = payment_id,
    updated_at = NOW()
  WHERE id = subscription_record.id;
  
  RETURN json_build_object(
    'success', true,
    'status', 'active',
    'subscription_end_date', subscription_end,
    'days_added', 30,
    'previous_end_date', current_end_date,
    'message', CASE 
      WHEN current_end_date > NOW() THEN 
        'Renovação: 30 dias adicionados ao tempo restante'
      ELSE 
        'Ativação: 30 dias a partir de hoje'
    END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;