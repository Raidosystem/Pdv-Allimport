-- =============================================
-- DIAGNÓSTICO E CORREÇÃO COMPLETA DE SENHAS
-- =============================================
-- 🎯 Objetivo: Diagnosticar e corrigir sistema de senhas
-- 📅 Data: 2025-12-07
-- ⚠️ PROBLEMA: Senhas não estão sendo atualizadas corretamente

-- =============================================
-- 1️⃣ DIAGNÓSTICO: Estado Atual
-- =============================================

-- Verificar estrutura da tabela login_funcionarios
SELECT 
    '📋 ESTRUTURA DA TABELA login_funcionarios' as secao;

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'login_funcionarios'
ORDER BY ordinal_position;

-- Verificar dados atuais (SEM MOSTRAR SENHAS)
SELECT 
    '👥 DADOS ATUAIS (sem senhas)' as secao;

SELECT 
    f.nome,
    lf.usuario,
    CASE 
        WHEN lf.senha_hash IS NOT NULL AND LENGTH(lf.senha_hash) > 0 THEN '✅ TEM senha_hash'
        ELSE '❌ SEM senha_hash'
    END as tem_senha_hash,
    CASE 
        WHEN lf.senha IS NOT NULL AND LENGTH(lf.senha) > 0 THEN '✅ TEM senha'
        ELSE '❌ SEM senha'
    END as tem_senha,
    lf.precisa_trocar_senha,
    lf.ativo,
    lf.updated_at
FROM login_funcionarios lf
INNER JOIN funcionarios f ON f.id = lf.funcionario_id
ORDER BY lf.updated_at DESC;

-- Verificar funções RPC existentes
SELECT 
    '🔧 FUNÇÕES RPC EXISTENTES' as secao;

SELECT 
    routine_name,
    routine_type,
    CASE 
        WHEN routine_definition LIKE '%senha_hash%' THEN '✅ Usa senha_hash'
        ELSE '⚠️ Não usa senha_hash'
    END as usa_senha_hash
FROM information_schema.routines
WHERE routine_name IN (
    'validar_senha_local',
    'atualizar_senha_funcionario',
    'trocar_senha_propria',
    'autenticar_funcionario_local'
)
ORDER BY routine_name;

-- =============================================
-- 2️⃣ TESTE: Validar senha "123456" para Jennifer
-- =============================================

SELECT 
    '🧪 TESTE: Validando senha 123456 para jennifer_sousa' as secao;

DO $$
DECLARE
    v_login RECORD;
    v_teste_senha_hash BOOLEAN;
    v_teste_senha BOOLEAN;
BEGIN
    -- Buscar login de Jennifer
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE usuario = 'jennifer_sousa';
    
    IF NOT FOUND THEN
        RAISE NOTICE '❌ Login não encontrado para jennifer_sousa';
        RETURN;
    END IF;
    
    RAISE NOTICE '📦 Registro encontrado para jennifer_sousa';
    RAISE NOTICE '   - ID: %', v_login.id;
    RAISE NOTICE '   - Usuario: %', v_login.usuario;
    RAISE NOTICE '   - Tem senha_hash: %', (v_login.senha_hash IS NOT NULL AND LENGTH(v_login.senha_hash) > 0);
    RAISE NOTICE '   - Tem senha: %', (v_login.senha IS NOT NULL AND LENGTH(v_login.senha) > 0);
    
    -- Testar senha_hash
    IF v_login.senha_hash IS NOT NULL AND LENGTH(v_login.senha_hash) > 0 THEN
        v_teste_senha_hash := (v_login.senha_hash = crypt('123456', v_login.senha_hash));
        RAISE NOTICE '🔑 Teste senha_hash com "123456": %', 
            CASE WHEN v_teste_senha_hash THEN '✅ VÁLIDA' ELSE '❌ INVÁLIDA' END;
    ELSE
        RAISE NOTICE '⚠️ senha_hash está NULL ou vazia';
    END IF;
    
    -- Testar senha
    IF v_login.senha IS NOT NULL AND LENGTH(v_login.senha) > 0 THEN
        v_teste_senha := (v_login.senha = crypt('123456', v_login.senha));
        RAISE NOTICE '🔑 Teste senha com "123456": %', 
            CASE WHEN v_teste_senha THEN '✅ VÁLIDA' ELSE '❌ INVÁLIDA' END;
    ELSE
        RAISE NOTICE '⚠️ senha está NULL ou vazia';
    END IF;
