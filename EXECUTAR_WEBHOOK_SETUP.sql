-- ====================================================================
-- SETUP COMPLETO DO SISTEMA DE WEBHOOKS MERCADO PAGO
-- Execute este script no SQL Editor do Supabase
-- ====================================================================

-- 1️⃣ CRIAR TABELA DE CONTROLE DE IDEMPOTÊNCIA
-- Esta tabela evita processamento duplicado de pagamentos

CREATE TABLE IF NOT EXISTS public.payments_processed (
  id BIGSERIAL PRIMARY KEY,
  payment_id TEXT NOT NULL UNIQUE,
  payer_email TEXT,
  processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_payments_processed_payment_id ON public.payments_processed(payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_processed_payer_email ON public.payments_processed(payer_email);
CREATE INDEX IF NOT EXISTS idx_payments_processed_processed_at ON public.payments_processed(processed_at);

-- RLS (Row Level Security)
ALTER TABLE public.payments_processed ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes se houver
DROP POLICY IF EXISTS "Allow read for authenticated users" ON public.payments_processed;
DROP POLICY IF EXISTS "Allow insert for service role" ON public.payments_processed;

-- Política para permitir leitura apenas para usuários autenticados
CREATE POLICY "Allow read for authenticated users" ON public.payments_processed
  FOR SELECT
  TO authenticated
  USING (true);

-- Política para permitir inserção apenas via service role (webhooks)
CREATE POLICY "Allow insert for service role" ON public.payments_processed
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- 2️⃣ CRIAR/ATUALIZAR FUNÇÃO DE ATIVAÇÃO DE ASSINATURA
-- Esta função é chamada pelo webhook quando o pagamento é aprovado

DROP FUNCTION IF EXISTS activate_subscription_after_payment(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION activate_subscription_after_payment(
  user_email TEXT,
  payment_id TEXT,
  payment_method TEXT
)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  subscription_end TIMESTAMPTZ;
  current_end_date TIMESTAMPTZ;
  base_date TIMESTAMPTZ;
  user_found BOOLEAN := FALSE;
  subscription_found BOOLEAN := FALSE;
BEGIN
  -- Log de início
  RAISE NOTICE 'Iniciando activate_subscription_after_payment para email: %, payment_id: %, método: %', user_email, payment_id, payment_method;
  
  -- Verificar se o usuário existe na tabela de assinaturas
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;
  
  subscription_found := FOUND;
  
  IF NOT subscription_found THEN
    RAISE NOTICE 'Assinatura não encontrada para email: %', user_email;
    RETURN json_build_object('success', false, 'error', 'Assinatura não encontrada para este email');
  END IF;
  
  RAISE NOTICE 'Assinatura encontrada: ID=%, Status=%, Data_fim=%, Dias_restantes=%', 
    subscription_record.id, 
    subscription_record.status, 
    subscription_record.subscription_end_date,
    COALESCE(EXTRACT(DAY FROM (subscription_record.subscription_end_date - NOW())), 0);
  
  -- Pegar a data atual de expiração
  current_end_date := subscription_record.subscription_end_date;
  
  -- Determinar a data base para adicionar 31 dias:
  -- Se a assinatura ainda está válida (data futura), usar a data de expiração atual
  -- Se já expirou, usar a data atual
  IF current_end_date > NOW() THEN
    base_date := current_end_date;
    RAISE NOTICE 'Assinatura ainda válida. Adicionando 31 dias à data atual de expiração: %', current_end_date;
  ELSE
    base_date := NOW();
    RAISE NOTICE 'Assinatura expirada. Adicionando 31 dias à data atual: %', base_date;
  END IF;
  
  -- Calcular nova data de expiração (31 dias adicionados à base_date)
  subscription_end := base_date + INTERVAL '31 days';
  
  RAISE NOTICE 'Nova data de expiração calculada: %', subscription_end;
  
  -- Atualizar assinatura
  UPDATE public.subscriptions 
  SET 
    status = 'active',
    subscription_start_date = CASE 
      WHEN subscription_record.subscription_start_date IS NULL THEN NOW()
      ELSE subscription_record.subscription_start_date
    END,
    subscription_end_date = subscription_end,
    payment_method = activate_subscription_after_payment.payment_method,
    payment_status = 'paid',
    payment_id = activate_subscription_after_payment.payment_id,
    updated_at = NOW()
  WHERE id = subscription_record.id;
  
  -- Verificar se a atualização foi bem-sucedida
  user_found := FOUND;
  
  IF NOT user_found THEN
    RAISE NOTICE 'Falha ao atualizar assinatura para ID: %', subscription_record.id;
    RETURN json_build_object('success', false, 'error', 'Falha ao atualizar assinatura no banco');
  END IF;
  
  RAISE NOTICE 'Assinatura atualizada com sucesso! Nova data de expiração: %', subscription_end;
  
  RETURN json_build_object(
    'success', true,
    'status', 'active',
    'subscription_id', subscription_record.id,
    'subscription_end_date', subscription_end,
    'previous_end_date', current_end_date,
    'days_added', 31,
    'payment_id', activate_subscription_after_payment.payment_id,
    'payment_method', activate_subscription_after_payment.payment_method,
    'total_days_now', EXTRACT(DAY FROM (subscription_end - NOW())),
    'message', CASE 
      WHEN current_end_date > NOW() THEN 
        'Renovação bem-sucedida: 31 dias adicionados ao tempo restante'
      ELSE 
        'Ativação bem-sucedida: 31 dias a partir de hoje'
    END
  );
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Erro na função: % %', SQLERRM, SQLSTATE;
    RETURN json_build_object(
      'success', false, 
      'error', 'Erro interno: ' || SQLERRM,
      'sqlstate', SQLSTATE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3️⃣ VERIFICAR SE TUDO FOI CRIADO CORRETAMENTE

-- Verificar se a tabela foi criada
SELECT 'Tabela payments_processed criada com sucesso!' as status
WHERE EXISTS (
  SELECT 1 FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'payments_processed'
);

-- Verificar se a função foi criada
SELECT 'Função activate_subscription_after_payment criada com sucesso!' as status
WHERE EXISTS (
  SELECT 1 FROM information_schema.routines 
  WHERE routine_schema = 'public' 
  AND routine_name = 'activate_subscription_after_payment'
);

-- 4️⃣ TESTAR A FUNÇÃO (OPCIONAL)
-- Descomente as linhas abaixo para testar com um email válido:

-- SELECT activate_subscription_after_payment(
--   'seu-email@exemplo.com',  -- Substitua pelo seu email
--   'test-payment-webhook',   -- ID de teste
--   'pix'                     -- Método de pagamento
-- );

-- ====================================================================
-- SETUP CONCLUÍDO! ✅
-- 
-- Agora você pode:
-- 1. Configurar o webhook no Dashboard do Mercado Pago
-- 2. Usar a URL: https://seu-dominio.vercel.app/api/mp/webhook
-- 3. Os pagamentos PIX serão ativados automaticamente
-- ====================================================================