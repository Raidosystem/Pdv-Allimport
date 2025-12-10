-- ============================================
-- VERIFICAÇÃO FINAL E LIMPEZA DEFINITIVA
-- Email: cris-ramos30@hotmail.com
-- ============================================

-- ============================================
-- 1️⃣ VERIFICAR auth.audit_log_entries
-- ============================================
SELECT 
  id,
  payload,
  created_at,
  ip_address
FROM auth.audit_log_entries
WHERE payload::text ILIKE '%cris-ramos30%'
ORDER BY created_at DESC
LIMIT 20;

-- ============================================
-- 2️⃣ VERIFICAR TODAS AS TABELAS NOVAMENTE
-- ============================================

-- auth.users
SELECT 'auth.users' as tabela, COUNT(*) as count
FROM auth.users
WHERE email ILIKE '%cris-ramos30%'

UNION ALL

-- auth.identities
SELECT 'auth.identities' as tabela, COUNT(*) as count
FROM auth.identities
WHERE identity_data->>'email' ILIKE '%cris-ramos30%'

UNION ALL

-- auth.sessions
SELECT 'auth.sessions' as tabela, COUNT(*) as count
FROM auth.sessions s
JOIN auth.users u ON s.user_id = u.id
WHERE u.email ILIKE '%cris-ramos30%'

UNION ALL

-- public.user_approvals
SELECT 'user_approvals' as tabela, COUNT(*) as count
FROM public.user_approvals
WHERE email ILIKE '%cris-ramos30%'

UNION ALL

-- public.empresas
SELECT 'empresas' as tabela, COUNT(*) as count
FROM public.empresas e
JOIN auth.users u ON e.user_id = u.id
WHERE u.email ILIKE '%cris-ramos30%';

-- ============================================
-- 3️⃣ LIMPAR auth.audit_log_entries
-- ============================================
DELETE FROM auth.audit_log_entries
WHERE payload::text ILIKE '%cris-ramos30%';

-- ============================================
-- 4️⃣ VERIFICAR SE AINDA EXISTE ALGO
-- ============================================
SELECT 
  'Verificação Final' as status,
  (SELECT COUNT(*) FROM auth.users WHERE email ILIKE '%cris-ramos30%') as users,
  (SELECT COUNT(*) FROM auth.identities WHERE identity_data->>'email' ILIKE '%cris-ramos30%') as identities,
  (SELECT COUNT(*) FROM public.user_approvals WHERE email ILIKE '%cris-ramos30%') as approvals,
  (SELECT COUNT(*) FROM auth.audit_log_entries WHERE payload::text ILIKE '%cris-ramos30%') as audit_logs;

-- ============================================
-- ✅ SE AINDA EXISTIR, TENTE COM EMAIL EXATO
-- ============================================

-- Deletar com email EXATO (case-insensitive)
DELETE FROM auth.users WHERE LOWER(email) = 'cris-ramos30@hotmail.com';
DELETE FROM auth.identities WHERE LOWER(identity_data->>'email') = 'cris-ramos30@hotmail.com';
DELETE FROM public.user_approvals WHERE LOWER(email) = 'cris-ramos30@hotmail.com';
DELETE FROM auth.audit_log_entries WHERE LOWER(payload::text) LIKE '%cris-ramos30@hotmail.com%';

-- ============================================
-- VERIFICAÇÃO ABSOLUTA FINAL
-- ============================================
SELECT 
  '🎯 RESULTADO FINAL' as status,
  CASE 
    WHEN NOT EXISTS (
      SELECT 1 FROM auth.users WHERE LOWER(email) = 'cris-ramos30@hotmail.com'
    ) AND NOT EXISTS (
      SELECT 1 FROM auth.identities WHERE LOWER(identity_data->>'email') = 'cris-ramos30@hotmail.com'
    ) AND NOT EXISTS (
      SELECT 1 FROM public.user_approvals WHERE LOWER(email) = 'cris-ramos30@hotmail.com'
    ) THEN '✅ TUDO LIMPO - Pode cadastrar!'
    ELSE '❌ Ainda existe algo - Veja queries acima'
  END as resultado;
