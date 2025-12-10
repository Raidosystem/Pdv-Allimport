-- 🎯 CRIAR USUÁRIO COMO ADMIN DA EMPRESA
-- Execute APÓS corrigir a recursão RLS

-- ⚠️ CONFIGURE O EMAIL DO USUÁRIO AQUI:
DO $$
DECLARE
  v_email TEXT := 'assistenciaallimport10@gmail.com'; -- ✏️ MUDE AQUI
  v_user_id UUID;
  v_empresa_id UUID;
  v_funcionario_id UUID;
BEGIN
  -- 1️⃣ Buscar user_id pelo email no auth.users
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = v_email;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário com email % não encontrado', v_email;
  END IF;
  
  RAISE NOTICE '✅ Usuário encontrado: % (ID: %)', v_email, v_user_id;
  
  -- 2️⃣ Verificar se já existe empresa
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE user_id = v_user_id;
  
  IF v_empresa_id IS NULL THEN
    -- Criar empresa se não existir
    INSERT INTO empresas (user_id, nome, email)
    VALUES (
      v_user_id,
      (SELECT COALESCE(raw_user_meta_data->>'company_name', 'Minha Empresa') FROM auth.users WHERE id = v_user_id),
      v_email
    )
    RETURNING id INTO v_empresa_id;
    
    RAISE NOTICE '✅ Empresa criada: %', v_empresa_id;
  ELSE
    RAISE NOTICE '✅ Empresa já existe: %', v_empresa_id;
  END IF;
  
  -- 3️⃣ Verificar se já existe funcionário
  SELECT id INTO v_funcionario_id
  FROM funcionarios
  WHERE user_id = v_user_id;
  
  IF v_funcionario_id IS NULL THEN
    -- Criar funcionário como admin da empresa
    INSERT INTO funcionarios (
      empresa_id,
      user_id,
      nome,
      email,
      telefone,
      cargo,
      tipo_admin,
      status
    )
    VALUES (
      v_empresa_id,
      v_user_id,
      (SELECT COALESCE(raw_user_meta_data->>'full_name', 'Administrador') FROM auth.users WHERE id = v_user_id),
      v_email,
      (SELECT COALESCE(phone, '(00) 00000-0000') FROM auth.users WHERE id = v_user_id),
      'Administrador',
      'admin_empresa', -- ⭐ TIPO ADMIN
      'ativo'
    )
    RETURNING id INTO v_funcionario_id;
    
    RAISE NOTICE '✅ Funcionário criado como admin_empresa: %', v_funcionario_id;
  ELSE
    -- Atualizar funcionário existente para admin_empresa
    UPDATE funcionarios
    SET 
      tipo_admin = 'admin_empresa',
      status = 'ativo',
      cargo = 'Administrador'
    WHERE id = v_funcionario_id;
    
    RAISE NOTICE '✅ Funcionário atualizado para admin_empresa: %', v_funcionario_id;
  END IF;
  
END $$;

-- 🔍 VERIFICAR RESULTADO
SELECT 
  '✅ RESULTADO' as status,
  u.email,
  e.id as empresa_id,
  e.nome as empresa_nome,
  f.id as funcionario_id,
  f.nome as funcionario_nome,
  f.tipo_admin,
  f.status,
  f.cargo
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id
WHERE u.email = 'assistenciaallimport10@gmail.com'; -- ✏️ MUDE AQUI TAMBÉM

-- ✅ RESULTADO ESPERADO:
-- - empresa_id: UUID da empresa
-- - funcionario_id: UUID do funcionário
-- - tipo_admin: 'admin_empresa'
-- - status: 'ativo'
-- - cargo: 'Administrador'
