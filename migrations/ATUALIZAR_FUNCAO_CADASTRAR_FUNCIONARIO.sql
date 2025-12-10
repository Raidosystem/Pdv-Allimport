-- ========================================
-- ATUALIZAR FUNÇÃO cadastrar_funcionario_simples
-- ========================================
-- Adicionar parâmetro de email para criar conta Supabase Auth

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
BEGIN
  -- Validações
  IF p_nome IS NULL OR trim(p_nome) = '' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Nome é obrigatório'
    );
  END IF;

  IF p_email IS NULL OR trim(p_email) = '' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Email é obrigatório'
    );
  END IF;

  IF p_senha IS NULL OR length(p_senha) < 6 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Senha deve ter no mínimo 6 caracteres'
    );
  END IF;

  -- Verificar se email já existe
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = p_email) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Email já cadastrado no sistema'
    );
  END IF;

  -- Gerar usuário a partir do nome (primeiras letras)
  v_usuario := lower(regexp_replace(split_part(p_nome, ' ', 1), '[^a-zA-Z0-9]', '', 'g'));
  
  -- Garantir que o usuário é único
  WHILE EXISTS (SELECT 1 FROM login_funcionarios WHERE usuario = v_usuario) LOOP
    v_usuario := v_usuario || floor(random() * 100)::text;
  END LOOP;

  -- 1. Criar usuário no Supabase Auth
  BEGIN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      created_at,
      updated_at,
      raw_app_meta_data,
      raw_user_meta_data,
      is_super_admin,
      confirmation_token,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      p_email,
      crypt(p_senha, gen_salt('bf')),
      now(),
      now(),
      now(),
      '{"provider":"email","providers":["email"]}',
      json_build_object('full_name', p_nome),
      false,
      encode(gen_random_bytes(32), 'hex'),
      '',
      ''
    )
    RETURNING id INTO v_user_id;
  EXCEPTION
    WHEN unique_violation THEN
      RETURN json_build_object(
        'success', false,
        'error', 'Email já está em uso'
      );
    WHEN OTHERS THEN
      RETURN json_build_object(
        'success', false,
        'error', 'Erro ao criar conta: ' || SQLERRM
      );
  END;

  -- 2. Criar registro na tabela funcionarios
  BEGIN
    INSERT INTO funcionarios (
      empresa_id,
      user_id,
      nome,
      email,
      tipo_admin,
      funcao_id,
      ativo
    ) VALUES (
      p_empresa_id,
      v_user_id,
      p_nome,
      p_email,
      'funcionario',
      p_funcao_id,
      true
    )
    RETURNING id INTO v_funcionario_id;
  EXCEPTION
    WHEN OTHERS THEN
      -- Se falhar, remover usuário criado no auth
      DELETE FROM auth.users WHERE id = v_user_id;
      RETURN json_build_object(
        'success', false,
        'error', 'Erro ao criar funcionário: ' || SQLERRM
      );
  END;

  -- 3. Criar registro na tabela login_funcionarios (compatibilidade)
  BEGIN
    INSERT INTO login_funcionarios (
      funcionario_id,
      usuario,
      senha_hash,
      ativo,
      precisa_trocar_senha
    ) VALUES (
      v_funcionario_id,
      v_usuario,
      crypt(p_senha, gen_salt('bf')),
      true,
      false
    );
  EXCEPTION
    WHEN OTHERS THEN
      -- Não é crítico se falhar, apenas log
      RAISE NOTICE 'Aviso: não foi possível criar login_funcionarios: %', SQLERRM;
  END;

  -- Retornar sucesso
  RETURN json_build_object(
    'success', true,
    'funcionario_id', v_funcionario_id,
    'user_id', v_user_id,
    'usuario', v_usuario,
    'message', 'Funcionário cadastrado com sucesso'
  );

END;
$$;

-- Comentário
COMMENT ON FUNCTION cadastrar_funcionario_simples IS 'Cria funcionário com conta própria no Supabase Auth. Cada funcionário tem email e senha únicos.';

-- Testar função
SELECT '✅ Função cadastrar_funcionario_simples atualizada com suporte a email' as status;
