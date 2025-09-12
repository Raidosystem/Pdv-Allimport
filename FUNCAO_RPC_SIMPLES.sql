-- FUNÇÃO RPC SIMPLES PARA EVITAR TRIGGERS
-- Esta versão evita problemas com campos que não existem

CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS TABLE(
    access_allowed BOOLEAN,
    has_subscription BOOLEAN,
    status TEXT,
    days_remaining INTEGER,
    subscription_id UUID
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(us.access_allowed, false) as access_allowed,
        COALESCE(us.has_subscription, false) as has_subscription,
        COALESCE(us.status, 'inactive') as status,
        COALESCE(us.days_remaining, 0) as days_remaining,
        s.id as subscription_id
    FROM user_subscriptions us
    LEFT JOIN subscriptions s ON s.user_id = us.user_id
    WHERE us.email = user_email
    LIMIT 1;
    
    -- Se não encontrou nada, retornar valores padrão
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT 
            false as access_allowed,
            false as has_subscription,
            'inactive'::TEXT as status,
            0 as days_remaining,
            NULL::UUID as subscription_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Testar
SELECT * FROM check_subscription_status('assistenciaallimport10@gmail.com');