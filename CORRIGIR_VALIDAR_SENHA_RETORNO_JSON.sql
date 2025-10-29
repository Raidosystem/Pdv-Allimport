-- =====================================================
-- 🔧 CORRIGIR RPC validar_senha_local (RETORNAR OBJETO)
-- =====================================================
-- Erro: Cannot read properties of undefined (reading 'sucesso')
-- Causa: Function retorna boolean, código espera objeto {sucesso, mensagem}
-- =====================================================

-- =====================================================
-- 1️⃣ REMOVER FUNCTION ANTIGA
-- =====================================================

DROP FUNCTION IF EXISTS validar_senha_local(uuid, text);

-- =====================================================
-- 2️⃣ CRIAR FUNCTION QUE RETORNA OBJETO JSON
-- =====================================================

CREATE OR REPLACE FUNCTION validar_senha_local(
  p_funcionario_id uuid,
  p_senha text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_senha_hash text;
  v_funcionario_nome text;
  v_funcionario_status text;
BEGIN
  -- Buscar dados do funcionário
  SELECT 
    senha_hash, 
    nome,
    status
  INTO 
    v_senha_hash, 
    v_funcionario_nome,
    v_funcionario_status
  FROM funcionarios
  WHERE id = p_funcionario_id;
  
  -- Se não encontrou funcionário
  IF v_senha_hash IS NULL THEN
    RETURN jsonb_build_object(
      'sucesso', false,
      'mensagem', 'Funcionário não encontrado'
    );
  END IF;

  -- Se funcionário está inativo ou pausado
  IF v_funcionario_status != 'ativo' THEN
    RETURN jsonb_build_object(
      'sucesso', false,
      'mensagem', 'Funcionário inativo ou pausado'
    );
  END IF;
  
  -- Verificar senha (comparação simples por enquanto)
  -- TODO: Implementar bcrypt quando disponível
  IF v_senha_hash = p_senha THEN
    RETURN jsonb_build_object(
      'sucesso', true,
      'mensagem', 'Login realizado com sucesso',
      'funcionario_id', p_funcionario_id,
      'funcionario_nome', v_funcionario_nome
    );
  ELSE
    RETURN jsonb_build_object(
      'sucesso', false,
      'mensagem', 'Senha incorreta'
    );
  END IF;
END;
$$;

-- =====================================================
-- 3️⃣ TESTAR A FUNCTION
-- =====================================================

-- Buscar um funcionário para testar
SELECT 
  '🧪 Funcionário de teste' as info,
  id,
  nome,
  status
FROM funcionarios
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id = '922d4f20-6c99-4438-a922-e275eb527c0b'
)
LIMIT 1;

-- =====================================================
-- 4️⃣ VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
  '✅ Function criada' as status,
  routine_name,
  data_type as return_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'validar_senha_local';

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ Function retorna JSONB (não boolean)
-- ✅ Retorna objeto: {sucesso: true/false, mensagem: '...'}
-- ✅ Erro "Cannot read properties of undefined" desaparece
-- ✅ Login de funcionários funciona
-- =====================================================
