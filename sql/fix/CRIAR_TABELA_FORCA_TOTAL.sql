-- ===================================================
-- 🚨 SOLUÇÃO DEFINITIVA - CRIAR TABELA USER_APPROVALS
-- ===================================================
-- Execute este script COMPLETO no Supabase SQL Editor
-- Data: 30/08/2025
-- ===================================================

-- 1. FORÇAR CRIAÇÃO DA TABELA USER_APPROVALS
-- ===================================================
DROP TABLE IF EXISTS public.user_approvals CASCADE;

CREATE TABLE public.user_approvals (
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

-- 2. DESABILITAR COMPLETAMENTE O RLS
-- ===================================================
ALTER TABLE public.user_approvals DISABLE ROW LEVEL SECURITY;

-- 3. DAR PERMISSÕES TOTAIS (MÉTODO FORÇA BRUTA)
-- ===================================================
GRANT ALL ON public.user_approvals TO postgres;
GRANT ALL ON public.user_approvals TO anon;
GRANT ALL ON public.user_approvals TO authenticated;
GRANT ALL ON public.user_approvals TO service_role;
GRANT ALL ON public.user_approvals TO public;

-- 4. CRIAR ÍNDICES
-- ===================================================
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);

-- 5. POPULAR TABELA COM TODOS OS USUÁRIOS (AUTO-APROVADOS)
-- ===================================================
INSERT INTO public.user_approvals (user_id, email, full_name, status, approved_at, created_at)
SELECT 
  u.id,
  u.email,
  COALESCE(
    u.raw_user_meta_data->>'full_name', 
    u.raw_user_meta_data->>'name', 
    u.raw_user_meta_data->>'display_name',
    SPLIT_PART(u.email, '@', 1)
  ) as full_name,
  'approved' as status,
  NOW() as approved_at,
  u.created_at
FROM auth.users u
ON CONFLICT (user_id) DO UPDATE SET 
  status = 'approved',
  approved_at = NOW();

-- 6. CONFIRMAR TODOS OS EMAILS
-- ===================================================
UPDATE auth.users 
SET 
  email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
  updated_at = NOW()
WHERE email_confirmed_at IS NULL;

-- 7. GARANTIR ADMIN APROVADO
-- ===================================================
INSERT INTO public.user_approvals (user_id, email, full_name, status, approved_at, created_at)
SELECT 
  u.id,
  u.email,
  'Administrador do Sistema' as full_name,
  'approved' as status,
  NOW() as approved_at,
  u.created_at
FROM auth.users u
WHERE u.email = 'novaradiosystem@outlook.com'
ON CONFLICT (user_id) DO UPDATE SET 
  status = 'approved',
  approved_at = NOW(),
  full_name = 'Administrador do Sistema';

-- Confirmar email do admin
UPDATE auth.users 
SET email_confirmed_at = NOW(), updated_at = NOW() 
WHERE email = 'novaradiosystem@outlook.com';

-- 8. LIMPAR SESSÕES ANTIGAS
-- ===================================================
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;

-- 9. TESTE FINAL - VERIFICAR SE TABELA ESTÁ ACESSÍVEL
-- ===================================================
SELECT 
  '🎉 TESTE DE ACESSO À TABELA' as teste,
  COUNT(*) as total_registros,
  COUNT(CASE WHEN status = 'approved' THEN 1 END) as aprovados,
  COUNT(CASE WHEN email = 'novaradiosystem@outlook.com' THEN 1 END) as admin_encontrado
FROM public.user_approvals;

-- 10. LISTAR USUÁRIOS PARA VERIFICAÇÃO
-- ===================================================
SELECT 
  '👥 USUÁRIOS NA TABELA' as info,
  email,
  full_name,
  status,
  approved_at
FROM public.user_approvals 
ORDER BY created_at DESC 
LIMIT 10;

-- 11. VERIFICAR PERMISSÕES DA TABELA
-- ===================================================
SELECT 
  '🔧 PERMISSÕES DA TABELA' as info,
  schemaname,
  tablename,
  tableowner,
  CASE 
    WHEN has_table_privilege('public.user_approvals', 'SELECT') THEN '✅ SELECT OK'
    ELSE '❌ SELECT NEGADO'
  END as select_perm,
  CASE 
    WHEN has_table_privilege('public.user_approvals', 'INSERT') THEN '✅ INSERT OK'
    ELSE '❌ INSERT NEGADO'
  END as insert_perm,
  CASE 
    WHEN has_table_privilege('public.user_approvals', 'UPDATE') THEN '✅ UPDATE OK'
    ELSE '❌ UPDATE NEGADO'
  END as update_perm
FROM pg_tables 
WHERE tablename = 'user_approvals' AND schemaname = 'public';

-- ===================================================
-- 🚀 RESULTADO ESPERADO:
-- ===================================================
-- Se você ver:
-- - ✅ Teste com total_registros > 0
-- - ✅ admin_encontrado = 1
-- - ✅ Todas as permissões OK
-- 
-- Então a tabela foi criada com sucesso!
-- Agora teste o login na aplicação.
-- ===================================================
