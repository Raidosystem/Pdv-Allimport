-- =============================================
-- DEPLOY BÁSICO SUPABASE - PDV ALLIMPORT  
-- Apenas comandos essenciais
-- =============================================

-- 1. ATUALIZAR PREÇO PARA R$ 59,90
UPDATE public.subscriptions 
SET payment_amount = 59.90, updated_at = NOW()
WHERE payment_amount = 29.90;

-- 2. CRIAR TABELA DE PAGAMENTOS MERCADO PAGO
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

-- 3. ATIVAR SEGURANÇA
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- 4. POLÍTICA BÁSICA
CREATE POLICY "anyone_can_insert_payments" ON public.payments FOR INSERT WITH CHECK (true);

-- 5. FUNÇÃO PARA ATIVAR ASSINATURA
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
    SELECT id INTO target_user_id FROM auth.users WHERE email = user_email;
    
    IF target_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Usuário não encontrado');
    END IF;
    
    UPDATE public.subscriptions SET 
        status = 'active',
        payment_amount = 59.90,
        subscription_start_date = NOW(),
        subscription_end_date = NOW() + INTERVAL '30 days',
        payment_status = 'paid',
        payment_id = activate_subscription_after_payment.payment_id,
        updated_at = NOW()
    WHERE user_id = target_user_id;
    
    RETURN json_build_object('success', true, 'user_id', target_user_id);
END;
$$;

-- VERIFICAÇÃO
SELECT 'DEPLOY CONCLUÍDO!' as status;
