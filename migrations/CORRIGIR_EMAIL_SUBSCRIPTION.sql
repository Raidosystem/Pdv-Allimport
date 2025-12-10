-- =========================================
-- CORRIGIR: admin_add_subscription_days
-- =========================================
-- Adicionar campo EMAIL obrigatório

CREATE OR REPLACE FUNCTION admin_add_subscription_days(
  p_user_id UUID,
  p_days INTEGER,
  p_plan_type TEXT DEFAULT 'premium'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_subscription RECORD;
  v_user_email TEXT;
  v_base_date TIMESTAMPTZ;
  v_new_end_date TIMESTAMPTZ;
  v_dias_atuais INTEGER;
  v_dias_finais INTEGER;
BEGIN
  -- Buscar email do usuário
  SELECT email INTO v_user_email
  FROM auth.users
  WHERE id = p_user_id;
  
  IF v_user_email IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'message', '❌ Usuário não encontrado'
    );
  END IF;

  -- Buscar assinatura completa
  SELECT 
    id,
    subscription_end_date,
    subscription_start_date,
    status,
    plan_type
  INTO v_subscription
  FROM subscriptions
  WHERE user_id = p_user_id;

  -- ========================================
  -- CASO 1: NÃO EXISTE ASSINATURA
  -- ========================================
  IF v_subscription.id IS NULL THEN
    v_new_end_date := NOW() + (p_days || ' days')::INTERVAL;
    
    INSERT INTO subscriptions (
      user_id,
      email,  -- ✅ CAMPO OBRIGATÓRIO ADICIONADO
      status,
      plan_type,
      subscription_start_date,
      subscription_end_date,
      created_at,
      updated_at
    ) VALUES (
      p_user_id,
      v_user_email,  -- ✅ EMAIL DO USUÁRIO
      CASE WHEN p_plan_type = 'trial' THEN 'trial' ELSE 'active' END,
      p_plan_type,
      NOW(),
      v_new_end_date,
      NOW(),
      NOW()
    )
    RETURNING id INTO v_subscription;

    RETURN json_build_object(
      'success', true,
      'message', '✅ Nova assinatura criada com ' || p_days || ' dias',
      'subscription_id', v_subscription.id,
      'end_date', v_new_end_date,
      'days_added', p_days,
      'total_days', p_days
    );
  END IF;

  -- ========================================
  -- CASO 2 e 3: ASSINATURA EXISTE
  -- ========================================
  
  -- Determinar a data base para adicionar dias
  IF v_subscription.subscription_end_date IS NULL THEN
    v_base_date := NOW();
    v_dias_atuais := 0;
    
  ELSIF v_subscription.subscription_end_date < NOW() THEN
    v_base_date := NOW();
    v_dias_atuais := 0;
    
  ELSE
    v_base_date := v_subscription.subscription_end_date;
    v_dias_atuais := EXTRACT(DAY FROM (v_subscription.subscription_end_date - NOW()))::INTEGER;
    
  END IF;

  -- Calcular nova data (SEMPRE somando)
  v_new_end_date := v_base_date + (p_days || ' days')::INTERVAL;
  v_dias_finais := EXTRACT(DAY FROM (v_new_end_date - NOW()))::INTEGER;

  -- Atualizar assinatura
  UPDATE subscriptions
  SET
    subscription_end_date = v_new_end_date,
    status = 'active',
    plan_type = p_plan_type,
    updated_at = NOW()
  WHERE user_id = p_user_id;

  RETURN json_build_object(
    'success', true,
    'message', '✅ ' || p_days || ' dias adicionados! Total: ' || v_dias_finais || ' dias',
    'subscription_id', v_subscription.id,
    'old_end_date', v_subscription.subscription_end_date,
    'new_end_date', v_new_end_date,
    'days_added', p_days,
    'days_before', v_dias_atuais,
    'total_days', v_dias_finais
  );
END;
$$;

-- Garantir permissão
GRANT EXECUTE ON FUNCTION admin_add_subscription_days(UUID, INTEGER, TEXT) TO authenticated;
