-- =====================================================
-- CORRIGIR RPCs: Compatibilidade senha e senha_hash
-- =====================================================
-- 🎯 Objetivo: Atualizar RPCs para funcionar com AMBAS colunas
-- 📅 Data: 2025-12-07
-- ⚠️ IMPORTANTE: Execute DEPOIS de MIGRAR_SENHA_PARA_HASH.sql

-- =====================================================
-- 1. ATUALIZAR: autenticar_funcionario
-- =====================================================
-- ✅ Compatível com senha E senha_hash
CREATE OR REPLACE FUNCTION autenticar_funcionario(
  p_usuario TEXT,
  p_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_login RECORD;
  v_funcionario RECORD;
  v_resultado JSON;
  v_senha_valida BOOLEAN := false;
BEGIN
  -- Buscar login
  SELECT * INTO v_login
  FROM public.login_funcionarios
  WHERE usuario = p_usuario
    AND ativo = true;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário ou senha inválidos'
    );
  END IF;

  -- Validar senha: priorizar senha_hash, fallback para senha
  IF v_login.senha_hash IS NOT NULL AND v_login.senha_hash != '' THEN
    -- Usar senha_hash (nova versão criptografada)
    v_senha_valida := (v_login.senha_hash = crypt(p_senha, v_login.senha_hash));
  ELSIF v_login.senha IS NOT NULL AND v_login.senha != '' THEN
    -- Fallback: usar senha antiga (texto plano ou crypt)
    v_senha_valida := (v_login.senha = crypt(p_senha, v_login.senha));
  END IF;

  IF NOT v_senha_valida THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário ou senha inválidos'
    );
  END IF;

  -- Buscar dados do funcionário
  SELECT f.*, func.nome as funcao_nome
  INTO v_funcionario
  FROM public.funcionarios f
  LEFT JOIN public.funcoes func ON f.funcao_id = func.id
  WHERE f.id = v_login.funcionario_id
    AND f.ativo = true;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Funcionário inativo ou não encontrado'
    );
  END IF;

  -- Atualizar último acesso
  UPDATE public.login_funcionarios
  SET ultimo_acesso = NOW()
  WHERE id = v_login.id;

  -- Retornar sucesso com dados
  v_resultado := json_build_object(
    'success', true,
    'funcionario', row_to_json(v_funcionario),
    'login_id', v_login.id,
    'precisa_trocar_senha', COALESCE(v_login.precisa_trocar_senha, false)
  );

  RETURN v_resultado;
END;
$$;

COMMENT ON FUNCTION autenticar_funcionario IS 
'Autentica funcionário local. Compatível com senha e senha_hash.';

GRANT EXECUTE ON FUNCTION autenticar_funcionario TO anon, authenticated;

-- =====================================================
-- 2. ATUALIZAR: atualizar_senha_funcionario
-- =====================================================
-- ✅ Atualiza senha_hash (prioridade) e senha (fallback)
CREATE OR REPLACE FUNCTION atualizar_senha_funcionario(
    p_funcionario_id UUID,
    p_nova_senha TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tem_senha_hash BOOLEAN;
BEGIN
  -- Validar entrada
  IF p_funcionario_id IS NULL OR p_nova_senha IS NULL THEN
    RAISE EXCEPTION 'ID do funcionário e nova senha são obrigatórios';
  END IF;

  IF LENGTH(p_nova_senha) < 6 THEN
    RAISE EXCEPTION 'A senha deve ter pelo menos 6 caracteres';
  END IF;

  -- Verificar se a coluna senha_hash existe
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'login_funcionarios' 
    AND column_name = 'senha_hash'
  ) INTO v_tem_senha_hash;

  -- Atualizar senha
  IF v_tem_senha_hash THEN
    -- Novo formato: usar senha_hash
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_nova_senha, gen_salt('bf')),
        senha = crypt(p_nova_senha, gen_salt('bf')), -- Manter compatibilidade
        precisa_trocar_senha = TRUE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;
  ELSE
    -- Formato antigo: usar apenas senha
    UPDATE login_funcionarios
    SET 
        senha = crypt(p_nova_senha, gen_salt('bf')),
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;
  END IF;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Funcionário não encontrado na tabela de login';
  END IF;

  RAISE NOTICE 'Senha resetada. Funcionário deve trocar no próximo login: %', p_funcionario_id;
