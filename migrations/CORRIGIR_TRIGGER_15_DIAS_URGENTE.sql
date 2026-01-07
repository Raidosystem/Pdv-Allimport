-- ============================================================================
-- CORRIGIR TRIGGER - BUG QUE IMPEDE TESTE DE 15 DIAS
-- ============================================================================
-- 🐛 PROBLEMA: status com valor 'status' ao invés de 'trial' causa erro
-- ✅ SOLUÇÃO: Corrigir para 'trial' e adicionar melhor tratamento de erros
-- ============================================================================

CREATE OR REPLACE FUNCTION create_empresa_for_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_cnpj_temp TEXT;
  v_empresa_id UUID;
BEGIN
  RAISE NOTICE '🎯 [TRIGGER] Novo usuário criado: %', NEW.email;
  
  -- Gerar CNPJ temporário único
  v_cnpj_temp := LPAD(EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT, 14, '0');
  v_cnpj_temp := SUBSTRING(v_cnpj_temp, 1, 2) || '.' || 
                 SUBSTRING(v_cnpj_temp, 3, 3) || '.' || 
                 SUBSTRING(v_cnpj_temp, 6, 3) || '/' || 
                 SUBSTRING(v_cnpj_temp, 9, 4) || '-' || 
                 SUBSTRING(v_cnpj_temp, 13, 2);

  -- 1️⃣ Criar empresa
  BEGIN
    INSERT INTO public.empresas (
      user_id,
      nome,
      cnpj,
      telefone,
      email,
      tipo_conta,
      data_fim_teste
    ) VALUES (
      NEW.id,
      COALESCE(NEW.raw_user_meta_data->>'full_name', 'Minha Empresa'),
      v_cnpj_temp,
      COALESCE(NEW.phone, '(00) 00000-0000'),
      NEW.email,
      'teste_ativo',
      NOW() + INTERVAL '15 days'
    )
    ON CONFLICT (user_id) DO NOTHING
    RETURNING id INTO v_empresa_id;

    RAISE NOTICE '✅ [TRIGGER] Empresa criada: %', v_empresa_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING '❌ [TRIGGER] Erro ao criar empresa: %', SQLERRM;
  END;

  -- 2️⃣ Criar subscription de TESTE por 15 DIAS
  BEGIN
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
      NEW.id,
      NEW.email,
      'free',
      'trial',  -- ✅ CORRIGIDO: Era 'status' e agora é 'trial'
      NOW(),
      NOW() + INTERVAL '15 days',
      NOW(),
      NOW() + INTERVAL '15 days',
      NOW(),
      NOW()
    )
    ON CONFLICT (user_id) DO NOTHING;

    RAISE NOTICE '✅ [TRIGGER] Subscription de 15 dias criada para: %', NEW.email;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING '❌ [TRIGGER] Erro ao criar subscription: %', SQLERRM;
  END;

  -- 3️⃣ Criar entrada em user_approvals como OWNER
  BEGIN
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
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuário'),
      COALESCE(NEW.raw_user_meta_data->>'full_name', 'Minha Empresa'),
      'approved',
      'owner',
      NOW(),
      NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
      user_role = 'owner',
      status = 'approved',
      updated_at = NOW();

    RAISE NOTICE '✅ [TRIGGER] user_approvals criado como OWNER para: %', NEW.email;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING '❌ [TRIGGER] Erro ao criar user_approvals: %', SQLERRM;
  END;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '❌ [TRIGGER] Erro geral no trigger: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recriar trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_empresa_for_new_user();

-- ============================================================================
-- ATIVAR MANUALMENTE O TESTE PARA O ÚLTIMO USUÁRIO (jf6059256@gmail.com)
-- ============================================================================

-- Buscar ID do último usuário
DO $$
DECLARE
  v_last_user_id UUID;
  v_last_email TEXT;
BEGIN
  -- Pegar último usuário cadastrado
  SELECT id, email INTO v_last_user_id, v_last_email
  FROM auth.users
  ORDER BY created_at DESC
  LIMIT 1;

  RAISE NOTICE '📝 Ativando teste para: % (ID: %)', v_last_email, v_last_user_id;

  -- 1. Criar empresa se não existe
  INSERT INTO public.empresas (
    user_id,
    nome,
    cnpj,
    telefone,
    email,
    tipo_conta,
    data_fim_teste
  ) VALUES (
    v_last_user_id,
    'Minha Empresa',
    LPAD(EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT, 14, '0'),
    '(00) 00000-0000',
    v_last_email,
    'teste_ativo',
    NOW() + INTERVAL '15 days'
  )
  ON CONFLICT (user_id) DO NOTHING;

  -- 2. Criar subscription de 15 dias
  INSERT INTO public.subscriptions (
    user_id,
    email,
    plan_type,
    status,
    trial_start_date,
    trial_end_date,
    subscription_start_date,
    subscription_end_date
  ) VALUES (
    v_last_user_id,
    v_last_email,
    'free',
    'trial',
    NOW(),
    NOW() + INTERVAL '15 days',
    NOW(),
    NOW() + INTERVAL '15 days'
  )
  ON CONFLICT (user_id) DO NOTHING;

  -- 3. Criar user_approvals como owner
  INSERT INTO public.user_approvals (
    user_id,
    email,
    full_name,
    company_name,
    status,
    user_role,
    approved_at
  ) VALUES (
    v_last_user_id,
    v_last_email,
    'Usuário',
    'Minha Empresa',
    'approved',
    'owner',
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    user_role = 'owner',
    status = 'approved',
    updated_at = NOW();

  RAISE NOTICE '✅ Teste de 15 dias ativado com sucesso para: %', v_last_email;
END $$;

-- ============================================================================
-- VERIFICAR SE FUNCIONOU
-- ============================================================================

-- Ver último usuário e seus dados
SELECT 
  u.email,
  ua.user_role,
  ua.status as approval_status,
  e.tipo_conta,
  e.data_fim_teste,
  s.status as subscription_status,
  s.trial_end_date,
  '✅ Dados criados' as resultado
FROM auth.users u
LEFT JOIN user_approvals ua ON ua.user_id = u.id
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN subscriptions s ON s.user_id = u.id
ORDER BY u.created_at DESC
LIMIT 1;
