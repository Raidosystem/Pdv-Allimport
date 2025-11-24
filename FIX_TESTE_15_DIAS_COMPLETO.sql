-- ============================================
-- CORRIGIR SISTEMA DE 15 DIAS DE TESTE
-- Resolução completa do problema de teste gratuito
-- ============================================

-- ⚠️ EXECUTE ESTE SCRIPT NO SUPABASE SQL EDITOR
-- URL: https://supabase.com/dashboard/project/SEU-PROJECT-ID/sql

-- ============================================
-- 1️⃣ CRIAR FUNÇÃO CORRETA (activate_trial_for_new_user)
-- ============================================

CREATE OR REPLACE FUNCTION activate_trial_for_new_user(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_existing_subscription record;
  v_trial_end_date TIMESTAMPTZ;
BEGIN
  RAISE NOTICE '🎯 Ativando teste de 15 dias para: %', user_email;

  -- Buscar user_id
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = user_email;

  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado'
    );
  END IF;

  -- Calcular data de fim do teste (15 dias a partir de agora)
  v_trial_end_date := NOW() + INTERVAL '15 days';
  RAISE NOTICE '📅 Data de fim do teste: %', v_trial_end_date;

  -- Verificar se já tem assinatura
  SELECT * INTO v_existing_subscription
  FROM subscriptions
  WHERE email = user_email;

  IF FOUND THEN
    RAISE NOTICE '⚠️ Usuário já possui assinatura: %', v_existing_subscription.status;
    
    -- Se já tem assinatura, apenas retornar sucesso
    RETURN json_build_object(
      'success', true,
      'message', 'Usuário já possui assinatura',
      'existing_status', v_existing_subscription.status,
      'days_remaining', GREATEST(0, EXTRACT(DAY FROM (
        COALESCE(v_existing_subscription.trial_end_date, v_existing_subscription.subscription_end_date) - NOW()
      ))::INTEGER)
    );
  END IF;

  -- Criar nova assinatura de teste (15 dias)
  RAISE NOTICE '✨ Criando nova assinatura com 15 dias de teste';
  
  INSERT INTO subscriptions (
    user_id,
    email,
    status,
    plan_type,
    trial_start_date,
    trial_end_date,
    subscription_start_date,
    subscription_end_date,
    email_verified,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    user_email,
    'trial',
    'free',
    NOW(),
    v_trial_end_date,
    NOW(),
    v_trial_end_date,
    TRUE,
    NOW(),
    NOW()
  );

  RAISE NOTICE '✅ Assinatura de teste criada com sucesso!';

  RETURN json_build_object(
    'success', true,
    'message', '15 dias de teste ativados com sucesso!',
    'days_remaining', 15,
    'trial_end_date', v_trial_end_date,
    'status', 'trial'
  );
END;
$$;

-- ============================================
-- 2️⃣ CONCEDER PERMISSÕES
-- ============================================

GRANT EXECUTE ON FUNCTION activate_trial_for_new_user(text) TO authenticated;
GRANT EXECUTE ON FUNCTION activate_trial_for_new_user(text) TO anon;

-- ============================================
-- 3️⃣ CRIAR/ATUALIZAR FUNÇÃO check_subscription_status
-- ============================================

