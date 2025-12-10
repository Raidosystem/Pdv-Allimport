-- ✅ Corrigir usuário teste@teste.com (Gregori) para ser funcionário

-- 1. Transformar Gregori em funcionário do proprietário assistenciaallimport10@gmail.com
UPDATE public.user_approvals 
SET 
    user_role = 'employee',
    parent_user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1', -- ID do assistenciaallimport10@gmail.com
    created_by = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
    status = 'approved',
    approved_at = NOW(),
    approved_by = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE email = 'teste@teste.com' AND full_name = 'Gregori';

-- 2. Verificar se a correção funcionou
SELECT 
    email,
    full_name,
    status,
    user_role,
    parent_user_id,
    created_by,
    approved_at IS NOT NULL as aprovado,
    created_at
FROM public.user_approvals 
WHERE email = 'teste@teste.com';

-- 3. Buscar todos os funcionários do proprietário
SELECT 
    email,
    full_name,
    user_role,
    status,
    created_at
FROM public.user_approvals 
WHERE parent_user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
AND user_role = 'employee'
AND status = 'approved'
ORDER BY created_at DESC;
