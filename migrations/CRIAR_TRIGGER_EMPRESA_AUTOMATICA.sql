-- ============================================
-- CRIAR EMPRESA AUTOMATICAMENTE PARA NOVOS USUÁRIOS
-- ============================================
-- Este script cria um trigger que automaticamente cria:
-- 1. Empresa para o usuário
-- 2. Subscription ativa por 1 ano
-- Sempre que um novo usuário se cadastrar

-- 1. CRIAR FUNÇÃO QUE SERÁ EXECUTADA AUTOMATICAMENTE
CREATE OR REPLACE FUNCTION create_empresa_for_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_cnpj_temp TEXT;
BEGIN
  -- Gerar CNPJ temporário único baseado no timestamp
  v_cnpj_temp := LPAD(EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT, 14, '0');
  v_cnpj_temp := SUBSTRING(v_cnpj_temp, 1, 2) || '.' || 
                 SUBSTRING(v_cnpj_temp, 3, 3) || '.' || 
                 SUBSTRING(v_cnpj_temp, 6, 3) || '/' || 
                 SUBSTRING(v_cnpj_temp, 9, 4) || '-' || 
                 SUBSTRING(v_cnpj_temp, 13, 2);

  -- Criar empresa para o novo usuário
  INSERT INTO public.empresas (
    user_id,
    nome,
    cnpj,
    telefone,
    email,
    endereco,
    cidade,
    estado,
    cep
  ) VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Minha Empresa'),
    v_cnpj_temp,
    COALESCE(NEW.phone, '(00) 00000-0000'),
    NEW.email,
    'Endereço não informado',
    'São Paulo',
    'SP',
    '00000-000'
  );

  -- Criar subscription ativa por 1 ano
  INSERT INTO public.subscriptions (
    user_id,
    plan_type,
    status,
    subscription_start_date,
    subscription_end_date
  ) VALUES (
    NEW.id,
    'yearly',
    'active',
    NOW(),
    NOW() + INTERVAL '1 year'
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. REMOVER TRIGGER SE JÁ EXISTIR
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 3. CRIAR TRIGGER NA TABELA auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_empresa_for_new_user();

-- 4. CRIAR EMPRESAS PARA USUÁRIOS EXISTENTES QUE NÃO TÊM
DO $$
DECLARE
  v_user RECORD;
  v_cnpj_temp TEXT;
  v_counter INT := 1;
BEGIN
  FOR v_user IN 
    SELECT u.id, u.email, u.phone, u.raw_user_meta_data
    FROM auth.users u
    WHERE NOT EXISTS (
      SELECT 1 FROM public.empresas e WHERE e.user_id = u.id
    )
  LOOP
    -- Gerar CNPJ único para cada usuário
    v_cnpj_temp := LPAD((EXTRACT(EPOCH FROM NOW())::BIGINT + v_counter)::TEXT, 14, '0');
    v_cnpj_temp := SUBSTRING(v_cnpj_temp, 1, 2) || '.' || 
                   SUBSTRING(v_cnpj_temp, 3, 3) || '.' || 
                   SUBSTRING(v_cnpj_temp, 6, 3) || '/' || 
                   SUBSTRING(v_cnpj_temp, 9, 4) || '-' || 
                   SUBSTRING(v_cnpj_temp, 13, 2);

    INSERT INTO public.empresas (
      user_id,
      nome,
      cnpj,
      telefone,
      email,
      endereco,
      cidade,
      estado,
      cep
    ) VALUES (
      v_user.id,
      COALESCE(v_user.raw_user_meta_data->>'full_name', 'Minha Empresa'),
      v_cnpj_temp,
      COALESCE(v_user.phone, '(00) 00000-0000'),
      v_user.email,
      'Endereço não informado',
      'São Paulo',
      'SP',
      '00000-000'
    );

    v_counter := v_counter + 1;
  END LOOP;

  RAISE NOTICE 'Empresas criadas para % usuários', v_counter - 1;
END $$;

-- 5. CRIAR SUBSCRIPTIONS PARA USUÁRIOS EXISTENTES QUE NÃO TÊM
INSERT INTO public.subscriptions (
  user_id,
  plan_type,
  status,
  subscription_start_date,
  subscription_end_date
)
SELECT 
  u.id,
  'yearly',
  'active',
  NOW(),
  NOW() + INTERVAL '1 year'
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.subscriptions s WHERE s.user_id = u.id
);

-- 6. VERIFICAR RESULTADO - TODOS OS USUÁRIOS DEVEM TER EMPRESA E SUBSCRIPTION
SELECT 
  u.email as usuario_email,
  e.nome as empresa_nome,
  s.plan_type as plano,
  s.status as status_assinatura,
  CASE 
    WHEN e.id IS NULL THEN '❌ SEM EMPRESA'
    WHEN s.id IS NULL THEN '❌ SEM SUBSCRIPTION'
    ELSE '✅ OK'
  END as status_geral
FROM auth.users u
LEFT JOIN public.empresas e ON e.user_id = u.id
LEFT JOIN public.subscriptions s ON s.user_id = u.id
ORDER BY u.created_at DESC;

-- 7. TESTE DO TRIGGER
-- Quando um novo usuário se cadastrar, automaticamente será criado:
-- - Registro na tabela empresas
-- - Registro na tabela subscriptions
-- Não é necessário fazer nada manualmente!

-- 8. VERIFICAR SE O TRIGGER FOI CRIADO
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
