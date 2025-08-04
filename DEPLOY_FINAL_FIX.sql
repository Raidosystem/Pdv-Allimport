-- ================================
-- 🚀 DEPLOY SIMPLIFICADO - APENAS PARTES NECESSÁRIAS
-- Execute este SQL no Supabase Dashboard SQL Editor
-- Data: 04/08/2025 
-- ================================

-- PARTE 1: CORRIGIR RLS user_approvals
-- ================================

-- Remover TODAS as políticas existentes primeiro
DROP POLICY IF EXISTS "Users can view own approval status" ON public.user_approvals;
DROP POLICY IF EXISTS "Admins can view all approvals" ON public.user_approvals;  
DROP POLICY IF EXISTS "Admins can update approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "System can insert approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Authenticated users can view approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Allow insert for system" ON public.user_approvals;
DROP POLICY IF EXISTS "Allow updates for authenticated users" ON public.user_approvals;
DROP POLICY IF EXISTS "Users can view own status" ON public.user_approvals;

-- Criar políticas corretas
CREATE POLICY "Authenticated users can view approvals" ON public.user_approvals
  FOR SELECT USING (true);

CREATE POLICY "Allow insert for system" ON public.user_approvals  
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow updates for authenticated users" ON public.user_approvals
  FOR UPDATE USING (true);

-- PARTE 2: CRIAR SISTEMA DE ASSINATURA
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
  payment_id TEXT,
  payment_amount DECIMAL(10,2) DEFAULT 59.90,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id)
);

-- 2. CRIAR TABELA DE PAGAMENTOS
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  mp_payment_id TEXT NOT NULL,
  mp_preference_id TEXT,
  mp_status TEXT NOT NULL,
  mp_status_detail TEXT,
  
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'BRL',
  payment_method TEXT NOT NULL,
  payment_type TEXT,
  
  payer_email TEXT,
  payer_name TEXT,
  payer_document TEXT,
  
  webhook_data JSONB,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. FUNÇÃO updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- 4. TRIGGERS
DROP TRIGGER IF EXISTS update_subscriptions_updated_at ON public.subscriptions;
CREATE TRIGGER update_subscriptions_updated_at 
  BEFORE UPDATE ON public.subscriptions 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_payments_updated_at ON public.payments;
CREATE TRIGGER update_payments_updated_at 
  BEFORE UPDATE ON public.payments 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- PARTE 3: FUNÇÕES DE ASSINATURA
-- ================================

-- Função para ativar período de teste
CREATE OR REPLACE FUNCTION activate_trial(user_email TEXT)
RETURNS JSON AS $$
DECLARE
  user_record auth.users%ROWTYPE;
  trial_end TIMESTAMPTZ;
BEGIN
  SELECT * INTO user_record FROM auth.users WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Usuário não encontrado');
  END IF;
  
  trial_end := NOW() + INTERVAL '30 days';
  
  INSERT INTO public.subscriptions (
    user_id, email, status, trial_start_date, trial_end_date
  ) VALUES (
    user_record.id, user_email, 'trial', NOW(), trial_end
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET
    status = 'trial',
    trial_start_date = NOW(),
    trial_end_date = trial_end,
    updated_at = NOW();
  
  UPDATE public.user_approvals 
  SET status = 'approved', updated_at = NOW()
  WHERE email = user_email;
  
  RETURN json_build_object('success', true, 'trial_end_date', trial_end, 'status', 'trial');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar status
CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  current_timestamp TIMESTAMPTZ := NOW();
BEGIN
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object('has_subscription', false, 'status', 'no_subscription', 'access_allowed', false);
  END IF;
  
  IF subscription_record.status = 'trial' THEN
    IF current_timestamp <= subscription_record.trial_end_date THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'trial_end_date', subscription_record.trial_end_date,
        'days_remaining', EXTRACT(DAY FROM subscription_record.trial_end_date - current_timestamp)
      );
    ELSE
      UPDATE public.subscriptions SET status = 'expired', updated_at = NOW() WHERE id = subscription_record.id;
      RETURN json_build_object('has_subscription', true, 'status', 'expired', 'access_allowed', false);
    END IF;
  END IF;
  
  IF subscription_record.status = 'active' THEN
    IF current_timestamp <= subscription_record.subscription_end_date THEN
      RETURN json_build_object('has_subscription', true, 'status', 'active', 'access_allowed', true);
    ELSE
      UPDATE public.subscriptions SET status = 'expired', updated_at = NOW() WHERE id = subscription_record.id;
      RETURN json_build_object('has_subscription', true, 'status', 'expired', 'access_allowed', false);
    END IF;
  END IF;
  
  RETURN json_build_object('has_subscription', true, 'status', subscription_record.status, 'access_allowed', false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para ativar após pagamento
CREATE OR REPLACE FUNCTION activate_subscription_after_payment(user_email TEXT, payment_id TEXT, payment_method TEXT)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  subscription_end TIMESTAMPTZ;
BEGIN
  SELECT * INTO subscription_record FROM public.subscriptions WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Assinatura não encontrada');
  END IF;
  
  subscription_end := NOW() + INTERVAL '30 days';
  
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
  
  RETURN json_build_object('success', true, 'status', 'active', 'subscription_end_date', subscription_end);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- PARTE 4: RLS PARA NOVAS TABELAS
-- ================================

-- RLS para subscriptions
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own subscription" ON public.subscriptions;
CREATE POLICY "Users can view own subscription" ON public.subscriptions
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can manage subscriptions" ON public.subscriptions;
CREATE POLICY "System can manage subscriptions" ON public.subscriptions
  FOR ALL USING (true);

-- RLS para payments  
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own payments" ON public.payments;
CREATE POLICY "Users can view own payments" ON public.payments
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can manage payments" ON public.payments;
CREATE POLICY "System can manage payments" ON public.payments
  FOR ALL USING (true);

-- PARTE 5: ÍNDICES
-- ================================

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_email ON public.subscriptions(email);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_mp_payment_id ON public.payments(mp_payment_id);

-- TESTE FINAL
-- ================================

SELECT '🎉 Deploy completado com sucesso!' as resultado;
SELECT 'Testando função...' as teste;
SELECT check_subscription_status('novaradiosystem@outlook.com') as status_admin;

-- ATIVAR TRIAL PARA ADMIN
-- ================================
SELECT 'Ativando trial de 30 dias para admin...' as ativando_trial;
SELECT activate_trial('novaradiosystem@outlook.com') as trial_ativado;

-- VERIFICAR STATUS APÓS ATIVAÇÃO
SELECT 'Verificando status após ativação...' as verificando;
SELECT check_subscription_status('novaradiosystem@outlook.com') as status_final;
