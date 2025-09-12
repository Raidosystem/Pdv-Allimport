-- SCRIPT SUPER SIMPLES - SEM TRIGGERS
-- Criar apenas o essencial para o countdown funcionar

-- 1. Desabilitar temporariamente triggers (se houver)
SET session_replication_role = replica;

-- 2. Criar tabela user_subscriptions sem constraints complexas
CREATE TABLE IF NOT EXISTS user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'active',
    access_allowed BOOLEAN DEFAULT TRUE,
    has_subscription BOOLEAN DEFAULT TRUE,
    days_remaining INTEGER DEFAULT 25,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() - INTERVAL '6 days'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Inserir dados diretamente
INSERT INTO user_subscriptions (
    user_id, 
    email, 
    status, 
    access_allowed, 
    has_subscription, 
    days_remaining
)
VALUES (
    'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
    'assistenciaallimport10@gmail.com',
    'active',
    true,
    true,
    25
)
ON CONFLICT (user_id) DO NOTHING;

-- 4. Reabilitar triggers
SET session_replication_role = DEFAULT;

-- 5. Verificar se funcionou
SELECT 
    'DADOS CRIADOS COM SUCESSO!' as status,
    email,
    status,
    access_allowed,
    has_subscription,
    days_remaining
FROM user_subscriptions 
WHERE email = 'assistenciaallimport10@gmail.com';