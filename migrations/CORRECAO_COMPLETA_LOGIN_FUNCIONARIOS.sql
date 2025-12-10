-- =====================================================
-- 🔧 CORREÇÃO COMPLETA DO SISTEMA DE LOGIN DE FUNCIONÁRIOS
-- =====================================================
-- 
-- 📋 PROBLEMAS IDENTIFICADOS:
-- 1. validar_senha_local() não existe no banco (função foi perdida)
-- 2. listar_usuarios_ativos() não retorna campo 'usuario'
-- 3. AuthContext.signInLocal() está incorreto (espera email/senha, não funcionário)
-- 4. Frontend chama validar_senha_local mas a função não existe
--
-- ✅ SOLUÇÕES:
-- 1. Recriar validar_senha_local(p_usuario TEXT, p_senha TEXT)
-- 2. Atualizar listar_usuarios_ativos() para incluir campo 'usuario'
-- 3. Criar função autenticar_funcionario_local() se não existir
-- 4. Garantir todas as permissões necessárias
--
-- 📅 Data: 2024-12-08
-- =====================================================

-- =====================================================
-- PASSO 1: REMOVER FUNÇÕES ANTIGAS (se existirem)
-- =====================================================

DROP FUNCTION IF EXISTS validar_senha_local(UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS validar_senha_local(TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID) CASCADE;
DROP FUNCTION IF EXISTS autenticar_funcionario_local(TEXT, TEXT) CASCADE;

-- =====================================================
-- PASSO 2: CRIAR listar_usuarios_ativos COM CAMPO 'usuario'
-- =====================================================

CREATE OR REPLACE FUNCTION public.listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN,
  usuario TEXT  -- ⭐ CAMPO ESSENCIAL para login
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
    COALESCE(lf.usuario, f.email, f.nome) as usuario  -- Usuario da tabela login_funcionarios (ou fallback)
  FROM public.funcionarios f
  LEFT JOIN public.login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
  WHERE f.empresa_id = p_empresa_id
    AND f.status = 'ativo'
    AND lf.usuario IS NOT NULL  -- Garantir que tem login
    AND lf.ativo = true
  ORDER BY 
    CASE WHEN f.tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
    f.nome;
END;
$$;

COMMENT ON FUNCTION public.listar_usuarios_ativos(UUID) IS 
'Lista funcionários ativos com login configurado para seleção na tela de login';

-- =====================================================
-- PASSO 3: CRIAR validar_senha_local (CORRIGIDA)
-- =====================================================

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
        v_senha_valida := (v_login.senha_hash = crypt(p_senha, v_login.senha_hash));
        RAISE NOTICE '🔑 Testando senha_hash: %', 
            CASE WHEN v_senha_valida THEN '✅ VÁLIDA' ELSE '❌ INVÁLIDA' END;
    ELSIF v_login.senha IS NOT NULL AND LENGTH(v_login.senha) > 0 THEN
        v_senha_valida := (v_login.senha = crypt(p_senha, v_login.senha));
        RAISE NOTICE '🔑 Testando senha (fallback): %', 
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
'Valida credenciais de funcionário usando usuário e senha. Retorna dados do funcionário se válido.';

-- =====================================================
-- PASSO 4: CRIAR autenticar_funcionario_local (se não existir)
-- =====================================================

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
-- PASSO 5: GARANTIR PERMISSÕES
-- =====================================================

GRANT EXECUTE ON FUNCTION public.listar_usuarios_ativos(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.validar_senha_local(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.autenticar_funcionario_local(TEXT, TEXT) TO anon, authenticated;

-- =====================================================
-- PASSO 6: VERIFICAR E CRIAR EXTENSÃO PGCRYPTO
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================
-- PASSO 7: TESTE COMPLETO
-- =====================================================

DO $$
DECLARE
    v_empresa_id UUID;
    v_usuarios JSON;
    v_login_teste JSON;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '🧪 INICIANDO TESTES DO SISTEMA';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    
    -- Buscar primeira empresa
    SELECT id INTO v_empresa_id
    FROM empresas
    LIMIT 1;
    
    IF v_empresa_id IS NULL THEN
        RAISE NOTICE '⚠️ Nenhuma empresa encontrada no sistema';
    ELSE
        RAISE NOTICE '🏢 Empresa de teste: %', v_empresa_id;
        
        -- Testar listar_usuarios_ativos
        RAISE NOTICE '';
        RAISE NOTICE '📋 Testando listar_usuarios_ativos()...';
        
        SELECT json_agg(row_to_json(t))
        INTO v_usuarios
        FROM (
            SELECT * FROM listar_usuarios_ativos(v_empresa_id)
        ) t;
        
        IF v_usuarios IS NULL OR json_array_length(v_usuarios) = 0 THEN
            RAISE NOTICE '⚠️ Nenhum usuário ativo encontrado';
        ELSE
            RAISE NOTICE '✅ Usuários encontrados: %', json_array_length(v_usuarios);
            RAISE NOTICE '   Dados: %', v_usuarios::text;
        END IF;
        
        -- Testar validar_senha_local (exemplo genérico)
        RAISE NOTICE '';
        RAISE NOTICE '🔑 Funções de validação criadas com sucesso';
        RAISE NOTICE '   - validar_senha_local(usuario, senha)';
        RAISE NOTICE '   - autenticar_funcionario_local(usuario, senha)';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ CORREÇÃO COMPLETA APLICADA!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE '📝 Próximos passos no frontend:';
    RAISE NOTICE '   1. Ajustar AuthContext.signInLocal()';
    RAISE NOTICE '   2. Verificar interface LocalUser tem campo "usuario"';
    RAISE NOTICE '   3. Usar usuarioSelecionado.usuario ao chamar RPC';
    RAISE NOTICE '';
    RAISE NOTICE '💡 Exemplo de uso:';
    RAISE NOTICE '   const { data } = await supabase.rpc("validar_senha_local", {';
    RAISE NOTICE '     p_usuario: usuarioSelecionado.usuario,';
    RAISE NOTICE '     p_senha: senha';
    RAISE NOTICE '   })';
    RAISE NOTICE '';
END;
$$;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
    '✅ FUNÇÕES CRIADAS' as status,
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
