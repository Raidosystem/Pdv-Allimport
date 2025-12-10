-- =====================================================
-- 🔧 ATIVAR EXTENSÃO PGCRYPTO (URGENTE)
-- =====================================================
-- 
-- ❌ PROBLEMA: function crypt(text, text) does not exist
-- ✅ SOLUÇÃO: Ativar extensão pgcrypto antes das funções
--
-- 📅 Data: 2024-12-08
-- =====================================================

-- =====================================================
-- PASSO 1: ATIVAR EXTENSÃO PGCRYPTO (CRÍTICO!)
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA public;

-- Verificar se foi criada
SELECT 
    '✅ Extensão pgcrypto ATIVADA' as status,
    extname,
    extversion
FROM pg_extension
WHERE extname = 'pgcrypto';

-- =====================================================
-- PASSO 2: TESTAR FUNÇÃO crypt()
-- =====================================================

DO $$
DECLARE
    v_hash TEXT;
BEGIN
    -- Testar se crypt() funciona
    v_hash := crypt('teste123', gen_salt('bf'));
    
    IF v_hash IS NOT NULL THEN
        RAISE NOTICE '✅ Função crypt() está funcionando!';
        RAISE NOTICE '   Hash gerado: %', v_hash;
    ELSE
        RAISE EXCEPTION '❌ Função crypt() não está disponível!';
    END IF;
END;
$$;

-- =====================================================
-- PASSO 3: RECRIAR FUNÇÃO validar_senha_local
-- =====================================================

DROP FUNCTION IF EXISTS validar_senha_local(TEXT, TEXT) CASCADE;

CREATE OR REPLACE FUNCTION public.validar_senha_local(
    p_usuario TEXT,
    p_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_login RECORD;
    v_funcionario RECORD;
    v_senha_valida BOOLEAN := false;
BEGIN
    RAISE NOTICE '🔍 validar_senha_local: Tentando login para usuario=%', p_usuario;
    
    -- Buscar login ativo
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

    -- Validar senha: PRIORIZAR senha_hash, depois senha (compatibilidade)
    IF v_login.senha_hash IS NOT NULL AND LENGTH(v_login.senha_hash) > 0 THEN
        -- Usar crypt() para comparar com bcrypt hash
        v_senha_valida := (v_login.senha_hash = crypt(p_senha, v_login.senha_hash));
        RAISE NOTICE '🔑 Testando senha_hash: %', 
            CASE WHEN v_senha_valida THEN '✅ VÁLIDA' ELSE '❌ INVÁLIDA' END;
    ELSIF v_login.senha IS NOT NULL AND LENGTH(v_login.senha) > 0 THEN
        -- Fallback: comparar texto plano (para migração)
        v_senha_valida := (v_login.senha = p_senha);
        RAISE NOTICE '🔑 Testando senha (texto plano): %', 
            CASE WHEN v_senha_valida THEN '✅ VÁLIDA' ELSE '❌ INVÁLIDA' END;
    ELSE
        RAISE NOTICE '⚠️ NENHUMA senha encontrada!';
        RETURN json_build_object(
            'success', false,
            'error', 'Configuração de senha inválida'
        );
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Usuário ou senha inválidos'
        );
    END IF;

    -- Buscar dados completos do funcionário
    SELECT 
        f.*,
        func.nome as funcao_nome,
        func.nivel as funcao_nivel
    INTO v_funcionario
    FROM funcionarios f
    LEFT JOIN funcoes func ON f.funcao_id = func.id
    WHERE f.id = v_login.funcionario_id
      AND f.status = 'ativo';

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
        'precisa_trocar_senha', COALESCE(v_login.precisa_trocar_senha, false),
        'usuario', v_login.usuario
    );
END;
$$;

COMMENT ON FUNCTION public.validar_senha_local(TEXT, TEXT) IS 
'Valida credenciais de funcionário usando usuário e senha. Suporta bcrypt hash e texto plano.';

-- =====================================================
-- PASSO 4: RECRIAR FUNÇÃO listar_usuarios_ativos
-- =====================================================

DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID) CASCADE;

CREATE OR REPLACE FUNCTION public.listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN,
  usuario TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    f.email,
    f.foto_perfil,
    f.tipo_admin,
    f.senha_definida,
    f.primeiro_acesso,
    COALESCE(lf.usuario, f.email, f.nome) as usuario
  FROM public.funcionarios f
  LEFT JOIN public.login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
  WHERE f.empresa_id = p_empresa_id
    AND f.status = 'ativo'
    AND lf.usuario IS NOT NULL
    AND lf.ativo = true
  ORDER BY 
    CASE WHEN f.tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
    f.nome;
END;
$$;

COMMENT ON FUNCTION public.listar_usuarios_ativos(UUID) IS 
'Lista funcionários ativos com login configurado para seleção na tela de login';

-- =====================================================
-- PASSO 5: RECRIAR FUNÇÃO autenticar_funcionario_local
-- =====================================================

DROP FUNCTION IF EXISTS autenticar_funcionario_local(TEXT, TEXT) CASCADE;

CREATE OR REPLACE FUNCTION public.autenticar_funcionario_local(
    p_usuario TEXT,
    p_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Reutilizar validar_senha_local
    SELECT validar_senha_local(p_usuario, p_senha) INTO v_result;
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION public.autenticar_funcionario_local(TEXT, TEXT) IS 
'Alias para validar_senha_local. Autentica funcionário por usuário e senha.';

-- =====================================================
-- PASSO 6: GARANTIR PERMISSÕES
-- =====================================================

GRANT EXECUTE ON FUNCTION public.listar_usuarios_ativos(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.validar_senha_local(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.autenticar_funcionario_local(TEXT, TEXT) TO anon, authenticated;

-- =====================================================
-- PASSO 7: VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
    '✅ FUNÇÕES RECRIADAS' as status,
    routine_name as funcao,
    routine_type as tipo
FROM information_schema.routines
WHERE routine_name IN (
    'listar_usuarios_ativos',
    'validar_senha_local',
    'autenticar_funcionario_local'
)
AND routine_schema = 'public'
ORDER BY routine_name;

-- =====================================================
-- MENSAGEM FINAL
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ CORREÇÃO PGCRYPTO APLICADA!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Extensões ativadas:';
    RAISE NOTICE '   ✅ pgcrypto (para bcrypt)';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 Funções recriadas:';
    RAISE NOTICE '   ✅ validar_senha_local(usuario, senha)';
    RAISE NOTICE '   ✅ listar_usuarios_ativos(empresa_id)';
    RAISE NOTICE '   ✅ autenticar_funcionario_local(usuario, senha)';
    RAISE NOTICE '';
    RAISE NOTICE '🧪 Próximo passo:';
    RAISE NOTICE '   1. Recarregue a página /login-local';
    RAISE NOTICE '   2. Selecione o funcionário';
    RAISE NOTICE '   3. Digite a senha e clique em Entrar';
    RAISE NOTICE '';
END;
$$;
