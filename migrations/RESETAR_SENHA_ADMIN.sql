-- ============================================================================
-- RESETAR SENHA DO ADMIN
-- ============================================================================
-- Este script reseta a senha do super admin para permitir login
-- 
-- INSTRUÇÕES:
-- 1. Copie este SQL completo
-- 2. Vá ao Supabase Dashboard > SQL Editor
-- 3. Cole e execute
-- 4. Teste login com: novaradiosystem@outlook.com / 12345678
-- ============================================================================

-- Resetar senha do super admin
UPDATE auth.users 
SET 
  encrypted_password = crypt('12345678', gen_salt('bf')),
  updated_at = NOW()
WHERE email = 'novaradiosystem@outlook.com';

-- Confirmar atualização
SELECT 
  email,
  email_confirmed_at,
  updated_at,
  'Senha resetada para: 12345678' as mensagem
FROM auth.users 
WHERE email = 'novaradiosystem@outlook.com';
