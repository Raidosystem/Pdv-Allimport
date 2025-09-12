-- Script para criar dados de teste de assinatura ativa
-- Execute este script no Supabase SQL Editor

-- 1. Primeiro, verificar se existe um usuário para teste
DO $$
DECLARE
    test_user_id UUID;
    test_email TEXT := 'admin@allimport.com'; -- Altere para o seu email de teste
BEGIN
    -- Buscar ID do usuário pelo email
    SELECT id INTO test_user_id 
    FROM auth.users 
    WHERE email = test_email
    LIMIT 1;
    
    IF test_user_id IS NULL THEN
        RAISE NOTICE 'Usuário com email % não encontrado. Crie um usuário primeiro.', test_email;
        RETURN;
    END IF;
    
    RAISE NOTICE 'Usuário encontrado: %', test_user_id;
    
    -- 2. Criar ou atualizar dados na tabela user_subscriptions
    INSERT INTO user_subscriptions (
        user_id,
        email,
        status,
        access_allowed,
        has_subscription,
        days_remaining,
        created_at,
        updated_at
    ) VALUES (
        test_user_id,
        test_email,
        'active',          -- Status ativo
        true,              -- Acesso permitido
        true,              -- Tem assinatura
        25,                -- 25 dias restantes (para testar countdown)
        NOW() - INTERVAL '6 days', -- Criado há 6 dias (restam 25 dos 31)
        NOW()
    )
    ON CONFLICT (user_id) 
    DO UPDATE SET
        status = 'active',
        access_allowed = true,
        has_subscription = true,
        days_remaining = 25,
        created_at = NOW() - INTERVAL '6 days',
        updated_at = NOW();
    
    -- 3. Criar ou atualizar dados na tabela subscriptions (dados completos)
    INSERT INTO subscriptions (
        user_id,
        status,
        plan_type,
        start_date,
        end_date,
        payment_method,
        amount_paid,
        created_at,
        updated_at
    ) VALUES (
        test_user_id,
        'active',
        'monthly',
        NOW() - INTERVAL '6 days',     -- Iniciou há 6 dias
        NOW() + INTERVAL '25 days',    -- Termina em 25 dias
        'test',
        99.90,
        NOW() - INTERVAL '6 days',
        NOW()
    )
    ON CONFLICT (user_id) 
    DO UPDATE SET
        status = 'active',
        plan_type = 'monthly',
        start_date = NOW() - INTERVAL '6 days',
        end_date = NOW() + INTERVAL '25 days',
        payment_method = 'test',
        amount_paid = 99.90,
        updated_at = NOW();
    
    RAISE NOTICE 'Dados de assinatura criados/atualizados com sucesso!';
    
    -- 4. Verificar os dados criados
    RAISE NOTICE 'Verificando dados criados:';
    
    -- Verificar user_subscriptions
    PERFORM 1 FROM user_subscriptions WHERE user_id = test_user_id;
    IF FOUND THEN
        RAISE NOTICE 'user_subscriptions: OK';
    END IF;
    
    -- Verificar subscriptions
    PERFORM 1 FROM subscriptions WHERE user_id = test_user_id;
    IF FOUND THEN
        RAISE NOTICE 'subscriptions: OK';
    END IF;
    
END $$;

-- 5. Verificar os resultados
SELECT 
    'user_subscriptions' as tabela,
    us.email,
    us.status,
    us.access_allowed,
    us.has_subscription,
    us.days_remaining,
    us.created_at
FROM user_subscriptions us
WHERE us.email = 'admin@allimport.com'

UNION ALL

SELECT 
    'subscriptions' as tabela,
    au.email,
    s.status::text,
    NULL as access_allowed,
    NULL as has_subscription,
    NULL as days_remaining,
    s.created_at
FROM subscriptions s
JOIN auth.users au ON au.id = s.user_id
WHERE au.email = 'admin@allimport.com';