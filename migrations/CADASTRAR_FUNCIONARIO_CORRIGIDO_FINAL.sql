-- Versão FINAL CORRIGIDA da função de cadastro
-- Problema identificado: foreign key constraint falha porque v_funcionario_id está NULL/inválido

CREATE OR REPLACE FUNCTION cadastrar_funcionario_simples(
  p_empresa_id uuid,
  p_nome text,
  p_email text,
  p_senha text,
  p_funcao_id uuid DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_funcionario_id uuid;
  v_user_id uuid;
  v_usuario text;
  v_email_existe boolean;
  v_senha_hash text;
BEGIN
  -- Validações básicas
  IF p_nome IS NULL OR trim(p_nome) = '' THEN
    RETURN json_build_object('success', false, 'error', 'Nome é obrigatório');
  END IF;

  IF p_email IS NULL OR trim(p_email) = '' THEN
    RETURN json_build_object('success', false, 'error', 'Email é obrigatório');
  END IF;

  IF p_senha IS NULL OR length(p_senha) < 6 THEN
    RETURN json_build_object('success', false, 'error', 'Senha deve ter no mínimo 6 caracteres');
  END IF;

  -- Verificar se email já está em uso
  SELECT EXISTS (
    SELECT 1 FROM auth.users au
    JOIN funcionarios f ON f.user_id = au.id
    WHERE au.email = p_email AND f.empresa_id = p_empresa_id
  ) INTO v_email_existe;

  IF v_email_existe THEN
    RETURN json_build_object('success', false, 'error', 'Email já cadastrado');
  END IF;

  -- Limpar usuário órfão se existir
  DELETE FROM auth.users
  WHERE email = p_email
    AND id NOT IN (SELECT user_id FROM funcionarios WHERE user_id IS NOT NULL);

  -- Gerar usuário único
  v_usuario := lower(regexp_replace(split_part(p_nome, ' ', 1), '[^a-zA-Z0-9]', '', 'g'));
  WHILE EXISTS (SELECT 1 FROM login_funcionarios WHERE usuario = v_usuario) LOOP
    v_usuario := v_usuario || floor(random() * 100)::text;
  END LOOP;

  -- ✅ GERAR HASH DA SENHA ANTES DE TUDO
  v_senha_hash := crypt(p_senha, gen_salt('bf'));
  
  IF v_senha_hash IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Erro ao criptografar senha');
  END IF;

  -- 1. Criar usuário no auth.users
  BEGIN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data, is_super_admin,
      confirmation_token, email_change_token_new, recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000', gen_random_uuid(),
      'authenticated', 'authenticated', p_email,
      v_senha_hash, now(), now(), now(),
      '{"provider":"email","providers":["email"]}',
      json_build_object('full_name', p_nome), false,
      encode(gen_random_bytes(32), 'hex'), '', ''
    ) RETURNING id INTO v_user_id;
    
    IF v_user_id IS NULL THEN
      RETURN json_build_object('success', false, 'error', 'Falha ao criar usuário no auth');
    END IF;
    
  EXCEPTION
    WHEN unique_violation THEN
      RETURN json_build_object('success', false, 'error', 'Email já em uso');
    WHEN OTHERS THEN
      RETURN json_build_object('success', false, 'error', 'Erro ao criar conta: ' || SQLERRM);
  END;

  -- 2. Criar funcionário
  BEGIN
    INSERT INTO funcionarios (
      empresa_id, user_id, nome, email, tipo_admin,
      funcao_id, status, usuario_ativo, senha_definida
    ) VALUES (
      p_empresa_id, v_user_id, p_nome, p_email, 'funcionario',
      p_funcao_id, 'ativo', true, true
    ) RETURNING id INTO v_funcionario_id;
    
    IF v_funcionario_id IS NULL THEN
      DELETE FROM auth.users WHERE id = v_user_id;
      RETURN json_build_object('success', false, 'error', 'Falha ao criar registro de funcionário');
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      DELETE FROM auth.users WHERE id = v_user_id;
      RETURN json_build_object('success', false, 'error', 'Erro ao criar funcionário: ' || SQLERRM);
  END;

  -- 3. Criar login_funcionarios
  BEGIN
    INSERT INTO login_funcionarios (funcionario_id, usuario, senha, ativo)
    VALUES (v_funcionario_id, v_usuario, v_senha_hash, true);
    
  EXCEPTION
    WHEN OTHERS THEN
      DELETE FROM funcionarios WHERE id = v_funcionario_id;
      DELETE FROM auth.users WHERE id = v_user_id;
      RETURN json_build_object('success', false, 'error', 'Erro ao criar login: ' || SQLERRM);
  END;

  RETURN json_build_object(
    'success', true,
    'message', 'Funcionário criado com sucesso',
    'funcionario_id', v_funcionario_id,
    'usuario', v_usuario
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'error', 'Erro inesperado: ' || SQLERRM);
END;
$$;

COMMENT ON FUNCTION cadastrar_funcionario_simples IS 'Cadastra funcionário com validação completa e rollback em caso de erro';
