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

-- 2. CRIAR/ATUALIZAR EMPRESA COM ACESSO PERMANENTE
INSERT INTO empresas (
  user_id,
  nome_empresa,
  cnpj,
  tipo_conta,
  data_inicio_teste,
  data_fim_teste,
  status_pagamento,
  created_at,
  updated_at
)
SELECT 
  id,
  'Raval System - Administração',
  '00000000000000',
  'premium', -- Tipo premium (não teste)
  NOW(),
  NOW() + INTERVAL '999 years', -- Nunca expira
  'active',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'novaradiosystem@outlook.com'
ON CONFLICT (user_id) 
DO UPDATE SET
  tipo_conta = 'premium',
  data_fim_teste = NOW() + INTERVAL '999 years',
  status_pagamento = 'active',
  updated_at = NOW();

RAISE NOTICE '✅ Empresa do Super Admin atualizada com acesso PERMANENTE';

-- 3. CRIAR/ATUALIZAR ASSINATURA PERMANENTE
INSERT INTO subscriptions (
  user_id,
  email,
  plan_type,
  status,
  start_date,
  end_date,
  payment_status,
  amount,
  currency,
  payment_method,
  created_at,
  updated_at
)
SELECT 
  id,
  email,
  'premium',
  'active',
  NOW(),
  NOW() + INTERVAL '999 years', -- Nunca expira
  'paid',
  0, -- Sem custo
  'BRL',
  'admin',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'novaradiosystem@outlook.com'
ON CONFLICT (user_id) 
DO UPDATE SET
  plan_type = 'premium',
  status = 'active',
  end_date = NOW() + INTERVAL '999 years',
  payment_status = 'paid',
  updated_at = NOW();

RAISE NOTICE '✅ Assinatura do Super Admin atualizada com acesso PERMANENTE';

-- 4. GARANTIR QUE É OWNER EM USER_APPROVALS
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

-- 5. VERIFICAÇÃO FINAL
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
  RAISE NOTICE 'Empresa: % (tipo: %)', v_empresa.nome_empresa, v_empresa.tipo_conta;
  RAISE NOTICE 'Acesso até: %', v_empresa.data_fim_teste;
  RAISE NOTICE 'Assinatura: % (status: %)', v_subscription.plan_type, v_subscription.status;
  RAISE NOTICE 'User Approval: % (role: %)', v_approval.status, v_approval.user_role;
  RAISE NOTICE '========================================';
END $$;

-- 6. TESTAR RPC check_subscription_status
SELECT 
  '✅ TESTE RPC' as teste,
  access_allowed,
  status,
  days_remaining,
  message
FROM check_subscription_status('novaradiosystem@outlook.com');
