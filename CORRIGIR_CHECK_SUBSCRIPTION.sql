-- ============================================
-- VERIFICAR E CORRIGIR check_subscription_status
-- ============================================

-- PASSO 1: Ver se a função existe
SELECT 
  proname as function_name,
  prosrc as source_code
FROM pg_proc
WHERE proname = 'check_subscription_status';

-- PASSO 2: Recriar a função CORRETA
CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS TABLE (
  has_subscription BOOLEAN,
  status VARCHAR,
  access_allowed BOOLEAN,
  days_remaining INTEGER,
  trial_end_date TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_subscription RECORD;
  v_empresa RECORD;
  v_now TIMESTAMPTZ := NOW();
BEGIN
  -- Buscar user_id pelo email
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = user_email;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não encontrado: %', user_email;
  END IF;

  -- 🔍 BUSCAR SUBSCRIPTION
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE subscriptions.user_id = v_user_id
  LIMIT 1;

  -- 🎯 SE TEM SUBSCRIPTION, USAR ELA (prioridade máxima)
  IF v_subscription.id IS NOT NULL THEN
    -- Verificar se está em trial ATIVO
    IF v_subscription.status = 'trial' AND v_subscription.trial_end_date > v_now THEN
      RETURN QUERY SELECT
        true::BOOLEAN,
        'trial'::VARCHAR,
        true::BOOLEAN, -- 🔥 ACESSO PERMITIDO!
        EXTRACT(DAY FROM (v_subscription.trial_end_date - v_now))::INTEGER,
        v_subscription.trial_end_date;
      RETURN;
    END IF;

    -- Verificar se subscription está ATIVA
    IF v_subscription.status = 'active' AND v_subscription.subscription_end_date > v_now THEN
      RETURN QUERY SELECT
        true::BOOLEAN,
        'active'::VARCHAR,
        true::BOOLEAN, -- 🔥 ACESSO PERMITIDO!
        EXTRACT(DAY FROM (v_subscription.subscription_end_date - v_now))::INTEGER,
        v_subscription.subscription_end_date;
      RETURN;
    END IF;

    -- Se chegou aqui, subscription existe mas está expirada
    RETURN QUERY SELECT
      true::BOOLEAN,
      'expired'::VARCHAR,
      false::BOOLEAN,
      0::INTEGER,
      v_subscription.trial_end_date;
    RETURN;
  END IF;

  -- 🔍 SE NÃO TEM SUBSCRIPTION, verificar empresa (fallback)
  SELECT * INTO v_empresa
  FROM empresas
  WHERE empresas.user_id = v_user_id
  LIMIT 1;

  IF v_empresa.id IS NOT NULL AND v_empresa.data_fim_teste IS NOT NULL THEN
    IF v_empresa.data_fim_teste > v_now THEN
      RETURN QUERY SELECT
        true::BOOLEAN,
        'trial'::VARCHAR,
        true::BOOLEAN,
        EXTRACT(DAY FROM (v_empresa.data_fim_teste - v_now))::INTEGER,
        v_empresa.data_fim_teste;
      RETURN;
    END IF;
  END IF;

  -- Nenhuma subscription ou teste ativo
  RETURN QUERY SELECT
    false::BOOLEAN,
    'none'::VARCHAR,
    false::BOOLEAN,
    0::INTEGER,
    NULL::TIMESTAMPTZ;
END;
$$;

-- PASSO 3: Dar permissão
GRANT EXECUTE ON FUNCTION check_subscription_status(TEXT) TO authenticated;

-- PASSO 4: Testar com usuário específico
SELECT * FROM check_subscription_status('cris-ramos30@hotmail.com');

-- PASSO 5: Resultado esperado
SELECT 
  '✅ Deve retornar:' as mensagem
UNION ALL
SELECT '  has_subscription: true'
UNION ALL
SELECT '  status: trial'
UNION ALL
SELECT '  access_allowed: true ⚠️ CRÍTICO!'
UNION ALL
SELECT '  days_remaining: 14'
UNION ALL
SELECT '  trial_end_date: 2026-01-05';
