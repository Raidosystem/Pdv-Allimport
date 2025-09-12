-- ALTERNATIVA MANUAL - EXECUTE UM POR VEZ

-- PASSO 1: Execute só esta linha primeiro
CREATE TABLE IF NOT EXISTS user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    email TEXT,
    status TEXT,
    access_allowed BOOLEAN,
    has_subscription BOOLEAN,
    days_remaining INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- PASSO 2: Depois execute só esta linha
INSERT INTO user_subscriptions VALUES (
    gen_random_uuid(),
    'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
    'assistenciaallimport10@gmail.com',
    'active',
    true,
    true,
    25,
    NOW(),
    NOW()
);

-- PASSO 3: Por último, execute esta verificação
SELECT * FROM user_subscriptions WHERE email = 'assistenciaallimport10@gmail.com';