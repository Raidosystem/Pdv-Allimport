-- ============================================================================
-- VERIFICAR E CRIAR FUNÇÃO upgrade_to_paid_subscription
-- ============================================================================

-- 1️⃣ Verificar se a função existe
SELECT 
  '🔍 FUNÇÃO EXISTE?' as info,
  proname as nome_funcao,
  pronargs as num_argumentos
FROM pg_proc
WHERE proname = 'upgrade_to_paid_subscription';

-- 2️⃣ Criar a função se não existir
CREATE OR REPLACE FUNCTION upgrade_to_paid_subscription(
  user_email TEXT,
  plan_name TEXT,  -- 'monthly', 'quarterly', 'semiannual', 'yearly'
  payment_amount NUMERIC
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_existing_sub RECORD;
  v_days_to_add INTEGER;
  v_new_end_date TIMESTAMPTZ;
  v_plan_type TEXT;
BEGIN
  RAISE NOTICE '🎯 Upgrade de assinatura: % para plano %', user_email, plan_name;
  
  -- Buscar user_id
  SELECT user_id INTO v_user_id
  FROM user_approvals
  WHERE email = user_email;
  
  IF v_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Usuário não encontrado');
  END IF;
  
  -- Determinar duração do plano
  CASE plan_name
    WHEN 'monthly' THEN 
      v_days_to_add := 30;
      v_plan_type := 'premium';
    WHEN 'quarterly' THEN 
      v_days_to_add := 90;
      v_plan_type := 'premium';
    WHEN 'semiannual' THEN 
      v_days_to_add := 180;
      v_plan_type := 'premium';
    WHEN 'yearly' THEN 
      v_days_to_add := 365;
      v_plan_type := 'premium';
    ELSE
      RETURN json_build_object('success', false, 'error', 'Plano inválido');
  END CASE;
  
  -- Buscar assinatura existente
  SELECT * INTO v_existing_sub
  FROM subscriptions
  WHERE email = user_email;
  
  IF FOUND THEN
    -- UPGRADE: Somar dias restantes do trial + dias do plano pago
    IF v_existing_sub.status = 'trial' AND v_existing_sub.trial_end_date > NOW() THEN
      -- Somar dias restantes do trial
      v_new_end_date := v_existing_sub.trial_end_date + (v_days_to_add || ' days')::INTERVAL;
      RAISE NOTICE '✅ Somando % dias do trial com % dias do plano = %', 
        EXTRACT(DAY FROM (v_existing_sub.trial_end_date - NOW())), 
        v_days_to_add,
        v_new_end_date;
    ELSIF v_existing_sub.status = 'active' AND v_existing_sub.subscription_end_date > NOW() THEN
      -- Somar dias restantes do plano ativo
      v_new_end_date := v_existing_sub.subscription_end_date + (v_days_to_add || ' days')::INTERVAL;
      RAISE NOTICE '✅ Renovando assinatura: % + % dias', 
        v_existing_sub.subscription_end_date, 
        v_days_to_add;
    ELSE
      -- Assinatura expirada, começar do zero
      v_new_end_date := NOW() + (v_days_to_add || ' days')::INTERVAL;
      RAISE NOTICE '✅ Nova assinatura: % dias a partir de agora', v_days_to_add;
    END IF;
    
    -- Atualizar assinatura existente
    UPDATE subscriptions
    SET 
      status = 'active',
      plan_type = v_plan_type,
      subscription_start_date = NOW(),
      subscription_end_date = v_new_end_date,
      trial_end_date = NULL,  -- Remover trial ao fazer upgrade
      updated_at = NOW()
    WHERE email = user_email;
    
  ELSE
    -- Criar nova assinatura paga
    v_new_end_date := NOW() + (v_days_to_add || ' days')::INTERVAL;
    
    INSERT INTO subscriptions (
      user_id,
      email,
      status,
      plan_type,
      subscription_start_date,
      subscription_end_date,
      created_at,
      updated_at
    ) VALUES (
      v_user_id,
      user_email,
      'active',
      v_plan_type,
      NOW(),
      v_new_end_date,
      NOW(),
      NOW()
    );
    
    RAISE NOTICE '✅ Nova assinatura criada: % dias', v_days_to_add;
  END IF;
  
  -- Registrar pagamento
  INSERT INTO payments (
    user_id,
    email,
    amount,
    plan_type,
    payment_method,
    status,
    created_at
  ) VALUES (
    v_user_id,
    user_email,
    payment_amount,
    plan_name,
    'mercadopago',
    'completed',
    NOW()
  );
  
  RETURN json_build_object(
    'success', true,
    'message', 'Upgrade realizado com sucesso',
    'total_days', v_days_to_add,
    'new_end_date', v_new_end_date
  );
END;
$$;

GRANT EXECUTE ON FUNCTION upgrade_to_paid_subscription(TEXT, TEXT, NUMERIC) TO authenticated;
GRANT EXECUTE ON FUNCTION upgrade_to_paid_subscription(TEXT, TEXT, NUMERIC) TO anon;

SELECT '✅ Função upgrade_to_paid_subscription criada/atualizada!' as resultado;

-- 3️⃣ Testar a função (APENAS SIMULAÇÃO - NÃO VAI EXECUTAR)
SELECT 
  '🧪 EXEMPLO DE USO:' as info,
  'upgrade_to_paid_subscription(''email@exemplo.com'', ''monthly'', 29.90)' as comando,
  'Isso vai: 1) Converter trial em premium, 2) Somar dias restantes do trial + 30 dias, 3) Registrar pagamento' as descricao;
