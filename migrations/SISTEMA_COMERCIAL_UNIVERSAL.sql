-- =============================================
-- SISTEMA PDV ALLIMPORT - AUTOMAÇÃO COMERCIAL
-- Para venda do sistema como produto SaaS
-- =============================================

-- ===============================================
-- 1. TABELA DE PLANOS DISPONÍVEIS
-- ===============================================

CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL, -- 'Mensal', 'Trimestral', 'Anual'
    description text,
    price_brl decimal(10,2) NOT NULL,
    days_duration integer NOT NULL, -- 30, 90, 365
    mp_preference_title text, -- Para MercadoPago
    is_active boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);

-- Inserir planos padrão
INSERT INTO public.subscription_plans (name, description, price_brl, days_duration, mp_preference_title, sort_order) VALUES
('Mensal', 'Acesso completo por 30 dias', 49.90, 30, 'PDV Allimport - Plano Mensal', 1),
('Trimestral', 'Acesso completo por 90 dias (economia de 20%)', 119.90, 90, 'PDV Allimport - Plano Trimestral', 2),
('Anual', 'Acesso completo por 365 dias (economia de 40%)', 299.90, 365, 'PDV Allimport - Plano Anual', 3)
ON CONFLICT DO NOTHING;

-- ===============================================
-- 2. TABELA PAYMENTS UNIVERSAL
-- ===============================================

