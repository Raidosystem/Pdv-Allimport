-- =============================================
-- DEPLOY SUPABASE SEGURO - Versão com verificações
-- =============================================

-- 1. ATUALIZAR PREÇO PARA R$ 59,90 (apenas se necessário)
UPDATE public.subscriptions 
SET payment_amount = 59.90, updated_at = NOW()
WHERE payment_amount != 59.90;

-- 2. CRIAR TABELA DE PAGAMENTOS (se não existir)
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    mp_payment_id TEXT NOT NULL UNIQUE,
    mp_status TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payer_email TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id),
    webhook_data JSONB
);

-- 3. ATIVAR SEGURANÇA (se ainda não estiver)
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- 4. REMOVER POLÍTICAS EXISTENTES E RECRIAR
DROP POLICY IF EXISTS "anyone_can_insert_payments" ON public.payments;
DROP POLICY IF EXISTS "users_can_view_own_payments" ON public.payments;
DROP POLICY IF EXISTS "admins_can_view_all_payments" ON public.payments;

-- 5. CRIAR POLÍTICAS DE SEGURANÇA
CREATE POLICY "anyone_can_insert_payments" ON public.payments 
    FOR INSERT WITH CHECK (true);

CREATE POLICY "users_can_view_own_payments" ON public.payments
    FOR SELECT USING (
        auth.uid() = user_id OR 
        auth.jwt()->>'email' = payer_email
    );

CREATE POLICY "admins_can_view_all_payments" ON public.payments
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- 6. FUNÇÃO PARA ATIVAR ASSINATURA (substituir se existir)
CREATE OR REPLACE FUNCTION public.activate_subscription_after_payment(
    user_email TEXT,
    payment_id TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
BEGIN
    -- Buscar usuário pelo email
    SELECT id INTO target_user_id FROM auth.users WHERE email = user_email;
    
    IF target_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Usuário não encontrado');
    END IF;
    
    -- Atualizar assinatura
    UPDATE public.subscriptions SET 
        status = 'active',
        payment_amount = 59.90,
        subscription_start_date = NOW(),
        subscription_end_date = NOW() + INTERVAL '30 days',
        payment_status = 'paid',
        payment_id = activate_subscription_after_payment.payment_id,
        updated_at = NOW()
    WHERE user_id = target_user_id;
    
    -- Se não existir assinatura, criar uma nova
    IF NOT FOUND THEN
        INSERT INTO public.subscriptions (
            user_id, email, status, payment_amount, 
            subscription_start_date, subscription_end_date, 
            payment_status, payment_id, created_at, updated_at
        ) VALUES (
            target_user_id, user_email, 'active', 59.90,
            NOW(), NOW() + INTERVAL '30 days',
            'paid', activate_subscription_after_payment.payment_id, NOW(), NOW()
        );
    END IF;
    
    RETURN json_build_object('success', true, 'user_id', target_user_id);
END;
$$;

-- 7. VERIFICAÇÕES FINAIS
SELECT 
    'Tabela payments criada: ' || 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') 
         THEN 'SIM' ELSE 'NÃO' END as payments_table;

SELECT 
    'Preços atualizados: ' || COUNT(*) || ' registros com R$ 59,90' 
FROM public.subscriptions WHERE payment_amount = 59.90;

SELECT 'DEPLOY SEGURO CONCLUÍDO!' as status;
