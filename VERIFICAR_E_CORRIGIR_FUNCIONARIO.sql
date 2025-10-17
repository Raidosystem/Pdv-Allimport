-- ========================================
-- VERIFICAR E CORRIGIR USUÁRIO SEM FUNCIONÁRIO
-- ========================================

-- 1. VERIFICAR se o usuário tem registro em funcionarios
SELECT 
  'Verificando funcionário para user_id...' as status;

SELECT 
  f.id,
  f.user_id,
  f.empresa_id,
  f.nome,
  f.email,
  f.status
FROM funcionarios f
WHERE f.user_id = auth.uid();

-- Se não retornar nada, o usuário não tem registro em funcionarios!

-- 2. VERIFICAR dados do usuário autenticado
SELECT 
  'Dados do usuário autenticado...' as status;

SELECT 
  id as user_id,
  email,
  created_at
FROM auth.users
WHERE id = auth.uid();

-- 3. VERIFICAR empresas existentes
SELECT 
  'Empresas existentes...' as status;

SELECT 
  id,
  nome,
  razao_social,
  cnpj,
  created_at
FROM empresas
ORDER BY created_at DESC
LIMIT 5;

-- 3.1 VERIFICAR assinaturas (planos)
SELECT 
  'Assinaturas existentes...' as status;

SELECT 
  s.id,
  s.user_id,
  s.plan_type,
  s.status,
  s.trial_end_date,
  s.subscription_end_date,
  u.email as user_email
FROM subscriptions s
LEFT JOIN auth.users u ON u.id = s.user_id
ORDER BY s.created_at DESC
LIMIT 5;

-- ========================================
-- SOLUÇÃO: CRIAR FUNCIONÁRIO PARA USUÁRIO
-- ========================================
-- Execute este bloco se o usuário não tiver funcionário

-- IMPORTANTE: Substitua 'ID_DA_SUA_EMPRESA' pelo ID real da sua empresa
-- Você pode pegar o ID da empresa na query acima

DO $$
DECLARE
  v_user_id uuid;
  v_user_email text;
  v_empresa_id uuid;
BEGIN
  -- Pegar dados do usuário atual
  SELECT id, email INTO v_user_id, v_user_email
  FROM auth.users
  WHERE id = auth.uid();

  -- Pegar primeira empresa (ou você pode especificar o ID)
  SELECT id INTO v_empresa_id
  FROM empresas
  ORDER BY created_at DESC
  LIMIT 1;

  -- Verificar se já existe
  IF NOT EXISTS (SELECT 1 FROM funcionarios WHERE user_id = v_user_id) THEN
    -- Criar funcionário
    INSERT INTO funcionarios (
      user_id,
      empresa_id,
      nome,
      email,
      cargo,
      status,
      is_main_account
    ) VALUES (
      v_user_id,
      v_empresa_id,
      'Administrador', -- Você pode mudar o nome
      v_user_email,
      'Administrador',
      'ativo',
      true -- Define como conta principal (admin)
    );

    RAISE NOTICE 'Funcionário criado com sucesso para user_id: %', v_user_id;
  ELSE
    RAISE NOTICE 'Funcionário já existe para user_id: %', v_user_id;
  END IF;
END;
$$;

-- 4. VERIFICAR se foi criado
SELECT 
  'Verificando se funcionário foi criado...' as status;

SELECT 
  f.id,
  f.user_id,
  f.empresa_id,
  f.nome,
  f.email,
  f.cargo,
  f.status,
  f.is_main_account,
  e.nome as empresa_nome,
  e.razao_social,
  s.plan_type as plano,
  s.status as assinatura_status,
  s.trial_end_date,
  s.subscription_end_date
FROM funcionarios f
INNER JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN subscriptions s ON s.user_id = f.user_id
WHERE f.user_id = auth.uid();
