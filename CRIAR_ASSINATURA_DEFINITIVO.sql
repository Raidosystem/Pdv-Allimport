-- SCRIPT DEFINITIVO PARA CRIAR ASSINATURA DE TESTE
-- Execute depois de verificar que o usuário existe

-- Criar assinatura para o admin (25 dias para testar countdown)
WITH admin_user AS (
    SELECT id, email 
    FROM auth.users 
    WHERE email = 'assistenciaallimport10@gmail.com'
    LIMIT 1
)
INSERT INTO user_subscriptions (
    user_id, email, status, access_allowed, has_subscription, 
    days_remaining, created_at, updated_at
)
SELECT 
    id, email, 'active', true, true, 
    25, NOW() - INTERVAL '6 days', NOW()
FROM admin_user
ON CONFLICT (user_id) DO UPDATE SET
    status = 'active',
    access_allowed = true,
    has_subscription = true,
    days_remaining = 25,
    created_at = NOW() - INTERVAL '6 days',
    updated_at = NOW();

-- Criar subscription detalhada
WITH admin_user AS (
    SELECT id 
    FROM auth.users 
    WHERE email = 'assistenciaallimport10@gmail.com'
    LIMIT 1
)
INSERT INTO subscriptions (
    user_id, status, plan_type, start_date, end_date,
    payment_method, amount_paid, created_at, updated_at
)
SELECT 
    id, 'active', 'monthly', 
    NOW() - INTERVAL '6 days', NOW() + INTERVAL '25 days',
    'admin_test', 99.90, NOW() - INTERVAL '6 days', NOW()
FROM admin_user
ON CONFLICT (user_id) DO UPDATE SET
    status = 'active',
    plan_type = 'monthly',
    start_date = NOW() - INTERVAL '6 days',
    end_date = NOW() + INTERVAL '25 days',
    updated_at = NOW();

-- Verificar resultado
SELECT 
    'SUCESSO!' as resultado,
    us.email,
    us.status,
    us.days_remaining as dias_restantes,
    s.plan_type
FROM user_subscriptions us
JOIN subscriptions s ON s.user_id = us.user_id
WHERE us.email = 'assistenciaallimport10@gmail.com';