END $$;

-- =============================================
-- 3️⃣ CORREÇÃO: Atualizar TODAS as funções RPC
-- =============================================

-- 🗑️ REMOVER FUNÇÕES ANTIGAS
DROP FUNCTION IF EXISTS validar_senha_local(TEXT, TEXT);
DROP FUNCTION IF EXISTS atualizar_senha_funcionario(UUID, TEXT);
DROP FUNCTION IF EXISTS trocar_senha_propria(UUID, TEXT, TEXT);

-- ✅ CRIAR: validar_senha_local
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
    RAISE NOTICE '🔍 validar_senha_local: Buscando usuario=%', p_usuario;
    
    -- Buscar login
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE usuario = p_usuario
      AND ativo = true;

    IF NOT FOUND THEN
        RAISE NOTICE '❌ Usuario não encontrado ou inativo: %', p_usuario;
        RETURN json_build_object(
            'success', false,
            'error', 'Usuário ou senha inválidos'
        );
    END IF;

    RAISE NOTICE '✅ Usuario encontrado: %', p_usuario;
    RAISE NOTICE '   - funcionario_id: %', v_login.funcionario_id;
    RAISE NOTICE '   - tem senha_hash: %', (v_login.senha_hash IS NOT NULL);
    RAISE NOTICE '   - tem senha: %', (v_login.senha IS NOT NULL);

    -- Validar senha: PRIORIZAR senha_hash
    IF v_login.senha_hash IS NOT NULL AND LENGTH(v_login.senha_hash) > 0 THEN
        v_senha_valida := (v_login.senha_hash = crypt(p_senha, v_login.senha_hash));
        RAISE NOTICE '🔑 Testando senha_hash: %', 
            CASE WHEN v_senha_valida THEN '✅ VÁLIDA' ELSE '❌ INVÁLIDA' END;
    ELSIF v_login.senha IS NOT NULL AND LENGTH(v_login.senha) > 0 THEN
        v_senha_valida := (v_login.senha = crypt(p_senha, v_login.senha));
        RAISE NOTICE '🔑 Testando senha (fallback): %', 
            CASE WHEN v_senha_valida THEN '✅ VÁLIDA' ELSE '❌ INVÁLIDA' END;
    ELSE
        RAISE NOTICE '⚠️ NENHUMA senha encontrada (senha e senha_hash vazios)!';
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Usuário ou senha inválidos'
        );
    END IF;

    -- Buscar dados do funcionário
    SELECT 
        f.*,
        func.nome as funcao_nome,
        func.nivel as funcao_nivel
    INTO v_funcionario
    FROM funcionarios f
    LEFT JOIN funcoes func ON f.funcao_id = func.id
    WHERE f.id = v_login.funcionario_id
      AND f.ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Funcionário inativo ou não encontrado'
        );
    END IF;

    -- Atualizar último acesso
    UPDATE login_funcionarios
    SET ultimo_acesso = NOW()
    WHERE id = v_login.id;

    RAISE NOTICE '✅ Login bem-sucedido para: %', p_usuario;

    -- Retornar sucesso com dados
    RETURN json_build_object(
        'success', true,
        'funcionario', row_to_json(v_funcionario),
        'precisa_trocar_senha', COALESCE(v_login.precisa_trocar_senha, false)
    );
END;
$$;

GRANT EXECUTE ON FUNCTION validar_senha_local(TEXT, TEXT) TO authenticated, anon;

-- ✅ CRIAR: atualizar_senha_funcionario
CREATE OR REPLACE FUNCTION atualizar_senha_funcionario(
    p_funcionario_id UUID,
    p_nova_senha TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RAISE NOTICE '🔧 atualizar_senha_funcionario: funcionario_id=%, nova_senha_length=%', 
        p_funcionario_id, LENGTH(p_nova_senha);
    
    -- Validar entrada
    IF p_funcionario_id IS NULL OR p_nova_senha IS NULL THEN
        RAISE EXCEPTION 'ID do funcionário e nova senha são obrigatórios';
    END IF;

    IF LENGTH(p_nova_senha) < 6 THEN
        RAISE EXCEPTION 'A senha deve ter pelo menos 6 caracteres';
    END IF;

    -- Atualizar AMBOS os campos (senha_hash e senha) e definir flag
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_nova_senha, gen_salt('bf')),
        senha = crypt(p_nova_senha, gen_salt('bf')),
        precisa_trocar_senha = TRUE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Funcionário não encontrado na tabela de login';
    END IF;

    RAISE NOTICE '✅ Senha atualizada com sucesso (precisa_trocar_senha = TRUE)';
