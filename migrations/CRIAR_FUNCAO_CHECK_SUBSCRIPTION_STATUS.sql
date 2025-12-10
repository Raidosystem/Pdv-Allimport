-- =====================================================
-- FUNÇÃO CHECK_SUBSCRIPTION_STATUS
-- =====================================================
-- Esta função verifica o status da assinatura e retorna
-- se o usuário tem acesso permitido ao sistema
-- =====================================================

-- Remover função se já existir
DROP FUNCTION IF EXISTS check_subscription_status(text);

-- Criar função
CREATE OR REPLACE FUNCTION check_subscription_status(user_email text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_subscription RECORD;
  v_result jsonb;
  v_days_remaining integer;
  v_access_allowed boolean;
  v_status text;
BEGIN
  -- Buscar assinatura do usuário
  SELECT *
  INTO v_subscription
  FROM subscriptions
  WHERE email = user_email
  ORDER BY created_at DESC
  LIMIT 1;

  -- Se não encontrou assinatura
  IF v_subscription IS NULL THEN
    RETURN jsonb_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;

  -- Calcular dias restantes e status
  v_status := v_subscription.status;
  v_access_allowed := false;
  v_days_remaining := 0;

  -- Verificar PREMIUM ATIVO
  IF v_subscription.status = 'active' 
     AND v_subscription.subscription_end_date IS NOT NULL 
     AND v_subscription.subscription_end_date > now() THEN
    
    v_days_remaining := EXTRACT(DAY FROM (v_subscription.subscription_end_date - now()));
    v_access_allowed := true;
    v_status := 'active';

  -- Verificar TRIAL ATIVO
  ELSIF v_subscription.status = 'trial'
     AND v_subscription.trial_end_date IS NOT NULL
     AND v_subscription.trial_end_date > now() THEN
    
    v_days_remaining := EXTRACT(DAY FROM (v_subscription.trial_end_date - now()));
    v_access_allowed := true;
    v_status := 'trial';

  -- Verificar EXPIRADO
  ELSIF (v_subscription.status = 'active' AND v_subscription.subscription_end_date < now())
     OR (v_subscription.status = 'trial' AND v_subscription.trial_end_date < now()) THEN
    
    v_status := 'expired';
    v_access_allowed := false;
    v_days_remaining := 0;

  ELSE
    -- Qualquer outro caso (pending, cancelled, etc)
    v_status := v_subscription.status;
    v_access_allowed := false;
    v_days_remaining := 0;
  END IF;

  -- Retornar resultado
  RETURN jsonb_build_object(
    'has_subscription', true,
    'status', v_status,
    'access_allowed', v_access_allowed,
    'days_remaining', v_days_remaining,
    'plan_type', v_subscription.plan_type,
    'subscription_end_date', v_subscription.subscription_end_date,
    'trial_end_date', v_subscription.trial_end_date
  );
END;
$$;

-- Dar permissão
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO authenticated;
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO anon;

-- Comentário
COMMENT ON FUNCTION check_subscription_status(text) IS 
  'Verifica o status da assinatura de um usuário e retorna se tem acesso permitido ao sistema';

-- =====================================================
-- TESTAR A FUNÇÃO
-- =====================================================

-- Teste com o usuário que está com problema
SELECT check_subscription_status('cris-ramos30@hotmail.com');

-- Deve retornar algo como:
-- {
--   "has_subscription": true,
--   "status": "active",
--   "access_allowed": true,
--   "days_remaining": 20,
--   "plan_type": "yearly",
--   "subscription_end_date": "2025-11-17T06:14:58.315Z",
--   "trial_end_date": null
-- }
