-- ============================================
-- 🚀 SCRIPT COMPLETO PARA EXECUTAR NO SUPABASE
-- Sistema de Assinaturas com Teste de 15 dias Automático
-- ============================================

-- ⚠️ IMPORTANTE: Execute este script no SQL Editor do Supabase Dashboard
-- URL: https://supabase.com/dashboard/project/SEU-PROJECT-ID/sql

-- ============================================
-- PASSO 1: CRIAR TABELA DE ASSINATURAS
-- ============================================

CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  
  -- Status da assinatura
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'trial', 'active', 'expired', 'cancelled')),
  
  -- Dados do período de teste (15 dias)
  trial_start_date TIMESTAMPTZ,
  trial_end_date TIMESTAMPTZ,
  
  -- Dados da assinatura paga
  subscription_start_date TIMESTAMPTZ,
  subscription_end_date TIMESTAMPTZ,
  
  -- Dados do pagamento
  payment_method TEXT CHECK (payment_method IN ('pix', 'credit_card', 'debit_card')),
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'paused')),
  payment_id TEXT,
  payment_amount DECIMAL(10,2) DEFAULT 59.90,
  
  -- Metadados
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_email ON public.subscriptions(email);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);

-- ============================================
-- PASSO 2: FUNÇÃO PARA CALCULAR DIAS RESTANTES
-- ============================================

CREATE OR REPLACE FUNCTION calculate_days_remaining(end_date_param TIMESTAMPTZ)
RETURNS INTEGER AS $$
BEGIN
  -- Calcula diferença em dias arredondando para cima
  RETURN GREATEST(0, CEILING(EXTRACT(EPOCH FROM (end_date_param - NOW())) / 86400)::INTEGER);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- PASSO 3: TRIGGER AUTOMÁTICO PARA ATIVAR TESTE DE 15 DIAS
-- ============================================

CREATE OR REPLACE FUNCTION create_trial_subscription()
RETURNS TRIGGER AS $$
BEGIN
  -- Quando um usuário é aprovado, criar assinatura de teste de 15 dias
  IF NEW.status = 'approved' AND (OLD.status IS NULL OR OLD.status != 'approved') THEN
    -- Verificar se já não existe uma assinatura
    IF NOT EXISTS (SELECT 1 FROM subscriptions WHERE user_id = NEW.user_id) THEN
      INSERT INTO subscriptions (
        user_id,
        email,
        status,
        trial_start_date,
        trial_end_date
      ) VALUES (
        NEW.user_id,
        NEW.email,
        'trial',
        NOW(),
        NOW() + INTERVAL '15 days' -- 15 DIAS DE TESTE
      );
      
      RAISE NOTICE '✅ Teste de 15 dias ativado para: %', NEW.email;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger na tabela user_approvals
DROP TRIGGER IF EXISTS trigger_create_trial_subscription ON user_approvals;
CREATE TRIGGER trigger_create_trial_subscription
  AFTER UPDATE ON user_approvals
  FOR EACH ROW
  EXECUTE FUNCTION create_trial_subscription();

-- ============================================
-- PASSO 4: FUNÇÃO PARA VERIFICAR STATUS (TEMPO REAL)
-- ============================================

CREATE OR REPLACE FUNCTION check_subscription_status(user_email TEXT)
RETURNS JSON AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  current_time TIMESTAMPTZ := NOW();
  days_left INTEGER;
