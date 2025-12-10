-- =============================================
-- Atualizar RPCs para marcar precisa_trocar_senha
-- =============================================

-- 1. ATUALIZAR: criar_funcionario_com_senha
-- Marca precisa_trocar_senha = TRUE quando admin cria
CREATE OR REPLACE FUNCTION criar_funcionario_com_senha(
    p_nome TEXT,
    p_email TEXT,
    p_senha TEXT,
    p_telefone TEXT DEFAULT NULL,
    p_cpf TEXT DEFAULT NULL,
    p_funcao_id UUID DEFAULT NULL,
    p_empresa_id UUID DEFAULT NULL,
    p_user_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_funcionario_id UUID;
    v_final_user_id UUID;
    v_final_empresa_id UUID;
BEGIN
    -- Usar user_id fornecido ou do usuário autenticado
    v_final_user_id := COALESCE(p_user_id, auth.uid());
    
    IF v_final_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado e user_id não fornecido';
    END IF;

    -- Usar empresa_id fornecido ou buscar do usuário
    v_final_empresa_id := p_empresa_id;
    
    IF v_final_empresa_id IS NULL THEN
        SELECT empresa_id INTO v_final_empresa_id
        FROM funcionarios
        WHERE user_id = v_final_user_id
        LIMIT 1;
    END IF;

    -- Validações
    IF p_nome IS NULL OR TRIM(p_nome) = '' THEN
        RAISE EXCEPTION 'Nome é obrigatório';
    END IF;

    IF p_email IS NULL OR TRIM(p_email) = '' THEN
        RAISE EXCEPTION 'Email é obrigatório';
    END IF;

    IF p_senha IS NULL OR LENGTH(p_senha) < 6 THEN
        RAISE EXCEPTION 'Senha deve ter pelo menos 6 caracteres';
    END IF;

    -- Verificar se email já existe
    IF EXISTS (SELECT 1 FROM login_funcionarios WHERE email = p_email) THEN
        RAISE EXCEPTION 'Email já cadastrado';
    END IF;

    -- Inserir funcionário
    INSERT INTO funcionarios (
        nome, 
        email, 
        telefone, 
        cpf,
        funcao_id,
        status,
        user_id,
        empresa_id
    )
    VALUES (
        p_nome,
        p_email,
        p_telefone,
        p_cpf,
        p_funcao_id,
        'ativo',
        v_final_user_id,
        v_final_empresa_id
    )
    RETURNING id INTO v_funcionario_id;

    -- Inserir login com senha criptografada
    -- 🔑 IMPORTANTE: precisa_trocar_senha = TRUE para forçar troca
    INSERT INTO login_funcionarios (
        funcionario_id,
        email,
        senha_hash,
        precisa_trocar_senha
    )
    VALUES (
        v_funcionario_id,
        p_email,
        crypt(p_senha, gen_salt('bf')),
        TRUE  -- ✅ Funcionário deve trocar senha no primeiro acesso
    );

    RETURN v_funcionario_id;
END;
$$;

COMMENT ON FUNCTION criar_funcionario_com_senha IS 
'Cria funcionário com senha temporária definida pelo admin. Funcionário deve trocar no primeiro login.';


-- 2. ATUALIZAR: atualizar_senha_funcionario
-- Marca precisa_trocar_senha = TRUE quando admin reseta
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

    -- Atualizar senha E marcar que precisa trocar
    -- 🔑 IMPORTANTE: precisa_trocar_senha = TRUE após reset do admin
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_nova_senha, gen_salt('bf')),
        precisa_trocar_senha = TRUE,  -- ✅ Forçar troca no próximo login
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Funcionário não encontrado na tabela de login';
    END IF;

    RAISE NOTICE 'Senha resetada. Funcionário deve trocar no próximo login: %', p_funcionario_id;
END;
$$;

COMMENT ON FUNCTION atualizar_senha_funcionario IS 
'Reseta senha do funcionário (admin define temporária). Funcionário deve trocar no próximo login.';


-- 3. CRIAR: trocar_senha_propria
-- Funcionário troca sua própria senha (sem admin saber)
CREATE OR REPLACE FUNCTION trocar_senha_propria(
    p_funcionario_id UUID,
    p_senha_antiga TEXT,
    p_senha_nova TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_senha_hash_atual TEXT;
BEGIN
    -- Validações
    IF p_funcionario_id IS NULL OR p_senha_antiga IS NULL OR p_senha_nova IS NULL THEN
        RAISE EXCEPTION 'Todos os campos são obrigatórios';
    END IF;

    IF LENGTH(p_senha_nova) < 6 THEN
        RAISE EXCEPTION 'A nova senha deve ter pelo menos 6 caracteres';
    END IF;

    -- Buscar hash atual
    SELECT senha_hash INTO v_senha_hash_atual
    FROM login_funcionarios
    WHERE funcionario_id = p_funcionario_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Funcionário não encontrado';
    END IF;

    -- Verificar se senha antiga está correta
    IF v_senha_hash_atual != crypt(p_senha_antiga, v_senha_hash_atual) THEN
        RAISE EXCEPTION 'Senha antiga incorreta';
    END IF;

    -- Atualizar senha e remover flag de troca obrigatória
    -- 🔑 IMPORTANTE: precisa_trocar_senha = FALSE após troca própria
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_senha_nova, gen_salt('bf')),
        precisa_trocar_senha = FALSE,  -- ✅ Não precisa mais trocar
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    RAISE NOTICE 'Senha alterada com sucesso pelo próprio funcionário: %', p_funcionario_id;
END;
$$;

COMMENT ON FUNCTION trocar_senha_propria IS 
'Permite funcionário trocar sua própria senha (sem admin saber). Remove flag de troca obrigatória.';

-- Conceder permissões
GRANT EXECUTE ON FUNCTION criar_funcionario_com_senha TO authenticated;
GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario TO authenticated;
GRANT EXECUTE ON FUNCTION trocar_senha_propria TO authenticated;

-- Verificar criação das funções
SELECT 
    routine_name,
    routine_type,
    routine_definition LIKE '%precisa_trocar_senha%' as usa_flag_troca
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'criar_funcionario_com_senha',
    'atualizar_senha_funcionario',
    'trocar_senha_propria'
)
ORDER BY routine_name;
