-- ================================
-- SCRIPT PARA CORRIGIR USUÁRIOS EXISTENTES
-- Execute este SQL no Supabase Dashboard SQL Editor
-- ================================

-- 1. INSERIR REGISTROS user_approvals PARA USUÁRIOS EXISTENTES
INSERT INTO public.user_approvals (user_id, email, full_name, company_name, status)
SELECT 
  au.id as user_id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', au.raw_user_meta_data->>'name') as full_name,
  au.raw_user_meta_data->>'company_name' as company_name,
  CASE 
    WHEN au.email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com') 
    OR au.raw_user_meta_data->>'role' = 'admin'
    THEN 'approved'  -- Admins são automaticamente aprovados
    ELSE 'pending'   -- Outros usuários ficam pendentes
  END as status
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.user_approvals ua 
  WHERE ua.user_id = au.id
);

-- 2. APROVAR AUTOMATICAMENTE OS ADMINS (se ainda não aprovados)
UPDATE public.user_approvals 
SET 
  status = 'approved',
  approved_at = NOW(),
  updated_at = NOW()
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com')
  OR raw_user_meta_data->>'role' = 'admin'
)
AND status != 'approved';

-- 3. VERIFICAR RESULTADOS
SELECT 
  'Total de usuários' as tipo,
  COUNT(*) as quantidade
FROM auth.users;

SELECT 
  'Usuários com aprovação' as tipo,
  COUNT(*) as quantidade
FROM public.user_approvals;

SELECT 
  'Status das aprovações' as info,
  status,
  COUNT(*) as quantidade
FROM public.user_approvals
GROUP BY status;

SELECT 
  'Admins aprovados' as info,
  au.email,
  ua.status
FROM public.user_approvals ua
JOIN auth.users au ON ua.user_id = au.id
WHERE au.email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com')
OR au.raw_user_meta_data->>'role' = 'admin';

-- Pronto! Agora todos os usuários existentes têm registro na tabela user_approvals
-- e apenas os admins estão aprovados automaticamente.
