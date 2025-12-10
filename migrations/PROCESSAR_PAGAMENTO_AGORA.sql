-- ==========================================
-- PROCESSAR PAGAMENTO 126596009978 AGORA
-- Versão mínima que funciona SEM criar tabelas
-- ==========================================

-- 1. FUNÇÃO SIMPLES PARA CREDITAR DIAS
CREATE OR REPLACE FUNCTION public.credit_days_simple(
    p_user_email text,
    p_days integer DEFAULT 31
)
RETURNS json AS $$
DECLARE
    v_subscription_record record;
    v_current_end_date timestamp with time zone;
    v_new_end_date timestamp with time zone;
    v_base_date timestamp with time zone;
    v_is_new_customer boolean := false;
BEGIN
    -- BUSCAR ASSINATURA PELO EMAIL
    SELECT * INTO v_subscription_record 
    FROM public.subscriptions 
    WHERE email = p_user_email;
    
    IF NOT FOUND THEN
        -- NOVO CLIENTE - CRIAR ASSINATURA
        v_is_new_customer := true;
        v_base_date := now();
        v_new_end_date := v_base_date + (p_days || ' days')::interval;
        
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
        -- CLIENTE EXISTENTE - RENOVAR
        v_current_end_date := v_subscription_record.subscription_end_date;
        
        -- Se a assinatura está ativa, adicionar aos dias restantes
        -- Se expirou, começar de hoje
        IF v_current_end_date > now() THEN
            v_base_date := v_current_end_date;
        ELSE
            v_base_date := now();
        END IF;
        
        v_new_end_date := v_base_date + (p_days || ' days')::interval;
        
        -- ATUALIZAR ASSINATURA EXISTENTE
        UPDATE public.subscriptions 
        SET 
            subscription_end_date = v_new_end_date,
            status = 'active',
            payment_status = 'paid',
            updated_at = now()
        WHERE email = p_user_email;
    END IF;
    
    -- RETORNAR SUCESSO
    RETURN json_build_object(
        'success', true,
        'is_new_customer', v_is_new_customer,
        'user_email', p_user_email,
        'days_added', p_days,
        'previous_end_date', v_current_end_date,
        'new_end_date', v_new_end_date,
        'total_days_remaining', EXTRACT(DAY FROM (v_new_end_date - now())),
        'message', CASE 
            WHEN v_is_new_customer THEN 'Bem-vindo! Sua assinatura foi ativada!'
            ELSE 'Assinatura renovada com sucesso!'
        END,
        'processed_at', now()
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Erro: ' || SQLERRM,
            'sqlstate', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================
-- 2. PROCESSAR SEU PAGAMENTO AGORA
-- ==========================================

-- Creditar 31 dias para seu pagamento
SELECT public.credit_days_simple(
    'novaradiosystem@outlook.com',
    31
);

-- ==========================================
-- 3. VERIFICAR RESULTADO
-- ==========================================

-- Ver sua assinatura atualizada
SELECT 
    email,
    status,
    subscription_end_date,
    payment_status,
    created_at,
    updated_at
FROM public.subscriptions 
WHERE email = 'novaradiosystem@outlook.com';

-- Calcular dias restantes
SELECT 
    email,
    EXTRACT(DAY FROM (subscription_end_date - now())) as dias_restantes,
    subscription_end_date,
    CASE 
        WHEN subscription_end_date > now() THEN 'ATIVA'
        ELSE 'EXPIRADA'
    END as situacao
FROM public.subscriptions 
WHERE email = 'novaradiosystem@outlook.com';