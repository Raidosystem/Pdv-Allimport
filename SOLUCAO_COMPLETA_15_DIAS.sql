-- ========================================
-- SOLUÇÃO COMPLETA: 15 DIAS GRATUITOS
-- ========================================
-- Execute TODO este SQL de uma vez no Supabase SQL Editor

-- ========================================
-- PARTE 1: PREPARAR ESTRUTURA DA TABELA
-- ========================================

-- Verificar estrutura atual
DO $$
BEGIN
    RAISE NOTICE '📋 Verificando estrutura da tabela subscriptions...';
END $$;

-- Adicionar colunas que podem estar faltando
ALTER TABLE public.subscriptions 
ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS trial_start_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS trial_end_date TIMESTAMPTZ;

-- ========================================
-- PARTE 2: CRIAR/ATUALIZAR FUNÇÃO DE ATIVAÇÃO
-- ========================================

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

-- ========================================
-- PARTE 3: GARANTIR PERMISSÕES
-- ========================================

GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO anon;

COMMENT ON FUNCTION activate_user_after_email_verification(TEXT) IS 
'Ativa usuário após verificação de email, concedendo 15 dias de teste gratuito';

-- ========================================
-- PARTE 4: TESTAR A FUNÇÃO
-- ========================================

-- Testar com email de exemplo
DO $$
DECLARE
  result JSONB;
BEGIN
  RAISE NOTICE '🧪 Testando função com email de teste...';
  result := activate_user_after_email_verification('teste-funcao@exemplo.com');
  RAISE NOTICE '✅ Resultado do teste: %', result;
END $$;

-- ========================================
-- PARTE 5: VERIFICAR RESULTADO
-- ========================================

SELECT 
  email,
  status,
  email_verified,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes,
  subscription_start_date,
  subscription_end_date
FROM public.subscriptions
WHERE email = 'teste-funcao@exemplo.com';

-- ========================================
-- ✅ PRONTO! A função está criada e testada
-- ========================================

-- Para corrigir um usuário específico, use:
-- SELECT activate_user_after_email_verification('seu-email@real.com');

-- Ou para corrigir manualmente:
-- UPDATE public.subscriptions
-- SET 
--   status = 'trial',
--   subscription_start_date = NOW(),
--   subscription_end_date = NOW() + INTERVAL '15 days',
--   trial_start_date = NOW(),
--   trial_end_date = NOW() + INTERVAL '15 days',
--   email_verified = TRUE,
--   updated_at = NOW()
-- WHERE email = 'seu-email@real.com';
