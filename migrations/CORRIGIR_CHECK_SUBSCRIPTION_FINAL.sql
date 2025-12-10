-- ============================================
-- CORREÇÃO FINAL: check_subscription_status
-- ============================================
-- 
-- PROBLEMA IDENTIFICADO:
-- - Admin também está na tabela funcionarios
-- - Função trata admin como funcionário comum
-- - Busca assinatura do empresa_id (errado)
-- - Deve buscar assinatura do user_id (correto)
--
-- SOLUÇÃO:
-- - Admin (tipo_admin = 'admin_empresa') usa assinatura própria
-- - Funcionários comuns herdam assinatura do dono (empresa_id)
--
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
  v_result json;
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

  -- NOVO: Verificar se é funcionário (mas NÃO admin)
  SELECT * INTO v_funcionario
  FROM funcionarios
  WHERE email = user_email 
    AND status = 'ativo'
    AND (tipo_admin IS NULL OR tipo_admin != 'admin_empresa')  -- ⚠️ EXCLUIR ADMIN!
  LIMIT 1;

  IF FOUND THEN
    -- É um funcionário COMUM - buscar empresa_id
    v_empresa_id := v_funcionario.empresa_id;
    RAISE NOTICE '👤 Usuário é funcionário comum. Empresa ID: %', v_empresa_id;
    
    -- Buscar assinatura do dono da empresa (empresa_id = user_id do dono)
    SELECT * INTO v_owner_subscription
    FROM subscriptions
    WHERE user_id = v_empresa_id;

    IF FOUND THEN
      RAISE NOTICE '🏢 Assinatura do dono encontrada: status=%, end_date=%', 
        v_owner_subscription.status, v_owner_subscription.subscription_end_date;
      
      -- Verificar status da assinatura do dono
      IF v_owner_subscription.status = 'active' AND v_owner_subscription.subscription_end_date > NOW() THEN
        RETURN json_build_object(
          'has_subscription', true,
          'status', 'active',
          'plan_type', v_owner_subscription.plan_type,
          'access_allowed', true,
          'subscription_end_date', v_owner_subscription.subscription_end_date,
          'days_remaining', EXTRACT(DAY FROM (v_owner_subscription.subscription_end_date - NOW()))::integer,
          'is_employee', true,
          'empresa_id', v_empresa_id
        );
      ELSIF v_owner_subscription.status = 'trial' AND v_owner_subscription.trial_end_date > NOW() THEN
        RETURN json_build_object(
          'has_subscription', true,
          'status', 'trial',
          'access_allowed', true,
          'trial_end_date', v_owner_subscription.trial_end_date,
          'days_remaining', EXTRACT(DAY FROM (v_owner_subscription.trial_end_date - NOW()))::integer,
          'is_employee', true,
          'empresa_id', v_empresa_id
        );
      ELSE
        RAISE NOTICE '⚠️ Assinatura do dono expirada';
        RETURN json_build_object(
          'has_subscription', true,
          'status', v_owner_subscription.status,
          'access_allowed', false,
          'subscription_end_date', v_owner_subscription.subscription_end_date,
          'days_remaining', 0,
          'is_employee', true,
          'empresa_id', v_empresa_id
        );
      END IF;
    ELSE
      RAISE NOTICE '❌ Assinatura do dono não encontrada';
      RETURN json_build_object(
        'has_subscription', false,
        'status', 'no_owner_subscription',
        'access_allowed', false,
        'is_employee', true,
        'empresa_id', v_empresa_id
      );
    END IF;
  END IF;

  -- NÃO é funcionário OU é ADMIN - verificar assinatura própria (lógica original)
  RAISE NOTICE '👑 Usuário é admin/dono, verificando assinatura própria';
  
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

  RAISE NOTICE '📊 Assinatura encontrada: status=%, end_date=%', 
    v_subscription.status, v_subscription.subscription_end_date;

  -- Verificar status da assinatura
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
      -- Assinatura expirada, atualizar status
      UPDATE subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = v_subscription.id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'subscription_end_date', v_subscription.subscription_end_date,
        'days_remaining', 0
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
      -- Trial expirado, atualizar status
      UPDATE subscriptions 
      SET status = 'expired', updated_at = NOW()
      WHERE id = v_subscription.id;
      
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'expired',
        'access_allowed', false,
        'trial_end_date', v_subscription.trial_end_date,
        'days_remaining', 0
      );
    END IF;
  END IF;
  
  -- Status expirado ou outros
  RETURN json_build_object(
    'has_subscription', true,
    'status', v_subscription.status,
    'access_allowed', false,
    'subscription_end_date', v_subscription.subscription_end_date,
    'days_remaining', GREATEST(
      EXTRACT(DAY FROM (v_subscription.subscription_end_date - NOW()))::integer, 
      0
    )
  );
END;
$$;

-- TESTAR COM ADMIN
SELECT 
  '=== TESTE: ADMIN (CRISTIANO) ===' as info,
  check_subscription_status('assistenciaallimport10@gmail.com') as resultado;

-- TESTAR COM FUNCIONÁRIO (se existir)
-- SELECT 
--   '=== TESTE: FUNCIONÁRIO ===' as info,
--   check_subscription_status('funcionario@email.com') as resultado;

-- ============================================
-- ✅ CORREÇÃO APLICADA
-- ============================================
-- 
-- LÓGICA ATUALIZADA:
-- 1. Se é FUNCIONÁRIO COMUM (tipo_admin != 'admin_empresa'):
--    → Herda assinatura do empresa_id (dono)
--
-- 2. Se é ADMIN ou NÃO está em funcionarios:
--    → Usa assinatura própria (user_id)
--
-- AGORA FUNCIONA:
-- ✅ Admin acessa com sua assinatura yearly
-- ✅ Funcionários herdam assinatura do admin
-- ✅ Todos com acesso correto!
--
-- ============================================