BEGIN
  -- Buscar assinatura
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email
  LIMIT 1;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;
  
  -- ⏱️ CALCULAR DIAS RESTANTES EM TEMPO REAL
  IF subscription_record.status = 'trial' AND subscription_record.trial_end_date IS NOT NULL THEN
    days_left := calculate_days_remaining(subscription_record.trial_end_date);
  ELSIF subscription_record.status = 'active' AND subscription_record.subscription_end_date IS NOT NULL THEN
    days_left := calculate_days_remaining(subscription_record.subscription_end_date);
  ELSE
    days_left := 0;
  END IF;
  
  -- Verificar se está em período de teste
  IF subscription_record.status = 'trial' THEN
    IF subscription_record.trial_end_date IS NOT NULL AND subscription_record.trial_end_date > current_time THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'trial_end_date', subscription_record.trial_end_date,
        'days_remaining', days_left,
        'is_trial', true
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
        'trial_end_date', subscription_record.trial_end_date,
        'days_remaining', 0
      );
    END IF;
  END IF;
  
  -- Verificar se tem assinatura ativa
  IF subscription_record.status = 'active' THEN
    IF subscription_record.subscription_end_date IS NOT NULL AND subscription_record.subscription_end_date > current_time THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'active',
        'access_allowed', true,
        'subscription_end_date', subscription_record.subscription_end_date,
        'days_remaining', days_left
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
        'subscription_end_date', subscription_record.subscription_end_date,
        'days_remaining', 0
      );
    END IF;
  END IF;
  
  -- Status expirado ou outros
  RETURN json_build_object(
    'has_subscription', true,
    'status', subscription_record.status,
    'access_allowed', false,
    'days_remaining', days_left
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASSO 5: FUNÇÃO PARA ATIVAR TESTE MANUALMENTE
-- ============================================

CREATE OR REPLACE FUNCTION activate_trial(user_email TEXT)
RETURNS JSON AS $$
DECLARE
  user_record auth.users%ROWTYPE;
  trial_end TIMESTAMPTZ;
BEGIN
  -- Buscar usuário
  SELECT * INTO user_record FROM auth.users WHERE email = user_email;
  
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Usuário não encontrado');
  END IF;
  
  -- Calcular data de expiração (15 dias)
  trial_end := NOW() + INTERVAL '15 days';
  
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
  
  RETURN json_build_object(
    'success', true, 
    'trial_end_date', trial_end,
    'status', 'trial',
    'days', 15
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASSO 6: POLÍTICAS RLS (ROW LEVEL SECURITY)
-- ============================================

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Usuários podem ver apenas suas próprias assinaturas
DROP POLICY IF EXISTS "Users can view own subscription" ON public.subscriptions;
CREATE POLICY "Users can view own subscription" ON public.subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- Admins podem ver tudo
DROP POLICY IF EXISTS "Admins can view all subscriptions" ON public.subscriptions;
CREATE POLICY "Admins can view all subscriptions" ON public.subscriptions
  FOR ALL USING (
    auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
    OR auth.jwt() ->> 'role' = 'admin'
  );

-- Sistema pode gerenciar
DROP POLICY IF EXISTS "System can manage subscriptions" ON public.subscriptions;
CREATE POLICY "System can manage subscriptions" ON public.subscriptions
  FOR ALL USING (true);

-- ============================================
-- PASSO 7: CRIAR ASSINATURAS PARA USUÁRIOS EXISTENTES
-- ============================================

-- Ativar teste de 15 dias para todos os usuários aprovados que ainda não têm assinatura
INSERT INTO public.subscriptions (user_id, email, status, trial_start_date, trial_end_date)
SELECT 
  user_id,
  email,
  'trial',
  created_at,
  created_at + INTERVAL '15 days'
FROM user_approvals
WHERE status = 'approved'
  AND user_role != 'employee'
  AND user_id NOT IN (SELECT user_id FROM subscriptions)
ON CONFLICT (user_id) DO NOTHING;

-- ============================================
-- PASSO 8: FUNÇÃO PARA ADICIONAR DIAS (ADMIN)
-- ============================================

CREATE OR REPLACE FUNCTION admin_add_subscription_days(
  target_user_id UUID,
  days_to_add INTEGER
)
RETURNS JSON AS $$
DECLARE
  subscription_record subscriptions%ROWTYPE;
  new_end_date TIMESTAMPTZ;
BEGIN
  -- Buscar assinatura
  SELECT * INTO subscription_record
  FROM subscriptions
  WHERE user_id = target_user_id;
  
  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'error', 'Assinatura não encontrada');
  END IF;
  
  -- Calcular nova data baseada no status
  IF subscription_record.status = 'trial' THEN
    new_end_date := subscription_record.trial_end_date + (days_to_add || ' days')::INTERVAL;
    UPDATE subscriptions
    SET trial_end_date = new_end_date, updated_at = NOW()
    WHERE user_id = target_user_id;
  ELSE
    new_end_date := subscription_record.subscription_end_date + (days_to_add || ' days')::INTERVAL;
    UPDATE subscriptions
    SET subscription_end_date = new_end_date, updated_at = NOW()
    WHERE user_id = target_user_id;
  END IF;
  
  RETURN json_build_object(
    'success', true,
    'new_end_date', new_end_date,
    'days_added', days_to_add
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASSO 9: VERIFICAÇÃO FINAL
-- ============================================

-- Ver todas as assinaturas criadas
SELECT 
  '✅ SISTEMA CONFIGURADO COM SUCESSO!' as status,
  COUNT(*) as total_subscriptions
FROM subscriptions;

-- Ver assinaturas ativas
SELECT 
  email,
  status,
  trial_end_date,
  calculate_days_remaining(trial_end_date) as dias_restantes
FROM subscriptions
WHERE status = 'trial'
ORDER BY created_at DESC;

-- ============================================
-- 📋 COMO USAR NO ADMIN PANEL
-- ============================================

-- 1. Aprovar usuário (o trigger criará automaticamente 15 dias de teste)
-- UPDATE user_approvals SET status = 'approved' WHERE email = 'usuario@exemplo.com';

-- 2. Verificar status de assinatura
-- SELECT check_subscription_status('usuario@exemplo.com');

-- 3. Adicionar dias manualmente (como admin)
-- SELECT admin_add_subscription_days('user-uuid-aqui', 30);

-- 4. Ver todas as assinaturas
-- SELECT * FROM subscriptions ORDER BY created_at DESC;

-- ============================================
-- ✅ PRONTO! AGORA O SISTEMA ESTÁ FUNCIONANDO
-- ============================================

SELECT 
  '🎉 CONFIGURAÇÃO CONCLUÍDA!' as mensagem,
  'O AdminPanel agora mostra dados REAIS de assinatura' as info,
  'Teste de 15 dias é ativado automaticamente ao aprovar usuário' as nota;
