-- ============================================
-- CORREÇÃO: FUNCIONÁRIOS HERDAM ASSINATURA DO DONO
-- ============================================
-- 
-- PROBLEMA:
-- - Funcionários foram criados com user_id próprio
-- - Ao fazer login, o sistema busca assinatura do user_id do funcionário
-- - Funcionário não tem assinatura própria (erro: "Período de teste expirado")
--
-- SOLUÇÃO:
-- - Modificar check_subscription_status para buscar assinatura do dono da empresa
-- - Funcionários herdam a assinatura do empresa_id (dono)
--
-- ============================================

-- 1. VERIFICAR ESTRUTURA ATUAL
SELECT 
  '=== FUNCIONÁRIOS ===' as info,
  f.id,
  f.nome,
  f.email,
  f.empresa_id,
  f.status,
  (SELECT nome FROM empresas WHERE id = f.empresa_id) as nome_empresa
FROM funcionarios f
WHERE f.email LIKE '%jenifer%' OR f.nome LIKE '%Jenifer%'
ORDER BY f.created_at DESC;

-- 2. VERIFICAR ASSINATURA DO DONO
SELECT 
  '=== ASSINATURA DO DONO ===' as info,
  s.id,
  s.user_id,
  u.email,
  s.status,
  s.plan_type,
  s.subscription_end_date,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW())) as dias_restantes
FROM subscriptions s
JOIN auth.users u ON s.user_id = u.id
WHERE u.email = 'assistenciaallimport10@gmail.com';

-- 3. RECRIAR FUNÇÃO check_subscription_status
-- Agora verifica se o usuário é funcionário e busca assinatura do dono
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

  -- NOVO: Verificar se é funcionário
  SELECT * INTO v_funcionario
  FROM funcionarios
  WHERE email = user_email AND status = 'ativo'
  LIMIT 1;

  IF FOUND THEN
    -- É um funcionário - buscar empresa_id
    v_empresa_id := v_funcionario.empresa_id;
    RAISE NOTICE '👤 Usuário é funcionário. Empresa ID: %', v_empresa_id;
    
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

  -- NÃO é funcionário - verificar assinatura própria (lógica original)
  RAISE NOTICE '👑 Usuário não é funcionário, verificando assinatura própria';
  
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

-- 4. TESTAR A FUNÇÃO COM FUNCIONÁRIO
SELECT 
  '=== TESTE: FUNCIONÁRIO JENIFER ===' as info,
  check_subscription_status('jenifer@email.com') as resultado;

-- 5. TESTAR A FUNÇÃO COM DONO
SELECT 
  '=== TESTE: DONO (CRISTIANO) ===' as info,
  check_subscription_status('assistenciaallimport10@gmail.com') as resultado;

-- 6. VERIFICAR LOGS
SELECT '=== VERIFICAR LOGS NO CONSOLE ===' as info;

-- ============================================
-- ✅ RESULTADO ESPERADO
-- ============================================
-- 
-- FUNCIONÁRIO (Jenifer):
-- {
--   "has_subscription": true,
--   "status": "active",
--   "plan_type": "yearly",
--   "access_allowed": true,
--   "subscription_end_date": "2026-04-15...",
--   "days_remaining": 180,
--   "is_employee": true,
--   "empresa_id": "f1726fcf-d23b-4cca-8079-39314ae56e00"
-- }
--
-- DONO (Cristiano):
-- {
--   "has_subscription": true,
--   "status": "active",
--   "plan_type": "yearly",
--   "access_allowed": true,
--   "subscription_end_date": "2026-04-15...",
--   "days_remaining": 180
-- }
--
-- ============================================
