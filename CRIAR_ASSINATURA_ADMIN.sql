-- SCRIPT PARA CRIAR ASSINATURA NO SISTEMA CUSTOMIZADO
-- Use este se os usuários estão em tabela customizada

DO $$
DECLARE
    test_email TEXT := 'assistenciaallimport10@gmail.com'; -- Email do admin
    user_uuid UUID;
    auth_user_id UUID;
BEGIN
    RAISE NOTICE 'Procurando usuário: %', test_email;
    
    -- Primeiro tentar auth.users
    SELECT id INTO auth_user_id 
    FROM auth.users 
    WHERE email = test_email;
    
    IF auth_user_id IS NOT NULL THEN
        RAISE NOTICE 'Usuário encontrado em auth.users: %', auth_user_id;
        user_uuid := auth_user_id;
    ELSE
        -- Tentar tabela usuarios customizada
        SELECT id INTO user_uuid 
        FROM usuarios 
        WHERE email = test_email;
        
        IF user_uuid IS NOT NULL THEN
            RAISE NOTICE 'Usuário encontrado em tabela usuarios: %', user_uuid;
        ELSE
            RAISE EXCEPTION 'Usuário % não encontrado em nenhuma tabela!', test_email;
        END IF;
    END IF;
    
    -- Criar/atualizar user_subscriptions
    INSERT INTO user_subscriptions (
        user_id, email, status, access_allowed, has_subscription, 
        days_remaining, created_at, updated_at
    ) VALUES (
        user_uuid, test_email, 'active', true, true, 
        25, NOW() - INTERVAL '6 days', NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        status = 'active',
        access_allowed = true,
        has_subscription = true,
        days_remaining = 25,
        created_at = NOW() - INTERVAL '6 days',
        updated_at = NOW();
    
    -- Criar/atualizar subscriptions
    INSERT INTO subscriptions (
        user_id, status, plan_type, start_date, end_date,
        payment_method, amount_paid, created_at, updated_at
    ) VALUES (
        user_uuid, 'active', 'monthly', 
        NOW() - INTERVAL '6 days', NOW() + INTERVAL '25 days',
        'admin_test', 99.90, NOW() - INTERVAL '6 days', NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        status = 'active',
        plan_type = 'monthly',
        start_date = NOW() - INTERVAL '6 days',
        end_date = NOW() + INTERVAL '25 days',
        payment_method = 'admin_test',
        amount_paid = 99.90,
        updated_at = NOW();
    
    RAISE NOTICE 'Assinatura criada com sucesso para admin!';
    
END $$;

-- Verificar o resultado
SELECT 
    'ASSINATURA CRIADA' as status,
    us.email,
    us.status,
    us.access_allowed,
    us.has_subscription,
    us.days_remaining,
    us.created_at::date as inicio,
    s.end_date::date as fim,
    s.plan_type
FROM user_subscriptions us
LEFT JOIN subscriptions s ON s.user_id = us.user_id
WHERE us.email = 'assistenciaallimport10@gmail.com';