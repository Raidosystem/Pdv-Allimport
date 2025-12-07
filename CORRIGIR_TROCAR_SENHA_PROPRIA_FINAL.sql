-- =====================================================
-- CORRIGIR FUNÇÃO trocar_senha_propria
-- =====================================================
-- 🎯 Objetivo: Criar função que FUNCIONA e desmarca flag
-- 📅 Data: 2025-12-07
-- ⚠️ EXECUTE ESTE SQL NO SUPABASE SQL EDITOR

-- =====================================================
-- 1. Remover todas as versões antigas
-- =====================================================
DROP FUNCTION IF EXISTS public.trocar_senha_propria(UUID, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS trocar_senha_propria(UUID, TEXT, TEXT) CASCADE;

-- =====================================================
-- 2. Verificar estrutura da tabela login_funcionarios
-- =====================================================
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'login_funcionarios'
ORDER BY ordinal_position;

-- =====================================================
-- 3. Criar função CORRETA trocar_senha_propria
-- =====================================================
CREATE OR REPLACE FUNCTION public.trocar_senha_propria(
    p_funcionario_id UUID,
    p_senha_antiga TEXT,
    p_senha_nova TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_login RECORD;
    v_senha_valida BOOLEAN := false;
    v_rows_updated INTEGER;
BEGIN
    -- Log inicial
    RAISE NOTICE '🔑 Iniciando troca de senha para funcionário: %', p_funcionario_id;

    -- Validar entrada
    IF p_funcionario_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'ID do funcionário é obrigatório'
        );
    END IF;

    IF p_senha_antiga IS NULL OR LENGTH(TRIM(p_senha_antiga)) = 0 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Senha atual é obrigatória'
        );
    END IF;

    IF p_senha_nova IS NULL OR LENGTH(TRIM(p_senha_nova)) < 6 THEN
        RETURN json_build_object(
            'success', false,
            'error', 'A nova senha deve ter pelo menos 6 caracteres'
        );
    END IF;

    -- Buscar login do funcionário
    SELECT * INTO v_login
    FROM public.login_funcionarios
    WHERE funcionario_id = p_funcionario_id
      AND ativo = true;

    IF NOT FOUND THEN
        RAISE NOTICE '❌ Funcionário não encontrado ou inativo: %', p_funcionario_id;
        RETURN json_build_object(
            'success', false,
            'error', 'Funcionário não encontrado ou inativo'
        );
    END IF;

    RAISE NOTICE '✅ Funcionário encontrado: usuario=%', v_login.usuario;

    -- Validar senha antiga usando crypt
    BEGIN
        v_senha_valida := (v_login.senha = crypt(p_senha_antiga, v_login.senha));
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ Erro ao validar senha antiga: %', SQLERRM;
        RETURN json_build_object(
            'success', false,
            'error', 'Erro ao validar senha antiga'
        );
    END;

    IF NOT v_senha_valida THEN
        RAISE NOTICE '❌ Senha antiga incorreta';
        RETURN json_build_object(
            'success', false,
            'error', 'Senha atual incorreta'
        );
    END IF;

    RAISE NOTICE '✅ Senha antiga validada com sucesso';

    -- Atualizar senha com hash bcrypt E DESMARCAR FLAG
    BEGIN
        UPDATE public.login_funcionarios
        SET 
            senha = crypt(p_senha_nova, gen_salt('bf')),
            precisa_trocar_senha = FALSE,  -- 🔥 CRUCIAL: Desmarcar flag
            updated_at = NOW()
        WHERE funcionario_id = p_funcionario_id;

        GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

        IF v_rows_updated = 0 THEN
            RAISE NOTICE '❌ Nenhuma linha foi atualizada';
            RETURN json_build_object(
                'success', false,
                'error', 'Erro ao atualizar senha - nenhuma linha afetada'
            );
        END IF;

        RAISE NOTICE '✅ Senha atualizada com sucesso! Linhas afetadas: %', v_rows_updated;

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '❌ Erro ao atualizar senha: %', SQLERRM;
        RETURN json_build_object(
            'success', false,
            'error', 'Erro ao atualizar senha: ' || SQLERRM
        );
    END;

    -- Retornar sucesso
    RETURN json_build_object(
        'success', true,
        'message', 'Senha atualizada com sucesso',
        'precisa_trocar_senha', false
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ Erro inesperado: %', SQLERRM;
        RETURN json_build_object(
            'success', false,
            'error', 'Erro interno: ' || SQLERRM
        );
END;
$$;

-- =====================================================
-- 4. Comentário e permissões
-- =====================================================
COMMENT ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) IS 
'Funcionário troca sua própria senha (validando senha atual) e desmarca flag precisa_trocar_senha.';

GRANT EXECUTE ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) TO anon;

-- =====================================================
-- 5. Verificar se a função foi criada
-- =====================================================
SELECT 
    routine_name,
    routine_type,
    data_type as return_type,
    routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'trocar_senha_propria';

-- =====================================================
-- 6. Verificar funcionários que precisam trocar senha
-- =====================================================
SELECT 
    f.id,
    f.nome,
    f.email,
    lf.usuario,
    lf.precisa_trocar_senha,
    lf.updated_at
FROM public.funcionarios f
INNER JOIN public.login_funcionarios lf ON lf.funcionario_id = f.id
WHERE lf.precisa_trocar_senha = TRUE
  AND lf.ativo = TRUE
ORDER BY f.nome;

-- =====================================================
-- 7. TESTE MANUAL (OPCIONAL - Ajuste os valores!)
-- =====================================================
/*
-- Substitua pelos dados reais:
SELECT * FROM public.trocar_senha_propria(
    'd2b6d25d-129e-4fa5-b963-d70fd3a95a87'::UUID,  -- p_funcionario_id (Jennifer Sousa)
    '123456',                                        -- p_senha_antiga (senha que você definiu)
    'novaSenha2025'                                  -- p_senha_nova
);

-- Verificar se flag foi desmarcada:
SELECT 
    f.nome,
    lf.precisa_trocar_senha,
    lf.updated_at
FROM public.funcionarios f
INNER JOIN public.login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.id = 'd2b6d25d-129e-4fa5-b963-d70fd3a95a87';
*/

-- =====================================================
-- ✅ PRONTO!
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- Depois teste no sistema:
-- 1. Faça login com a funcionária Jennifer
-- 2. Troque a senha
-- 3. Saia e tente fazer login com a NOVA senha
-- 4. Não deve pedir para trocar senha novamente
