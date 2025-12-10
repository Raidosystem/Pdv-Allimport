-- ============================================
-- BUSCAR USUÁRIO "OCULTO" NO AUTH.USERS
-- Procura por cris-ramos30@hotmail.com em TODOS os estados
-- ============================================

-- ============================================
-- 1️⃣ BUSCAR POR EMAIL EXATO (incluindo deletados)
-- ============================================
SELECT 
  id,
  email,
  created_at,
  updated_at,
  last_sign_in_at,
  email_confirmed_at,
  phone_confirmed_at,
  confirmation_sent_at,
  recovery_sent_at,
  email_change_sent_at,
  new_email,
  invited_at,
  deleted_at,
  is_super_admin,
  raw_app_meta_data,
  raw_user_meta_data,
  CASE 
    WHEN deleted_at IS NOT NULL THEN '🗑️ SOFT DELETED'
    WHEN email_confirmed_at IS NULL THEN '⚠️ EMAIL NÃO CONFIRMADO'
    ELSE '✅ ATIVO'
  END as status
FROM auth.users
WHERE email = 'cris-ramos30@hotmail.com';

-- ============================================
-- 2️⃣ BUSCAR POR EMAIL SEMELHANTE (case insensitive)
-- ============================================
SELECT 
  id,
  email,
  created_at,
  deleted_at,
  email_confirmed_at,
  'Busca case-insensitive' as tipo_busca
FROM auth.users
WHERE LOWER(email) = LOWER('cris-ramos30@hotmail.com');

-- ============================================
-- 3️⃣ BUSCAR POR PARTE DO EMAIL
-- ============================================
SELECT 
  id,
  email,
  created_at,
  deleted_at,
  email_confirmed_at,
  'Busca parcial (LIKE)' as tipo_busca
FROM auth.users
WHERE email LIKE '%cris-ramos30%';

-- ============================================
-- 4️⃣ VERIFICAR SE EXISTE IDENTIDADE (auth.identities)
-- ============================================
SELECT 
  i.id,
  i.user_id,
  i.identity_data->>'email' as email_from_identity,
  i.provider,
  i.created_at,
  i.updated_at,
  u.email as email_from_users,
  u.deleted_at
FROM auth.identities i
LEFT JOIN auth.users u ON u.id = i.user_id
WHERE i.identity_data->>'email' = 'cris-ramos30@hotmail.com'
   OR LOWER(i.identity_data->>'email') = LOWER('cris-ramos30@hotmail.com');

-- ============================================
-- 5️⃣ LISTAR TODOS OS USUÁRIOS (para comparar)
-- ============================================
SELECT 
  id,
  email,
  created_at,
  deleted_at,
  email_confirmed_at,
  CASE 
    WHEN deleted_at IS NOT NULL THEN '🗑️ DELETADO'
    WHEN email_confirmed_at IS NULL THEN '⚠️ NÃO CONFIRMADO'
    WHEN email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com') THEN '✅ ATIVO'
    ELSE '❓ OUTRO'
  END as status
FROM auth.users
ORDER BY created_at DESC;

-- ============================================
-- ✅ RESUMO
-- ============================================
-- Este script busca o email em TODOS os estados possíveis:
-- 1. Email exato (incluindo soft deleted)
-- 2. Email case-insensitive
-- 3. Email parcial (LIKE)
-- 4. Identidades (auth.identities)
-- 5. Lista todos os usuários para comparação
