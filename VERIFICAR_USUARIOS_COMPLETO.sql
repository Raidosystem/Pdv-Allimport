-- SCRIPT PARA VERIFICAR USUÁRIOS - VERSÃO CORRIGIDA
-- Execute este para ver onde estão os usuários

-- 1. Verificar usuários no sistema auth do Supabase
SELECT 
    'AUTH.USERS' as origem,
    id,
    email,
    created_at
FROM auth.users 
WHERE email IN (
    'assistenciaallimport10@gmail.com',
    'smartcellinova@gmail.com', 
    'silviobritoempreendedor@gmail.com',
    'marcovalentim04@gmail.com',
    'teste123@teste.com',
    'novaradiosystem@outlook.com'
)
ORDER BY created_at DESC;

-- 2. Verificar todas as tabelas que podem conter usuários
SELECT table_name, column_name
FROM information_schema.columns 
WHERE column_name = 'email' 
AND table_schema = 'public';

-- 3. Se existe tabela usuarios, execute separadamente:
-- SELECT 'USUARIOS_CUSTOM' as origem, id::text, email, created_at
-- FROM usuarios 
-- WHERE email IN ('assistenciaallimport10@gmail.com', ...);