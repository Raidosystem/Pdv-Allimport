-- ============================================================================
-- CORRIGIR FUNÇÃO activate_trial_for_new_user (remover email_verified)
-- ============================================================================

CREATE OR REPLACE FUNCTION activate_trial_for_new_user(user_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_trial_end_date TIMESTAMPTZ;
  v_existing_subscription RECORD;
BEGIN
  RAISE NOTICE '🎯 Ativando trial para: %', user_email;
  
  -- Buscar user_id
  SELECT user_id INTO v_user_id
  FROM user_approvals
  WHERE email = user_email;
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '⚠️ Usuário não encontrado em user_approvals';
    RETURN json_build_object('success', false, 'error', 'Usuário não encontrado');
  END IF;
  
  -- Verificar se já tem assinatura
  SELECT * INTO v_existing_subscription
  FROM subscriptions
  WHERE email = user_email;
  
  IF FOUND THEN
    RAISE NOTICE '⚠️ Usuário já tem assinatura';
    RETURN json_build_object(
      'success', true,
      'message', 'Assinatura já existe',
      'trial_end_date', v_existing_subscription.trial_end_date
    );
  END IF;
  
  -- Calcular data de fim do trial (15 dias)
  v_trial_end_date := NOW() + INTERVAL '15 days';
  
  -- Criar assinatura trial (SEM email_verified)
  INSERT INTO subscriptions (
    user_id,
    email,
    status,
    plan_type,
    trial_start_date,
    trial_end_date,
    subscription_start_date,
    subscription_end_date,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    user_email,
    'trial',
    'free',
    NOW(),
    v_trial_end_date,
    NOW(),
    v_trial_end_date,
    NOW(),
    NOW()
  );
  
  RAISE NOTICE '✅ Trial de 15 dias ativado até: %', v_trial_end_date;
  
  RETURN json_build_object(
    'success', true,
    'message', '15 dias de teste ativados',
    'trial_end_date', v_trial_end_date,
    'days_remaining', 15
  );
END;
$$;

GRANT EXECUTE ON FUNCTION activate_trial_for_new_user(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION activate_trial_for_new_user(TEXT) TO anon;

SELECT '✅ Função activate_trial_for_new_user corrigida!' as resultado;
