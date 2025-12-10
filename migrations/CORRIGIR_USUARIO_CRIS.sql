-- ============================================
-- VERIFICAR TRIGGER E EMPRESA DO USUÁRIO
-- ============================================

-- 1️⃣ Verificar se usuário existe
SELECT 
  '👤 USUÁRIO' as info,
  id,
  email,
  created_at,
  email_confirmed_at
FROM auth.users
WHERE email = 'cris-ramos1979@hotmail.com';

-- 2️⃣ Verificar se empresa foi criada
SELECT 
  '🏢 EMPRESA' as info,
  e.id,
  e.user_id,
  e.nome,
  e.tipo_conta,
  e.data_cadastro,
  e.data_fim_teste
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE u.email = 'cris-ramos1979@hotmail.com';

-- 3️⃣ Verificar se está em user_approvals
SELECT 
  '✅ USER_APPROVALS' as info,
  ua.user_id,
  ua.email,
  ua.user_role,
  ua.status
FROM user_approvals ua
WHERE ua.email = 'cris-ramos1979@hotmail.com';

-- 4️⃣ VERIFICAR SE TRIGGER ESTÁ ATIVO
SELECT 
  '🔧 TRIGGER STATUS' as info,
  trigger_name,
  event_object_table,
  action_timing,
  event_manipulation
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- 5️⃣ SE EMPRESA NÃO EXISTE, CRIAR MANUALMENTE
DO $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = 'cris-ramos1979@hotmail.com';
  
  IF v_user_id IS NOT NULL THEN
    -- Criar empresa
    INSERT INTO empresas (
      user_id,
      nome,
      email,
      tipo_conta,
      data_cadastro,
      data_fim_teste
    ) VALUES (
      v_user_id,
      'Cristiane Ramos',
      'cris-ramos1979@hotmail.com',
      'teste_ativo',
      NOW(),
      NOW() + INTERVAL '15 days'
    )
    ON CONFLICT (user_id) DO UPDATE
    SET
      tipo_conta = 'teste_ativo',
      data_fim_teste = NOW() + INTERVAL '15 days';
    
    -- Criar/atualizar user_approvals
    INSERT INTO user_approvals (
      user_id,
      email,
      full_name,
      user_role,
      status,
      approved_at
    ) VALUES (
      v_user_id,
      'cris-ramos1979@hotmail.com',
      'Cristiane Ramos',
      'owner',
      'approved',
      NOW()
    )
    ON CONFLICT (user_id) DO UPDATE
    SET
      user_role = 'owner',
      status = 'approved',
      approved_at = NOW();
    
    RAISE NOTICE '✅ Empresa e aprovação criadas para %', 'cris-ramos1979@hotmail.com';
  ELSE
    RAISE NOTICE '❌ Usuário não encontrado';
  END IF;
END $$;

-- 6️⃣ VERIFICAR RESULTADO FINAL
SELECT 
  '✅ VERIFICAÇÃO FINAL' as status,
  u.email,
  e.tipo_conta,
  e.data_fim_teste,
  EXTRACT(DAY FROM (e.data_fim_teste - NOW()))::INTEGER as dias_restantes,
  ua.user_role,
  ua.status
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE u.email = 'cris-ramos1979@hotmail.com';

-- 7️⃣ TESTAR FUNÇÃO RPC
SELECT check_subscription_status('cris-ramos1979@hotmail.com');
