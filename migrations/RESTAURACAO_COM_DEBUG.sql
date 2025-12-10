-- 🔧 RESTAURAÇÃO COM DEBUG - MOSTRA CADA PASSO

-- ====================================
-- 1. STATUS INICIAL
-- ====================================
DO $$
BEGIN
  RAISE NOTICE '🚀 INICIANDO RESTAURAÇÃO COMPLETA...';
  RAISE NOTICE '📅 Data/Hora: %', NOW();
END $$;

-- ====================================
-- 2. REMOVER FUNÇÕES ANTIGAS (COM DEBUG)
-- ====================================
DO $$
BEGIN
  RAISE NOTICE '🗑️ Removendo funções antigas...';
  
  DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID);
  RAISE NOTICE '✅ listar_usuarios_ativos removida';
  
  DROP FUNCTION IF EXISTS validar_senha_local(UUID, TEXT);
  RAISE NOTICE '✅ validar_senha_local removida';
END $$;

-- ====================================
-- 3. CRIAR FUNÇÃO listar_usuarios_ativos (COM DEBUG)
-- ====================================
DO $$
BEGIN
  RAISE NOTICE '🔨 Criando função listar_usuarios_ativos...';
END $$;

CREATE OR REPLACE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    COALESCE(f.email, '') as email,
    f.foto_perfil,
    f.tipo_admin,
    COALESCE(f.senha_definida, false) as senha_definida,
    COALESCE(f.primeiro_acesso, true) as primeiro_acesso
  FROM funcionarios f
  WHERE f.empresa_id = p_empresa_id
    AND (f.usuario_ativo = true OR f.usuario_ativo IS NULL)
    AND (f.status = 'ativo' OR f.status IS NULL)
    AND f.senha_definida = true
  ORDER BY f.nome;
END;
$$;

DO $$
BEGIN
  RAISE NOTICE '✅ Função listar_usuarios_ativos criada com sucesso!';
END $$;

-- ====================================
-- 4. CRIAR FUNÇÃO validar_senha_local (COM DEBUG)
-- ====================================
DO $$
BEGIN
  RAISE NOTICE '🔨 Criando função validar_senha_local...';
END $$;

CREATE OR REPLACE FUNCTION validar_senha_local(
  p_funcionario_id UUID,
  p_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_funcionario RECORD;
  v_login RECORD;
  v_senha_hash TEXT;
BEGIN
  SELECT * INTO v_funcionario FROM funcionarios WHERE id = p_funcionario_id;
  
  IF NOT FOUND THEN
    RETURN json_build_object('sucesso', false, 'mensagem', 'Funcionário não encontrado');
  END IF;
  
  SELECT * INTO v_login FROM login_funcionarios WHERE funcionario_id = p_funcionario_id AND ativo = true LIMIT 1;
  
  IF NOT FOUND THEN
    v_senha_hash := crypt(p_senha, gen_salt('bf'));
    INSERT INTO login_funcionarios (funcionario_id, usuario, senha, ativo) VALUES (p_funcionario_id, v_funcionario.nome, v_senha_hash, true) RETURNING * INTO v_login;
  END IF;
  
  IF v_login.senha = crypt(p_senha, v_login.senha) THEN
    RETURN json_build_object('sucesso', true, 'token', 'local_token_' || p_funcionario_id::TEXT, 'funcionario_id', v_funcionario.id, 'nome', v_funcionario.nome, 'email', COALESCE(v_funcionario.email, ''), 'tipo_admin', v_funcionario.tipo_admin, 'empresa_id', v_funcionario.empresa_id);
  ELSE
    RETURN json_build_object('sucesso', false, 'mensagem', 'Senha incorreta');
  END IF;
END;
$$;

DO $$
BEGIN
  RAISE NOTICE '✅ Função validar_senha_local criada com sucesso!';
END $$;

-- ====================================
-- 5. GARANTIR PERMISSÕES (COM DEBUG)
-- ====================================
DO $$
BEGIN
  RAISE NOTICE '🔑 Configurando permissões...';
END $$;

GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO anon;
GRANT EXECUTE ON FUNCTION validar_senha_local(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION validar_senha_local(UUID, TEXT) TO anon;

DO $$
BEGIN
  RAISE NOTICE '✅ Permissões configuradas!';
END $$;

-- ====================================
-- 6. ATIVAR FUNCIONÁRIOS (COM DEBUG)
-- ====================================
DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  RAISE NOTICE '👥 Ativando funcionários...';
  
  UPDATE funcionarios
  SET 
    usuario_ativo = true,
    senha_definida = true,
    status = 'ativo',
    primeiro_acesso = COALESCE(primeiro_acesso, true)
  WHERE usuario_ativo IS NULL 
     OR usuario_ativo = false 
     OR senha_definida IS NULL 
     OR senha_definida = false 
     OR status IS NULL 
     OR status != 'ativo';
  
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE '✅ % funcionários foram ativados!', v_updated;
END $$;

-- ====================================
-- 7. VERIFICAÇÃO FINAL (COM DEBUG)
-- ====================================
DO $$
DECLARE
  v_func1 BOOLEAN;
  v_func2 BOOLEAN;
  v_funcionarios INTEGER;
BEGIN
  RAISE NOTICE '🔍 Fazendo verificação final...';
  
  -- Verificar funções
  SELECT EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos') INTO v_func1;
  SELECT EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'validar_senha_local') INTO v_func2;
  
  -- Contar funcionários ativos
  SELECT COUNT(*) INTO v_funcionarios FROM funcionarios WHERE usuario_ativo = true AND senha_definida = true;
  
  -- Relatório final
  IF v_func1 AND v_func2 THEN
    RAISE NOTICE '🎉 SUCESSO! Todas as funções foram criadas!';
    RAISE NOTICE '👥 Funcionários ativos: %', v_funcionarios;
    RAISE NOTICE '🔗 Teste agora: https://pdv-allimport-c9c32his2-radiosystem.vercel.app';
  ELSE
    RAISE NOTICE '❌ ERRO! Algumas funções não foram criadas:';
    RAISE NOTICE '   - listar_usuarios_ativos: %', CASE WHEN v_func1 THEN 'OK' ELSE 'ERRO' END;
    RAISE NOTICE '   - validar_senha_local: %', CASE WHEN v_func2 THEN 'OK' ELSE 'ERRO' END;
  END IF;
END $$;

-- ====================================
-- 8. MOSTRAR FUNÇÕES CRIADAS
-- ====================================
SELECT 
  '✅ FUNÇÕES FINAIS' as status,
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('listar_usuarios_ativos', 'validar_senha_local')
ORDER BY routine_name;