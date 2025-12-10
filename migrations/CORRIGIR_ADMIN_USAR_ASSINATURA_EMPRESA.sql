-- ============================================
-- 🔧 CORREÇÃO: Admin também usa assinatura da empresa
-- ============================================
-- 
-- PROBLEMA:
-- - Admin Cristiano está mostrando 12 dias (trial pessoal)
-- - Deveria mostrar 358 dias (assinatura da empresa)
-- - A função check_subscription_status só busca assinatura própria para admin_empresa
--
-- SOLUÇÃO:
-- - Admin da empresa TAMBÉM herda assinatura da subscription com user_id = empresa_id
-- - Priorizar assinatura da empresa ao invés da pessoal
--
-- ⚠️ EXECUTAR NO SUPABASE SQL EDITOR
-- ============================================

DROP FUNCTION IF EXISTS check_subscription_status(text);

CREATE OR REPLACE FUNCTION check_subscription_status(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_subscription record;
  v_funcionario record;
  v_empresa_id uuid;
  v_owner_subscription record;
BEGIN
  RAISE NOTICE '🔍 check_subscription_status chamado para: %', user_email;
  
  -- Buscar user_id pelo email
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = user_email;

  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ Usuário não encontrado no auth.users';
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_user',
      'access_allowed', false
    );
  END IF;

  RAISE NOTICE '✅ User ID encontrado: %', v_user_id;

  -- ✅ VERIFICAR SE É FUNCIONÁRIO (incluindo admin_empresa)
  -- Buscar na tabela funcionarios INDEPENDENTE do tipo_admin
  SELECT * INTO v_funcionario
  FROM funcionarios
  WHERE (email = user_email OR user_id = v_user_id)
    AND status = 'ativo'
  LIMIT 1;

  IF FOUND THEN
    -- É um funcionário (incluindo admin) - usar assinatura da EMPRESA
    v_empresa_id := v_funcionario.empresa_id;
    RAISE NOTICE '👤 Funcionário encontrado. Tipo: %, Empresa ID: %', 
      v_funcionario.tipo_admin, v_empresa_id;
    
    -- Buscar assinatura da empresa (subscription com user_id = empresa_id)
    SELECT * INTO v_owner_subscription
    FROM subscriptions
    WHERE user_id = v_empresa_id;

    IF FOUND THEN
      RAISE NOTICE '🏢 Assinatura da empresa: status=%, end_date=%', 
        v_owner_subscription.status, v_owner_subscription.subscription_end_date;
      
      -- Verificar se assinatura está ativa
      IF v_owner_subscription.status = 'active' AND v_owner_subscription.subscription_end_date > NOW() THEN
        RETURN json_build_object(
          'has_subscription', true,
          'status', 'active',
          'plan_type', v_owner_subscription.plan_type,
          'access_allowed', true,
          'subscription_end_date', v_owner_subscription.subscription_end_date,
          'days_remaining', EXTRACT(DAY FROM (v_owner_subscription.subscription_end_date - NOW()))::integer,
          'is_employee', CASE 
            WHEN v_funcionario.tipo_admin = 'admin_empresa' THEN false
            ELSE true 
          END,
          'empresa_id', v_empresa_id
        );
      ELSIF v_owner_subscription.status = 'trial' AND v_owner_subscription.trial_end_date > NOW() THEN
        RETURN json_build_object(
          'has_subscription', true,
          'status', 'trial',
          'access_allowed', true,
          'trial_end_date', v_owner_subscription.trial_end_date,
          'days_remaining', EXTRACT(DAY FROM (v_owner_subscription.trial_end_date - NOW()))::integer,
          'is_employee', CASE 
            WHEN v_funcionario.tipo_admin = 'admin_empresa' THEN false
            ELSE true 
          END,
          'empresa_id', v_empresa_id
        );
      ELSE
        RAISE NOTICE '⚠️ Assinatura da empresa expirada/inativa';
        RETURN json_build_object(
          'has_subscription', true,
          'status', v_owner_subscription.status,
          'access_allowed', false,
          'is_employee', CASE 
            WHEN v_funcionario.tipo_admin = 'admin_empresa' THEN false
            ELSE true 
          END,
          'empresa_id', v_empresa_id
        );
      END IF;
    ELSE
      RAISE NOTICE '❌ Empresa não tem assinatura cadastrada';
      -- Fallback: tentar buscar assinatura pessoal
      SELECT * INTO v_subscription
      FROM subscriptions
      WHERE user_id = v_user_id;
      
      IF FOUND AND v_subscription.status IN ('active', 'trial') THEN
        RAISE NOTICE '💡 Usando assinatura pessoal como fallback';
        IF v_subscription.status = 'active' AND v_subscription.subscription_end_date > NOW() THEN
          RETURN json_build_object(
            'has_subscription', true,
            'status', 'active',
            'plan_type', v_subscription.plan_type,
            'access_allowed', true,
            'subscription_end_date', v_subscription.subscription_end_date,
            'days_remaining', EXTRACT(DAY FROM (v_subscription.subscription_end_date - NOW()))::integer
          );
        ELSIF v_subscription.status = 'trial' AND v_subscription.trial_end_date > NOW() THEN
          RETURN json_build_object(
            'has_subscription', true,
            'status', 'trial',
            'access_allowed', true,
            'trial_end_date', v_subscription.trial_end_date,
            'days_remaining', EXTRACT(DAY FROM (v_subscription.trial_end_date - NOW()))::integer
          );
        END IF;
      END IF;
      
      RETURN json_build_object(
        'has_subscription', false,
        'status', 'no_owner_subscription',
        'access_allowed', false,
        'is_employee', CASE 
          WHEN v_funcionario.tipo_admin = 'admin_empresa' THEN false
          ELSE true 
        END,
        'empresa_id', v_empresa_id
      );
    END IF;
  END IF;

  -- NÃO é funcionário - usar assinatura própria
  RAISE NOTICE '👤 Usuário sem registro de funcionário, buscando assinatura própria';
  
  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id;

  IF NOT FOUND THEN
    RAISE NOTICE '❌ Assinatura não encontrada';
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false
    );
  END IF;

  RAISE NOTICE '📊 Assinatura: status=%, end_date=%', 
    v_subscription.status, v_subscription.subscription_end_date;

  -- Verificar status da assinatura própria
  IF v_subscription.status = 'active' THEN
    IF v_subscription.subscription_end_date > NOW() THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'active',
        'plan_type', v_subscription.plan_type,
        'access_allowed', true,
        'subscription_end_date', v_subscription.subscription_end_date,
        'days_remaining', EXTRACT(DAY FROM (v_subscription.subscription_end_date - NOW()))::integer
      );
    ELSE
      -- Assinatura expirada
      UPDATE subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE user_id = v_user_id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false
      );
    END IF;
  ELSIF v_subscription.status = 'trial' THEN
    IF v_subscription.trial_end_date > NOW() THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'trial_end_date', v_subscription.trial_end_date,
        'days_remaining', EXTRACT(DAY FROM (v_subscription.trial_end_date - NOW()))::integer
      );
    ELSE
      -- Trial expirado
      UPDATE subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE user_id = v_user_id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial_expired',
        'access_allowed', false
      );
    END IF;
  ELSE
    RETURN json_build_object(
      'has_subscription', true,
      'status', v_subscription.status,
      'access_allowed', false
    );
  END IF;
END;
$$;

-- Conceder permissões
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO authenticated;
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO anon;

-- ============================================
-- 📝 TESTE
-- ============================================
-- Deve retornar 358 dias para Cristiano (admin)
SELECT check_subscription_status('assistenciaallimport10@gmail.com');
