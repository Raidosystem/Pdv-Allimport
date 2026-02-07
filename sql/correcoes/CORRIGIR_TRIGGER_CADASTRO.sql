-- ============================================
-- CORRIGIR TRIGGER E USUÁRIOS SEM EMPRESA
-- ============================================

-- 1️⃣ RECRIAR FUNÇÃO DO TRIGGER (CORRIGIDA)
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

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '❌ [TRIGGER] Erro ao criar empresa/subscription: %', SQLERRM;
    RETURN NEW; -- Não bloquear cadastro mesmo se houver erro
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2️⃣ RECRIAR TRIGGER
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_empresa_for_new_user();

-- 3️⃣ CORRIGIR USUÁRIOS EXISTENTES SEM EMPRESA/SUBSCRIPTION
DO $$
DECLARE
  v_user RECORD;
  v_cnpj_temp TEXT;
  v_empresa_id UUID;
  v_count INT := 0;
BEGIN
  -- Para cada usuário sem empresa
  FOR v_user IN 
    SELECT u.id, u.email, u.raw_user_meta_data, u.phone
    FROM auth.users u
    LEFT JOIN empresas e ON e.user_id = u.id
    WHERE e.id IS NULL
  LOOP
    v_count := v_count + 1;
    
    RAISE NOTICE '🔧 Corrigindo usuário: %', v_user.email;
    
    -- Gerar CNPJ único
    v_cnpj_temp := LPAD((EXTRACT(EPOCH FROM NOW()) + v_count)::BIGINT::TEXT, 14, '0');
    v_cnpj_temp := SUBSTRING(v_cnpj_temp, 1, 2) || '.' || 
                   SUBSTRING(v_cnpj_temp, 3, 3) || '.' || 
                   SUBSTRING(v_cnpj_temp, 6, 3) || '/' || 
                   SUBSTRING(v_cnpj_temp, 9, 4) || '-' || 
                   SUBSTRING(v_cnpj_temp, 13, 2);
    
    -- Criar empresa
    INSERT INTO empresas (
      user_id,
      nome,
      cnpj,
      telefone,
      email
    ) VALUES (
      v_user.id,
      COALESCE(v_user.raw_user_meta_data->>'full_name', 'Minha Empresa'),
      v_cnpj_temp,
      COALESCE(v_user.phone, '(00) 00000-0000'),
      v_user.email
    )
    ON CONFLICT (user_id) DO NOTHING
    RETURNING id INTO v_empresa_id;
    
    -- Criar subscription de 15 dias
    INSERT INTO subscriptions (
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
      v_user.id,
      v_user.email,
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
    
    RAISE NOTICE '✅ Usuário % corrigido!', v_user.email;
  END LOOP;
  
  RAISE NOTICE '✅ Total de usuários corrigidos: %', v_count;
END $$;

-- 4️⃣ VERIFICAR RESULTADO
SELECT 
  u.email,
  e.nome as empresa,
  s.status as subscription_status,
  EXTRACT(DAY FROM (COALESCE(s.trial_end_date, s.subscription_end_date) - NOW())) as dias_restantes,
  CASE 
    WHEN e.id IS NULL THEN '❌ SEM EMPRESA'
    WHEN s.id IS NULL THEN '❌ SEM SUBSCRIPTION'
    ELSE '✅ OK'
  END as status
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN subscriptions s ON s.user_id = u.id
ORDER BY u.created_at DESC
LIMIT 10;