END;
$$;

GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) TO authenticated;

-- ✅ CRIAR: trocar_senha_propria
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
    RAISE NOTICE '🔧 trocar_senha_propria: funcionario_id=%', p_funcionario_id;
    
    -- Validar entrada
    IF p_funcionario_id IS NULL OR p_senha_antiga IS NULL OR p_senha_nova IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Todos os campos são obrigatórios'
        );
    END IF;

    IF LENGTH(p_senha_nova) < 6 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'A nova senha deve ter pelo menos 6 caracteres'
        );
    END IF;

    -- Buscar login
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

    RAISE NOTICE '   - tem senha_hash: %', (v_login.senha_hash IS NOT NULL);
    RAISE NOTICE '   - tem senha: %', (v_login.senha IS NOT NULL);

    -- Validar senha antiga: PRIORIZAR senha_hash
    IF v_login.senha_hash IS NOT NULL AND LENGTH(v_login.senha_hash) > 0 THEN
        v_senha_valida := (v_login.senha_hash = crypt(p_senha_antiga, v_login.senha_hash));
        RAISE NOTICE '🔑 Validando senha_hash antiga: %', 
            CASE WHEN v_senha_valida THEN '✅ VÁLIDA' ELSE '❌ INVÁLIDA' END;
    ELSIF v_login.senha IS NOT NULL AND LENGTH(v_login.senha) > 0 THEN
        v_senha_valida := (v_login.senha = crypt(p_senha_antiga, v_login.senha));
        RAISE NOTICE '🔑 Validando senha antiga (fallback): %', 
            CASE WHEN v_senha_valida THEN '✅ VÁLIDA' ELSE '❌ INVÁLIDA' END;
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Senha atual incorreta'
        );
    END IF;

    -- Atualizar AMBOS os campos (senha_hash e senha) e DESATIVAR flag
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_senha_nova, gen_salt('bf')),
        senha = crypt(p_senha_nova, gen_salt('bf')),
        precisa_trocar_senha = FALSE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    RAISE NOTICE '✅ Senha própria atualizada com sucesso (precisa_trocar_senha = FALSE)';

    RETURN json_build_object(
        'success', true,
        'message', 'Senha atualizada com sucesso'
    );
END;
$$;

GRANT EXECUTE ON FUNCTION trocar_senha_propria(UUID, TEXT, TEXT) TO authenticated;

-- =============================================
-- 4️⃣ TESTE FINAL: Resetar senha para "123456"
-- =============================================

SELECT 
    '🧪 TESTE FINAL: Resetando senha de jennifer_sousa para 123456' as secao;

-- Resetar senha para "123456"
SELECT atualizar_senha_funcionario(
    lf.funcionario_id,
    '123456'
)
FROM login_funcionarios lf
WHERE lf.usuario = 'jennifer_sousa';

-- Verificar resultado
SELECT 
    f.nome,
    lf.usuario,
    lf.precisa_trocar_senha,
    CASE 
        WHEN lf.senha_hash IS NOT NULL AND LENGTH(lf.senha_hash) > 0 THEN '✅ TEM senha_hash'
        ELSE '❌ SEM senha_hash'
    END as tem_senha_hash,
    CASE 
        WHEN lf.senha IS NOT NULL AND LENGTH(lf.senha) > 0 THEN '✅ TEM senha'
        ELSE '❌ SEM senha'
    END as tem_senha,
    lf.updated_at
FROM login_funcionarios lf
INNER JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE lf.usuario = 'jennifer_sousa';

-- ✅ RESULTADO ESPERADO:
-- - precisa_trocar_senha = TRUE
-- - tem_senha_hash = "✅ TEM senha_hash"
-- - tem_senha = "✅ TEM senha"
-- - updated_at = AGORA

SELECT '✅ CORREÇÃO COMPLETA! Agora teste fazer login com jennifer_sousa e senha 123456' as resultado;