CREATE OR REPLACE FUNCTION check_subscription_status(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_subscription record;
  v_now TIMESTAMPTZ := NOW();
  v_days_remaining INTEGER;
  v_access_allowed BOOLEAN := FALSE;
  v_status TEXT;
BEGIN
  -- Buscar assinatura
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE email = user_email
  ORDER BY created_at DESC
  LIMIT 1;

  -- Se não encontrou, retornar sem assinatura
  IF NOT FOUND THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;

  -- Determinar status e acesso baseado nas datas
  v_status := v_subscription.status;

  -- Se status é 'trial', verificar se ainda está válido
  IF v_subscription.status = 'trial' AND v_subscription.trial_end_date IS NOT NULL THEN
    IF v_subscription.trial_end_date > v_now THEN
      v_days_remaining := CEILING(EXTRACT(EPOCH FROM (v_subscription.trial_end_date - v_now)) / 86400)::INTEGER;
      v_access_allowed := TRUE;
      v_status := 'trial';
    ELSE
      v_days_remaining := 0;
      v_access_allowed := FALSE;
      v_status := 'expired';
      
      -- Atualizar status para expired
      UPDATE subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = v_subscription.id;
    END IF;
  -- Se status é 'active', verificar se ainda está válido
  ELSIF v_subscription.status = 'active' AND v_subscription.subscription_end_date IS NOT NULL THEN
    IF v_subscription.subscription_end_date > v_now THEN
      v_days_remaining := CEILING(EXTRACT(EPOCH FROM (v_subscription.subscription_end_date - v_now)) / 86400)::INTEGER;
      v_access_allowed := TRUE;
      v_status := 'active';
    ELSE
      v_days_remaining := 0;
      v_access_allowed := FALSE;
      v_status := 'expired';
      
      -- Atualizar status para expired
      UPDATE subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = v_subscription.id;
    END IF;
  ELSE
    v_days_remaining := 0;
    v_access_allowed := FALSE;
  END IF;

  -- Retornar status completo
  RETURN json_build_object(
    'has_subscription', true,
    'status', v_status,
    'access_allowed', v_access_allowed,
    'days_remaining', v_days_remaining,
    'plan_type', v_subscription.plan_type,
    'trial_end_date', v_subscription.trial_end_date,
    'subscription_end_date', v_subscription.subscription_end_date,
    'is_trial', v_status = 'trial'
  );
END;
$$;

-- Conceder permissões
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO authenticated;
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO anon;

-- ============================================
-- 4️⃣ TESTAR AS FUNÇÕES
-- ============================================

-- Teste 1: Ativar 15 dias para um email de teste
SELECT activate_trial_for_new_user('teste@exemplo.com');

-- Teste 2: Verificar status do teste
SELECT check_subscription_status('teste@exemplo.com');

-- ============================================
-- 5️⃣ CORRIGIR USUÁRIO EXISTENTE (SE NECESSÁRIO)
-- ============================================

-- ⚠️ DESCOMENTE E SUBSTITUA O EMAIL PARA CORRIGIR SEU USUÁRIO:
/*
DO $$
DECLARE
  v_email TEXT := 'SEU-EMAIL@exemplo.com'; -- SUBSTITUA AQUI
  v_user_id uuid;
  v_trial_end TIMESTAMPTZ;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id FROM auth.users WHERE email = v_email;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não encontrado: %', v_email;
  END IF;
  
  -- Calcular 15 dias
  v_trial_end := NOW() + INTERVAL '15 days';
  
  -- Deletar assinatura antiga (se existir)
  DELETE FROM subscriptions WHERE email = v_email;
  
  -- Criar nova com 15 dias
  INSERT INTO subscriptions (
    user_id,
    email,
    status,
    plan_type,
    trial_start_date,
    trial_end_date,
    subscription_start_date,
    subscription_end_date,
    email_verified,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    v_email,
    'trial',
    'free',
    NOW(),
    v_trial_end,
    NOW(),
    v_trial_end,
    TRUE,
    NOW(),
    NOW()
  );
  
  RAISE NOTICE '✅ Usuário % corrigido com 15 dias de teste!', v_email;
END $$;
*/

-- ============================================
-- 6️⃣ VERIFICAR RESULTADO
-- ============================================

-- Ver todas as assinaturas
SELECT 
  email,
  status,
  EXTRACT(DAY FROM (COALESCE(trial_end_date, subscription_end_date) - NOW())) as dias_restantes,
  trial_start_date,
  trial_end_date,
  created_at
FROM subscriptions
ORDER BY created_at DESC;

-- ============================================
-- ✅ SCRIPT CONCLUÍDO
-- ============================================

-- Agora:
-- 1. O cadastro vai funcionar e ativar 15 dias automaticamente
-- 2. O sistema vai reconhecer o período de teste
-- 3. O usuário vai ter acesso completo durante os 15 dias
