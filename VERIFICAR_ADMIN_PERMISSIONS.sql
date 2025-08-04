-- ================================
-- SCRIPT PARA VERIFICAR E CORRIGIR PERMISSÕES ADMIN
-- Execute este SQL no Supabase Dashboard SQL Editor
-- ================================

-- 1. VERIFICAR USUÁRIO ADMIN ATUAL
SELECT 
  'Usuário Admin Atual' as info,
  id,
  email,
  raw_user_meta_data,
  created_at
FROM auth.users 
WHERE email = 'novaradiosystem@outlook.com';

-- 2. VERIFICAR SE ADMIN ESTÁ NA TABELA user_approvals
SELECT 
  'Status Admin na tabela approvals' as info,
  ua.email,
  ua.status,
  ua.user_id
FROM public.user_approvals ua
WHERE ua.email = 'novaradiosystem@outlook.com';

-- 3. GARANTIR QUE ADMIN ESTEJA APROVADO
INSERT INTO public.user_approvals (user_id, email, full_name, status)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', 'Administrador'),
  'approved'
FROM auth.users au
WHERE au.email = 'novaradiosystem@outlook.com'
AND NOT EXISTS (
  SELECT 1 FROM public.user_approvals ua 
  WHERE ua.user_id = au.id
);

-- 4. ATUALIZAR STATUS PARA APPROVED (se não estiver)
UPDATE public.user_approvals 
SET 
  status = 'approved',
  approved_at = NOW(),
  updated_at = NOW()
WHERE email = 'novaradiosystem@outlook.com'
AND status != 'approved';

-- 5. TESTAR CONSULTA QUE O PAINEL ADMIN FAZ
SELECT 
  'Teste da consulta do AdminPanel' as info,
  user_id,
  email,
  full_name,
  company_name,
  status,
  approved_by,
  approved_at,
  created_at
FROM public.user_approvals
ORDER BY created_at DESC;

-- 6. VERIFICAR SE USUÁRIO ATUAL PODE ACESSAR A TABELA
SELECT 
  'Teste de acesso direto' as info,
  COUNT(*) as total_registros
FROM public.user_approvals;

-- 7. TESTAR POLÍTICA DE ADMIN
SELECT 
  'Verificação de política admin' as info,
  auth.uid() as current_user_id,
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE auth.uid() = id 
    AND (
      email = 'novaradiosystem@outlook.com'
      OR email = 'admin@pdvallimport.com'
      OR email = 'teste@teste.com'
      OR raw_user_meta_data->>'role' = 'admin'
    )
  ) as is_admin;

-- Pronto! Agora o admin deve conseguir acessar o painel sem erros.
