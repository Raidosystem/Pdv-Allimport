-- ========================================
-- VERIFICAR E CRIAR FUNCIONÁRIO PARA novaradiosystem@outlook.com
-- ========================================

-- 1. Verificar se existe o usuário no auth.users
SELECT 
  id,
  email,
  raw_user_meta_data,
  created_at
FROM auth.users
WHERE email = 'novaradiosystem@outlook.com';

-- 2. Verificar se existe funcionário para este usuário
SELECT 
  id,
  nome,
  email,
  user_id,
  empresa_id,
  funcao_id,
  tipo_admin,
  status,
  created_at
FROM funcionarios
WHERE email = 'novaradiosystem@outlook.com'
   OR user_id = (SELECT id FROM auth.users WHERE email = 'novaradiosystem@outlook.com');

-- 3. Verificar funções disponíveis
SELECT 
  id,
  nome,
  descricao,
  nivel_acesso
FROM funcoes
ORDER BY nivel_acesso DESC;

-- 4. SE NÃO EXISTIR, criar funcionário admin para novaradiosystem@outlook.com
DO $$
DECLARE
  v_user_id uuid;
  v_funcao_admin_id uuid;
  v_funcionario_id uuid;
BEGIN
  -- Pegar o user_id do auth.users
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = 'novaradiosystem@outlook.com';
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ Usuário novaradiosystem@outlook.com não encontrado no auth.users';
    RETURN;
  END IF;
  
  RAISE NOTICE '✅ User ID encontrado: %', v_user_id;
  
  -- Verificar se já existe funcionário
  SELECT id INTO v_funcionario_id
  FROM funcionarios
  WHERE user_id = v_user_id OR email = 'novaradiosystem@outlook.com';
  
  IF v_funcionario_id IS NOT NULL THEN
    RAISE NOTICE '✅ Funcionário já existe com ID: %', v_funcionario_id;
    
    -- Atualizar para garantir que está como admin
    UPDATE funcionarios
    SET 
      tipo_admin = 'admin_empresa',
      status = 'ativo',
      user_id = v_user_id,
      empresa_id = v_user_id
    WHERE id = v_funcionario_id;
    
    RAISE NOTICE '✅ Funcionário atualizado para admin_empresa';
    RETURN;
  END IF;
  
  -- Buscar ou criar função "Administrador"
  SELECT id INTO v_funcao_admin_id
  FROM funcoes
  WHERE nome = 'Administrador'
    AND empresa_id = v_user_id
  LIMIT 1;
  
  IF v_funcao_admin_id IS NULL THEN
    RAISE NOTICE '⚠️ Função Administrador não encontrada para empresa. Criando...';
    
    INSERT INTO funcoes (
      empresa_id,
      user_id,
      nome,
      descricao,
      nivel_acesso,
      escopo_lojas
    ) VALUES (
      v_user_id,
      v_user_id,
      'Administrador',
      'Acesso total ao sistema',
      100,
      ARRAY[]::text[]
    )
    RETURNING id INTO v_funcao_admin_id;
    
    RAISE NOTICE '✅ Função Administrador criada com ID: %', v_funcao_admin_id;
  END IF;
  
  -- Criar funcionário admin
  INSERT INTO funcionarios (
    empresa_id,
    user_id,
    nome,
    email,
    cpf,
    telefone,
    funcao_id,
    tipo_admin,
    status,
    senha,
    senha_aparelho,
    permissoes
  ) VALUES (
    v_user_id,
    v_user_id,
    'Administrador Principal',
    'novaradiosystem@outlook.com',
    '00000000000',
    '',
    v_funcao_admin_id,
    'admin_empresa',
    'ativo',
    crypt('admin123', gen_salt('bf')),
    '0000',
    jsonb_build_object(
      'vendas', true,
      'produtos', true,
      'clientes', true,
      'caixa', true,
      'ordens_servico', true,
      'relatorios', true,
      'configuracoes', true,
      'backup', true
    )
  )
  RETURNING id INTO v_funcionario_id;
  
  RAISE NOTICE '✅ Funcionário admin criado com ID: %', v_funcionario_id;
  
  -- Atualizar user_metadata do auth.users
  UPDATE auth.users
  SET raw_user_meta_data = raw_user_meta_data || 
    jsonb_build_object(
      'funcionario_id', v_funcionario_id,
      'tipo_admin', 'admin_empresa',
      'role', 'admin'
    )
  WHERE id = v_user_id;
  
  RAISE NOTICE '✅ user_metadata atualizado no auth.users';
  
END $$;

-- 5. Verificar resultado final
SELECT 
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.user_id,
  f.empresa_id,
  f.funcao_id,
  f.tipo_admin,
  f.status,
  func.nome as funcao_nome,
  u.email as user_email,
  u.raw_user_meta_data->>'funcionario_id' as metadata_funcionario_id
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN auth.users u ON u.id = f.user_id
WHERE f.email = 'novaradiosystem@outlook.com'
   OR f.user_id = (SELECT id FROM auth.users WHERE email = 'novaradiosystem@outlook.com');
