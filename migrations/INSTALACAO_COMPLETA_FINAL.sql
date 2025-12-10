-- =============================================
-- ?? SCRIPT CONSOLIDADO FINAL - EXECUTE TUDO AQUI
-- =============================================
-- Este script faz TUDO em uma única execução:
-- 1. Garante extensão pgcrypto
-- 2. Corrige RPC listar_usuarios_ativos
-- 3. Corrige RPC validar_senha_local
-- 4. Corrige RPC atualizar_senha_funcionario
-- 5. Corrige RPC trocar_senha_propria
-- 6. Ativa Jennifer (e qualquer outro funcionário)
-- 7. Instala TRIGGER para novos funcionários
-- 8. Testa tudo
-- =============================================
-- ?? Tempo estimado: 1 minuto
-- =============================================

-- =============================================
-- PARTE 1: GARANTIR EXTENSÃO pgcrypto
-- =============================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

SELECT '? PASSO 1: Extension pgcrypto garantida' as status;

-- =============================================
-- PARTE 2: CORRIGIR RPC listar_usuarios_ativos
-- =============================================

DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID);

CREATE OR REPLACE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
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
    COALESCE(f.primeiro_acesso, true) as primeiro_acesso,
    COALESCE(lf.usuario, lower(regexp_replace(f.nome, '[^a-zA-Z0-9]', '', 'g'))) as usuario
  FROM funcionarios f
  LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
  WHERE f.empresa_id = p_empresa_id
    AND (f.ativo = true OR f.ativo IS NULL)
    AND (f.usuario_ativo = true OR f.usuario_ativo IS NULL)
    AND (f.status = 'ativo' OR f.status IS NULL)
    AND f.senha_definida = true
    AND (f.tipo_admin IS NULL OR f.tipo_admin != 'super_admin')
  ORDER BY f.nome;
END;
$$;

GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated, anon;

SELECT '? PASSO 2: RPC listar_usuarios_ativos corrigida' as status;

-- =============================================
-- PARTE 3: CORRIGIR RPC validar_senha_local
-- =============================================

DROP FUNCTION IF EXISTS validar_senha_local(TEXT, TEXT);

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
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE usuario = p_usuario AND ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Usuário ou senha inválidos');
    END IF;

    IF v_login.senha_hash IS NOT NULL AND v_login.senha_hash != '' THEN
        v_senha_valida := (v_login.senha_hash = crypt(p_senha, v_login.senha_hash));
    ELSIF v_login.senha IS NOT NULL AND v_login.senha != '' THEN
        v_senha_valida := (v_login.senha = crypt(p_senha, v_login.senha));
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object('success', false, 'error', 'Usuário ou senha inválidos');
    END IF;

    SELECT f.*, func.nome as funcao_nome, func.nivel as funcao_nivel
    INTO v_funcionario
    FROM funcionarios f
    LEFT JOIN funcoes func ON f.funcao_id = func.id
    WHERE f.id = v_login.funcionario_id AND f.ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Funcionário inativo');
    END IF;

    RETURN json_build_object(
        'success', true,
        'funcionario', row_to_json(v_funcionario),
        'precisa_trocar_senha', COALESCE(v_login.precisa_trocar_senha, false)
    );
END;
$$;

GRANT EXECUTE ON FUNCTION validar_senha_local(TEXT, TEXT) TO authenticated, anon;

SELECT '? PASSO 3: RPC validar_senha_local corrigida' as status;

-- =============================================
-- PARTE 4: CORRIGIR RPC atualizar_senha_funcionario
-- =============================================

DROP FUNCTION IF EXISTS atualizar_senha_funcionario(UUID, TEXT);

CREATE OR REPLACE FUNCTION atualizar_senha_funcionario(
    p_funcionario_id UUID,
    p_nova_senha TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_funcionario_id IS NULL OR p_nova_senha IS NULL THEN
        RAISE EXCEPTION 'ID e senha obrigatórios';
    END IF;

    IF LENGTH(p_nova_senha) < 6 THEN
        RAISE EXCEPTION 'Senha deve ter pelo menos 6 caracteres';
    END IF;

    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_nova_senha, gen_salt('bf')),
        senha = crypt(p_nova_senha, gen_salt('bf')),
        precisa_trocar_senha = TRUE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Funcionário não encontrado';
    END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) TO authenticated;

SELECT '? PASSO 4: RPC atualizar_senha_funcionario corrigida' as status;

-- =============================================
-- PARTE 5: CORRIGIR RPC trocar_senha_propria
-- =============================================

