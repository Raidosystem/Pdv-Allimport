-- ============================================
-- BUSCA PROFUNDA: cris-ramos30@hotmail.com
-- Verifica TODAS as tabelas auth.*
-- ============================================

-- ============================================
-- 1️⃣ VERIFICAR auth.users
-- ============================================
SELECT 'auth.users' as tabela, id, email, created_at, deleted_at
FROM auth.users
WHERE email ILIKE '%cris-ramos30%' OR email ILIKE '%cris%ramos%';

-- ============================================
-- 2️⃣ VERIFICAR auth.identities
-- ============================================
SELECT 
  'auth.identities' as tabela,
  id,
  user_id,
  provider,
  identity_data->>'email' as email,
  created_at
FROM auth.identities
WHERE identity_data->>'email' ILIKE '%cris-ramos30%' 
   OR identity_data->>'email' ILIKE '%cris%ramos%';

-- ============================================
-- 3️⃣ VERIFICAR auth.sessions
-- ============================================
SELECT 
  'auth.sessions' as tabela,
  id,
  user_id,
  created_at,
  updated_at
FROM auth.sessions
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email ILIKE '%cris-ramos30%'
);

-- ============================================
-- 4️⃣ VERIFICAR auth.refresh_tokens
-- ============================================
SELECT 
  'auth.refresh_tokens' as tabela,
  id,
  token,
  user_id,
  created_at
FROM auth.refresh_tokens
WHERE user_id::text IN (
  SELECT id::text FROM auth.users WHERE email ILIKE '%cris-ramos30%'
);

-- ============================================
-- 5️⃣ VERIFICAR auth.audit_log_entries (se existir)
-- ============================================
SELECT 
  'auth.audit_log_entries' as tabela,
  id,
  payload->>'email' as email,
  payload->>'user_id' as user_id,
  created_at
FROM auth.audit_log_entries
WHERE payload->>'email' ILIKE '%cris-ramos30%'
   OR payload->>'user_email' ILIKE '%cris-ramos30%'
LIMIT 10;

-- ============================================
-- 6️⃣ VERIFICAR TODAS as tabelas auth.* que contenham email
-- ============================================
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'auth'
  AND (column_name ILIKE '%email%' OR column_name ILIKE '%user%')
ORDER BY table_name, ordinal_position;

-- ============================================
-- 7️⃣ LISTAR TODAS as tabelas do schema auth
-- ============================================
SELECT 
  schemaname,
  tablename,
  tableowner
FROM pg_tables
WHERE schemaname = 'auth'
ORDER BY tablename;

-- ============================================
-- ✅ PRÓXIMOS PASSOS
-- ============================================
-- Se encontrar o usuário em alguma tabela acima:
-- 1. Identifique a tabela específica
-- 2. Delete manualmente com o ID correto
-- 3. Tente cadastrar novamente
