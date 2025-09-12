-- CRIAR FUNÇÃO RPC PARA CHECK_SUBSCRIPTION_STATUS
-- Esta função está sendo chamada pela aplicação mas não existe

CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS JSON AS $$
DECLARE
    result JSON;
    subscription_data RECORD;
    user_data RECORD;
BEGIN
    -- Buscar dados do usuário e assinatura
    SELECT 
        us.status,
        us.access_allowed,
        us.has_subscription,
        us.days_remaining,
        us.created_at,
        s.id as subscription_id,
        s.status as subscription_status
    INTO subscription_data
    FROM user_subscriptions us
    LEFT JOIN subscriptions s ON s.user_id = us.user_id
    WHERE us.email = user_email;
    
    -- Se não encontrou dados na user_subscriptions, verificar se existe na auth.users
    IF NOT FOUND THEN
        SELECT id INTO user_data FROM auth.users WHERE email = user_email;
        
        IF FOUND THEN
            -- Usuário existe mas não tem dados de assinatura
            result := json_build_object(
                'access_allowed', false,
                'has_subscription', false,
                'status', 'inactive',
                'days_remaining', 0,
                'subscription_id', null,
                'message', 'No subscription found'
            );
        ELSE
            -- Usuário não existe
            result := json_build_object(
                'access_allowed', false,
                'has_subscription', false,
                'status', 'not_found',
                'days_remaining', 0,
                'subscription_id', null,
                'message', 'User not found'
            );
        END IF;
    ELSE
        -- Dados encontrados
        result := json_build_object(
            'access_allowed', subscription_data.access_allowed,
            'has_subscription', subscription_data.has_subscription,
            'status', subscription_data.status,
            'days_remaining', subscription_data.days_remaining,
            'subscription_id', subscription_data.subscription_id,
            'subscription_status', subscription_data.subscription_status,
            'created_at', subscription_data.created_at,
            'message', 'Subscription found'
        );
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Testar a função
SELECT check_subscription_status('assistenciaallimport10@gmail.com') as test_result;