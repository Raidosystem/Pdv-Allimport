-- ================================
-- SISTEMA DE ASSINATURA COM PERÍODO DE TESTE
-- Execute este SQL no Supabase Dashboard SQL Editor
-- ================================

-- 1. CRIAR TABELA DE ASSINATURAS
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'trial', 'active', 'expired', 'cancelled')),
  
  -- Dados do período de teste
  trial_start_date TIMESTAMPTZ,
  trial_end_date TIMESTAMPTZ,
  
  -- Dados da assinatura paga
  subscription_start_date TIMESTAMPTZ,
  subscription_end_date TIMESTAMPTZ,
  
  -- Dados do pagamento
  payment_method TEXT CHECK (payment_method IN ('pix', 'credit_card', 'debit_card')),
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
  payment_id TEXT, -- ID do pagamento no Mercado Pago
  payment_amount DECIMAL(10,2) DEFAULT 59.90,
  
  -- Metadados
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id)
);

-- 2. FUNÇÃO PARA ATUALIZAR updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- 3. TRIGGER PARA ATUALIZAR updated_at
CREATE TRIGGER update_subscriptions_updated_at 
  BEFORE UPDATE ON public.subscriptions 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- 4. TABELA DE PAGAMENTOS (histórico detalhado)
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Dados do Mercado Pago
  mp_payment_id TEXT NOT NULL,
  mp_preference_id TEXT,
  mp_status TEXT NOT NULL,
  mp_status_detail TEXT,
  
  -- Dados do pagamento
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'BRL',
  payment_method TEXT NOT NULL,
  payment_type TEXT, -- pix, credit_card, debit_card
  
  -- Dados do pagador
  payer_email TEXT,
  payer_name TEXT,
  payer_document TEXT,
  
  -- Webhook data
  webhook_data JSONB,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TRIGGER PARA PAGAMENTOS
CREATE TRIGGER update_payments_updated_at 
  BEFORE UPDATE ON public.payments 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- 6. FUNÇÃO PARA ATIVAR PERÍODO DE TESTE
CREATE OR REPLACE FUNCTION activate_trial(user_email TEXT)
RETURNS JSON AS $$
DECLARE
  user_record auth.users%ROWTYPE;
  trial_end TIMESTAMPTZ;
  result JSON;
BEGIN
  -- Buscar usuário
  SELECT * INTO user_record FROM auth.users WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Usuário não encontrado');
  END IF;
  
  -- Calcular data de expiração (30 dias)
  trial_end := NOW() + INTERVAL '30 days';
  
  -- Inserir ou atualizar assinatura
  INSERT INTO public.subscriptions (
    user_id, 
    email, 
    status, 
    trial_start_date, 
    trial_end_date
  ) VALUES (
    user_record.id,
    user_email,
    'trial',
    NOW(),
    trial_end
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET
    status = 'trial',
    trial_start_date = NOW(),
    trial_end_date = trial_end,
    updated_at = NOW();
  
  -- Atualizar status de aprovação
  UPDATE public.user_approvals 
  SET status = 'approved', updated_at = NOW()
  WHERE email = user_email;
  
  RETURN json_build_object(
    'success', true, 
    'trial_end_date', trial_end,
    'status', 'trial'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. FUNÇÃO PARA VERIFICAR STATUS DA ASSINATURA
CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  current_time TIMESTAMPTZ := NOW();
  result JSON;
BEGIN
  -- Buscar assinatura
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false
    );
  END IF;
  
  -- Verificar se está em período de teste
  IF subscription_record.status = 'trial' THEN
    IF current_time <= subscription_record.trial_end_date THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'trial_end_date', subscription_record.trial_end_date,
        'days_remaining', EXTRACT(DAY FROM subscription_record.trial_end_date - current_time)
      );
    ELSE
      -- Trial expirado, atualizar status
      UPDATE public.subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = subscription_record.id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'trial_end_date', subscription_record.trial_end_date
      );
    END IF;
  END IF;
  
  -- Verificar se tem assinatura ativa
  IF subscription_record.status = 'active' THEN
    IF current_time <= subscription_record.subscription_end_date THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'active',
        'access_allowed', true,
        'subscription_end_date', subscription_record.subscription_end_date
      );
    ELSE
      -- Assinatura expirada
      UPDATE public.subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = subscription_record.id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'subscription_end_date', subscription_record.subscription_end_date
      );
    END IF;
  END IF;
  
  -- Status expirado ou outros
  RETURN json_build_object(
    'has_subscription', true,
    'status', subscription_record.status,
    'access_allowed', false
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. FUNÇÃO PARA ATIVAR ASSINATURA APÓS PAGAMENTO
CREATE OR REPLACE FUNCTION activate_subscription_after_payment(
  user_email TEXT,
  payment_id TEXT,
  payment_method TEXT
)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  subscription_end TIMESTAMPTZ;
BEGIN
  -- Buscar assinatura
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Assinatura não encontrada');
  END IF;
  
  -- Calcular data de expiração (30 dias a partir de agora)
  subscription_end := NOW() + INTERVAL '30 days';
  
  -- Atualizar assinatura
  UPDATE public.subscriptions 
  SET 
    status = 'active',
    subscription_start_date = NOW(),
    subscription_end_date = subscription_end,
    payment_method = payment_method,
    payment_status = 'paid',
    payment_id = payment_id,
    updated_at = NOW()
  WHERE id = subscription_record.id;
  
  RETURN json_build_object(
    'success', true,
    'status', 'active',
    'subscription_end_date', subscription_end
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. RLS POLICIES PARA SUBSCRIPTIONS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription" ON public.subscriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all subscriptions" ON public.subscriptions
  FOR ALL USING (
    auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
    OR auth.jwt() ->> 'role' = 'admin'
  );

CREATE POLICY "System can manage subscriptions" ON public.subscriptions
  FOR ALL USING (true);

-- 10. RLS POLICIES PARA PAYMENTS
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own payments" ON public.payments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all payments" ON public.payments
  FOR ALL USING (
    auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
    OR auth.jwt() ->> 'role' = 'admin'
  );

CREATE POLICY "System can manage payments" ON public.payments
  FOR ALL USING (true);

-- 11. ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_email ON public.subscriptions(email);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_mp_payment_id ON public.payments(mp_payment_id);

-- 12. TESTE DAS FUNÇÕES
SELECT 'Testando função check_subscription_status' as teste;
SELECT check_subscription_status('admin@pdvallimport.com');

-- FINALIZADO
SELECT 'Sistema de assinatura configurado com sucesso!' as resultado;
