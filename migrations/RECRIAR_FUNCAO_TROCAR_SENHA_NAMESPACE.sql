-- ============================================
-- RECRIAR FUNÇÃO trocar_senha_propria COM NAMESPACE CORRETO
-- ============================================
-- Problema: Funções crypt/gen_salt não estão sendo encontradas
-- Solução: Especificar schema explicitamente
-- ============================================

-- 1. VERIFICAR EXTENSÃO PGCRYPTO
-- ============================================
SELECT 
    extname,
    extversion,
    nspname as schema
FROM pg_extension e
JOIN pg_namespace n ON e.extnamespace = n.oid
WHERE extname = 'pgcrypto';

-- 2. REMOVER FUNÇÃO ANTIGA
-- ============================================
DROP FUNCTION IF EXISTS public.trocar_senha_propria(UUID, TEXT, TEXT) CASCADE;

-- 3. CRIAR FUNÇÃO COM NAMESPACE EXPLÍCITO
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

    -- ⭐ USAR public.crypt() EXPLICITAMENTE
    v_senha_hash_antiga := public.crypt(p_senha_antiga, v_login.senha_hash);
    
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

    -- ⭐ USAR public.gen_salt() EXPLICITAMENTE
    v_senha_hash_nova := public.crypt(p_senha_nova, public.gen_salt('bf'));
    
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

-- 4. PERMISSÕES
-- ============================================
COMMENT ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) IS 
'Permite que um funcionário troque sua própria senha, validando a senha antiga com bcrypt (pgcrypto).';

GRANT EXECUTE ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) TO anon;

-- 5. VERIFICAR
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

-- 6. TESTE DAS FUNÇÕES PGCRYPTO
-- ============================================
DO $$
DECLARE
    v_hash TEXT;
BEGIN
    -- Testar gen_salt
    v_hash := public.gen_salt('bf');
    RAISE NOTICE '✅ public.gen_salt() funciona: %', SUBSTRING(v_hash, 1, 10);
    
    -- Testar crypt
    v_hash := public.crypt('teste123', public.gen_salt('bf'));
    RAISE NOTICE '✅ public.crypt() funciona: %', SUBSTRING(v_hash, 1, 20);
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ FUNÇÃO RECRIADA COM SUCESSO!';
    RAISE NOTICE '✅ pgcrypto funcionando corretamente';
    RAISE NOTICE '========================================';
END;
$$;
