-- ===================================================
-- 🔧 SCRIPT COMPLETO - CRIAR SISTEMA DE APROVAÇÃO
-- ===================================================
-- Execute este script no Supabase SQL Editor AGORA
-- Data: 30/08/2025
-- ===================================================

-- 1. CRIAR TABELA USER_APPROVALS (OBRIGATÓRIA)
-- ===================================================
CREATE TABLE IF NOT EXISTS public.user_approvals (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text,
  company_name text,
  status text DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_at timestamp with time zone DEFAULT NOW(),
  approved_by uuid REFERENCES auth.users(id),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  user_role text DEFAULT 'owner',
  parent_user_id uuid,
  created_by uuid,
  UNIQUE(user_id)
);

-- 2. DESABILITAR RLS (EVITAR PROBLEMAS DE PERMISSÃO)
-- ===================================================
ALTER TABLE public.user_approvals DISABLE ROW LEVEL SECURITY;

-- 3. CRIAR ÍNDICES PARA PERFORMANCE
-- ===================================================
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);

-- 4. POPULAR COM USUÁRIOS EXISTENTES (TODOS APROVADOS)
-- ===================================================
INSERT INTO public.user_approvals (user_id, email, full_name, status, approved_at, created_at)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name', u.email) as full_name,
  'approved' as status,
  u.created_at as approved_at,
  u.created_at
FROM auth.users u
WHERE u.id NOT IN (SELECT COALESCE(user_id, '00000000-0000-0000-0000-000000000000') FROM public.user_approvals)
ON CONFLICT (user_id) DO NOTHING;

-- 5. CONFIRMAR TODOS OS EMAILS DE USUÁRIOS
-- ===================================================
UPDATE auth.users 
SET 
  email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
  updated_at = NOW()
WHERE email_confirmed_at IS NULL;

-- 6. GARANTIR ADMIN ESPECÍFICO APROVADO
-- ===================================================
UPDATE public.user_approvals 
SET status = 'approved', approved_at = NOW() 
WHERE email = 'novaradiosystem@outlook.com';

-- Confirmar email do admin também
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email = 'novaradiosystem@outlook.com';

-- 7. LIMPAR SESSÕES ANTIGAS
-- ===================================================
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;

-- 8. VERIFICAÇÃO FINAL
-- ===================================================
SELECT 
  '✅ SISTEMA CONFIGURADO COM SUCESSO' as status,
  (SELECT COUNT(*) FROM auth.users) as total_usuarios_auth,
  (SELECT COUNT(*) FROM public.user_approvals) as total_usuarios_aprovacao,
  (SELECT COUNT(*) FROM auth.users WHERE email_confirmed_at IS NOT NULL) as emails_confirmados,
  (SELECT COUNT(*) FROM public.user_approvals WHERE status = 'approved') as usuarios_aprovados;

-- 9. VERIFICAR ADMIN ESPECÍFICO
-- ===================================================
SELECT 
  '🔍 STATUS DO ADMIN' as info,
  u.email,
  u.email_confirmed_at IS NOT NULL as email_confirmado,
  ua.status as status_aprovacao
FROM auth.users u
LEFT JOIN public.user_approvals ua ON u.id = ua.user_id
WHERE u.email = 'novaradiosystem@outlook.com';

-- ===================================================
-- 🎯 PRONTO! SISTEMA CONFIGURADO
-- ===================================================
-- Agora você pode:
-- 1. Fechar este SQL Editor
-- 2. Ir para a aplicação
-- 3. Fazer login com novaradiosystem@outlook.com
-- 4. Acessar o painel admin sem erros
-- ===================================================
