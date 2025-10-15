-- ============================================
-- VERIFICAR E RECRIAR FUNÇÃO check_subscription_status
-- ============================================

-- 1. PRIMEIRO: Verificar se os dados estão corretos no banco
SELECT 
  u.email,
  s.status,
  s.plan_type,
  s.trial_start_date,
  s.trial_end_date,
  s.subscription_start_date,
  s.subscription_end_date,
  s.updated_at,
  CASE 
    WHEN s.status = 'active' AND s.subscription_end_date > NOW() THEN 'DEVERIA TER ACESSO'
    WHEN s.status = 'trial' AND s.trial_end_date > NOW() THEN 'DEVERIA TER ACESSO'
    ELSE 'SEM ACESSO'
  END as resultado_esperado
FROM auth.users u
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE u.email = 'cris-ramos30@hotmail.com';

-- 2. DROPAR E RECRIAR A FUNÇÃO check_subscription_status
DROP FUNCTION IF EXISTS check_subscription_status(text);

CREATE OR REPLACE FUNCTION check_subscription_status(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_subscription record;
  v_result json;
BEGIN
  -- Buscar user_id pelo email
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

  -- Buscar assinatura do usuário
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id;

  -- Se não tem assinatura
  IF NOT FOUND THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false
    );
  END IF;

  -- Verificar status da assinatura
  IF v_subscription.status = 'active' THEN
    -- Assinatura ativa
    IF v_subscription.subscription_end_date IS NULL OR v_subscription.subscription_end_date > NOW() THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'active',
        'access_allowed', true,
        'plan_type', v_subscription.plan_type,
        'subscription_end_date', v_subscription.subscription_end_date,
        'days_remaining', COALESCE(EXTRACT(DAY FROM (v_subscription.subscription_end_date - NOW()))::integer, 999)
      );
    ELSE
      -- Assinatura expirou
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'plan_type', v_subscription.plan_type,
        'subscription_end_date', v_subscription.subscription_end_date,
        'days_remaining', 0
      );
    END IF;
  ELSIF v_subscription.status = 'trial' THEN
    -- Período de teste
    IF v_subscription.trial_end_date IS NULL OR v_subscription.trial_end_date > NOW() THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'plan_type', 'free',
        'trial_end_date', v_subscription.trial_end_date,
        'days_remaining', COALESCE(EXTRACT(DAY FROM (v_subscription.trial_end_date - NOW()))::integer, 15)
      );
    ELSE
      -- Teste expirou
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'trial_end_date', v_subscription.trial_end_date,
        'days_remaining', 0
      );
    END IF;
  ELSE
    -- Outros status (cancelled, expired, etc.)
    RETURN json_build_object(
      'has_subscription', true,
      'status', v_subscription.status,
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;
END;
$$;

-- 3. TESTAR A FUNÇÃO COM SEU EMAIL
SELECT check_subscription_status('cris-ramos30@hotmail.com');

-- 4. TESTAR COM O CLIENTE PAGO
SELECT check_subscription_status('assistenciaallimport10@gmail.com');

-- 5. VERIFICAR SE TODOS OS USUÁRIOS ATIVOS ESTÃO OK
SELECT 
  u.email,
  check_subscription_status(u.email) as status_calculado
FROM auth.users u
WHERE u.email IN (
  'assistenciaallimport10@gmail.com',
  'cris-ramos30@hotmail.com',
  'novaradiosystem@outlook.com',
  'marcovalentim04@gmail.com'
);

-- ============================================
-- SE AINDA NÃO FUNCIONAR, FORCE O CACHE DO POSTGREST
-- ============================================
NOTIFY pgrst, 'reload schema';
NOTIFY pgrst, 'reload config';
