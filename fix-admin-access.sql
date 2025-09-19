-- ========================================
-- SCRIPT PARA RESOLVER PROBLEMA DE ACESSO ADMINISTRATIVO
-- ========================================

-- 1. Verificar se o usuário tem registro de funcionário
SELECT 
  au.id as user_id,
  au.email,
  f.id as funcionario_id,
  f.nome,
  f.tipo_admin,
  f.status,
  f.empresa_id
FROM auth.users au
LEFT JOIN public.funcionarios f ON f.user_id = au.id
WHERE au.email = 'novaradiosystem@outlook.com';

-- 2. Se não existe funcionário, criar um como admin_empresa
DO $$
DECLARE
  v_user_id uuid;
  v_empresa_id uuid;
  v_funcionario_id uuid;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id 
  FROM auth.users 
  WHERE email = 'novaradiosystem@outlook.com';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário não encontrado';
  END IF;
  
  -- Verificar se já existe funcionário
  SELECT id INTO v_funcionario_id
  FROM public.funcionarios
  WHERE user_id = v_user_id;
  
  IF v_funcionario_id IS NULL THEN
    -- Buscar empresa padrão ou criar uma
    SELECT id INTO v_empresa_id
    FROM public.empresas
    LIMIT 1;
    
    IF v_empresa_id IS NULL THEN
      -- Criar empresa padrão
      INSERT INTO public.empresas (nome, cnpj, telefone, email)
      VALUES ('Allimport', '00.000.000/0001-00', '(00) 0000-0000', 'novaradiosystem@outlook.com')
      RETURNING id INTO v_empresa_id;
    END IF;
    
    -- Criar funcionário como admin_empresa
    INSERT INTO public.funcionarios (
      user_id,
      empresa_id,
      nome,
      email,
      tipo_admin,
      status
    ) VALUES (
      v_user_id,
      v_empresa_id,
      'Administrador',
      'novaradiosystem@outlook.com',
      'admin_empresa',
      'ativo'
    ) RETURNING id INTO v_funcionario_id;
    
    RAISE NOTICE 'Funcionário criado com ID: %', v_funcionario_id;
  ELSE
    -- Atualizar funcionário existente para admin_empresa
    UPDATE public.funcionarios
    SET 
      tipo_admin = 'admin_empresa',
      status = 'ativo'
    WHERE id = v_funcionario_id;
    
    RAISE NOTICE 'Funcionário atualizado para admin_empresa: %', v_funcionario_id;
  END IF;
END $$;

-- 3. Verificar se existem funções básicas na empresa
DO $$
DECLARE
  v_empresa_id uuid;
  v_admin_role_id uuid;
BEGIN
  -- Buscar empresa
  SELECT id INTO v_empresa_id 
  FROM public.empresas 
  LIMIT 1;
  
  IF v_empresa_id IS NOT NULL THEN
    -- Verificar se existe função de Administrador
    SELECT id INTO v_admin_role_id
    FROM public.funcoes
    WHERE empresa_id = v_empresa_id 
    AND nome = 'Administrador';
    
    IF v_admin_role_id IS NULL THEN
      -- Criar função de Administrador
      INSERT INTO public.funcoes (
        empresa_id,
        nome,
        descricao,
        is_system
      ) VALUES (
        v_empresa_id,
        'Administrador',
        'Acesso total ao sistema',
        true
      ) RETURNING id INTO v_admin_role_id;
      
      -- Associar todas as permissões ao Administrador
      INSERT INTO public.funcao_permissoes (funcao_id, permissao_id, empresa_id)
      SELECT v_admin_role_id, p.id, v_empresa_id
      FROM public.permissoes p;
      
      RAISE NOTICE 'Função Administrador criada: %', v_admin_role_id;
    END IF;
  END IF;
END $$;

-- 4. Verificar resultado final
SELECT 
  'STATUS FINAL' as tipo,
  au.email,
  f.nome as funcionario_nome,
  f.tipo_admin,
  f.status,
  e.nome as empresa_nome
FROM auth.users au
JOIN public.funcionarios f ON f.user_id = au.id
JOIN public.empresas e ON e.id = f.empresa_id
WHERE au.email = 'novaradiosystem@outlook.com';

-- 5. Verificar permissões do funcionário
SELECT 
  'PERMISSOES' as tipo,
  f.nome as funcionario,
  func.nome as funcao,
  p.recurso,
  p.acao
FROM public.funcionarios f
JOIN public.funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN public.funcoes func ON func.id = ff.funcao_id
JOIN public.funcao_permissoes fp ON fp.funcao_id = func.id
JOIN public.permissoes p ON p.id = fp.permissao_id
JOIN auth.users au ON au.id = f.user_id
WHERE au.email = 'novaradiosystem@outlook.com'
ORDER BY p.recurso, p.acao;