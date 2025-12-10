-- ========================================
-- SUPER ADMIN - ACESSO TOTAL GARANTIDO
-- ========================================
-- Email: novaradiosystem@outlook.com
-- NUNCA deve ser bloqueado por assinatura
-- ========================================

-- 1. VERIFICAR STATUS ATUAL
DO $$
DECLARE
  v_user_id UUID;
  v_empresa_count INTEGER;
  v_subscription_count INTEGER;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id 
  FROM auth.users 
  WHERE email = 'novaradiosystem@outlook.com';
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ Usuário não encontrado!';
    RETURN;
  END IF;
  
  RAISE NOTICE '✅ Super Admin ID: %', v_user_id;
  
  -- Contar empresas
  SELECT COUNT(*) INTO v_empresa_count 
  FROM empresas 
  WHERE user_id = v_user_id;
  
  RAISE NOTICE '📊 Empresas encontradas: %', v_empresa_count;
  
  -- Contar assinaturas
  SELECT COUNT(*) INTO v_subscription_count 
  FROM subscriptions 
  WHERE user_id = v_user_id;
  
  RAISE NOTICE '📊 Assinaturas encontradas: %', v_subscription_count;
END $$;

-- 2. CRIAR/ATUALIZAR EMPRESA + ASSINATURA + USER_APPROVALS
DO $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id 
  FROM auth.users 
  WHERE email = 'novaradiosystem@outlook.com';
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ Usuário não encontrado!';
    RETURN;
  END IF;
  
  -- 2A. CRIAR/ATUALIZAR EMPRESA (usando apenas user_id que é obrigatório)
  -- A empresa será criada/atualizada com configuração mínima
  INSERT INTO empresas (user_id)
  VALUES (v_user_id)
  ON CONFLICT (user_id) DO NOTHING;
  
  -- Atualizar campos que existirem (ignora erros de colunas inexistentes)
  BEGIN
    UPDATE empresas SET tipo_conta = 'premium' WHERE user_id = v_user_id;
  EXCEPTION WHEN undefined_column THEN
    NULL; -- Ignora se coluna não existir
  END;
  
  BEGIN
    UPDATE empresas SET data_fim_teste = NOW() + INTERVAL '999 years' WHERE user_id = v_user_id;
  EXCEPTION WHEN undefined_column THEN
    NULL;
  END;
  
  BEGIN
    UPDATE empresas SET status_pagamento = 'active' WHERE user_id = v_user_id;
  EXCEPTION WHEN undefined_column THEN
    NULL;
  END;
  
  RAISE NOTICE '✅ Empresa do Super Admin criada/atualizada';
  
  -- 2B. CRIAR/ATUALIZAR ASSINATURA (usando apenas colunas básicas)
  INSERT INTO subscriptions (user_id, email, status)
  SELECT id, email, 'active'
  FROM auth.users
  WHERE email = 'novaradiosystem@outlook.com'
  ON CONFLICT (user_id) DO NOTHING;
  
  -- Atualizar campos opcionais
  BEGIN
    UPDATE subscriptions SET plan_type = 'premium' WHERE user_id = v_user_id;
  EXCEPTION WHEN undefined_column THEN
    NULL;
  END;
  
  BEGIN
    UPDATE subscriptions SET status = 'active' WHERE user_id = v_user_id;
  EXCEPTION WHEN undefined_column THEN
    NULL;
  END;
  
  BEGIN
    UPDATE subscriptions SET payment_status = 'paid' WHERE user_id = v_user_id;
  EXCEPTION WHEN undefined_column THEN
    NULL;
  END;
  
  BEGIN
    UPDATE subscriptions SET end_date = NOW() + INTERVAL '999 years' WHERE user_id = v_user_id;
  EXCEPTION WHEN undefined_column THEN
    NULL;
  END;
  
  RAISE NOTICE '✅ Assinatura do Super Admin criada/atualizada';
  
  -- 2C. GARANTIR QUE É OWNER EM USER_APPROVALS
  INSERT INTO user_approvals (
    user_id,
    email,
    full_name,
    company_name,
    status,
    user_role,
    approved_at,
    created_at
  )
  SELECT 
    id,
    email,
    COALESCE(raw_user_meta_data->>'full_name', 'Administrador Principal'),
    'Raval System - Administração',
    'approved',
    'owner',
    NOW(),
    NOW()
  FROM auth.users
  WHERE email = 'novaradiosystem@outlook.com'
  ON CONFLICT (user_id) 
  DO UPDATE SET
    status = 'approved',
    user_role = 'owner',
    approved_at = NOW();
  
  RAISE NOTICE '✅ Super Admin configurado como OWNER aprovado';
END $$;

-- 3. VERIFICAÇÃO FINAL
DO $$
DECLARE
  v_user_id UUID;
  v_empresa empresas%ROWTYPE;
  v_subscription subscriptions%ROWTYPE;
  v_approval user_approvals%ROWTYPE;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id 
  FROM auth.users 
  WHERE email = 'novaradiosystem@outlook.com';
  
  -- Buscar empresa
  SELECT * INTO v_empresa 
  FROM empresas 
  WHERE user_id = v_user_id;
  
  -- Buscar assinatura
  SELECT * INTO v_subscription 
  FROM subscriptions 
  WHERE user_id = v_user_id;
  
  -- Buscar approval
  SELECT * INTO v_approval 
  FROM user_approvals 
  WHERE user_id = v_user_id;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ SUPER ADMIN CONFIGURADO COM SUCESSO';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Empresa ID: % (tipo: %)', v_empresa.user_id, v_empresa.tipo_conta;
  RAISE NOTICE 'Acesso até: %', v_empresa.data_fim_teste;
  RAISE NOTICE 'Assinatura: % (status: %)', v_subscription.plan_type, v_subscription.status;
  RAISE NOTICE 'User Approval: % (role: %)', v_approval.status, v_approval.user_role;
  RAISE NOTICE '========================================';
END $$;

-- 4. TESTAR RPC check_subscription_status
SELECT * FROM check_subscription_status('novaradiosystem@outlook.com');
