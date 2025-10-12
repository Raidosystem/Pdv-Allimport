-- ========================================
-- FUNÇÃO PARA ATIVAR USUÁRIO APÓS VERIFICAÇÃO DE EMAIL
-- ========================================
-- 
-- Esta função será chamada quando o usuário verificar o código OTP
-- Ela irá:
-- 1. Marcar email_verified como TRUE
-- 2. Ativar a assinatura com 15 dias de teste gratuito
-- 3. Atualizar status para 'active'

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
  RAISE NOTICE 'Ativando usuário após verificação de email: %', user_email;

  -- Calcular data de fim do período de teste (15 dias)
  trial_end_date := NOW() + INTERVAL '15 days';

  -- Buscar assinatura do usuário
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;

  -- Se não existe assinatura, criar uma nova
  IF NOT FOUND THEN
    RAISE NOTICE 'Criando nova assinatura para: %', user_email;
    
    INSERT INTO public.subscriptions (
      email,
      status,
      subscription_start_date,
      subscription_end_date,
      email_verified,
      created_at,
      updated_at
    ) VALUES (
      user_email,
      'trial',  -- Status de teste
      NOW(),
      trial_end_date,
      TRUE,
      NOW(),
      NOW()
    ) RETURNING * INTO subscription_record;
    
    RAISE NOTICE 'Assinatura criada com sucesso! ID: %', subscription_record.id;
  ELSE
    -- Se já existe, atualizar para ativar período de teste
    RAISE NOTICE 'Atualizando assinatura existente ID: %', subscription_record.id;
    
    UPDATE public.subscriptions 
    SET 
      email_verified = TRUE,
      status = 'trial',
      subscription_start_date = CASE 
        WHEN subscription_start_date IS NULL THEN NOW()
        ELSE subscription_start_date
      END,
      subscription_end_date = trial_end_date,
      updated_at = NOW()
    WHERE id = subscription_record.id
    RETURNING * INTO subscription_record;
  END IF;

  -- Preparar resposta
  result_data := jsonb_build_object(
    'success', TRUE,
    'message', 'Email verificado e período de teste ativado com sucesso!',
    'subscription', jsonb_build_object(
      'id', subscription_record.id,
      'email', subscription_record.email,
      'status', subscription_record.status,
      'trial_end_date', subscription_record.subscription_end_date,
      'days_remaining', EXTRACT(DAY FROM (subscription_record.subscription_end_date - NOW()))
    )
  );

  RAISE NOTICE 'Resultado: %', result_data;

  RETURN result_data;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Erro ao ativar usuário: %', SQLERRM;
    RETURN jsonb_build_object(
      'success', FALSE,
      'error', SQLERRM
    );
END;
$$;

-- Comentário da função
COMMENT ON FUNCTION activate_user_after_email_verification(TEXT) IS 
'Ativa o usuário após verificação de email, concedendo 15 dias de teste gratuito';

-- Garantir que a função pode ser executada
GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO anon;

-- ========================================
-- TESTE (DESCOMENTAR PARA TESTAR)
-- ========================================
-- SELECT activate_user_after_email_verification('teste@exemplo.com');
