-- PRIMEIRO: Verificar usuários existentes
-- Execute este script primeiro para ver quais usuários existem

SELECT 
    id,
    email,
    created_at,
    email_confirmed_at,
    last_sign_in_at
FROM auth.users 
ORDER BY created_at DESC
LIMIT 10;