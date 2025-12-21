-- ========================================
-- CORRIGIR PRIMEIRO ACESSO E TROCA DE SENHA
-- ========================================
-- Problema: Ao criar funcionário, sistema não pede para trocar senha
-- Causa: função cadastrar_funcionario_simples define senha_definida=true
-- Solução: Definir senha_definida=false e primeiro_acesso=true

-- ========================================
-- 1️⃣ RECRIAR FUNÇÃO COM CORREÇÃO
-- ========================================

-- Primeiro, remover a função existente
DROP FUNCTION IF EXISTS cadastrar_funcionario_simples(uuid, text, text, text, uuid);

-- Agora criar a função corrigida
CREATE OR REPLACE FUNCTION cadastrar_funcionario_simples(
  p_empresa_id uuid,
  p_nome text,
  p_email text,
  p_senha text,
  p_funcao_id uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_funcionario_id uuid;
  v_usuario text;
  v_senha_hash text;
BEGIN
  -- Validar campos obrigatórios
  IF p_empresa_id IS NULL OR p_nome IS NULL OR p_email IS NULL OR p_senha IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Campos obrigatórios não preenchidos'
    );
  END IF;

  -- Gerar nome de usuário baseado no nome (primeira parte do nome)
  v_usuario := lower(split_part(p_nome, ' ', 1));
  
  -- Gerar hash da senha ANTES de usar
  v_senha_hash := crypt(p_senha, gen_salt('bf'));

  -- Validar que hash foi gerado
  IF v_senha_hash IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Erro ao gerar hash da senha'
    );
  END IF;

  -- 1. Criar usuário no auth.users
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
        'error', 'Email já está em uso em outro contexto'
      );
    WHEN OTHERS THEN
      RETURN json_build_object(
        'success', false,
        'error', 'Erro ao criar conta: ' || SQLERRM
      );
  END;

  -- Validar que user_id foi criado
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Falha ao criar usuário no auth.users'
    );
  END IF;

  -- 2. Criar registro na tabela funcionarios
  BEGIN
    INSERT INTO funcionarios (
      empresa_id,
      user_id,
      nome,
      email,
      tipo_admin,
      funcao_id,
      status,
      usuario_ativo,
      senha_definida,
      primeiro_acesso
    ) VALUES (
      p_empresa_id,
      v_user_id,
      p_nome,
      p_email,
      'funcionario',
      p_funcao_id,
      'ativo',
      true,
      false,  -- ⭐ Senha ainda NÃO foi definida pelo funcionário
      true    -- ⭐ É o PRIMEIRO ACESSO
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

  -- Validar que funcionario_id foi criado
  IF v_funcionario_id IS NULL THEN
    DELETE FROM auth.users WHERE id = v_user_id;
    RETURN json_build_object(
      'success', false,
      'error', 'Falha ao criar registro de funcionário'
    );
  END IF;

  -- 3. Criar registro na tabela login_funcionarios
  BEGIN
    INSERT INTO login_funcionarios (
      funcionario_id,
      usuario,
      senha,
      ativo
    ) VALUES (
      v_funcionario_id,
      v_usuario,
      v_senha_hash,
      true
    );
  EXCEPTION
    WHEN OTHERS THEN
      -- Rollback: excluir funcionário e auth.users
      DELETE FROM funcionarios WHERE id = v_funcionario_id;
      DELETE FROM auth.users WHERE id = v_user_id;
      RETURN json_build_object(
        'success', false,
        'error', 'Erro ao criar login: ' || SQLERRM
      );
  END;

  -- Sucesso - retornar dados
  RETURN json_build_object(
    'success', true,
    'funcionario_id', v_funcionario_id,
    'usuario', v_usuario
  );
END;
$$;

-- ========================================
-- 2️⃣ VERIFICAR SE CORREÇÃO FOI APLICADA
-- ========================================

SELECT 
  '✅ FUNÇÃO ATUALIZADA' as status,
  proname as funcao,
  pg_get_functiondef(oid) as definicao
FROM pg_proc 
WHERE proname = 'cadastrar_funcionario_simples';
