-- EXECUTAR NO SUPABASE SQL EDITOR
-- Script para criar dados de assinatura de teste

-- PASSO 1: Alterar este email para o seu email de usuário
-- Substitua pelo email que você usa para fazer login
DO $$
DECLARE
    test_email TEXT := 'assistenciaallimport10@gmail.com'; -- <<<< ALTERE ESTE EMAIL
    user_uuid UUID;
BEGIN
    -- Buscar o ID do usuário
    SELECT id INTO user_uuid 
    FROM auth.users 
    WHERE email = test_email;
    
    IF user_uuid IS NULL THEN
        RAISE NOTICE 'Usuário com email % não encontrado. Criando usuário...', test_email;
        
        -- Criar usuário na tabela auth.users
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            invited_at,
            confirmation_token,
            confirmation_sent_at,
            recovery_token,
            recovery_sent_at,
            email_change_token_new,
            email_change,
            email_change_sent_at,
            last_sign_in_at,
            raw_app_meta_data,
            raw_user_meta_data,
            is_super_admin,
            created_at,
            updated_at,
            phone,
            phone_confirmed_at,
            phone_change,
            phone_change_token,
            phone_change_sent_at,
            email_change_token_current,
            email_change_confirm_status,
            banned_until,
            reauthentication_token,
            reauthentication_sent_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            gen_random_uuid(),
            'authenticated',
            'authenticated',
            test_email,
            crypt('123456', gen_salt('bf')), -- senha padrão: 123456
            NOW(),
            NULL,
            '',
            NULL,
            '',
            NULL,
            '',
            '',
            NULL,
            NOW(),
            '{"provider": "email", "providers": ["email"]}',
            '{}',
            FALSE,
            NOW(),
            NOW(),
            NULL,
            NULL,
            '',
            '',
            NULL,
            '',
            0,
            NULL,
            '',
            NULL
        ) RETURNING id INTO user_uuid;
        
        RAISE NOTICE 'Usuário criado com ID: %', user_uuid;
    END IF;
    
    RAISE NOTICE 'Criando assinatura para usuário: % (ID: %)', test_email, user_uuid;
    
    -- Inserir/atualizar user_subscriptions
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
    
    -- Inserir/atualizar subscriptions
    INSERT INTO subscriptions (
        user_id, status, plan_type, start_date, end_date,
        payment_method, amount_paid, created_at, updated_at
    ) VALUES (
        user_uuid, 'active', 'monthly', 
        NOW() - INTERVAL '6 days', NOW() + INTERVAL '25 days',
        'test', 99.90, NOW() - INTERVAL '6 days', NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        status = 'active',
        plan_type = 'monthly',
        start_date = NOW() - INTERVAL '6 days',
        end_date = NOW() + INTERVAL '25 days',
        payment_method = 'test',
        amount_paid = 99.90,
        updated_at = NOW();
    
    RAISE NOTICE 'Assinatura criada com sucesso!';
END $$;

-- Verificar os dados criados
SELECT 
    'Dados criados:' as status,
    us.email,
    us.status,
    us.days_remaining,
    us.created_at::date as inicio,
    s.end_date::date as fim
FROM user_subscriptions us
JOIN subscriptions s ON s.user_id = us.user_id
WHERE us.email = 'assistenciaallimport10@gmail.com'; -- Altere aqui também se mudou o email acima