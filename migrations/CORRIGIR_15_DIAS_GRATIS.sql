-- ========================================
-- VERIFICAR E CORRIGIR SISTEMA DE 15 DIAS GRATUITOS
-- ========================================
-- Execute este SQL no Supabase SQL Editor

-- 1. Verificar se a função existe
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'activate_user_after_email_verification';

-- 2. Verificar assinaturas recentes
SELECT 
  email,
  status,
  email_verified,
  subscription_start_date,
  subscription_end_date,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes,
  created_at
FROM public.subscriptions
ORDER BY created_at DESC
LIMIT 10;

-- 3. CORRIGIR: Recriar função de ativação com 15 dias
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
      subscription_start_date = NOW(),
      subscription_end_date = trial_end_date,
      trial_start_date = NOW(),
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

-- 4. Garantir permissões
GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO anon;

-- 5. Comentário
COMMENT ON FUNCTION activate_user_after_email_verification(TEXT) IS 
'Ativa usuário após verificação de email, concedendo 15 dias de teste gratuito';

-- 6. TESTAR: Ativar 15 dias para um usuário específico
-- Descomente e substitua o email para testar:
-- SELECT activate_user_after_email_verification('seu-email@exemplo.com');

-- 7. CORRIGIR usuário que não recebeu os 15 dias
-- Descomente e substitua o email para corrigir manualmente:
-- UPDATE public.subscriptions
-- SET 
--   status = 'trial',
--   subscription_start_date = NOW(),
--   subscription_end_date = NOW() + INTERVAL '15 days',
--   trial_start_date = NOW(),
--   trial_end_date = NOW() + INTERVAL '15 days',
--   email_verified = TRUE,
--   updated_at = NOW()
-- WHERE email = 'seu-email@exemplo.com';
