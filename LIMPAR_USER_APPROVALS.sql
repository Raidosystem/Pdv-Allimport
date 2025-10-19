-- ============================================
-- LIMPAR auth.user_approvals
-- Deletar registros de usuários não ativos
-- ============================================

-- ============================================
-- 1️⃣ VER TODOS OS REGISTROS EM user_approvals
-- ============================================
SELECT 
  id,
  user_id,
  email,
  created_at,
  updated_at,
  CASE 
    WHEN email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com') THEN '✅ PRESERVAR'
    ELSE '❌ DELETAR'
  END as acao
FROM auth.user_approvals
ORDER BY created_at DESC;

-- ============================================
-- 2️⃣ CONTAR TOTAL A SER DELETADO
-- ============================================
SELECT 
  (SELECT COUNT(*) FROM auth.user_approvals 
   WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as approvals_a_deletar,
  (SELECT COUNT(*) FROM auth.user_approvals 
   WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as approvals_a_preservar;

-- ============================================
-- 3️⃣ BUSCAR ESPECIFICAMENTE cris-ramos30@hotmail.com
-- ============================================
SELECT 
  id,
  user_id,
  email,
  created_at,
  updated_at,
  '🎯 ESTE É O PROBLEMA!' as status
FROM auth.user_approvals
WHERE email ILIKE '%cris-ramos30%';

-- ============================================
-- 4️⃣ DELETAR TODOS EXCETO OS 2 ATIVOS
-- ============================================

DELETE FROM auth.user_approvals
WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com');

-- ============================================
-- 5️⃣ VERIFICAÇÃO FINAL
-- ============================================

-- Deve retornar 0 (todos deletados)
SELECT 
  COUNT(*) as approvals_nao_ativos,
  'User approvals NÃO ativos (deve ser 0)' as descricao
FROM auth.user_approvals
WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com');

-- Deve retornar 2 ou 0 (apenas os ativos, se existirem)
SELECT 
  COUNT(*) as approvals_ativos,
  'User approvals ativos preservados' as descricao
FROM auth.user_approvals
WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com');

-- Verificar que cris-ramos30 foi deletado (deve retornar 0)
SELECT 
  COUNT(*) as cris_ramos_count,
  'cris-ramos30 em user_approvals (deve ser 0)' as descricao
FROM auth.user_approvals
WHERE email ILIKE '%cris-ramos30%';

-- ============================================
-- 6️⃣ LISTAR APENAS APPROVALS DOS ATIVOS
-- ============================================

SELECT 
  id,
  user_id,
  email,
  created_at,
  '✅ ATIVO - Preservado' as status
FROM auth.user_approvals
WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
ORDER BY email;

-- ============================================
-- ✅ PRONTO!
-- ============================================
-- Após executar este script:
-- 1. Todos os registros em user_approvals (exceto os 2 ativos) serão deletados
-- 2. O email cris-ramos30@hotmail.com será completamente removido
-- 3. Você poderá cadastrar novos usuários sem erro "User already registered"
