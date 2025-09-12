-- CRIAR user_subscriptions (só esta tabela está faltando)
-- A tabela subscriptions já existe

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

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_email ON user_subscriptions(email);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON user_subscriptions(status);

-- RLS
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Política para visualizar próprios dados
DROP POLICY IF EXISTS "Users can view own subscription status" ON user_subscriptions;
CREATE POLICY "Users can view own subscription status" ON user_subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- Política para atualizar próprios dados
DROP POLICY IF EXISTS "Users can update own subscription status" ON user_subscriptions;
CREATE POLICY "Users can update own subscription status" ON user_subscriptions
    FOR UPDATE USING (auth.uid() = user_id);

-- Verificar se foi criada
SELECT 
    'user_subscriptions criada!' as resultado,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name = 'user_subscriptions';