-- ============================================
-- CORRIGIR TRIGGER - ADICIONAR user_approvals COM owner
-- ============================================
-- PROBLEMA: Novos usuários que compram o sistema não são marcados como 'owner'
-- SOLUÇÃO: Adicionar INSERT em user_approvals no trigger

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

  -- Criar empresa
  INSERT INTO public.empresas (
    user_id,
    nome,
    cnpj,
    telefone,
    email
  ) VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Minha Empresa'),
    v_cnpj_temp,
    COALESCE(NEW.phone, '(00) 00000-0000'),
    NEW.email
  )
  ON CONFLICT (user_id) DO NOTHING
  RETURNING id INTO v_empresa_id;

  RAISE NOTICE '✅ [TRIGGER] Empresa criada: %', v_empresa_id;

  -- Criar subscription de TESTE por 15 DIAS
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
    'status',
    NOW(),
    NOW() + INTERVAL '15 days',
    NOW(),
    NOW() + INTERVAL '15 days',
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO NOTHING;

  RAISE NOTICE '✅ [TRIGGER] Subscription de 15 dias criada para: %', NEW.email;

  -- ✅ NOVO: Criar entrada em user_approvals como OWNER
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
    'owner', -- ✅ DONO DA EMPRESA
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    user_role = 'owner',
    updated_at = NOW();

  RAISE NOTICE '✅ [TRIGGER] user_approvals criado como OWNER para: %', NEW.email;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '❌ [TRIGGER] Erro ao criar empresa/subscription: %', SQLERRM;
    RETURN NEW; -- Não bloquear cadastro mesmo se houver erro
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recriar trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_empresa_for_new_user();

-- ============================================
-- RESULTADO:
-- ============================================
-- ✅ Novos usuários que comprarem o sistema serão automaticamente:
--    1. Empresa criada
--    2. Subscription de 15 dias (trial)
--    3. user_approvals com user_role = 'owner' (PERMISSÕES TOTAIS)
--
-- ✅ Funcionários criados via funcionarioAuthService.ts:
--    - user_approvals com user_role = 'employee' (permissões da função)
--
-- ✅ Sistema funcionará perfeitamente para novos clientes!
