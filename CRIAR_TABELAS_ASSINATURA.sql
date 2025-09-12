-- CRIAR TABELAS DE ASSINATURA
-- Execute este script para criar as tabelas necessárias

-- 1. Criar tabela user_subscriptions
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

-- 2. Criar tabela subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    status TEXT NOT NULL DEFAULT 'inactive',
    plan_type TEXT DEFAULT 'monthly',
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    payment_method TEXT,
    amount_paid DECIMAL(10,2) DEFAULT 0.00,
    payment_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT subscriptions_user_id_unique UNIQUE (user_id),
    CONSTRAINT subscriptions_status_check CHECK (status IN ('active', 'inactive', 'expired', 'trial', 'cancelled')),
    CONSTRAINT subscriptions_plan_check CHECK (plan_type IN ('monthly', 'yearly', 'admin_premium', 'trial'))
);

-- 3. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_email ON user_subscriptions(email);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);

-- 4. Configurar RLS (Row Level Security) se necessário
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- 5. Políticas básicas de RLS (usuário só vê seus próprios dados)
DROP POLICY IF EXISTS "Users can view own subscription status" ON user_subscriptions;
CREATE POLICY "Users can view own subscription status" ON user_subscriptions
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own subscription status" ON user_subscriptions;
CREATE POLICY "Users can update own subscription status" ON user_subscriptions
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view own subscriptions" ON subscriptions;
CREATE POLICY "Users can view own subscriptions" ON subscriptions
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own subscriptions" ON subscriptions;
CREATE POLICY "Users can update own subscriptions" ON subscriptions
    FOR UPDATE USING (auth.uid() = user_id);

-- 6. Verificar se as tabelas foram criadas
SELECT 
    'Tabelas criadas com sucesso!' as resultado,
    table_name,
    'Criada' as status
FROM information_schema.tables 
WHERE table_schema = 'public'
AND table_name IN ('user_subscriptions', 'subscriptions')
ORDER BY table_name;