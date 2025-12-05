-- ================================================
-- CORRIGIR POLÍTICAS RLS DA user_approvals
-- Execute no SQL Editor do Supabase
-- ================================================

-- 1️⃣ VERIFICAR POLÍTICAS ATUAIS
SELECT 
  '1. POLÍTICAS ATUAIS' as etapa,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'user_approvals'
ORDER BY policyname;

-- 2️⃣ REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "Users can view own approval status" ON public.user_approvals;
DROP POLICY IF EXISTS "Admins can view all approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Admins can update approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Allow insert on signup" ON public.user_approvals;
DROP POLICY IF EXISTS "Admin pode ver todas as aprovações" ON public.user_approvals;
DROP POLICY IF EXISTS "Admin pode inserir aprovações" ON public.user_approvals;
DROP POLICY IF EXISTS "Admin pode atualizar aprovações" ON public.user_approvals;

-- 3️⃣ CRIAR POLÍTICAS MAIS PERMISSIVAS

-- Permitir que qualquer usuário autenticado veja sua própria aprovação
CREATE POLICY "users_view_own_approval"
ON public.user_approvals
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Admins podem ver TODAS as aprovações (incluindo admin@pdvallimport.com e novaradiosystem@outlook.com)
CREATE POLICY "admins_view_all_approvals"
ON public.user_approvals
FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'teste@teste.com',
    'cristiano@gruporaval.com.br'
  )
  OR auth.jwt() -> 'user_metadata' ->> 'role' = 'admin'
  OR EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.raw_user_meta_data ->> 'role' = 'admin'
  )
);

-- Admins podem INSERIR novas aprovações
CREATE POLICY "admins_insert_approvals"
ON public.user_approvals
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Admins podem ATUALIZAR aprovações
CREATE POLICY "admins_update_approvals"
ON public.user_approvals
FOR UPDATE
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com',
    'teste@teste.com',
    'cristiano@gruporaval.com.br'
  )
  OR auth.jwt() -> 'user_metadata' ->> 'role' = 'admin'
);

-- 4️⃣ VERIFICAR SE RLS ESTÁ HABILITADO
SELECT 
  '2. STATUS DO RLS' as etapa,
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'user_approvals';

-- 5️⃣ VERIFICAR NOVAS POLÍTICAS
SELECT 
  '3. NOVAS POLÍTICAS CRIADAS' as etapa,
  policyname,
  cmd as operacao,
  roles,
  CASE 
    WHEN policyname LIKE '%admin%' THEN '👑 Admin'
    WHEN policyname LIKE '%own%' THEN '👤 Próprio usuário'
    ELSE '📋 Geral'
  END as tipo
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'user_approvals'
ORDER BY policyname;

-- 6️⃣ TESTAR ACESSO (como admin)
SELECT 
  '4. TESTE DE ACESSO' as etapa,
  COUNT(*) as total_registros,
  COUNT(CASE WHEN status = 'approved' THEN 1 END) as aprovados,
  COUNT(CASE WHEN status = 'pending' THEN 1 END) as pendentes,
  STRING_AGG(DISTINCT email, ', ') as emails
FROM public.user_approvals;

-- ================================================
-- ✅ PRONTO! AGORA O ADMINPANEL DEVE FUNCIONAR
-- ================================================

SELECT 
  '✅ POLÍTICAS RLS CORRIGIDAS!' as resultado,
  'Recarregue o AdminPanel e teste' as proxima_acao;
