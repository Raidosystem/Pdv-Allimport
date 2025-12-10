-- ============================================
-- CORRIGIR PRIORIZAÇÃO: check_subscription_status
-- PRIORIDADE: subscription ACTIVE > trial > empresa teste
-- ============================================

CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_empresa RECORD;
  v_subscription RECORD;
  v_user_id UUID;
  v_now TIMESTAMPTZ := NOW();
  v_days_remaining INTEGER := 0;
  v_access_allowed BOOLEAN := FALSE;
  v_status TEXT := 'no_subscription';
  v_has_subscription BOOLEAN := FALSE;
BEGIN
  
  -- 1️⃣ Buscar user_id pelo email
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = user_email
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false,
      'days_remaining', 0,
      'message', 'Usuário não encontrado'
    );
  END IF;
  
  -- 2️⃣ Buscar empresa pelo user_id
  SELECT * INTO v_empresa
  FROM empresas
  WHERE user_id = v_user_id
  LIMIT 1;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false,
      'days_remaining', 0,
      'message', 'Empresa não encontrada'
    );
  END IF;
  
  -- 3️⃣ Buscar assinatura na tabela subscriptions
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id
  ORDER BY created_at DESC
  LIMIT 1;
  
  -- ========================================
  -- PRIORIDADE 1: SUBSCRIPTION ACTIVE (dias pagos)
  -- ========================================
  IF v_subscription.id IS NOT NULL AND v_subscription.status = 'active' THEN
    v_has_subscription := TRUE;
    
    IF v_subscription.subscription_end_date IS NOT NULL AND v_subscription.subscription_end_date > v_now THEN
      v_days_remaining := CEILING(EXTRACT(EPOCH FROM (v_subscription.subscription_end_date - v_now)) / 86400)::INTEGER;
      v_access_allowed := TRUE;
      v_status := 'active';
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'active',
        'access_allowed', true,
        'days_remaining', v_days_remaining,
        'subscription_end_date', v_subscription.subscription_end_date,
        'plan_type', v_subscription.plan_type,
        'message', format('✅ Assinatura ativa: %s dias restantes', v_days_remaining)
      );
    ELSE
      -- Assinatura expirada
      v_access_allowed := FALSE;
      v_status := 'expired';
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'days_remaining', 0,
        'subscription_end_date', v_subscription.subscription_end_date,
        'message', '❌ Assinatura expirada'
      );
    END IF;
  END IF;
  
  -- ========================================
  -- PRIORIDADE 2: SUBSCRIPTION TRIAL
  -- ========================================
  IF v_subscription.id IS NOT NULL AND v_subscription.status = 'trialing' THEN
    v_has_subscription := TRUE;
    
    IF v_subscription.trial_end_date IS NOT NULL AND v_subscription.trial_end_date > v_now THEN
      v_days_remaining := CEILING(EXTRACT(EPOCH FROM (v_subscription.trial_end_date - v_now)) / 86400)::INTEGER;
      v_access_allowed := TRUE;
      v_status := 'trial';
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'days_remaining', v_days_remaining,
        'trial_end_date', v_subscription.trial_end_date,
        'message', format('✅ Trial ativo (subscription): %s dias restantes', v_days_remaining)
      );
    END IF;
  END IF;
  
  -- ========================================
  -- PRIORIDADE 3: EMPRESA TESTE (fallback)
  -- ========================================
  IF v_empresa.tipo_conta = 'teste_ativo' THEN
    v_has_subscription := TRUE;
    
    IF v_empresa.data_fim_teste IS NOT NULL AND v_empresa.data_fim_teste > v_now THEN
      -- TESTE ATIVO - Calcular dias restantes
      v_days_remaining := CEILING(EXTRACT(EPOCH FROM (v_empresa.data_fim_teste - v_now)) / 86400)::INTEGER;
      v_access_allowed := TRUE;
      v_status := 'trial';
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'days_remaining', v_days_remaining,
        'trial_end_date', v_empresa.data_fim_teste,
        'message', format('✅ Teste ativo (empresa): %s dias restantes', v_days_remaining)
      );
    ELSE
      -- TESTE EXPIRADO
      v_access_allowed := FALSE;
      v_status := 'expired';
      v_days_remaining := 0;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'days_remaining', 0,
        'trial_end_date', v_empresa.data_fim_teste,
        'message', '❌ Período de teste expirado'
      );
    END IF;
  END IF;
  
  -- ========================================
  -- SEM ASSINATURA
  -- ========================================
  RETURN json_build_object(
    'has_subscription', false,
    'status', 'no_subscription',
    'access_allowed', false,
    'days_remaining', 0,
    'message', '❌ Nenhuma assinatura encontrada'
  );
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION check_subscription_status(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION check_subscription_status(TEXT) TO anon;

-- ========================================
-- TESTAR A FUNÇÃO
-- ========================================
SELECT check_subscription_status('jf6059256@gmail.com');
