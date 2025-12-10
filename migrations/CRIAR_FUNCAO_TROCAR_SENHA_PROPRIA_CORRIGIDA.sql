-- ============================================
-- CRIAR FUNÇÃO: trocar_senha_propria (ORDEM CORRETA)
-- ============================================
-- Data: 07/12/2024
-- Problema: Ordem dos parâmetros estava invertida
-- Solução: Alinhar com o que o frontend espera
-- ============================================

-- 1. REMOVER VERSÕES ANTIGAS (todas as assinaturas possíveis)
-- ============================================
DROP FUNCTION IF EXISTS public.trocar_senha_propria(UUID, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS trocar_senha_propria(UUID, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.trocar_senha_propria CASCADE;
DROP FUNCTION IF EXISTS trocar_senha_propria CASCADE;

-- 2. CRIAR FUNÇÃO COM ORDEM CORRETA DOS PARÂMETROS
-- ============================================
-- ⚠️ ATENÇÃO: Ordem dos parâmetros = p_funcionario_id, p_senha_antiga, p_senha_nova
-- (para alinhar com o frontend)
-- ============================================

CREATE OR REPLACE FUNCTION public.trocar_senha_propria(
    p_funcionario_id UUID,
    p_senha_antiga TEXT,      -- ⭐ Senha antiga PRIMEIRO
    p_senha_nova TEXT         -- ⭐ Senha nova SEGUNDO
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
    FROM login_funcionarios
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

    -- Validar senha antiga usando bcrypt
    v_senha_hash_antiga := crypt(p_senha_antiga, v_login.senha_hash);
    
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

    -- Gerar hash da nova senha usando bcrypt
    v_senha_hash_nova := crypt(p_senha_nova, gen_salt('bf'));
    
    RAISE NOTICE '🔐 Gerando hash da nova senha (bcrypt)...';

    -- ⭐ ATUALIZAR: senha + desmarcar precisa_trocar_senha
    UPDATE login_funcionarios
    SET 
        senha_hash = v_senha_hash_nova,
        precisa_trocar_senha = false,  -- ✅ Funcionário já trocou a senha
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
'Permite que um funcionário troque sua própria senha, validando a senha antiga com bcrypt. Desmarca precisa_trocar_senha após troca bem-sucedida.';

GRANT EXECUTE ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.trocar_senha_propria(UUID, TEXT, TEXT) TO anon;

-- 4. VERIFICAR CRIAÇÃO
-- ============================================

SELECT 
    p.proname as funcao,
    pg_get_function_arguments(p.oid) as parametros,
    pg_get_function_result(p.oid) as retorno
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'trocar_senha_propria';

-- 5. RESULTADO ESPERADO
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ FUNÇÃO CRIADA COM SUCESSO!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Assinatura:';
    RAISE NOTICE '   trocar_senha_propria(';
    RAISE NOTICE '     p_funcionario_id UUID,';
    RAISE NOTICE '     p_senha_antiga TEXT,    ⭐ Ordem correta';
    RAISE NOTICE '     p_senha_nova TEXT       ⭐ Ordem correta';
    RAISE NOTICE '   )';
    RAISE NOTICE '';
    RAISE NOTICE '🧪 Teste frontend:';
    RAISE NOTICE '   await supabase.rpc("trocar_senha_propria", {';
    RAISE NOTICE '     p_funcionario_id: "uuid-do-funcionario",';
    RAISE NOTICE '     p_senha_antiga: "senhaAtual123",';
    RAISE NOTICE '     p_senha_nova: "novaSenha456"';
    RAISE NOTICE '   })';
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
END;
$$;