END;
$$;

COMMENT ON FUNCTION atualizar_senha_funcionario IS 
'Reseta senha do funcionário (admin). Compatível com senha e senha_hash.';

GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario TO authenticated;

-- =====================================================
-- 3. CRIAR: trocar_senha_propria
-- =====================================================
-- ✅ Funcionário troca sua própria senha
DROP FUNCTION IF EXISTS trocar_senha_propria(UUID, TEXT, TEXT);

CREATE OR REPLACE FUNCTION trocar_senha_propria(
    p_funcionario_id UUID,
    p_senha_atual TEXT,
    p_nova_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_login RECORD;
    v_senha_valida BOOLEAN := false;
    v_tem_senha_hash BOOLEAN;
BEGIN
    -- Validar entrada
    IF p_funcionario_id IS NULL OR p_senha_atual IS NULL OR p_nova_senha IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Todos os campos são obrigatórios'
        );
    END IF;

    IF LENGTH(p_nova_senha) < 6 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'A nova senha deve ter pelo menos 6 caracteres'
        );
    END IF;

    -- Buscar login do funcionário
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE funcionario_id = p_funcionario_id
      AND ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Funcionário não encontrado ou inativo'
        );
    END IF;

    -- Validar senha atual: priorizar senha_hash, fallback para senha
    IF v_login.senha_hash IS NOT NULL AND v_login.senha_hash != '' THEN
        v_senha_valida := (v_login.senha_hash = crypt(p_senha_atual, v_login.senha_hash));
    ELSIF v_login.senha IS NOT NULL AND v_login.senha != '' THEN
        v_senha_valida := (v_login.senha = crypt(p_senha_atual, v_login.senha));
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Senha atual incorreta'
        );
    END IF;

    -- Verificar se a coluna senha_hash existe
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'login_funcionarios' 
        AND column_name = 'senha_hash'
    ) INTO v_tem_senha_hash;

    -- Atualizar senha
    IF v_tem_senha_hash THEN
        -- Novo formato: usar senha_hash
        UPDATE login_funcionarios
        SET 
            senha_hash = crypt(p_nova_senha, gen_salt('bf')),
            senha = crypt(p_nova_senha, gen_salt('bf')), -- Manter compatibilidade
            precisa_trocar_senha = FALSE, -- Funcionário JÁ trocou
            updated_at = NOW()
        WHERE funcionario_id = p_funcionario_id;
    ELSE
        -- Formato antigo: usar apenas senha
        UPDATE login_funcionarios
        SET 
            senha = crypt(p_nova_senha, gen_salt('bf')),
            updated_at = NOW()
        WHERE funcionario_id = p_funcionario_id;
    END IF;

    RETURN json_build_object(
        'success', true,
        'message', 'Senha atualizada com sucesso'
    );
END;
$$;

COMMENT ON FUNCTION trocar_senha_propria IS 
'Funcionário troca sua própria senha (validando senha atual). Compatível com senha e senha_hash.';

GRANT EXECUTE ON FUNCTION trocar_senha_propria TO authenticated;

