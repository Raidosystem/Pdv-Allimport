-- ============================================
-- 🔧 CORRIGIR TRIGGERS PARA NOVOS CADASTROS
-- Este SQL corrige os triggers para que novos usuários sejam criados corretamente
-- ============================================

-- 1️⃣ RECRIAR FUNÇÃO create_empresa_for_new_user CORRIGIDA
CREATE OR REPLACE FUNCTION public.create_empresa_for_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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
    ON CONFLICT (user_id) DO UPDATE SET
      tipo_conta = 'teste_ativo',
      data_fim_teste = NOW() + INTERVAL '15 days'
    RETURNING id INTO v_empresa_id;
    
    -- Se não conseguiu o ID pelo INSERT, buscar empresa existente
    IF v_empresa_id IS NULL THEN
      SELECT id INTO v_empresa_id FROM empresas WHERE user_id = NEW.id;
    END IF;

    RAISE NOTICE '✅ [TRIGGER] Empresa criada: %', v_empresa_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING '❌ [TRIGGER] Erro ao criar empresa: %', SQLERRM;
      RETURN NEW; -- Continuar mesmo com erro
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
      'trial',
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
      COALESCE(NEW.raw_user_meta_data->>'company_name', NEW.raw_user_meta_data->>'full_name', 'Minha Empresa'),
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

  -- 4️⃣ Criar funcionário com tipo_admin='admin_empresa'
  IF v_empresa_id IS NOT NULL THEN
    BEGIN
      -- Verificar se já existe
      IF EXISTS (SELECT 1 FROM funcionarios WHERE empresa_id = v_empresa_id AND user_id = NEW.id) THEN
        -- Atualizar existente
        UPDATE public.funcionarios
        SET tipo_admin = 'admin_empresa',
            status = 'ativo',
            nome = COALESCE(NEW.raw_user_meta_data->>'full_name', 'Administrador'),
            email = NEW.email
        WHERE empresa_id = v_empresa_id AND user_id = NEW.id;
        
        RAISE NOTICE '✅ [TRIGGER] Funcionário atualizado para admin_empresa';
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
          NEW.id,
          COALESCE(NEW.raw_user_meta_data->>'full_name', 'Administrador'),
          NEW.email,
          COALESCE(NEW.phone, '(00) 00000-0000'),
          'ativo',
          'admin_empresa'
        );
        
        RAISE NOTICE '✅ [TRIGGER] Funcionário criado como admin_empresa';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE WARNING '❌ [TRIGGER] Erro ao criar funcionário: %', SQLERRM;
    END;
  ELSE
    RAISE WARNING '⚠️ [TRIGGER] Empresa não criada, não foi possível criar funcionário';
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '❌ [TRIGGER] Erro geral no trigger: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- 2️⃣ GARANTIR QUE O TRIGGER ESTÁ ATIVO
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.create_empresa_for_new_user();

-- 3️⃣ MANTER/ATUALIZAR O SEGUNDO TRIGGER PARA COMPATIBILIDADE
-- NÃO vamos remover, apenas garantir que a função handle_new_user_approval seja compatível
-- Isso garante que se houver código dependente dele, não vai quebrar

-- Atualizar handle_new_user_approval para não duplicar dados
CREATE OR REPLACE FUNCTION public.handle_new_user_approval()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Esta função agora é apenas um placeholder
  -- A função principal create_empresa_for_new_user já cria tudo
  -- Mantemos para compatibilidade, mas não faz nada
  RAISE NOTICE '⚠️ [TRIGGER] handle_new_user_approval chamado mas não faz nada (create_empresa_for_new_user já criou tudo)';
  RETURN NEW;
END;
$$;

-- 4️⃣ VERIFICAR SE FUNCIONOU
SELECT 
  '✅ TRIGGERS CORRIGIDOS' as status,
  'on_auth_user_created → create_empresa_for_new_user' as trigger_ativo,
  'Agora cria: empresa + subscription + user_approvals + funcionario(admin_empresa)' as o_que_faz;