DROP FUNCTION IF EXISTS trocar_senha_propria(UUID, TEXT, TEXT);

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
    IF p_funcionario_id IS NULL OR p_senha_antiga IS NULL OR p_senha_nova IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Todos os campos obrigatórios');
    END IF;

    IF LENGTH(p_senha_nova) < 6 THEN
        RETURN json_build_object('success', false, 'error', 'Nova senha deve ter 6+ caracteres');
    END IF;

    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE funcionario_id = p_funcionario_id AND ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Funcionário não encontrado');
    END IF;

    IF v_login.senha_hash IS NOT NULL AND v_login.senha_hash != '' THEN
        v_senha_valida := (v_login.senha_hash = crypt(p_senha_antiga, v_login.senha_hash));
    ELSIF v_login.senha IS NOT NULL AND v_login.senha != '' THEN
        v_senha_valida := (v_login.senha = crypt(p_senha_antiga, v_login.senha));
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object('success', false, 'error', 'Senha atual incorreta');
    END IF;

    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_senha_nova, gen_salt('bf')),
        senha = crypt(p_senha_nova, gen_salt('bf')),
        precisa_trocar_senha = FALSE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    RETURN json_build_object('success', true, 'message', 'Senha atualizada com sucesso');
END;
$$;

GRANT EXECUTE ON FUNCTION trocar_senha_propria(UUID, TEXT, TEXT) TO authenticated;

SELECT '? PASSO 5: RPC trocar_senha_propria criada' as status;

-- =============================================
-- PARTE 6: ATIVAR TODOS OS FUNCIONÁRIOS
-- =============================================

-- Ativar TODOS os funcionários da empresa
UPDATE funcionarios
SET 
  usuario_ativo = TRUE,
  senha_definida = TRUE,
  status = 'ativo',
  ativo = TRUE
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND (usuario_ativo IS NULL OR usuario_ativo = FALSE OR senha_definida IS NULL OR senha_definida = FALSE);

SELECT '? PASSO 6: Todos os funcionários ativados' as status;

-- =============================================
-- PARTE 7: CRIAR/ATUALIZAR LOGIN PARA TODOS
-- =============================================

DO $$
DECLARE
  v_funcionario RECORD;
  v_username TEXT;
  v_login_exists BOOLEAN;
  v_count INT := 0;
BEGIN
  FOR v_funcionario IN 
    SELECT id, nome 
    FROM funcionarios 
    WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
      AND senha_definida = TRUE
  LOOP
    -- Gerar username
    v_username := lower(regexp_replace(v_funcionario.nome, '[^a-zA-Z0-9]', '', 'g'));
    
    -- Verificar se login existe
    SELECT EXISTS (
      SELECT 1 FROM login_funcionarios WHERE funcionario_id = v_funcionario.id
    ) INTO v_login_exists;
    
    IF v_login_exists THEN
      -- Atualizar existente
      UPDATE login_funcionarios
      SET 
        ativo = TRUE,
        precisa_trocar_senha = TRUE,
        senha_hash = crypt('123456', gen_salt('bf')),
        senha = crypt('123456', gen_salt('bf')),
        updated_at = NOW()
      WHERE funcionario_id = v_funcionario.id;
      
      RAISE NOTICE '? Login ATUALIZADO: % (usuario: %)', v_funcionario.nome, v_username;
    ELSE
      -- Criar novo
      INSERT INTO login_funcionarios (funcionario_id, usuario, senha_hash, senha, ativo, precisa_trocar_senha)
      VALUES (
        v_funcionario.id,
        v_username,
        crypt('123456', gen_salt('bf')),
        crypt('123456', gen_salt('bf')),
        TRUE,
        TRUE
      );
      
      RAISE NOTICE '? Login CRIADO: % (usuario: %, senha: 123456)', v_funcionario.nome, v_username;
    END IF;
    
    v_count := v_count + 1;
  END LOOP;
  
  RAISE NOTICE '?? Total de logins criados/atualizados: %', v_count;
END $$;

SELECT '? PASSO 7: Logins criados/atualizados para todos' as status;

-- =============================================
-- PARTE 8: INSTALAR TRIGGER PARA NOVOS FUNCIONÁRIOS
-- =============================================

-- Função do Trigger
CREATE OR REPLACE FUNCTION auto_criar_login_funcionario()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_usuario TEXT;
  v_senha_padrao TEXT := '123456';
BEGIN
  v_usuario := lower(regexp_replace(NEW.nome, '[^a-zA-Z0-9]', '', 'g'));
  
  INSERT INTO login_funcionarios (
    funcionario_id,
    usuario,
    senha_hash,
    senha,
    ativo,
    precisa_trocar_senha,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    v_usuario,
    crypt(v_senha_padrao, gen_salt('bf')),
    crypt(v_senha_padrao, gen_salt('bf')),
    TRUE,
    TRUE,
    NOW(),
    NOW()
  )
  ON CONFLICT (funcionario_id) DO UPDATE
  SET 
    usuario = EXCLUDED.usuario,
    ativo = TRUE,
    updated_at = NOW();
  
  NEW.senha_definida := TRUE;
  NEW.usuario_ativo := TRUE;
  NEW.primeiro_acesso := TRUE;
  
  RETURN NEW;
END;
$$;

-- Criar Trigger
DROP TRIGGER IF EXISTS trigger_auto_criar_login ON funcionarios;

CREATE TRIGGER trigger_auto_criar_login
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION auto_criar_login_funcionario();

