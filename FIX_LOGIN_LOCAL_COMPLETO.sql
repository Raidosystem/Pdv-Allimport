-- 🔧 CRIAR RPC listar_usuarios_ativos E CORRIGIR SISTEMA

-- ====================================
-- 1. VER TODOS FUNCIONÁRIOS (SEM FILTRO)
-- ====================================
SELECT 
  '👥 TODOS FUNCIONÁRIOS' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  tipo_admin,
  status,
  empresa_id,
  created_at
FROM funcionarios
ORDER BY created_at DESC
LIMIT 10;

-- ====================================
-- 2. VERIFICAR SE RPC EXISTE
-- ====================================
SELECT 
  '🔍 VERIFICAR RPC' as info,
  COUNT(*) as existe
FROM pg_proc
WHERE proname = 'listar_usuarios_ativos';

-- ====================================
-- 3. CRIAR OU SUBSTITUIR RPC listar_usuarios_ativos
-- ====================================
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
    AND (f.usuario_ativo = true OR f.usuario_ativo IS NULL)  -- NULL é considerado ativo
    AND (f.status = 'ativo' OR f.status IS NULL)
    AND f.senha_definida = true  -- Só mostra se tem senha definida
  ORDER BY f.nome;
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO anon;

-- ====================================
-- 4. CRIAR OU SUBSTITUIR RPC validar_senha_local
-- ====================================
-- Dropar função antiga se existir
DROP FUNCTION IF EXISTS validar_senha_local(UUID, TEXT);

CREATE OR REPLACE FUNCTION validar_senha_local(
  p_funcionario_id UUID,
  p_senha TEXT
)
RETURNS TABLE (
  sucesso BOOLEAN,
  token TEXT,
  funcionario_id UUID,
  nome TEXT,
  email TEXT,
  tipo_admin TEXT,
  empresa_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_funcionario RECORD;
  v_login RECORD;
  v_senha_hash TEXT;
BEGIN
  -- Buscar funcionário
  SELECT * INTO v_funcionario
  FROM funcionarios
  WHERE id = p_funcionario_id;
  
  IF NOT FOUND THEN
    RETURN QUERY SELECT false, ''::TEXT, NULL::UUID, ''::TEXT, ''::TEXT, ''::TEXT, NULL::UUID;
    RETURN;
  END IF;
  
  -- Buscar login
  SELECT * INTO v_login
  FROM login_funcionarios
  WHERE funcionario_id = p_funcionario_id
    AND ativo = true
  LIMIT 1;
  
  -- Se não tem login, criar um com a senha fornecida
  IF NOT FOUND THEN
    v_senha_hash := crypt(p_senha, gen_salt('bf'));
    
    INSERT INTO login_funcionarios (funcionario_id, usuario, senha, ativo)
    VALUES (p_funcionario_id, v_funcionario.nome, v_senha_hash, true)
    RETURNING * INTO v_login;
  END IF;
  
  -- Validar senha
  IF v_login.senha = crypt(p_senha, v_login.senha) THEN
    -- Atualizar primeiro_acesso se necessário
    IF v_funcionario.primeiro_acesso THEN
      UPDATE funcionarios
      SET primeiro_acesso = false
      WHERE id = p_funcionario_id;
    END IF;
    
    -- Retornar sucesso
    RETURN QUERY SELECT 
      true,
      'local_token_' || p_funcionario_id::TEXT,
      v_funcionario.id,
      v_funcionario.nome,
      COALESCE(v_funcionario.email, ''),
      v_funcionario.tipo_admin,
      v_funcionario.empresa_id;
  ELSE
    -- Senha incorreta
    RETURN QUERY SELECT false, ''::TEXT, NULL::UUID, ''::TEXT, ''::TEXT, ''::TEXT, NULL::UUID;
  END IF;
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION validar_senha_local(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION validar_senha_local(UUID, TEXT) TO anon;

-- ====================================
-- 5. ATIVAR FUNCIONÁRIOS SEM SENHA
-- ====================================
-- Marca funcionários como ativos e com senha definida se forem novos
UPDATE funcionarios
SET 
  usuario_ativo = true,
  senha_definida = true,
  status = 'ativo',
  primeiro_acesso = true
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
  AND (usuario_ativo IS NULL OR usuario_ativo = false)
  AND (senha_definida IS NULL OR senha_definida = false);

-- ====================================
-- 6. TESTAR NOVAMENTE
-- ====================================
SELECT 
  '🧪 TESTE APÓS CORREÇÃO' as teste,
  *
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- ====================================
-- 7. VER RESULTADO FINAL
-- ====================================
SELECT 
  '✅ FUNCIONÁRIOS ATIVOS' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  tipo_admin
FROM funcionarios
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY nome;
