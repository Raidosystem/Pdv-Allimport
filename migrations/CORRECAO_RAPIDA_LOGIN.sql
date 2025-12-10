-- 🔧 CORREÇÃO RÁPIDA - SEM CONFLITOS DE FUNÇÃO
-- Script simplificado para corrigir apenas o essencial

-- ====================================
-- 1. REMOVER FUNÇÕES CONFLITANTES
-- ====================================
DROP FUNCTION IF EXISTS validar_senha_local(UUID, TEXT);
DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID);

-- ====================================
-- 2. RECRIAR FUNÇÃO listar_usuarios_ativos
-- ====================================
CREATE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
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

-- ====================================
-- 3. RECRIAR FUNÇÃO validar_senha_local (VERSÃO SIMPLIFICADA)
-- ====================================
CREATE FUNCTION validar_senha_local(
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
  v_result JSON;
BEGIN
  -- Buscar funcionário
  SELECT * INTO v_funcionario
  FROM funcionarios
  WHERE id = p_funcionario_id;
  
  IF NOT FOUND THEN
    v_result := json_build_object(
      'sucesso', false,
      'mensagem', 'Funcionário não encontrado'
    );
    RETURN v_result;
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
    v_result := json_build_object(
      'sucesso', true,
      'mensagem', 'Login realizado com sucesso',
      'token', 'local_token_' || p_funcionario_id::TEXT,
      'funcionario_id', v_funcionario.id,
      'nome', v_funcionario.nome,
      'email', COALESCE(v_funcionario.email, ''),
      'tipo_admin', v_funcionario.tipo_admin,
      'empresa_id', v_funcionario.empresa_id
    );
  ELSE
    -- Senha incorreta
    v_result := json_build_object(
      'sucesso', false,
      'mensagem', 'Senha incorreta'
    );
  END IF;
  
  RETURN v_result;
END;
$$;

-- ====================================
-- 4. GARANTIR PERMISSÕES
-- ====================================
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO anon;
GRANT EXECUTE ON FUNCTION validar_senha_local(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION validar_senha_local(UUID, TEXT) TO anon;

-- ====================================
-- 5. ATIVAR TODOS OS FUNCIONÁRIOS
-- ====================================
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

-- ====================================
-- 6. VERIFICAR RESULTADO
-- ====================================
SELECT 
  '✅ FUNCIONÁRIOS ATIVADOS' as info,
  COUNT(*) as total,
  COUNT(CASE WHEN usuario_ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN senha_definida = true THEN 1 END) as com_senha
FROM funcionarios;

SELECT 
  '📊 POR TIPO' as info,
  tipo_admin,
  COUNT(*) as quantidade
FROM funcionarios
WHERE usuario_ativo = true AND senha_definida = true
GROUP BY tipo_admin;

-- ====================================
-- 7. TESTE RÁPIDO
-- ====================================
SELECT 
  '🎉 CORREÇÃO APLICADA' as status,
  'Agora teste o login no sistema!' as mensagem;