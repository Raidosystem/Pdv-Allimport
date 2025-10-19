-- 🔧 CORRIGIR RPC validar_senha_local - ERRO DE AMBIGUIDADE

-- ⚠️ PROBLEMA:
-- Erro: column reference "funcionario_id" is ambiguous
-- Causa: Nome do parâmetro conflita com nome da coluna

-- ====================================
-- 1. DROPAR FUNÇÃO ANTIGA
-- ====================================
DROP FUNCTION IF EXISTS validar_senha_local(UUID, TEXT);

-- ====================================
-- 2. RECRIAR COM NOMES DE PARÂMETROS DIFERENTES
-- ====================================
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
  FROM funcionarios f
  WHERE f.id = p_funcionario_id;
  
  IF NOT FOUND THEN
    RETURN QUERY SELECT false, ''::TEXT, NULL::UUID, ''::TEXT, ''::TEXT, ''::TEXT, NULL::UUID;
    RETURN;
  END IF;
  
  -- Buscar login
  SELECT * INTO v_login
  FROM login_funcionarios lf
  WHERE lf.funcionario_id = p_funcionario_id
    AND lf.ativo = true
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
-- 3. TESTAR VALIDAÇÃO
-- ====================================
-- Testar com Jennifer (senha: 123456)
SELECT 
  '🧪 TESTE VALIDAÇÃO - Jennifer' as teste,
  *
FROM validar_senha_local('ab35e8a4-3408-487c-8f3b-8cbc903de283', '123456');

-- Testar com senha errada
SELECT 
  '🧪 TESTE SENHA ERRADA' as teste,
  *
FROM validar_senha_local('ab35e8a4-3408-487c-8f3b-8cbc903de283', 'senhaerrada');

-- ====================================
-- 4. RESUMO
-- ====================================
SELECT 
  '✅ CORREÇÃO APLICADA' as info,
  'Ambiguidade resolvida usando aliases (f.id, lf.funcionario_id)' as solucao,
  'Função validar_senha_local corrigida' as resultado;
