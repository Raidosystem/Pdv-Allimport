
-- LIMPEZA COMPLETA PARA NOVO DOMÍNIO
-- Execute no SQL Editor do Supabase

-- 1. Limpar todas as sessões existentes
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;

-- 2. Resetar configurações de email dos usuários
UPDATE auth.users 
SET 
  email_confirmed_at = NOW(),
  confirmation_token = NULL,
  recovery_token = NULL,
  email_change_token_new = NULL,
  email_change_token_current = NULL
WHERE email IS NOT NULL;

-- 3. Verificar usuários existentes
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  last_sign_in_at,
  CASE 
    WHEN email_confirmed_at IS NULL THEN 'Email não confirmado'
    WHEN last_sign_in_at IS NULL THEN 'Nunca fez login'
    ELSE 'OK'
  END as status
FROM auth.users
ORDER BY created_at DESC;
  