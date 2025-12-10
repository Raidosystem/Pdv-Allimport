-- ============================================
-- LIMPAR RATE LIMITING E CACHE DO SUPABASE
-- ============================================

-- ============================================
-- 1️⃣ VERIFICAR TENTATIVAS RECENTES NO AUDIT LOG
-- ============================================
SELECT 
  payload->>'action' as action,
  payload->>'actor_username' as email,
  COUNT(*) as tentativas,
  MAX(created_at) as ultima_tentativa
FROM auth.audit_log_entries
WHERE payload->>'actor_username' ILIKE '%cris-ramos30%'
   OR payload::text ILIKE '%cris-ramos30%'
GROUP BY payload->>'action', payload->>'actor_username'
ORDER BY MAX(created_at) DESC;

-- ============================================
-- 2️⃣ DELETAR TODAS AS TENTATIVAS DO AUDIT LOG
-- ============================================
DELETE FROM auth.audit_log_entries
WHERE payload->>'actor_username' ILIKE '%cris-ramos30%'
   OR payload::text ILIKE '%cris-ramos30%';

-- ============================================
-- 3️⃣ VERIFICAR E LIMPAR FLOW_STATE (pode ter registro de signup)
-- ============================================
SELECT 
  id,
  user_id,
  auth_code,
  created_at,
  updated_at
FROM auth.flow_state
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email ILIKE '%cris-ramos30%'
)
ORDER BY created_at DESC;

-- Deletar flow_state órfãos
DELETE FROM auth.flow_state
WHERE user_id NOT IN (
  SELECT id FROM auth.users
);

-- ============================================
-- 4️⃣ VERIFICAR auth.saml_providers e auth.saml_relay_states
-- ============================================
-- Verificar se existem tabelas SAML
SELECT 
  table_name
FROM information_schema.tables
WHERE table_schema = 'auth'
  AND table_name LIKE '%saml%';

-- ============================================
-- 5️⃣ VERIFICAÇÃO FINAL ABSOLUTA
-- ============================================
SELECT 
  'Verificação Completa' as status,
  (SELECT COUNT(*) FROM auth.users WHERE email = 'cris-ramos30@hotmail.com') as users,
  (SELECT COUNT(*) FROM auth.identities WHERE identity_data->>'email' = 'cris-ramos30@hotmail.com') as identities,
  (SELECT COUNT(*) FROM auth.audit_log_entries WHERE payload::text ILIKE '%cris-ramos30%') as audit_logs,
  (SELECT COUNT(*) FROM public.user_approvals WHERE email = 'cris-ramos30@hotmail.com') as approvals;

-- ============================================
-- ✅ RESULTADO ESPERADO
-- ============================================
-- Todos os counts devem ser 0
-- Se ainda houver erro "User already registered", é cache do Supabase Auth
-- Solução: Aguardar 5-10 minutos OU usar email ligeiramente diferente