-- =====================================================
-- 4. CRIAR: autenticar_funcionario_local
-- =====================================================
-- ✅ Versão completa para login local (retorna mais dados)
CREATE OR REPLACE FUNCTION autenticar_funcionario_local(
  p_usuario TEXT,
  p_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_login RECORD;
  v_funcionario RECORD;
  v_empresa RECORD;
  v_resultado JSON;
  v_senha_valida BOOLEAN := false;
BEGIN
  -- Buscar login
  SELECT * INTO v_login
  FROM public.login_funcionarios
  WHERE usuario = p_usuario
    AND ativo = true;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário ou senha inválidos'
    );
  END IF;

  -- Validar senha: priorizar senha_hash, fallback para senha
  IF v_login.senha_hash IS NOT NULL AND v_login.senha_hash != '' THEN
    v_senha_valida := (v_login.senha_hash = crypt(p_senha, v_login.senha_hash));
  ELSIF v_login.senha IS NOT NULL AND v_login.senha != '' THEN
    v_senha_valida := (v_login.senha = crypt(p_senha, v_login.senha));
  END IF;

  IF NOT v_senha_valida THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário ou senha inválidos'
    );
  END IF;

  -- Buscar dados do funcionário com função
  SELECT f.*, func.nome as funcao_nome, func.nivel as funcao_nivel
  INTO v_funcionario
  FROM public.funcionarios f
  LEFT JOIN public.funcoes func ON f.funcao_id = func.id
  WHERE f.id = v_login.funcionario_id
    AND f.ativo = true;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Funcionário inativo ou não encontrado'
    );
  END IF;

  -- Buscar dados da empresa
  SELECT nome, cnpj INTO v_empresa
  FROM public.empresas
  WHERE id = v_funcionario.empresa_id;

  -- Atualizar último acesso
  UPDATE public.login_funcionarios
  SET ultimo_acesso = NOW()
  WHERE id = v_login.id;

  -- Retornar sucesso com dados completos
  v_resultado := json_build_object(
    'success', true,
    'funcionario', row_to_json(v_funcionario),
    'empresa', row_to_json(v_empresa),
    'login_id', v_login.id,
    'precisa_trocar_senha', COALESCE(v_login.precisa_trocar_senha, false)
  );

  RETURN v_resultado;
END;
$$;

COMMENT ON FUNCTION autenticar_funcionario_local IS 
'Autentica funcionário local com dados completos (empresa, função). Compatível com senha e senha_hash.';

GRANT EXECUTE ON FUNCTION autenticar_funcionario_local TO anon, authenticated;

-- =====================================================
-- 5. VERIFICAR INSTALAÇÃO
-- =====================================================
SELECT 
    routine_name as funcao,
    routine_type as tipo
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'autenticar_funcionario',
    'autenticar_funcionario_local',
    'atualizar_senha_funcionario',
    'trocar_senha_propria'
)
ORDER BY routine_name;

-- Resultado esperado:
-- funcao                        | tipo
-- autenticar_funcionario        | FUNCTION
-- autenticar_funcionario_local  | FUNCTION
-- atualizar_senha_funcionario   | FUNCTION
-- trocar_senha_propria          | FUNCTION

-- =====================================================
-- 📋 CHECKLIST DE EXECUÇÃO
-- =====================================================
-- ✅ 1. Execute MIGRAR_SENHA_PARA_HASH.sql PRIMEIRO
-- ✅ 2. Execute este arquivo (CORRIGIR_RPCS_SENHA_HASH.sql)
-- ✅ 3. Teste login com autenticar_funcionario_local
-- ✅ 4. Teste atualização de senha no AdminUsersPage
-- ✅ 5. Teste troca de senha própria (funcionário)

-- =====================================================
-- 🧪 TESTES
-- =====================================================
-- Teste 1: Autenticar funcionário
-- SELECT * FROM autenticar_funcionario_local('seu_usuario', 'sua_senha');

-- Teste 2: Atualizar senha (admin)
-- SELECT atualizar_senha_funcionario('id-do-funcionario', 'novaSenha123');

-- Teste 3: Trocar senha própria
-- SELECT * FROM trocar_senha_propria('id-do-funcionario', 'senhaAtual', 'novaSenha456');
