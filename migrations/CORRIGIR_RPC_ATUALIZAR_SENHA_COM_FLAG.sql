-- =============================================
-- CORREÇÃO: RPC atualizar_senha_funcionario
-- Problema: Quando admin troca senha, não define precisa_trocar_senha = TRUE
-- Solução: Atualizar a função para sempre definir a flag ao trocar senha
-- =============================================

-- 🗑️ REMOVER FUNÇÃO ANTIGA (necessário para alterar tipo de retorno)
DROP FUNCTION IF EXISTS atualizar_senha_funcionario(UUID, TEXT);

-- 🔧 CRIAR FUNÇÃO ATUALIZADA
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

-- 🔑 CONCEDER PERMISSÕES
GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) TO anon;

-- 📝 Comentário atualizado na função
COMMENT ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) IS 
'Atualiza a senha de um funcionário usando bcrypt e DEFINE precisa_trocar_senha = TRUE. Usado quando o admin precisa resetar senha. O funcionário será forçado a trocar a senha no próximo login.';

-- ✅ VERIFICAÇÃO
SELECT '✅ Função atualizada com sucesso! Agora ao trocar senha, a flag precisa_trocar_senha será definida como TRUE.' as resultado;

-- 📊 VERIFICAR LOGIN_FUNCIONARIOS ATUAL
SELECT 
    f.nome,
    f.email,
    lf.usuario,
    lf.precisa_trocar_senha,
    lf.updated_at
FROM login_funcionarios lf
INNER JOIN funcionarios f ON f.id = lf.funcionario_id
ORDER BY lf.updated_at DESC;
