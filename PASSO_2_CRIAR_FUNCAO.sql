-- ========================================
-- PASSO 2: CRIAR FUNÇÃO DE ATIVAÇÃO (15 DIAS)
-- ========================================
-- Execute este SQL agora que as colunas já existem

CREATE OR REPLACE FUNCTION activate_user_after_email_verification(
  user_email TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  trial_end_date TIMESTAMPTZ;
  result_data JSONB;
BEGIN
  RAISE NOTICE '🎯 Ativando usuário: %', user_email;

  -- Calcular 15 dias de teste a partir de AGORA
  trial_end_date := NOW() + INTERVAL '15 days';
  
  RAISE NOTICE '📅 Data de fim do teste: %', trial_end_date;

  -- Buscar assinatura existente
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;

  IF NOT FOUND THEN
    -- Criar nova assinatura com 15 dias de teste
    RAISE NOTICE '✨ Criando nova assinatura com 15 dias de teste';
    
    INSERT INTO public.subscriptions (
      email,
      status,
      subscription_start_date,
      subscription_end_date,
      trial_start_date,
      trial_end_date,
      email_verified,
      created_at,
      updated_at
    ) VALUES (
      user_email,
      'trial',
      NOW(),
      trial_end_date,
      NOW(),
      trial_end_date,
      TRUE,
      NOW(),
      NOW()
    ) RETURNING * INTO subscription_record;
    
    RAISE NOTICE '✅ Assinatura criada! ID: %', subscription_record.id;
  ELSE
    -- Atualizar assinatura existente para ativar teste
    RAISE NOTICE '🔄 Atualizando assinatura existente: %', subscription_record.id;
    
    UPDATE public.subscriptions 
    SET 
      email_verified = TRUE,
      status = 'trial',
      subscription_start_date = COALESCE(subscription_start_date, NOW()),
      subscription_end_date = trial_end_date,
      trial_start_date = COALESCE(trial_start_date, NOW()),
      trial_end_date = trial_end_date,
      updated_at = NOW()
    WHERE id = subscription_record.id
    RETURNING * INTO subscription_record;
    
    RAISE NOTICE '✅ Assinatura atualizada!';
  END IF;

  -- Preparar resposta
  result_data := jsonb_build_object(
    'success', TRUE,
    'message', 'Email verificado e 15 dias de teste ativados!',
    'subscription', jsonb_build_object(
      'id', subscription_record.id,
      'email', subscription_record.email,
      'status', subscription_record.status,
      'trial_end_date', subscription_record.subscription_end_date,
      'subscription_end_date', subscription_record.subscription_end_date,
      'days_remaining', EXTRACT(DAY FROM (subscription_record.subscription_end_date - NOW()))
    )
  );

  RAISE NOTICE '📊 Resultado: %', result_data;

  RETURN result_data;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro: %', SQLERRM;
    RETURN jsonb_build_object(
      'success', FALSE,
      'error', SQLERRM
    );
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO anon;

COMMENT ON FUNCTION activate_user_after_email_verification(TEXT) IS 
'Ativa usuário após verificação de email, concedendo 15 dias de teste gratuito';

-- ✅ Função criada com sucesso!
-- Agora execute o PASSO 3 para corrigir seu usuário
