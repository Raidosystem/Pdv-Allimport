-- SCRIPT SUPER SIMPLES - SÓ AUTH.USERS
-- Execute este primeiro

-- Ver todos os usuários em auth.users
SELECT 
    id,
    email,
    created_at,
    'Encontrado' as status
FROM auth.users 
ORDER BY created_at DESC;

-- Ver especificamente o admin
SELECT 
    'ADMIN ENCONTRADO:' as info,
    id,
    email,
    created_at
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com';