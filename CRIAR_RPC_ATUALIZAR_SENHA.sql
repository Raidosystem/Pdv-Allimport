-- =============================================
-- RPC: atualizar_senha_funcionario
-- Descrição: Atualiza a senha de um funcionário
--            usando bcrypt para hash seguro
-- =============================================

-- Função para atualizar senha de funcionário
CREATE OR REPLACE FUNCTION atualizar_senha_funcionario(
    p_funcionario_id UUID,
    p_nova_senha TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Validar entrada
    IF p_funcionario_id IS NULL OR p_nova_senha IS NULL THEN
        RAISE EXCEPTION 'ID do funcionário e nova senha são obrigatórios';
    END IF;

    IF LENGTH(p_nova_senha) < 6 THEN
        RAISE EXCEPTION 'A senha deve ter pelo menos 6 caracteres';
    END IF;

    -- Atualizar senha na tabela login_funcionarios E definir flag de troca obrigatória
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_nova_senha, gen_salt('bf')),
        precisa_trocar_senha = TRUE,  -- 🔑 FORÇAR TROCA DE SENHA NO PRÓXIMO LOGIN
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    -- Verificar se atualizou
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Funcionário não encontrado na tabela de login';
    END IF;

    RAISE NOTICE 'Senha atualizada com sucesso para funcionário ID: % (precisa_trocar_senha = TRUE)', p_funcionario_id;
END;
$$;

-- Comentário na função
COMMENT ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) IS 
'Atualiza a senha de um funcionário existente usando bcrypt. Usado quando o admin precisa resetar senha esquecida.';

-- Conceder permissão de execução para usuários autenticados
GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) TO authenticated;

-- Testar a função (comentar após executar)
-- SELECT atualizar_senha_funcionario(
--     'SEU_FUNCIONARIO_ID_AQUI'::uuid,
--     'novaSenha123'
-- );

-- Verificar se a senha foi atualizada
-- SELECT funcionario_id, senha_hash, updated_at 
-- FROM login_funcionarios 
-- WHERE funcionario_id = 'SEU_FUNCIONARIO_ID_AQUI'::uuid;
