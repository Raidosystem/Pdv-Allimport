-- EXECUTAR ESTE SCRIPT PRIMEIRO NO SUPABASE SQL EDITOR
-- Sistema de Pagamento Automático - Versão Universal

-- ===============================================
-- 1. CRIAR TABELA PAYMENTS
-- ===============================================

CREATE TABLE IF NOT EXISTS public.payments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    mp_payment_id bigint UNIQUE NOT NULL,
    user_email text NOT NULL,
    mp_status text NOT NULL,
    mp_status_detail text,
    payment_method text NOT NULL,
    amount decimal(10,2) NOT NULL,
    currency text DEFAULT 'BRL',
    payer_email text,
    payer_name text,
    mp_preference_id text,
    subscription_days_added integer DEFAULT 0,
    webhook_processed_at timestamp with time zone,
    webhook_data jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- ===============================================
-- 2. CRIAR TABELA PAYMENT_RECEIPTS (IDEMPOTÊNCIA)
-- ===============================================

CREATE TABLE IF NOT EXISTS public.payment_receipts (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    mp_payment_id bigint UNIQUE NOT NULL,
    user_email text NOT NULL,
    subscription_days_credited integer NOT NULL,
    processed_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now()
);

-- ===============================================
-- 3. FUNÇÃO PARA CREDITAR DIAS
-- ===============================================

CREATE OR REPLACE FUNCTION public.credit_subscription_days(
    p_mp_payment_id bigint,
    p_user_email text,
    p_days_to_add integer DEFAULT 31
)
RETURNS json AS $$
DECLARE
    v_subscription_record record;
    v_current_end_date timestamp with time zone;
    v_new_end_date timestamp with time zone;
    v_base_date timestamp with time zone;
    v_already_processed boolean := false;
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
    
    -- 2. BUSCAR ASSINATURA
    SELECT * INTO v_subscription_record 
    FROM public.subscriptions 
    WHERE email = p_user_email;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Assinatura não encontrada para: ' || p_user_email,
            'mp_payment_id', p_mp_payment_id
        );
    END IF;
    
    -- 3. CALCULAR NOVA DATA
    v_current_end_date := v_subscription_record.subscription_end_date;
    
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
    WHERE email = p_user_email;
    
    -- 5. REGISTRAR RECIBO
    INSERT INTO public.payment_receipts (
        mp_payment_id,
        user_email,
        subscription_days_credited,
        processed_at
    ) VALUES (
        p_mp_payment_id,
        p_user_email,
        p_days_to_add,
        now()
    );
    
    -- 6. ATUALIZAR PAYMENTS SE EXISTIR
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
        'user_email', p_user_email,
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
            'mp_payment_id', p_mp_payment_id
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===============================================
-- 4. PROCESSAR SEU PAGAMENTO PENDENTE
-- ===============================================

-- Processar o pagamento 126596009978
SELECT public.credit_subscription_days(
    126596009978::bigint,
    'novaradiosystem@outlook.com',
    31
);

-- ===============================================
-- 5. VERIFICAR RESULTADO
-- ===============================================

-- Ver sua assinatura atualizada
SELECT 
    email,
    status,
    subscription_end_date,
    payment_status,
    updated_at
FROM public.subscriptions 
WHERE email = 'novaradiosystem@outlook.com';

-- Ver recibo do pagamento
SELECT * FROM public.payment_receipts 
WHERE mp_payment_id = 126596009978;