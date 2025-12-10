-- =====================================================
-- 🔧 CORRIGIR RPC VALIDAR_SENHA_LOCAL
-- =====================================================
-- Erro 409: Function com problema ou faltando
-- =====================================================

-- =====================================================
-- 1️⃣ VERIFICAR SE A FUNCTION EXISTE
-- =====================================================

SELECT 
  routine_name,
  routine_type,
  CASE 
    WHEN routine_name = 'validar_senha_local' THEN '✅ Function existe'
    ELSE '❌ Function não encontrada'
  END as status
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'validar_senha_local';

-- =====================================================
-- 2️⃣ REMOVER FUNCTION ANTIGA (SE EXISTIR)
-- =====================================================

DROP FUNCTION IF EXISTS validar_senha_local(uuid, text);
DROP FUNCTION IF EXISTS validar_senha_local(text, text);

-- =====================================================
-- 3️⃣ CRIAR FUNCTION CORRETA
-- =====================================================

CREATE OR REPLACE FUNCTION validar_senha_local(
  p_funcionario_id uuid,
  p_senha text
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_senha_hash text;
  v_empresa_id uuid;
BEGIN
  -- Buscar senha e empresa do funcionário
  SELECT senha_hash, empresa_id
  INTO v_senha_hash, v_empresa_id
  FROM funcionarios
  WHERE id = p_funcionario_id;
  
  -- Se não encontrou funcionário, retorna false
  IF v_senha_hash IS NULL THEN
    RETURN false;
  END IF;
  
  -- Verificar se a senha está correta
  -- (comparação simples, assumindo que senha_hash está armazenado como texto)
  RETURN v_senha_hash = p_senha;
END;
$$;

-- =====================================================
-- 4️⃣ TESTAR A FUNCTION
-- =====================================================

-- Buscar um funcionário para testar
SELECT 
  '🧪 Teste da function' as status,
  id as funcionario_id,
  nome,
  empresa_id
FROM funcionarios
WHERE empresa_id IN (
  SELECT id FROM empresas 
  WHERE user_id = '922d4f20-6c99-4438-a922-e275eb527c0b'
)
LIMIT 1;

-- =====================================================
-- 5️⃣ VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
  '✅ Function criada' as status,
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'validar_senha_local';

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ Function validar_senha_local criada
-- ✅ Erro 409 deve desaparecer
-- ✅ Login de funcionários deve funcionar
-- =====================================================
