-- ============================================
-- DELETAR DE public.user_approvals
-- Email: cris-ramos30@hotmail.com
-- ============================================

-- ============================================
-- 1️⃣ VER TODOS OS REGISTROS EM user_approvals
-- ============================================
SELECT 
  id,
  email,
  cpf,
  nome,
  status,
  created_at,
  approved_at,
  approved_by
FROM public.user_approvals
ORDER BY created_at DESC;

-- ============================================
-- 2️⃣ BUSCAR cris-ramos30@hotmail.com ESPECIFICAMENTE
-- ============================================
SELECT 
  id,
  email,
  cpf,
  nome,
  status,
  created_at,
  approved_at,
  approved_by
FROM public.user_approvals
WHERE email ILIKE '%cris-ramos30%';

-- ============================================
-- 3️⃣ DELETAR cris-ramos30@hotmail.com
-- ============================================
DELETE FROM public.user_approvals
WHERE email ILIKE '%cris-ramos30%';

-- ============================================
-- 4️⃣ VERIFICAR SE FOI DELETADO
-- ============================================
SELECT 
  COUNT(*) as registros_restantes,
  'Deve ser 0' as esperado
FROM public.user_approvals
WHERE email ILIKE '%cris-ramos30%';

-- ============================================
-- 5️⃣ LISTAR TODOS NOVAMENTE (para confirmar)
-- ============================================
SELECT 
  id,
  email,
  cpf,
  nome,
  status,
  created_at
FROM public.user_approvals
ORDER BY created_at DESC;

-- ============================================
-- ✅ PRONTO!
-- ============================================
-- Após executar:
-- 1. O registro de cris-ramos30@hotmail.com será deletado
-- 2. Você poderá cadastrar novamente sem erro "User already registered"
