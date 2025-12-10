-- ================================================
-- CORREÇÃO COMPLETA DE ACESSO ADMIN
-- Para: novaradiosystem@outlook.com
-- ================================================

-- 0️⃣ ADICIONAR COLUNA user_role SE NÃO EXISTIR
ALTER TABLE public.user_approvals 
ADD COLUMN IF NOT EXISTS user_role TEXT DEFAULT 'owner';

-- 1️⃣ VERIFICAR SE O USUÁRIO EXISTE
SELECT 
  '1. VERIFICAR USUÁRIO' as etapa,
  id,
  email,
  raw_user_meta_data,
  created_at
FROM auth.users
WHERE email = 'novaradiosystem@outlook.com';

-- 2️⃣ VERIFICAR USER_APPROVALS
SELECT 
  '2. VERIFICAR USER_APPROVALS' as etapa,
  user_id,
  email,
  status,
  user_role,
  approved_at
FROM public.user_approvals
WHERE email = 'novaradiosystem@outlook.com';

-- 3️⃣ ATUALIZAR/CRIAR REGISTRO NO USER_APPROVALS COMO ADMIN
INSERT INTO public.user_approvals (
  user_id,
  email,
  full_name,
  status,
  user_role,
  approved_at,
  approved_by
)
SELECT 
  id,
  email,
  'Admin Sistema',
  'approved',
  'admin',
  NOW(),
  id
FROM auth.users
WHERE email = 'novaradiosystem@outlook.com'
ON CONFLICT (user_id) 
DO UPDATE SET
  status = 'approved',
  user_role = 'admin',
  approved_at = NOW(),
  full_name = COALESCE(user_approvals.full_name, 'Admin Sistema');

-- 4️⃣ ATUALIZAR METADATA DO USUÁRIO NO AUTH.USERS
UPDATE auth.users
SET 
  raw_user_meta_data = jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb),
    '{role}',
    '"admin"'
  ),
  updated_at = NOW()
WHERE email = 'novaradiosystem@outlook.com';

-- 5️⃣ GARANTIR ASSINATURA ATIVA (ILIMITADA PARA ADMIN)
INSERT INTO public.subscriptions (
  user_id,
  email,
  status,
  plan_type,
  subscription_start_date,
  subscription_end_date,
  trial_end_date,
  created_at,
  updated_at
)
SELECT 
  id,
  email,
  'active',
  'enterprise', -- Plano máximo disponível
  NOW(),
  NOW() + INTERVAL '100 years', -- Admin nunca expira
  NULL,
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'novaradiosystem@outlook.com'
ON CONFLICT (user_id) 
DO UPDATE SET
  status = 'active',
  plan_type = 'enterprise',
  subscription_end_date = NOW() + INTERVAL '100 years',
  updated_at = NOW();

-- 6️⃣ CRIAR/ATUALIZAR POLÍTICAS RLS PARA ADMIN
-- Permitir admin ver TODAS as assinaturas
DROP POLICY IF EXISTS "Admin pode ver todas assinaturas" ON public.subscriptions;
CREATE POLICY "Admin pode ver todas assinaturas" 
ON public.subscriptions 
FOR SELECT 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR auth.jwt() -> 'user_metadata' ->> 'role' = 'admin'
  OR EXISTS (
    SELECT 1 FROM public.user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
);

-- Permitir admin ATUALIZAR assinaturas
DROP POLICY IF EXISTS "Admin pode atualizar assinaturas" ON public.subscriptions;
CREATE POLICY "Admin pode atualizar assinaturas" 
ON public.subscriptions 
FOR UPDATE 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR auth.jwt() -> 'user_metadata' ->> 'role' = 'admin'
  OR EXISTS (
    SELECT 1 FROM public.user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
);

-- Permitir admin ver TODOS os user_approvals
DROP POLICY IF EXISTS "Admin pode ver todos user_approvals" ON public.user_approvals;
CREATE POLICY "Admin pode ver todos user_approvals" 
ON public.user_approvals 
FOR SELECT 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR auth.jwt() -> 'user_metadata' ->> 'role' = 'admin'
  OR user_role = 'admin'
  OR user_id = auth.uid()
);

-- 7️⃣ VERIFICAÇÃO FINAL
SELECT 
  '7. VERIFICAÇÃO FINAL' as etapa,
  u.email,
  u.raw_user_meta_data->>'role' as role_metadata,
  ua.user_role,
  ua.status,
  s.status as subscription_status,
  s.plan_type,
  s.subscription_end_date
FROM auth.users u
LEFT JOIN public.user_approvals ua ON ua.user_id = u.id
LEFT JOIN public.subscriptions s ON s.user_id = u.id
WHERE u.email = 'novaradiosystem@outlook.com';

-- ================================================
-- ✅ RESULTADO ESPERADO:
-- - role_metadata: 'admin'
-- - user_role: 'admin'
-- - status: 'approved'
-- - subscription_status: 'active'
-- - plan_type: 'enterprise'
-- - subscription_end_date: 100 anos no futuro
-- ================================================
