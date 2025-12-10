-- =====================================================
-- CRIAR RPC: trocar_senha_propria
-- =====================================================
-- 🎯 Objetivo: Criar função para funcionário trocar própria senha
-- 📅 Data: 2025-12-07
-- ⚠️ EXECUTE ESTE SQL NO SUPABASE SQL EDITOR

-- =====================================================
-- 1. Remover função antiga (se existir)
-- =====================================================
DROP FUNCTION IF EXISTS public.trocar_senha_propria(UUID, TEXT, TEXT);

-- =====================================================
-- 2. Criar nova função trocar_senha_propria
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
BEGIN
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

    -- Buscar login do funcionário
    SELECT * INTO v_login
    FROM public.login_funcionarios
    WHERE funcionario_id = p_funcionario_id
      AND ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Funcionário não encontrado ou inativo'
        );
    END IF;

    -- Validar senha antiga usando crypt
    v_senha_valida := (v_login.senha = crypt(p_senha_antiga, v_login.senha));

    IF NOT v_senha_valida THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Senha atual incorreta'
        );
    END IF;

    -- Atualizar senha com hash bcrypt
    UPDATE public.login_funcionarios
    SET 
        senha = crypt(p_senha_nova, gen_salt('bf')),
        precisa_trocar_senha = FALSE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    -- Verificar se update foi bem-sucedido
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Erro ao atualizar senha'
        );
    END IF;

    RETURN json_build_object(
        'success', true,
        'message', 'Senha atualizada com sucesso'
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Erro interno: ' || SQLERRM
        );
END;
$$;

-- =====================================================
-- 3. Adicionar comentário e permissões
-- =====================================================
COMMENT ON FUNCTION public.trocar_senha_propria IS 
'Funcionário troca sua própria senha (validando senha atual). Usa crypt para segurança.';

GRANT EXECUTE ON FUNCTION public.trocar_senha_propria TO authenticated;
GRANT EXECUTE ON FUNCTION public.trocar_senha_propria TO anon;

-- =====================================================
-- 4. Verificar se a função foi criada
-- =====================================================
SELECT 
    routine_name,
    routine_type,
    data_type as return_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'trocar_senha_propria';

-- =====================================================
-- 5. TESTE MANUAL (OPCIONAL)
-- =====================================================
-- Substitua os valores pelos dados reais do seu funcionário:
/*
SELECT * FROM public.trocar_senha_propria(
    'd2b6d25d-129e-4fa5-b963-d70fd3a95a87'::UUID,  -- p_funcionario_id
    '123456',                                        -- p_senha_antiga
    'novaSenha123'                                   -- p_senha_nova
);
*/

-- =====================================================
-- ✅ PRONTO!
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- A função trocar_senha_propria estará disponível
-- Parâmetros corretos: (p_funcionario_id, p_senha_antiga, p_senha_nova)
