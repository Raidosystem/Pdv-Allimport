-- =========================================
-- CORRIGIR: atualizar_senha_funcionario
-- Retornar JSON ao invés de void
-- =========================================

DROP FUNCTION IF EXISTS atualizar_senha_funcionario(UUID, TEXT);

CREATE OR REPLACE FUNCTION atualizar_senha_funcionario(
    p_funcionario_id UUID,
    p_nova_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_funcionario RECORD;
BEGIN
    -- Validações
    IF p_funcionario_id IS NULL OR p_nova_senha IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'ID e senha são obrigatórios'
        );
    END IF;

    IF LENGTH(p_nova_senha) < 6 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Senha deve ter pelo menos 6 caracteres'
        );
    END IF;

    -- Buscar funcionário
    SELECT * INTO v_funcionario
    FROM funcionarios
    WHERE id = p_funcionario_id;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Funcionário não encontrado'
        );
    END IF;

    -- ATUALIZAR AMBOS OS CAMPOS (senha e senha_hash) na tabela login_funcionarios
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_nova_senha, gen_salt('bf')),
        senha = crypt(p_nova_senha, gen_salt('bf')),
        precisa_trocar_senha = FALSE,  -- Senha já foi trocada pelo admin
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    IF NOT FOUND THEN
        -- Se não existe login, criar um novo
        INSERT INTO login_funcionarios (
            funcionario_id,
            usuario,
            senha_hash,
            senha,
            precisa_trocar_senha,
            ativo
        ) VALUES (
            p_funcionario_id,
            v_funcionario.nome,
            crypt(p_nova_senha, gen_salt('bf')),
            crypt(p_nova_senha, gen_salt('bf')),
            FALSE,
            TRUE
        );
    END IF;

    RETURN json_build_object(
        'success', true,
        'message', 'Senha atualizada com sucesso'
    );
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) TO authenticated;

-- =========================================
-- TESTAR A FUNÇÃO
-- =========================================
-- Exemplo (substitua pelos IDs reais):
-- SELECT atualizar_senha_funcionario(
--     '866ae21a-ba51-4fca-bbba-4d4610017a4e'::uuid,
--     '123456'
-- );

SELECT '✅ Função atualizar_senha_funcionario corrigida - agora retorna JSON' as status;
