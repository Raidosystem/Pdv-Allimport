-- =============================================
-- CORREÇÃO RÁPIDA DE SENHAS - EXECUTAR AGORA
-- =============================================

-- 🗑️ PASSO 1: Remover funções antigas
DROP FUNCTION IF EXISTS validar_senha_local(TEXT, TEXT);
DROP FUNCTION IF EXISTS atualizar_senha_funcionario(UUID, TEXT);
DROP FUNCTION IF EXISTS trocar_senha_propria(UUID, TEXT, TEXT);

-- ✅ PASSO 2: Criar função validar_senha_local CORRIGIDA
CREATE OR REPLACE FUNCTION validar_senha_local(
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
    v_senha_valida BOOLEAN := false;
BEGIN
    -- Buscar login
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE usuario = p_usuario AND ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Usuário ou senha inválidos');
    END IF;

    -- Validar senha: PRIORIZAR senha_hash, fallback senha
    IF v_login.senha_hash IS NOT NULL AND v_login.senha_hash != '' THEN
        v_senha_valida := (v_login.senha_hash = crypt(p_senha, v_login.senha_hash));
    ELSIF v_login.senha IS NOT NULL AND v_login.senha != '' THEN
        v_senha_valida := (v_login.senha = crypt(p_senha, v_login.senha));
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object('success', false, 'error', 'Usuário ou senha inválidos');
    END IF;

    -- Buscar funcionário
    SELECT f.*, func.nome as funcao_nome, func.nivel as funcao_nivel
    INTO v_funcionario
    FROM funcionarios f
    LEFT JOIN funcoes func ON f.funcao_id = func.id
    WHERE f.id = v_login.funcionario_id AND f.ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Funcionário inativo');
    END IF;

    -- Retornar sucesso
    RETURN json_build_object(
        'success', true,
        'funcionario', row_to_json(v_funcionario),
        'precisa_trocar_senha', COALESCE(v_login.precisa_trocar_senha, false)
    );
END;
$$;

GRANT EXECUTE ON FUNCTION validar_senha_local(TEXT, TEXT) TO authenticated, anon;

-- ✅ PASSO 3: Criar função atualizar_senha_funcionario CORRIGIDA
CREATE OR REPLACE FUNCTION atualizar_senha_funcionario(
    p_funcionario_id UUID,
    p_nova_senha TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_funcionario_id IS NULL OR p_nova_senha IS NULL THEN
        RAISE EXCEPTION 'ID e senha obrigatórios';
    END IF;

    IF LENGTH(p_nova_senha) < 6 THEN
        RAISE EXCEPTION 'Senha deve ter pelo menos 6 caracteres';
    END IF;

    -- ATUALIZAR AMBOS OS CAMPOS (senha e senha_hash)
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_nova_senha, gen_salt('bf')),
        senha = crypt(p_nova_senha, gen_salt('bf')),
        precisa_trocar_senha = TRUE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Funcionário não encontrado';
    END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) TO authenticated;

-- ✅ PASSO 4: Criar função trocar_senha_propria CORRIGIDA
CREATE OR REPLACE FUNCTION trocar_senha_propria(
    p_funcionario_id UUID,
    p_senha_antiga TEXT,
    p_senha_nova TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_login RECORD;
    v_senha_valida BOOLEAN := false;
BEGIN
    IF p_funcionario_id IS NULL OR p_senha_antiga IS NULL OR p_senha_nova IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Todos os campos obrigatórios');
    END IF;

    IF LENGTH(p_senha_nova) < 6 THEN
        RETURN json_build_object('success', false, 'error', 'Nova senha deve ter 6+ caracteres');
    END IF;

    -- Buscar login
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE funcionario_id = p_funcionario_id AND ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Funcionário não encontrado');
    END IF;

    -- Validar senha antiga: PRIORIZAR senha_hash, fallback senha
    IF v_login.senha_hash IS NOT NULL AND v_login.senha_hash != '' THEN
        v_senha_valida := (v_login.senha_hash = crypt(p_senha_antiga, v_login.senha_hash));
    ELSIF v_login.senha IS NOT NULL AND v_login.senha != '' THEN
        v_senha_valida := (v_login.senha = crypt(p_senha_antiga, v_login.senha));
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object('success', false, 'error', 'Senha atual incorreta');
    END IF;

    -- ATUALIZAR AMBOS OS CAMPOS (senha e senha_hash)
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_senha_nova, gen_salt('bf')),
        senha = crypt(p_senha_nova, gen_salt('bf')),
        precisa_trocar_senha = FALSE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    RETURN json_build_object('success', true, 'message', 'Senha atualizada com sucesso');
END;
$$;

GRANT EXECUTE ON FUNCTION trocar_senha_propria(UUID, TEXT, TEXT) TO authenticated;

-- ✅ PASSO 5: TESTAR - Resetar senha Jennifer para "123456"
SELECT atualizar_senha_funcionario(
    (SELECT funcionario_id FROM login_funcionarios WHERE usuario = 'jennifer_sousa'),
    '123456'
);

-- ✅ VERIFICAR RESULTADO
SELECT 
    f.nome,
    lf.usuario,
    lf.precisa_trocar_senha as deve_trocar,
    lf.updated_at as data_atualizacao
FROM login_funcionarios lf
INNER JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE lf.usuario = 'jennifer_sousa';

-- ✅ RESULTADO ESPERADO:
-- deve_trocar = true
-- data_atualizacao = AGORA (horário atual)
