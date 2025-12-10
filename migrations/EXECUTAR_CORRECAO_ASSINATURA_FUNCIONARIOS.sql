-- ============================================
-- 🔧 CORREÇÃO: Assinatura compartilhada entre Admin e Funcionários
-- ============================================
-- 
-- PROBLEMA:
-- - Admin da empresa (Cristiano) tem assinatura ativa yearly
-- - Funcionários não conseguem acessar usando essa mesma assinatura
-- - A função check_subscription_status precisa ser atualizada
--
-- SOLUÇÃO:
-- - Funcionários comuns herdam assinatura do dono (empresa_id)
-- - Admin da empresa usa sua própria assinatura (user_id)
-- - A função RPC verifica se é funcionário e busca assinatura correta
--
-- ⚠️ EXECUTAR NO SUPABASE SQL EDITOR
-- ============================================

-- 1️⃣ RECRIAR A FUNÇÃO check_subscription_status
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

  -- VERIFICAR SE É FUNCIONÁRIO COMUM (NÃO admin)
  SELECT * INTO v_funcionario
  FROM funcionarios
  WHERE email = user_email 
    AND status = 'ativo'
    AND (tipo_admin IS NULL OR tipo_admin != 'admin_empresa')
  LIMIT 1;

  IF FOUND THEN
    -- É um funcionário COMUM - herdar assinatura do dono
    v_empresa_id := v_funcionario.empresa_id;
    RAISE NOTICE '👤 Funcionário comum encontrado. Empresa ID: %', v_empresa_id;
    
    -- Buscar assinatura do dono da empresa
    SELECT * INTO v_owner_subscription
    FROM subscriptions
    WHERE user_id = v_empresa_id;

    IF FOUND THEN
      RAISE NOTICE '🏢 Assinatura do dono: status=%, end_date=%', 
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
        RAISE NOTICE '⚠️ Assinatura do dono expirada/inativa';
        RETURN json_build_object(
          'has_subscription', true,
          'status', v_owner_subscription.status,
          'access_allowed', false,
          'is_employee', true,
          'empresa_id', v_empresa_id
        );
      END IF;
    ELSE
      RAISE NOTICE '❌ Dono não tem assinatura cadastrada';
      RETURN json_build_object(
        'has_subscription', false,
        'status', 'no_owner_subscription',
        'access_allowed', false,
        'is_employee', true,
        'empresa_id', v_empresa_id
      );
    END IF;
  END IF;

  -- NÃO é funcionário OU é ADMIN - usar assinatura própria
  RAISE NOTICE '👑 Admin/Dono, buscando assinatura própria';
  
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
      -- Trial expirado
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
  
  -- Status expirado ou outro
  RETURN json_build_object(
    'has_subscription', true,
    'status', v_subscription.status,
    'access_allowed', false,
    'days_remaining', 0
  );
END;
$$;

-- 2️⃣ CONCEDER PERMISSÕES
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO authenticated;
GRANT EXECUTE ON FUNCTION check_subscription_status(text) TO anon;

-- 3️⃣ TESTAR A FUNÇÃO

-- Teste com o admin (Cristiano)
SELECT 
  '=== TESTE: ADMIN (Cristiano) ===' as info,
  check_subscription_status('assistenciaallimport10@gmail.com') as resultado;

-- Resultado esperado:
-- {
--   "has_subscription": true,
--   "status": "active",
--   "plan_type": "yearly",
--   "access_allowed": true,
--   "subscription_end_date": "2026-XX-XX",
--   "days_remaining": XXX
-- }

-- Teste com funcionário (se existir - ajuste o email)
-- SELECT 
--   '=== TESTE: FUNCIONÁRIO ===' as info,
--   check_subscription_status('funcionario@email.com') as resultado;

-- Resultado esperado para funcionário:
-- {
--   "has_subscription": true,
--   "status": "active",
--   "plan_type": "yearly",
--   "access_allowed": true,
--   "subscription_end_date": "2026-XX-XX",
--   "days_remaining": XXX,
--   "is_employee": true,
--   "empresa_id": "uuid-do-dono"
-- }

-- ============================================
-- ✅ CORREÇÃO CONCLUÍDA
-- ============================================
-- 
-- O QUE FOI CORRIGIDO:
-- 1. Função RPC agora distingue entre admin e funcionário comum
-- 2. Funcionários herdam assinatura do dono (empresa_id)
-- 3. Admin usa sua própria assinatura (user_id)
-- 4. Frontend simplificado - só passa o email do usuário logado
--
-- COMO FUNCIONA:
-- - Frontend chama: checkSubscriptionStatus(user.email)
-- - Backend verifica se é funcionário comum
-- - Se SIM: busca assinatura do dono
-- - Se NÃO: busca assinatura própria
--
-- PRÓXIMOS PASSOS:
-- 1. Executar este SQL no Supabase
-- 2. Fazer rebuild do frontend: npm run build
-- 3. Testar login do admin e funcionários
-- 4. Verificar se todos têm acesso correto
--
-- ============================================
