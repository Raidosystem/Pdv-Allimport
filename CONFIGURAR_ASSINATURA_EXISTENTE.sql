-- CRIAR DADOS DE TESTE USANDO TABELA EXISTENTE
-- Como a tabela subscriptions já existe e tem dados, vamos adaptar

-- 1. Criar apenas a tabela user_subscriptions (que não existe)
CREATE TABLE IF NOT EXISTS user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    email TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'inactive',
    access_allowed BOOLEAN DEFAULT FALSE,
    has_subscription BOOLEAN DEFAULT FALSE,
    days_remaining INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT user_subscriptions_user_id_unique UNIQUE (user_id),
    CONSTRAINT user_subscriptions_email_unique UNIQUE (email),
    CONSTRAINT user_subscriptions_status_check CHECK (status IN ('active', 'inactive', 'expired', 'trial'))
);

-- 2. Inserir dados para o admin baseado na subscription existente
INSERT INTO user_subscriptions (
    user_id, email, status, access_allowed, has_subscription, 
    days_remaining, created_at, updated_at
)
VALUES (
    'f7fdf4cf-7101-45ab-86db-5248a7ac58c1', -- ID do admin
    'assistenciaallimport10@gmail.com',     -- Email do admin
    'active',                               -- Status ativo
    true,                                   -- Acesso permitido
    true,                                   -- Tem assinatura
    25,                                     -- 25 dias para teste
    NOW() - INTERVAL '6 days',             -- Criado há 6 dias
    NOW()
)
ON CONFLICT (user_id) DO UPDATE SET
    status = 'active',
    access_allowed = true,
    has_subscription = true,
    days_remaining = 25,
    created_at = NOW() - INTERVAL '6 days',
    updated_at = NOW();

-- 3. Atualizar a subscription existente para ter dados corretos
UPDATE subscriptions 
SET 
    status = 'active',
    updated_at = NOW()
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 4. Verificar resultado
SELECT 
    'ASSINATURA CONFIGURADA!' as resultado,
    us.email,
    us.status as user_status,
    us.days_remaining,
    s.status as subscription_status,
    s.created_at::date as inicio
FROM user_subscriptions us
JOIN subscriptions s ON s.user_id = us.user_id
WHERE us.email = 'assistenciaallimport10@gmail.com';