CREATE TABLE IF NOT EXISTS public.payments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    mp_payment_id bigint UNIQUE NOT NULL,
    user_email text NOT NULL,
    plan_id uuid REFERENCES public.subscription_plans(id),
    mp_status text NOT NULL,
    mp_status_detail text,
    payment_method text NOT NULL,
    amount decimal(10,2) NOT NULL,
    currency text DEFAULT 'BRL',
    payer_email text,
    payer_name text,
    payer_document text,
    mp_preference_id text,
    subscription_days_added integer DEFAULT 0,
    webhook_processed_at timestamp with time zone,
    webhook_data jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_payments_mp_payment_id ON public.payments(mp_payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_email ON public.payments(user_email);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(mp_status);
CREATE INDEX IF NOT EXISTS idx_payments_plan_id ON public.payments(plan_id);

-- ===============================================
-- 3. TABELA PAYMENT_RECEIPTS (IDEMPOTÊNCIA)
-- ===============================================

CREATE TABLE IF NOT EXISTS public.payment_receipts (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    mp_payment_id bigint UNIQUE NOT NULL,
    user_email text NOT NULL,
    plan_name text NOT NULL,
    subscription_days_credited integer NOT NULL,
    amount_paid decimal(10,2) NOT NULL,
    processed_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);

-- ===============================================
-- 4. FUNÇÃO UNIVERSAL PARA CRIAR/ATUALIZAR ASSINATURA
-- ===============================================

CREATE OR REPLACE FUNCTION public.create_or_update_subscription(
    p_mp_payment_id bigint,
    p_user_email text,
    p_plan_id uuid DEFAULT NULL,
    p_custom_days integer DEFAULT NULL
)
RETURNS json AS $$
DECLARE
    v_subscription_record record;
    v_plan_record record;
    v_current_end_date timestamp with time zone;
    v_new_end_date timestamp with time zone;
    v_base_date timestamp with time zone;
    v_days_to_add integer;
    v_already_processed boolean := false;
    v_is_new_customer boolean := false;
    v_amount_paid decimal(10,2);
BEGIN
    -- 1. VERIFICAR SE JÁ FOI PROCESSADO
    SELECT EXISTS(
        SELECT 1 FROM public.payment_receipts 
        WHERE mp_payment_id = p_mp_payment_id
    ) INTO v_already_processed;
    
    IF v_already_processed THEN
        RETURN json_build_object(
            'success', true,
            'already_processed', true,
            'message', 'Pagamento já foi processado anteriormente',
            'mp_payment_id', p_mp_payment_id
        );
    END IF;
    
    -- 2. DETERMINAR QUANTOS DIAS ADICIONAR
    IF p_custom_days IS NOT NULL THEN
        v_days_to_add := p_custom_days;
        v_amount_paid := 0;
    ELSIF p_plan_id IS NOT NULL THEN
        SELECT * INTO v_plan_record 
        FROM public.subscription_plans 
        WHERE id = p_plan_id AND is_active = true;
        
        IF NOT FOUND THEN
            RETURN json_build_object(
                'success', false,
                'error', 'Plano não encontrado: ' || p_plan_id,
                'mp_payment_id', p_mp_payment_id
            );
        END IF;
        
        v_days_to_add := v_plan_record.days_duration;
        v_amount_paid := v_plan_record.price_brl;
    ELSE
        -- Padrão: 30 dias
        v_days_to_add := 30;
        v_amount_paid := 49.90;
    END IF;
    
    -- 3. BUSCAR OU CRIAR ASSINATURA
    SELECT * INTO v_subscription_record 
    FROM public.subscriptions 
    WHERE email = p_user_email;
    
    IF NOT FOUND THEN
        -- NOVO CLIENTE - CRIAR ASSINATURA
        v_is_new_customer := true;
        v_base_date := now();
        v_new_end_date := v_base_date + (v_days_to_add || ' days')::interval;
        
        INSERT INTO public.subscriptions (
            email,
            status,
            payment_status,
            subscription_start_date,
            subscription_end_date,
            created_at,
            updated_at
        ) VALUES (
            p_user_email,
            'active',
            'paid',
            v_base_date,
            v_new_end_date,
            now(),
            now()
        );
        
        v_current_end_date := NULL;
    ELSE
        -- CLIENTE EXISTENTE - RENOVAR/ESTENDER
        v_current_end_date := v_subscription_record.subscription_end_date;
        
        -- Se a assinatura está ativa, adicionar aos dias restantes
        -- Se expirou, começar de hoje
        IF v_current_end_date > now() THEN
            v_base_date := v_current_end_date;
        ELSE
            v_base_date := now();
        END IF;
        
        v_new_end_date := v_base_date + (v_days_to_add || ' days')::interval;
        
        -- ATUALIZAR ASSINATURA EXISTENTE
        UPDATE public.subscriptions 
        SET 
            subscription_end_date = v_new_end_date,
            status = 'active',
            payment_status = 'paid',
            updated_at = now()
        WHERE email = p_user_email;
    END IF;
    
    -- 4. REGISTRAR RECIBO (IDEMPOTÊNCIA)
    INSERT INTO public.payment_receipts (
        mp_payment_id,
        user_email,
        plan_name,
        subscription_days_credited,
        amount_paid,
        processed_at
    ) VALUES (
        p_mp_payment_id,
        p_user_email,
        COALESCE(v_plan_record.name, 'Personalizado'),
        v_days_to_add,
        v_amount_paid,
        now()
    );
    
    -- 5. ATUALIZAR TABELA PAYMENTS
    UPDATE public.payments 
    SET 
        subscription_days_added = v_days_to_add,
        webhook_processed_at = now(),
        updated_at = now()
    WHERE mp_payment_id = p_mp_payment_id;
    
    -- 6. RETORNAR SUCESSO
    RETURN json_build_object(
        'success', true,
        'already_processed', false,
        'is_new_customer', v_is_new_customer,
        'user_email', p_user_email,
        'plan_name', COALESCE(v_plan_record.name, 'Personalizado'),
        'days_added', v_days_to_add,
        'amount_paid', v_amount_paid,
        'previous_end_date', v_current_end_date,
        'new_end_date', v_new_end_date,
        'total_days_remaining', EXTRACT(DAY FROM (v_new_end_date - now())),
        'mp_payment_id', p_mp_payment_id,
        'message', CASE 
            WHEN v_is_new_customer THEN 'Bem-vindo! Sua assinatura foi ativada com sucesso!'
            ELSE 'Assinatura renovada com sucesso!'
        END,
        'processed_at', now()
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Erro interno: ' || SQLERRM,
            'sqlstate', SQLSTATE,
            'mp_payment_id', p_mp_payment_id
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- 5. FUNÇÃO SIMPLIFICADA PARA WEBHOOK
-- ===============================================

CREATE OR REPLACE FUNCTION public.process_payment_webhook(
    p_mp_payment_id bigint,
    p_user_email text,
    p_plan_id uuid DEFAULT NULL
)
RETURNS json AS $$
BEGIN
    RETURN public.create_or_update_subscription(
        p_mp_payment_id,
        p_user_email,
        p_plan_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- 6. FUNÇÃO PARA TRIAL GRATUITO (7 DIAS)
-- ===============================================

CREATE OR REPLACE FUNCTION public.create_trial_subscription(
    p_user_email text
)
RETURNS json AS $$
DECLARE
    v_trial_payment_id bigint;
BEGIN
    -- Gerar ID único para o trial
    v_trial_payment_id := (EXTRACT(EPOCH FROM now()) * 1000000)::bigint + random()::bigint;
    
    RETURN public.create_or_update_subscription(
        v_trial_payment_id,
        p_user_email,
        NULL, -- sem plano específico
        7 -- 7 dias de trial
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- 7. VIEW PARA DASHBOARD COMERCIAL
-- ===============================================

CREATE OR REPLACE VIEW public.sales_dashboard AS
SELECT 
    DATE(pr.processed_at) as sale_date,
    COUNT(*) as total_sales,
    COUNT(DISTINCT pr.user_email) as unique_customers,
    SUM(pr.amount_paid) as total_revenue,
    AVG(pr.amount_paid) as avg_ticket,
    pr.plan_name,
    COUNT(CASE WHEN s.created_at::date = pr.processed_at::date THEN 1 END) as new_customers,
    COUNT(CASE WHEN s.created_at::date < pr.processed_at::date THEN 1 END) as returning_customers
FROM public.payment_receipts pr
LEFT JOIN public.subscriptions s ON s.email = pr.user_email
WHERE pr.processed_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(pr.processed_at), pr.plan_name
ORDER BY sale_date DESC;

-- ===============================================
-- 8. POLÍTICAS RLS PARA SEGURANÇA
-- ===============================================

-- Payments
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Payments read for authenticated users" ON public.payments;
CREATE POLICY "Payments read for authenticated users" ON public.payments
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Payments insert for service role" ON public.payments;
CREATE POLICY "Payments insert for service role" ON public.payments
    FOR INSERT TO service_role WITH CHECK (true);

-- Payment receipts
ALTER TABLE public.payment_receipts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Payment receipts read for authenticated" ON public.payment_receipts;
CREATE POLICY "Payment receipts read for authenticated" ON public.payment_receipts
    FOR SELECT TO authenticated USING (true);

-- Subscription plans (público para todos verem)
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Plans read for everyone" ON public.subscription_plans;
CREATE POLICY "Plans read for everyone" ON public.subscription_plans
    FOR SELECT TO anon, authenticated USING (is_active = true);

-- ===============================================
-- 9. PROCESSAR SEU PAGAMENTO PENDENTE
-- ===============================================

-- Processar o pagamento 126596009978 (seu pagamento específico)
SELECT public.create_or_update_subscription(
    126596009978::bigint,
    'novaradiosystem@outlook.com',
    (SELECT id FROM public.subscription_plans WHERE name = 'Mensal' LIMIT 1)
);

-- ===============================================
-- 10. VERIFICAÇÃO FINAL
-- ===============================================

-- Ver planos disponíveis
SELECT id, name, description, price_brl, days_duration FROM public.subscription_plans WHERE is_active = true;

-- Ver sua assinatura
SELECT email, status, subscription_end_date, payment_status FROM public.subscriptions WHERE email = 'novaradiosystem@outlook.com';

-- Ver dashboard de vendas
SELECT * FROM public.sales_dashboard ORDER BY sale_date DESC LIMIT 10;