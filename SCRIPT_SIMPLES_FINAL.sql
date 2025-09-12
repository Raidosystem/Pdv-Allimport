-- SCRIPT SIMPLES PARA CRIAR APENAS O NECESSÁRIO
-- Não vamos mexer na tabela subscriptions existente

-- 1. Criar apenas a tabela user_subscriptions
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
    CONSTRAINT user_subscriptions_email_unique UNIQUE (email)
);

-- 2. Inserir dados para o admin
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

-- 3. Verificar resultado
SELECT 
    'SUCESSO! TABELA CRIADA E DADOS INSERIDOS!' as resultado,
    us.email,
    us.status,
    us.access_allowed,
    us.has_subscription,
    us.days_remaining,
    'Subscription já existe e está ativa' as obs
FROM user_subscriptions us
WHERE us.email = 'assistenciaallimport10@gmail.com';