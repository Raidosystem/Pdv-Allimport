-- =====================================================
-- 🧪 TESTAR RPC validar_senha_local
-- =====================================================
-- Verificar se a function está retornando JSON corretamente
-- =====================================================

-- =====================================================
-- 1️⃣ VERIFICAR TIPO DE RETORNO
-- =====================================================

SELECT 
  routine_name,
  data_type as return_type,
  routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'validar_senha_local';

-- =====================================================
-- 2️⃣ BUSCAR FUNCIONÁRIO PARA TESTE
-- =====================================================

SELECT 
  id,
  nome,
  senha_hash,
  status
FROM funcionarios
WHERE empresa_id = '6acedc99-3b4d-4441-a545-3bfaab6bfb19'
LIMIT 1;

-- =====================================================
-- 3️⃣ TESTAR RPC COM SENHA ERRADA
-- =====================================================

-- Substitua o ID do funcionário pelo resultado da query anterior
SELECT validar_senha_local(
  'COLE_ID_DO_FUNCIONARIO_AQUI'::uuid,
  'senha_errada'
);

-- =====================================================
-- 4️⃣ RESULTADO ESPERADO
-- =====================================================
-- Deve retornar algo como:
-- {"sucesso": false, "mensagem": "Senha incorreta"}
-- 
-- Se retornar NULL ou undefined = RPC não está funcionando
-- =====================================================
