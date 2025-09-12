-- SCRIPT SIMPLES - Execute este se o anterior não funcionar
-- Primeiro execute este para ver se já existe algum usuário:

-- PASSO 1: Ver usuários existentes
SELECT 'Usuários existentes:' as info, email, id 
FROM auth.users 
LIMIT 5;

-- PASSO 2: Se não houver usuários, use qualquer email existente ou execute:
-- (Altere o email abaixo)

-- Criar assinatura para usuário existente
INSERT INTO user_subscriptions (
    user_id,
    email,
    status,
    access_allowed,
    has_subscription,
    days_remaining,
    created_at,
    updated_at
) 
SELECT 
    u.id,
    u.email,
    'active',
    true,
    true,
    25,
    NOW() - INTERVAL '6 days',
    NOW()
FROM auth.users u
WHERE u.email = 'assistenciaallimport10@gmail.com' -- Altere este email
LIMIT 1
ON CONFLICT (user_id) DO UPDATE SET
    status = 'active',
    access_allowed = true,
    has_subscription = true,
    days_remaining = 25,
    created_at = NOW() - INTERVAL '6 days',
    updated_at = NOW();

-- Criar subscription detalhada
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
)
SELECT 
    u.id,
    'active',
    'monthly',
    NOW() - INTERVAL '6 days',
    NOW() + INTERVAL '25 days',
    'test',
    99.90,
    NOW() - INTERVAL '6 days',
    NOW()
FROM auth.users u
WHERE u.email = 'assistenciaallimport10@gmail.com' -- Altere este email
LIMIT 1
ON CONFLICT (user_id) DO UPDATE SET
    status = 'active',
    plan_type = 'monthly',
    start_date = NOW() - INTERVAL '6 days',
    end_date = NOW() + INTERVAL '25 days',
    updated_at = NOW();

-- Verificar resultado
SELECT 
    'Resultado:' as info,
    us.email,
    us.status,
    us.days_remaining,
    s.plan_type
FROM user_subscriptions us
JOIN subscriptions s ON s.user_id = us.user_id
WHERE us.email = 'assistenciaallimport10@gmail.com'; -- Altere este email