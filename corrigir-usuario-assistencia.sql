-- ✅ Script para corrigir usuário assistenciaallimport10@gmail.com

-- 1. Adicionar colunas hierárquicas se não existirem
ALTER TABLE public.user_approvals ADD COLUMN IF NOT EXISTS user_role text DEFAULT 'owner';
ALTER TABLE public.user_approvals ADD COLUMN IF NOT EXISTS parent_user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.user_approvals ADD COLUMN IF NOT EXISTS created_by uuid;

-- 2. Atualizar o usuário específico
UPDATE public.user_approvals 
SET user_role = 'owner'
WHERE email = 'assistenciaallimport10@gmail.com';

-- 3. Verificar o resultado
SELECT 
    email, 
    status, 
    user_role, 
    full_name, 
    company_name,
    created_at
FROM public.user_approvals 
WHERE email = 'assistenciaallimport10@gmail.com';