-- Trigger para UPDATE (nome alterado)
CREATE OR REPLACE FUNCTION auto_atualizar_login_funcionario()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_usuario TEXT;
BEGIN
  IF OLD.nome != NEW.nome THEN
    v_usuario := lower(regexp_replace(NEW.nome, '[^a-zA-Z0-9]', '', 'g'));
    
    UPDATE login_funcionarios
    SET 
      usuario = v_usuario,
      updated_at = NOW()
    WHERE funcionario_id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_auto_atualizar_login ON funcionarios;

CREATE TRIGGER trigger_auto_atualizar_login
  AFTER UPDATE ON funcionarios
  FOR EACH ROW
  WHEN (OLD.nome IS DISTINCT FROM NEW.nome)
  EXECUTE FUNCTION auto_atualizar_login_funcionario();

SELECT '? PASSO 8: Triggers instalados' as status;

-- =============================================
-- PARTE 9: VERIFICAÇÃO FINAL
-- =============================================

-- Verificar RPCs
SELECT 
  '?? VERIFICAÇÃO FINAL - RPCs' as secao,
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN '?'
    ELSE '?'
  END as pgcrypto,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos') THEN '?'
    ELSE '?'
  END as rpc_listar_usuarios,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'validar_senha_local') THEN '?'
    ELSE '?'
  END as rpc_validar_senha,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'atualizar_senha_funcionario') THEN '?'
    ELSE '?'
  END as rpc_atualizar_senha,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'trocar_senha_propria') THEN '?'
    ELSE '?'
  END as rpc_trocar_senha;

-- Verificar Triggers
SELECT 
  '?? VERIFICAÇÃO FINAL - Triggers' as secao,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'trigger_auto_criar_login') THEN '?'
    ELSE '?'
  END as trigger_criar,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'trigger_auto_atualizar_login') THEN '?'
    ELSE '?'
  END as trigger_atualizar;

-- Testar RPC
SELECT 
  '? TESTE RPC - Usuários que vão aparecer' as secao,
  id,
  nome,
  email,
  tipo_admin,
  usuario
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1')
ORDER BY nome;

-- Estatísticas
SELECT 
  '?? ESTATÍSTICAS' as secao,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1') as total_funcionarios,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' AND usuario_ativo = true) as funcionarios_ativos,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' AND senha_definida = true) as com_senha_definida,
  (SELECT COUNT(*) FROM login_funcionarios lf JOIN funcionarios f ON f.id = lf.funcionario_id WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1') as total_logins,
  (SELECT COUNT(*) FROM login_funcionarios lf JOIN funcionarios f ON f.id = lf.funcionario_id WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' AND lf.ativo = true) as logins_ativos,
  (SELECT COUNT(*) FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1')) as aparecendo_login_local;

-- Estado final detalhado
SELECT 
  '?? ESTADO FINAL DETALHADO' as secao,
  f.nome,
  f.tipo_admin,
  f.usuario_ativo,
  f.senha_definida,
  f.ativo,
  f.status,
  lf.usuario as username,
  lf.ativo as login_ativo,
  CASE 
    WHEN f.usuario_ativo = TRUE 
     AND f.senha_definida = TRUE 
     AND (f.ativo = TRUE OR f.ativo IS NULL)
     AND (f.status = 'ativo' OR f.status IS NULL)
     AND lf.usuario IS NOT NULL
    THEN '? VAI APARECER'
    ELSE '? NÃO VAI APARECER'
  END as status_login_local
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- =============================================
-- ? CONCLUSÃO
-- =============================================

SELECT 
  '?? INSTALAÇÃO COMPLETA!' as resultado,
  '? Todas as RPCs corrigidas' as rpcs,
  '? Todos os funcionários ativados' as funcionarios,
  '? Triggers instalados para novos funcionários' as triggers,
  '? Senha padrão para todos: 123456' as senha,
  'Acesse: http://localhost:5173/login-local' as proximo_passo;

-- =============================================
-- ?? INFORMAÇÕES IMPORTANTES
-- =============================================
-- 
-- ? O QUE FOI FEITO:
-- 1. Extension pgcrypto instalada
-- 2. 5 RPCs corrigidas (listar, validar, atualizar, trocar)
-- 3. Todos os funcionários ativados
-- 4. Login criado para TODOS os funcionários
-- 5. Triggers instalados para automação
-- 
-- ?? SENHAS:
-- - Todos os funcionários: 123456
-- - Precisa trocar no primeiro login: SIM
-- 
-- ?? NOVOS FUNCIONÁRIOS:
-- - Login criado automaticamente
-- - Senha padrão: 123456
-- - Username: nome sem espaços
-- 
-- ?? TESTAR AGORA:
-- 1. Acesse http://localhost:5173/login-local
-- 2. Deve ver TODOS os funcionários
-- 3. Senha de todos: 123456
-- 4. Sistema vai pedir troca de senha
-- 
-- ?? CADASTRAR NOVO FUNCIONÁRIO:
-- - Basta cadastrar normalmente no painel
-- - Login será criado automaticamente
-- - Aparecerá imediatamente em /login-local
-- 
-- =============================================
