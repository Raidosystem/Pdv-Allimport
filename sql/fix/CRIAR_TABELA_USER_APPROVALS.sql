-- ===================================================
-- 🔧 CRIAR SISTEMA DE APROVAÇÃO DE USUÁRIOS
-- ===================================================
-- Execute este script no Supabase SQL Editor para criar
-- a tabela user_approvals e resolver erros de permissão
-- Data: 30/08/2025
-- ===================================================

-- 1. CRIAR TABELA USER_APPROVALS (SE NÃO EXISTIR)
-- ===================================================
CREATE TABLE IF NOT EXISTS public.user_approvals (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  name text,
  requested_at timestamp with time zone DEFAULT now(),
  approved_at timestamp with time zone,
  approved_by uuid REFERENCES auth.users(id),
  status text DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- 2. DESABILITAR RLS TEMPORARIAMENTE (PARA TESTES)
-- ===================================================
ALTER TABLE public.user_approvals DISABLE ROW LEVEL SECURITY;

-- 3. CRIAR ÍNDICES PARA PERFORMANCE
-- ===================================================
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);
CREATE INDEX IF NOT EXISTS idx_user_approvals_created_at ON public.user_approvals(created_at);

-- 4. POPULAR TABELA COM USUÁRIOS EXISTENTES
-- ===================================================
-- Inserir todos os usuários existentes como já aprovados
INSERT INTO public.user_approvals (user_id, email, name, status, approved_at, approved_by)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'name', u.email) as name,
  'APPROVED' as status,
  u.created_at as approved_at,
  u.id as approved_by -- Auto-aprovação para usuários existentes
FROM auth.users u
WHERE u.id NOT IN (SELECT user_id FROM public.user_approvals WHERE user_id IS NOT NULL)
ON CONFLICT (user_id) DO NOTHING;

-- 5. VERIFICAR CRIAÇÃO DA TABELA
-- ===================================================
SELECT 
  '📊 TABELA USER_APPROVALS CRIADA' as info,
  COUNT(*) as total_registros,
  COUNT(CASE WHEN status = 'APPROVED' THEN 1 END) as aprovados,
  COUNT(CASE WHEN status = 'PENDING' THEN 1 END) as pendentes,
  COUNT(CASE WHEN status = 'REJECTED' THEN 1 END) as rejeitados
FROM public.user_approvals;

-- 6. LISTAR USUÁRIOS APROVADOS
-- ===================================================
SELECT 
  '👥 USUÁRIOS NO SISTEMA' as info,
  ua.email,
  ua.status,
  ua.approved_at,
  CASE 
    WHEN ua.status = 'APPROVED' THEN '✅ Aprovado'
    WHEN ua.status = 'PENDING' THEN '⏳ Pendente'
    ELSE '❌ Rejeitado'
  END as status_display
FROM public.user_approvals ua
ORDER BY ua.created_at DESC
LIMIT 10;

-- 7. CONFIRMAR ADMIN ESPECÍFICO
-- ===================================================
-- Garantir que o admin está aprovado
UPDATE public.user_approvals 
SET 
  status = 'APPROVED',
  approved_at = NOW(),
  updated_at = NOW()
WHERE email = 'novaradiosystem@outlook.com';

-- 8. VERIFICAR PERMISSÕES
-- ===================================================
SELECT 
  '🔧 VERIFICAÇÃO FINAL' as info,
  tablename,
  schemaname,
  tableowner,
  CASE 
    WHEN has_table_privilege('public.user_approvals', 'SELECT') THEN '✅ SELECT'
    ELSE '❌ SELECT'
  END as select_permission,
  CASE 
    WHEN has_table_privilege('public.user_approvals', 'INSERT') THEN '✅ INSERT'
    ELSE '❌ INSERT'
  END as insert_permission,
  CASE 
    WHEN has_table_privilege('public.user_approvals', 'UPDATE') THEN '✅ UPDATE'
    ELSE '❌ UPDATE'
  END as update_permission
FROM pg_tables 
WHERE tablename = 'user_approvals' AND schemaname = 'public';

-- ===================================================
-- 🎯 PRÓXIMOS PASSOS:
-- ===================================================
-- 1. ✅ Tabela user_approvals criada
-- 2. ✅ Usuários existentes marcados como aprovados
-- 3. ✅ Admin confirmado como aprovado
-- 4. 🔄 Teste a aplicação novamente
-- 5. 🔧 Se ainda der erro, verifique as políticas RLS
-- ===================================================
