-- ============================================
-- 🔧 CRIAR EMPRESA MANUALMENTE PARA O USUÁRIO
-- Este SQL tenta criar a empresa manualmente para diagnosticar o erro
-- ============================================

DO $$
DECLARE
  v_user_id UUID := 'a832f6a8-3e56-45cd-b33d-725fe9c19343';
  v_user_email TEXT := 'silviobritoempreendedor@gmail.com';
  v_user_name TEXT := 'Silvio Brito dos santos';
  v_company_name TEXT := 'Novo estylo';
  v_cnpj_temp TEXT;
  v_empresa_id UUID;
BEGIN
  RAISE NOTICE '🎯 Tentando criar empresa para: %', v_user_email;
  
  -- Gerar CNPJ temporário
  v_cnpj_temp := LPAD(EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT, 14, '0');
  v_cnpj_temp := SUBSTRING(v_cnpj_temp, 1, 2) || '.' || 
                 SUBSTRING(v_cnpj_temp, 3, 3) || '.' || 
                 SUBSTRING(v_cnpj_temp, 6, 3) || '/' || 
                 SUBSTRING(v_cnpj_temp, 9, 4) || '-' || 
                 SUBSTRING(v_cnpj_temp, 13, 2);

  -- 1️⃣ Criar empresa (ou pegar ID se já existir)
  INSERT INTO public.empresas (
    user_id,
    nome,
    cnpj,
    telefone,
    email,
    tipo_conta,
    data_fim_teste
  ) VALUES (
    v_user_id,
    v_user_name,
    v_cnpj_temp,
    '(00) 00000-0000',
    v_user_email,
    'teste_ativo',
    NOW() + INTERVAL '15 days'
  )
  ON CONFLICT (user_id) DO UPDATE SET
    tipo_conta = 'teste_ativo',
    data_fim_teste = NOW() + INTERVAL '15 days'
  RETURNING id INTO v_empresa_id;
  
  -- Se não conseguiu o ID pelo INSERT, buscar empresa existente
  IF v_empresa_id IS NULL THEN
    SELECT id INTO v_empresa_id FROM empresas WHERE user_id = v_user_id;
  END IF;

  RAISE NOTICE '✅ Empresa criada: %', v_empresa_id;

  -- 2️⃣ Criar subscription
  INSERT INTO public.subscriptions (
    user_id,
    email,
    plan_type,
    status,
    trial_start_date,
    trial_end_date,
    subscription_start_date,
    subscription_end_date,
    created_at,
    updated_at
  ) VALUES (
    v_user_id,
    v_user_email,
    'free',
    'trial',
    NOW(),
    NOW() + INTERVAL '15 days',
    NOW(),
    NOW() + INTERVAL '15 days',
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO NOTHING;

  RAISE NOTICE '✅ Subscription criada';

  -- 3️⃣ Criar user_approvals
  INSERT INTO public.user_approvals (
    user_id,
    email,
    full_name,
    company_name,
    status,
    user_role,
    approved_at,
    created_at
  ) VALUES (
    v_user_id,
    v_user_email,
    v_user_name,
    v_company_name,
    'approved',
    'owner',
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    user_role = 'owner',
    status = 'approved',
    updated_at = NOW();

  RAISE NOTICE '✅ user_approvals criado';

  -- 4️⃣ Criar funcionário com tipo_admin='admin_empresa'
  -- Verificar se já existe
  IF EXISTS (SELECT 1 FROM funcionarios WHERE empresa_id = v_empresa_id AND user_id = v_user_id) THEN
    -- Atualizar existente
    UPDATE public.funcionarios
    SET tipo_admin = 'admin_empresa',
        status = 'ativo',
        nome = v_user_name,
        email = v_user_email
    WHERE empresa_id = v_empresa_id AND user_id = v_user_id;
    
    RAISE NOTICE '✅ Funcionário atualizado para admin_empresa';
  ELSE
    -- Criar novo
    INSERT INTO public.funcionarios (
      empresa_id,
      user_id,
      nome,
      email,
      telefone,
      status,
      tipo_admin
    ) VALUES (
      v_empresa_id,
      v_user_id,
      v_user_name,
      v_user_email,
      '(00) 00000-0000',
      'ativo',
      'admin_empresa'
    );
    
    RAISE NOTICE '✅ Funcionário criado como admin_empresa';
  END IF;

  RAISE NOTICE '🎉 SUCESSO! Todas as tabelas criadas.';
END $$;

-- Verificar se funcionou
SELECT 
  'Verificação Final' as etapa,
  (SELECT COUNT(*) FROM empresas WHERE user_id = 'a832f6a8-3e56-45cd-b33d-725fe9c19343') as tem_empresa,
  (SELECT COUNT(*) FROM user_approvals WHERE user_id = 'a832f6a8-3e56-45cd-b33d-725fe9c19343') as tem_approval,
  (SELECT COUNT(*) FROM funcionarios WHERE user_id = 'a832f6a8-3e56-45cd-b33d-725fe9c19343') as tem_funcionario,
  (SELECT tipo_admin FROM funcionarios WHERE user_id = 'a832f6a8-3e56-45cd-b33d-725fe9c19343') as tipo_admin;
