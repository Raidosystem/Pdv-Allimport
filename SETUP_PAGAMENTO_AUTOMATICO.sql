-- SISTEMA DE PAGAMENTO AUTOMÁTICO PDV ALLIMPORT
-- Execute este script no SQL Editor do Supabase
-- Implementa "aprova e libera na hora" conforme PDF

-- ===============================================
-- 1. TABELA PAYMENTS (com idempotência)
-- ===============================================

CREATE TABLE IF NOT EXISTS public.payments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    mp_payment_id bigint UNIQUE NOT NULL, -- ID do MercadoPago (único!)
    empresa_id text NOT NULL, -- external_reference/metadata.empresa_id
    mp_status text NOT NULL, -- approved, accredited, pending, etc
    mp_status_detail text, -- accredited, pending_waiting_transfer, etc
    payment_method text NOT NULL, -- pix, credit_card
    amount decimal(10,2) NOT NULL,
    currency text DEFAULT 'BRL',
    payer_email text,
    payer_name text,
    mp_preference_id text, -- Para rastrear preferências
    subscription_days_added integer DEFAULT 0, -- Quantos dias foram creditados
    webhook_processed_at timestamp with time zone, -- Quando o webhook processou
    webhook_data jsonb, -- Dados completos do webhook
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_payments_mp_payment_id ON public.payments(mp_payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_empresa_id ON public.payments(empresa_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(mp_status);

-- RLS Policies
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Payments read for authenticated users" ON public.payments;
CREATE POLICY "Payments read for authenticated users" ON public.payments
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Payments insert for service role" ON public.payments;
CREATE POLICY "Payments insert for service role" ON public.payments
    FOR INSERT TO service_role WITH CHECK (true);

DROP POLICY IF EXISTS "Payments update for service role" ON public.payments;
CREATE POLICY "Payments update for service role" ON public.payments
    FOR UPDATE TO service_role USING (true);

-- ===============================================
-- 2. TABELA PAYMENT_RECEIPTS (idempotência absoluta)
-- ===============================================

CREATE TABLE IF NOT EXISTS public.payment_receipts (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    mp_payment_id bigint UNIQUE NOT NULL, -- Uma vez processado, nunca mais
    empresa_id text NOT NULL,
    subscription_days_credited integer NOT NULL,
    processed_at timestamp with time zone DEFAULT now(),
    webhook_signature text, -- Para validar origem
    created_at timestamp with time zone DEFAULT now()
);

-- RLS Policy
ALTER TABLE public.payment_receipts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Payment receipts read for authenticated" ON public.payment_receipts;
CREATE POLICY "Payment receipts read for authenticated" ON public.payment_receipts
    FOR SELECT TO authenticated USING (true);

-- ===============================================
-- 3. FUNÇÃO IDEMPOTENTE DE CRÉDITO DE DIAS
-- ===============================================

DROP FUNCTION IF EXISTS public.credit_subscription_days(bigint, text, integer);

CREATE OR REPLACE FUNCTION public.credit_subscription_days(
    p_mp_payment_id bigint,
    p_empresa_id text,
    p_days_to_add integer DEFAULT 31
)
RETURNS json AS $$
DECLARE
    v_subscription_record public.subscriptions%ROWTYPE;
    v_current_end_date timestamp with time zone;
    v_new_end_date timestamp with time zone;
    v_base_date timestamp with time zone;
    v_already_processed boolean := false;
BEGIN
    -- 1. VERIFICAR IDEMPOTÊNCIA (já foi processado?)
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
    
    -- 2. BUSCAR ASSINATURA
    SELECT * INTO v_subscription_record 
    FROM public.subscriptions 
    WHERE email = p_empresa_id; -- empresa_id = email na estrutura atual
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Assinatura não encontrada para empresa: ' || p_empresa_id,
            'mp_payment_id', p_mp_payment_id
        );
    END IF;
    
    -- 3. CALCULAR NOVA DATA DE EXPIRAÇÃO
    v_current_end_date := v_subscription_record.subscription_end_date;
    
    -- Se a assinatura está ativa, adicionar aos dias restantes
    -- Se expirou, começar de hoje
    IF v_current_end_date > now() THEN
        v_base_date := v_current_end_date;
    ELSE
        v_base_date := now();
    END IF;
    
    v_new_end_date := v_base_date + (p_days_to_add || ' days')::interval;
    
    -- 4. ATUALIZAR ASSINATURA
    UPDATE public.subscriptions 
    SET 
        subscription_end_date = v_new_end_date,
        status = 'active',
        payment_status = 'paid',
        updated_at = now()
    WHERE id = v_subscription_record.id;
    
    -- 5. REGISTRAR RECIBO (IDEMPOTÊNCIA)
    INSERT INTO public.payment_receipts (
        mp_payment_id,
        empresa_id,
        subscription_days_credited,
        processed_at
    ) VALUES (
        p_mp_payment_id,
        p_empresa_id,
        p_days_to_add,
        now()
    );
    
    -- 6. ATUALIZAR TABELA PAYMENTS
    UPDATE public.payments 
    SET 
        subscription_days_added = p_days_to_add,
        webhook_processed_at = now(),
        updated_at = now()
    WHERE mp_payment_id = p_mp_payment_id;
    
    -- 7. RETORNAR SUCESSO
    RETURN json_build_object(
        'success', true,
        'already_processed', false,
        'empresa_id', p_empresa_id,
        'days_added', p_days_to_add,
        'previous_end_date', v_current_end_date,
        'new_end_date', v_new_end_date,
        'total_days_now', EXTRACT(DAY FROM (v_new_end_date - now())),
        'mp_payment_id', p_mp_payment_id,
        'message', 'Assinatura renovada com sucesso!',
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
-- 4. FUNÇÃO PARA WEBHOOK PROCESSAR PAGAMENTO
-- ===============================================

DROP FUNCTION IF EXISTS public.process_payment_webhook(bigint, text);

CREATE OR REPLACE FUNCTION public.process_payment_webhook(
    p_mp_payment_id bigint,
    p_empresa_id text
)
RETURNS json AS $$
DECLARE
    v_result json;
BEGIN
    -- Chamar função de crédito com 31 dias padrão
    SELECT public.credit_subscription_days(
        p_mp_payment_id,
        p_empresa_id,
        31 -- 31 dias padrão por pagamento
    ) INTO v_result;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- 5. TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA
-- ===============================================

-- Trigger para updated_at em payments
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_payments_updated_at ON public.payments;
CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON public.payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===============================================
-- 6. VERIFICAÇÃO FINAL
-- ===============================================

-- Verificar se tudo foi criado
SELECT 
    'payments' as table_name,
    COUNT(*) as records
FROM public.payments
UNION ALL
SELECT 
    'payment_receipts' as table_name,
    COUNT(*) as records
FROM public.payment_receipts
UNION ALL
SELECT 
    'credit_subscription_days' as function_name,
    1 as exists
WHERE EXISTS (
    SELECT 1 FROM information_schema.routines 
    WHERE routine_schema = 'public' 
    AND routine_name = 'credit_subscription_days'
)
UNION ALL
SELECT 
    'process_payment_webhook' as function_name,
    1 as exists
WHERE EXISTS (
    SELECT 1 FROM information_schema.routines 
    WHERE routine_schema = 'public' 
    AND routine_name = 'process_payment_webhook'
);

-- ===============================================
-- 7. TESTE OPCIONAL
-- ===============================================
/*
-- Para testar, descomente e execute:

-- Inserir pagamento de teste
INSERT INTO public.payments (
    mp_payment_id,
    empresa_id,
    mp_status,
    payment_method,
    amount
) VALUES (
    999999999,
    'teste@pdvallimport.com',
    'approved',
    'pix',
    59.90
) ON CONFLICT (mp_payment_id) DO NOTHING;

-- Testar função
SELECT public.credit_subscription_days(
    999999999,
    'teste@pdvallimport.com',
    31
);

-- Verificar resultado
SELECT email, status, subscription_end_date, payment_status 
FROM public.subscriptions 
WHERE email = 'teste@pdvallimport.com';

-- Testar idempotência (deve retornar already_processed = true)
SELECT public.credit_subscription_days(
    999999999,
    'teste@pdvallimport.com',
    31
);
*/