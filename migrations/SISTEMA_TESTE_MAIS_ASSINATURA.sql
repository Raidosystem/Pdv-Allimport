-- ============================================
-- SISTEMA DE TESTE + ASSINATURA COM SOMA DE DIAS
-- ============================================

-- 1️⃣ FUNÇÃO: Ativar 15 dias de teste para novos usuários
-- ============================================
CREATE OR REPLACE FUNCTION activate_trial_for_new_user(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_existing_subscription record;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = user_email;

  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado'
    );
  END IF;

  -- Verificar se já tem assinatura
  SELECT * INTO v_existing_subscription
  FROM subscriptions
  WHERE user_id = v_user_id;

  -- Se já tem assinatura, não fazer nada
  IF FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário já possui assinatura',
      'existing_status', v_existing_subscription.status
    );
  END IF;

  -- Criar nova assinatura de teste (15 dias)
  INSERT INTO subscriptions (
    user_id,
    status,
    plan_type,
    trial_start_date,
    trial_end_date,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    'trial',
    'free',
    NOW(),
    NOW() + INTERVAL '15 days',
    NOW(),
    NOW()
  );

  RETURN json_build_object(
    'success', true,
    'message', 'Período de teste ativado com sucesso',
    'days_remaining', 15,
    'trial_end_date', NOW() + INTERVAL '15 days'
  );
END;
$$;

-- 2️⃣ FUNÇÃO: Converter teste em assinatura paga (SOMANDO OS DIAS)
-- ============================================
CREATE OR REPLACE FUNCTION upgrade_to_paid_subscription(
  user_email text,
  plan_name text,  -- 'monthly', 'yearly', etc.
  payment_amount numeric
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_subscription record;
  v_trial_days_remaining integer;
  v_new_end_date timestamp with time zone;
  v_subscription_duration interval;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = user_email;

  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado'
    );
  END IF;

  -- Buscar assinatura existente
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não possui assinatura'
    );
  END IF;

  -- Calcular dias restantes do teste (se ainda estiver em trial)
  v_trial_days_remaining := 0;
  
  IF v_subscription.status = 'trial' AND v_subscription.trial_end_date > NOW() THEN
    v_trial_days_remaining := EXTRACT(DAY FROM (v_subscription.trial_end_date - NOW()))::integer;
    RAISE NOTICE 'Dias restantes do teste: %', v_trial_days_remaining;
  END IF;

  -- Determinar duração da assinatura baseada no plano
  CASE plan_name
    WHEN 'monthly' THEN
      v_subscription_duration := INTERVAL '1 month';
    WHEN 'quarterly' THEN
      v_subscription_duration := INTERVAL '3 months';
    WHEN 'semiannual' THEN
      v_subscription_duration := INTERVAL '6 months';
    WHEN 'yearly' THEN
      v_subscription_duration := INTERVAL '1 year';
    ELSE
      v_subscription_duration := INTERVAL '1 month';
  END CASE;

  -- ✨ MÁGICA: Somar dias do teste com a assinatura paga
  -- Data final = HOJE + duração do plano + dias restantes do teste
  v_new_end_date := NOW() + v_subscription_duration + (v_trial_days_remaining || ' days')::interval;

  RAISE NOTICE 'Data final calculada: %', v_new_end_date;

  -- Atualizar assinatura para PAGA
  UPDATE subscriptions
  SET
    status = 'active',
    plan_type = plan_name,
    subscription_start_date = NOW(),
    subscription_end_date = v_new_end_date,
    trial_start_date = NULL,  -- Limpar dados do teste
    trial_end_date = NULL,
    amount = payment_amount,
    payment_method = 'upgrade_from_trial',
    last_payment_date = NOW(),
    next_payment_date = v_new_end_date,
    updated_at = NOW()
  WHERE user_id = v_user_id;

  RETURN json_build_object(
    'success', true,
    'message', 'Assinatura ativada com sucesso',
    'plan_type', plan_name,
    'trial_days_added', v_trial_days_remaining,
    'subscription_end_date', v_new_end_date,
    'total_days', EXTRACT(DAY FROM (v_new_end_date - NOW()))::integer
  );
END;
$$;

-- 3️⃣ FUNÇÃO: Atualizar check_subscription_status para mostrar corretamente
-- ============================================
CREATE OR REPLACE FUNCTION check_subscription_status(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_subscription record;
  v_days_remaining integer;
BEGIN
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = user_email;

  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_user',
      'access_allowed', false
    );
  END IF;

  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false
    );
  END IF;

  -- ✅ ASSINATURA ATIVA (PAGA)
  IF v_subscription.status = 'active' THEN
    IF v_subscription.subscription_end_date IS NULL OR v_subscription.subscription_end_date > NOW() THEN
      v_days_remaining := COALESCE(EXTRACT(DAY FROM (v_subscription.subscription_end_date - NOW()))::integer, 999);
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'active',
        'access_allowed', true,
        'plan_type', v_subscription.plan_type,
        'subscription_end_date', v_subscription.subscription_end_date,
        'days_remaining', v_days_remaining,
        'is_trial', false
      );
    ELSE
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'plan_type', v_subscription.plan_type,
        'subscription_end_date', v_subscription.subscription_end_date,
        'days_remaining', 0,
        'is_trial', false
      );
    END IF;
  
  -- ⚠️ PERÍODO DE TESTE
  ELSIF v_subscription.status = 'trial' THEN
    IF v_subscription.trial_end_date IS NULL OR v_subscription.trial_end_date > NOW() THEN
      v_days_remaining := COALESCE(EXTRACT(DAY FROM (v_subscription.trial_end_date - NOW()))::integer, 15);
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'plan_type', 'free',
        'trial_end_date', v_subscription.trial_end_date,
        'days_remaining', v_days_remaining,
        'is_trial', true
      );
    ELSE
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'trial_end_date', v_subscription.trial_end_date,
        'days_remaining', 0,
        'is_trial', true
      );
    END IF;
  
  -- ❌ OUTROS STATUS
  ELSE
    RETURN json_build_object(
      'has_subscription', true,
      'status', v_subscription.status,
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;
END;
$$;

-- ============================================
-- TESTES
-- ============================================

-- Teste 1: Ativar teste para novo usuário
SELECT activate_trial_for_new_user('teste_novo@exemplo.com');

-- Teste 2: Verificar status
SELECT check_subscription_status('teste_novo@exemplo.com');

-- Teste 3: Simular upgrade de teste para pago (mensal)
-- Isso vai SOMAR os dias restantes do teste com 30 dias do plano mensal
SELECT upgrade_to_paid_subscription('teste_novo@exemplo.com', 'monthly', 59.90);

-- Teste 4: Verificar status após upgrade
SELECT check_subscription_status('teste_novo@exemplo.com');

-- ============================================
-- EXEMPLO REAL
-- ============================================
-- Usuário se cadastra: ganha 15 dias de teste
-- Dia 5: usuário decide pagar (ainda tem 10 dias de teste)
-- Paga plano mensal (30 dias)
-- Total: 30 + 10 = 40 dias de acesso! 🎉
