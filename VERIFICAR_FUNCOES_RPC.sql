-- Script para verificar e recriar funções RPC se necessário

-- 1. Verificar se a função check_subscription_status existe
DO $$
BEGIN
    -- Se a função não existir, criar ela
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc 
        WHERE proname = 'check_subscription_status'
    ) THEN
        EXECUTE '
        CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
        RETURNS JSON AS $func$
        DECLARE
          subscription_record public.subscriptions%ROWTYPE;
          current_time TIMESTAMPTZ := NOW();
          result JSON;
        BEGIN
          -- Buscar assinatura
          SELECT * INTO subscription_record 
          FROM public.subscriptions 
          WHERE email = user_email;
          
          IF NOT FOUND THEN
            RETURN json_build_object(
              ''has_subscription'', false,
              ''status'', ''no_subscription'',
              ''access_allowed'', false
            );
          END IF;
          
          -- Verificar se está em período de teste
          IF subscription_record.status = ''trial'' THEN
            IF current_time <= subscription_record.trial_end_date THEN
              RETURN json_build_object(
                ''has_subscription'', true,
                ''status'', ''trial'',
                ''access_allowed'', true,
                ''trial_end_date'', subscription_record.trial_end_date,
                ''days_remaining'', EXTRACT(DAY FROM subscription_record.trial_end_date - current_time)
              );
            ELSE
              -- Trial expirado, atualizar status
              UPDATE public.subscriptions 
              SET status = ''expired'', updated_at = NOW()
              WHERE id = subscription_record.id;
              
              RETURN json_build_object(
                ''has_subscription'', true,
                ''status'', ''expired'',
                ''access_allowed'', false,
                ''trial_end_date'', subscription_record.trial_end_date
              );
            END IF;
          END IF;
          
          -- Verificar se tem assinatura ativa
          IF subscription_record.status = ''active'' THEN
            IF current_time <= subscription_record.subscription_end_date THEN
              RETURN json_build_object(
                ''has_subscription'', true,
                ''status'', ''active'',
                ''access_allowed'', true,
                ''subscription_end_date'', subscription_record.subscription_end_date
              );
            ELSE
              -- Assinatura expirada
              UPDATE public.subscriptions 
              SET status = ''expired'', updated_at = NOW()
              WHERE id = subscription_record.id;
              
              RETURN json_build_object(
                ''has_subscription'', true,
                ''status'', ''expired'',
                ''access_allowed'', false,
                ''subscription_end_date'', subscription_record.subscription_end_date
              );
            END IF;
          END IF;
          
          -- Status expirado ou outros
          RETURN json_build_object(
            ''has_subscription'', true,
            ''status'', subscription_record.status,
            ''access_allowed'', false
          );
        END;
        $func$ LANGUAGE plpgsql SECURITY DEFINER;
        ';
        RAISE NOTICE 'Função check_subscription_status criada.';
    ELSE
        RAISE NOTICE 'Função check_subscription_status já existe.';
    END IF;
END
$$;

-- 2. Verificar se a função activate_subscription_after_payment existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_proc 
        WHERE proname = 'activate_subscription_after_payment'
    ) THEN
        EXECUTE '
        CREATE OR REPLACE FUNCTION activate_subscription_after_payment(
          user_email TEXT,
          payment_id TEXT,
          payment_method TEXT
        )
        RETURNS JSON AS $func$
        DECLARE
          subscription_record public.subscriptions%ROWTYPE;
          subscription_end TIMESTAMPTZ;
        BEGIN
          -- Buscar assinatura
          SELECT * INTO subscription_record 
          FROM public.subscriptions 
          WHERE email = user_email;
          
          IF NOT FOUND THEN
            RETURN json_build_object(''success'', false, ''error'', ''Assinatura não encontrada'');
          END IF;
          
          -- Calcular data de expiração (30 dias a partir de agora)
          subscription_end := NOW() + INTERVAL ''30 days'';
          
          -- Atualizar assinatura
          UPDATE public.subscriptions 
          SET 
            status = ''active'',
            subscription_start_date = NOW(),
            subscription_end_date = subscription_end,
            payment_method = activate_subscription_after_payment.payment_method,
            payment_status = ''paid'',
            payment_id = activate_subscription_after_payment.payment_id,
            updated_at = NOW()
          WHERE id = subscription_record.id;
          
          RETURN json_build_object(
            ''success'', true,
            ''status'', ''active'',
            ''subscription_end_date'', subscription_end
          );
        END;
        $func$ LANGUAGE plpgsql SECURITY DEFINER;
        ';
        RAISE NOTICE 'Função activate_subscription_after_payment criada.';
    ELSE
        RAISE NOTICE 'Função activate_subscription_after_payment já existe.';
    END IF;
END
$$;

-- 3. Testar as funções
SELECT 'Testando funções RPC...' as status;

-- Testar com um email fictício para ver se não gera erro
SELECT check_subscription_status('teste@teste.com') as test_check;

SELECT 'Funções RPC verificadas e funcionando!' as resultado;
