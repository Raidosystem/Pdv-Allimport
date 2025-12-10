-- ============================================
-- CRIAR FUNÇÃO trocar_senha_propria (SCHEMA CORRETO)
-- ============================================
-- Solução: Usar extensions.crypt() e extensions.gen_salt()
-- ============================================

-- 1. REMOVER FUNÇÃO ANTIGA
-- ============================================
DROP FUNCTION IF EXISTS public.trocar_senha_propria(UUID, TEXT, TEXT) CASCADE;

-- 2. CRIAR FUNÇÃO COM SCHEMA CORRETO (extensions.)
-- ============================================
CREATE OR REPLACE FUNCTION public.trocar_senha_propria(
    p_funcionario_id UUID,
    p_senha_antiga TEXT,
    p_senha_nova TEXT
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_login RECORD;
    v_senha_hash_antiga TEXT;
    v_senha_hash_nova TEXT;
BEGIN
    -- 🔍 DEBUG: Log dos parâmetros
    RAISE NOTICE '🔑 [trocar_senha_propria] Iniciando troca de senha';
    RAISE NOTICE '   funcionario_id: %', p_funcionario_id;
    RAISE NOTICE '   p_senha_antiga length: %', LENGTH(p_senha_antiga);
    RAISE NOTICE '   p_senha_nova length: %', LENGTH(p_senha_nova);

    -- Validar nova senha
    IF LENGTH(p_senha_nova) < 6 THEN
        RAISE NOTICE '❌ Nova senha muito curta';
        RETURN jsonb_build_object(
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
        RAISE NOTICE '❌ Funcionário não encontrado no login_funcionarios';
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Funcionário não possui login local ou está inativo'
        );
    END IF;

    -- 🔍 DEBUG: Login encontrado
    RAISE NOTICE '✅ Login encontrado: usuario=% precisa_trocar=%', v_login.usuario, v_login.precisa_trocar_senha;

    -- ⭐ VALIDAR SENHA ANTIGA usando extensions.crypt()
    v_senha_hash_antiga := extensions.crypt(p_senha_antiga, v_login.senha_hash);
    
    IF v_senha_hash_antiga != v_login.senha_hash THEN
        RAISE NOTICE '❌ Senha antiga incorreta';
        RAISE NOTICE '   Hash armazenado: %', SUBSTRING(v_login.senha_hash, 1, 20) || '...';
        RAISE NOTICE '   Hash calculado:  %', SUBSTRING(v_senha_hash_antiga, 1, 20) || '...';
        
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Senha atual incorreta'
        );
    END IF;

    RAISE NOTICE '✅ Senha antiga validada com sucesso';

    -- ⭐ GERAR HASH DA NOVA SENHA usando extensions.crypt() e extensions.gen_salt()
    v_senha_hash_nova := extensions.crypt(p_senha_nova, extensions.gen_salt('bf'));
    
    RAISE NOTICE '🔐 Gerando hash da nova senha (bcrypt)...';
    RAISE NOTICE '   Novo hash: %', SUBSTRING(v_senha_hash_nova, 1, 20) || '...';

    -- Atualizar senha e desmarcar precisa_trocar_senha
    UPDATE public.login_funcionarios
    SET 
        senha_hash = v_senha_hash_nova,
        precisa_trocar_senha = false,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    RAISE NOTICE '✅ Senha atualizada no banco de dados';
    RAISE NOTICE '✅ Flag precisa_trocar_senha = false';

    -- Retornar sucesso
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Senha alterada com sucesso',
        'precisa_trocar_senha', false
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ ERRO INESPERADO: % - %', SQLERRM, SQLSTATE;
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Erro ao trocar senha: ' || SQLERRM
        );
END;
$$;

-- 3. COMENTÁRIOS E PERMISSÕES
-- ============================================
COMMENT ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) IS 
'Permite que um funcionário troque sua própria senha, validando a senha antiga com bcrypt (extensions.crypt).';

GRANT EXECUTE ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) TO anon;

-- 4. VERIFICAR CRIAÇÃO
-- ============================================
SELECT 
    p.proname as funcao,
    pg_get_function_arguments(p.oid) as parametros,
    pg_get_function_result(p.oid) as retorno,
    '✅ CRIADA' as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'trocar_senha_propria';

-- 5. TESTAR FUNÇÃO COM DADOS REAIS
-- ============================================
DO $$
DECLARE
    v_hash TEXT;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ FUNÇÃO CRIADA COM SUCESSO!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 Usando:';
    RAISE NOTICE '   • extensions.crypt()';
    RAISE NOTICE '   • extensions.gen_salt()';
    RAISE NOTICE '';
    
    -- Testar funções
    v_hash := extensions.gen_salt('bf');
    RAISE NOTICE '✅ extensions.gen_salt() OK: %', SUBSTRING(v_hash, 1, 10);
    
    v_hash := extensions.crypt('teste123', extensions.gen_salt('bf'));
    RAISE NOTICE '✅ extensions.crypt() OK: %', SUBSTRING(v_hash, 1, 20);
    
    RAISE NOTICE '';
    RAISE NOTICE '🎯 Pronto para testar no frontend!';
    RAISE NOTICE '========================================';
END;
$$;
