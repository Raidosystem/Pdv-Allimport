-- =============================================
-- 🚀 DEPLOY FINAL SUPABASE - PDV ALLIMPORT
-- Execute este SQL no Supabase Dashboard SQL Editor
-- Data: 04/08/2025 23:58 - VERSÃO FINAL
-- =============================================

-- 📋 ETAPA 1: ATUALIZAR PREÇO PARA R$ 59,90
-- =============================================

-- Atualizar valor padrão na tabela
ALTER TABLE public.subscriptions 
ALTER COLUMN payment_amount SET DEFAULT 59.90;

-- Atualizar registros existentes
UPDATE public.subscriptions 
SET payment_amount = 59.90, updated_at = NOW()
WHERE payment_amount = 29.90;

-- =============================================
-- 📋 ETAPA 2: CRIAR/ATUALIZAR TABELA DE PAGAMENTOS
-- =============================================

-- Criar tabela de pagamentos se não existir
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Dados do Mercado Pago
    mp_payment_id TEXT NOT NULL UNIQUE,
    mp_status TEXT NOT NULL,
    mp_status_detail TEXT,
    
    -- Dados do pagamento
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'BRL',
    payment_method TEXT NOT NULL, -- pix, credit_card, debit_card
    payment_type TEXT,
    
    -- Dados do pagador
    payer_email TEXT NOT NULL,
    payer_name TEXT,
    
    -- Relacionamento com usuário
    user_id UUID REFERENCES auth.users(id),
    
    -- Dados completos do webhook
    webhook_data JSONB,
    
    -- Índices
    CONSTRAINT payments_amount_positive CHECK (amount > 0)
);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_payments_mp_payment_id ON public.payments(mp_payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_payer_email ON public.payments(payer_email);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(mp_status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON public.payments(created_at);

-- =============================================
-- 📋 ETAPA 3: POLÍTICAS RLS PARA PAGAMENTOS
-- =============================================

-- Ativar RLS
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Política para usuários verem seus próprios pagamentos
CREATE POLICY "users_can_view_own_payments" ON public.payments
    FOR SELECT USING (
        auth.uid() = user_id OR 
        auth.jwt()->>'email' = payer_email
    );

-- Política para admins verem todos os pagamentos
CREATE POLICY "admins_can_view_all_payments" ON public.payments
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Política para inserção via webhook (service role)
CREATE POLICY "service_can_insert_payments" ON public.payments
    FOR INSERT WITH CHECK (true);

-- Política para atualização via webhook (service role)  
CREATE POLICY "service_can_update_payments" ON public.payments
    FOR UPDATE USING (true);

-- =============================================
-- 📋 ETAPA 4: FUNÇÃO PARA ATIVAR ASSINATURA APÓS PAGAMENTO
-- =============================================

CREATE OR REPLACE FUNCTION public.activate_subscription_after_payment(
    user_email TEXT,
    payment_id TEXT,
    payment_method TEXT DEFAULT 'pix'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
    subscription_record RECORD;
    result JSON;
BEGIN
    -- Buscar user_id pelo email
    SELECT id INTO target_user_id
    FROM auth.users
    WHERE email = user_email;
    
    IF target_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Usuário não encontrado',
            'email', user_email
        );
    END IF;
    
    -- Atualizar pagamento com user_id
    UPDATE public.payments 
    SET user_id = target_user_id,
        updated_at = NOW()
    WHERE mp_payment_id = payment_id;
    
    -- Verificar se já existe assinatura
    SELECT * INTO subscription_record
    FROM public.subscriptions
    WHERE user_id = target_user_id;
    
    IF subscription_record IS NOT NULL THEN
        -- Atualizar assinatura existente
        UPDATE public.subscriptions
        SET 
            status = 'active',
            payment_amount = 59.90,
            payment_method = activate_subscription_after_payment.payment_method,
            subscription_start_date = NOW(),
            subscription_end_date = NOW() + INTERVAL '30 days',
            payment_status = 'paid',
            payment_id = activate_subscription_after_payment.payment_id,
            updated_at = NOW()
        WHERE user_id = target_user_id;
        
        result := json_build_object(
            'success', true,
            'action', 'updated',
            'user_id', target_user_id,
            'email', user_email,
            'payment_id', payment_id,
            'subscription_end', NOW() + INTERVAL '30 days'
        );
    ELSE
        -- Criar nova assinatura
        INSERT INTO public.subscriptions (
            user_id,
            email,
            status,
            payment_amount,
            payment_method,
            subscription_start_date,
            subscription_end_date,
            payment_status,
            payment_id
        ) VALUES (
            target_user_id,
            user_email,
            'active',
            59.90,
            activate_subscription_after_payment.payment_method,
            NOW(),
            NOW() + INTERVAL '30 days',
            'paid',
            activate_subscription_after_payment.payment_id
        );
        
        result := json_build_object(
            'success', true,
            'action', 'created',
            'user_id', target_user_id,
            'email', user_email,
            'payment_id', payment_id,
            'subscription_end', NOW() + INTERVAL '30 days'
        );
    END IF;
    
    RETURN result;
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', SQLERRM,
        'email', user_email,
        'payment_id', payment_id
    );
END;
$$;

-- =============================================
-- 📋 ETAPA 5: TRIGGER PARA UPDATED_AT AUTOMÁTICO
-- =============================================

-- Trigger para payments
DROP TRIGGER IF EXISTS update_payments_updated_at ON public.payments;
CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON public.payments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================
-- 📋 ETAPA 6: VERIFICAÇÕES E VALIDAÇÃO
-- =============================================

-- Verificar assinatura do admin
SELECT 
    'Status da assinatura admin' as info,
    id,
    email,
    status,
    payment_amount,
    subscription_start_date,
    subscription_end_date,
    CASE 
        WHEN subscription_end_date IS NOT NULL THEN
            EXTRACT(DAY FROM (subscription_end_date - NOW()))
        WHEN trial_end_date IS NOT NULL THEN
            EXTRACT(DAY FROM (trial_end_date - NOW()))
        ELSE NULL
    END as days_remaining
FROM public.subscriptions
WHERE email = 'novaradiosystem@outlook.com';

-- Contar registros nas tabelas
SELECT 
    'Contadores' as info,
    (SELECT COUNT(*) FROM public.subscriptions) as total_subscriptions,
    (SELECT COUNT(*) FROM public.payments) as total_payments,
    (SELECT COUNT(*) FROM public.profiles) as total_profiles;

-- Verificar políticas RLS
SELECT 
    tablename,
    policyname,
    cmd,
    permissive
FROM pg_policies
WHERE tablename IN ('subscriptions', 'payments', 'profiles')
ORDER BY tablename, policyname;

-- =============================================
-- 🎉 DEPLOY CONCLUÍDO
-- =============================================

SELECT 
    '✅ DEPLOY SUPABASE CONCLUÍDO COM SUCESSO!' as resultado,
    NOW() as timestamp,
    'PDV Allimport v1.0' as sistema,
    'R$ 59,90/mês' as preco_atual;
