-- ============================================================================
-- CORREÇÃO FINAL: Campo email_change NULL
-- ============================================================================
-- O erro está na coluna email_change (índice 8) que está NULL
-- ============================================================================

-- 1. Verificar estado atual
SELECT 
  id,
  email,
  email_change,
  'ANTES' as momento
FROM auth.users
WHERE email = 'novaradiosystem@outlook.com';

-- 2. CORREÇÃO: Preencher email_change com string vazia
UPDATE auth.users
SET 
  email_change = '',
  updated_at = NOW()
WHERE email_confirmed_at IS NOT NULL
  AND (email_change IS NULL OR email_change = '');

-- 3. Verificar resultado
SELECT 
  id,
  email,
  email_change,
  CASE 
    WHEN email_change = '' THEN 'OK' 
    WHEN email_change IS NULL THEN 'AINDA_NULL'
    ELSE 'TEM_VALOR' 
  END as status,
  'DEPOIS' as momento
FROM auth.users
WHERE email = 'novaradiosystem@outlook.com';
