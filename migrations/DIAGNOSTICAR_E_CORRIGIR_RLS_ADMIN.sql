-- ================================================
-- DIAGNÓSTICO E CORREÇÃO COMPLETA DE RLS ADMIN
-- Para resolver erro 403 no acesso a subscriptions
-- ================================================

-- 1️⃣ VERIFICAR POLÍTICAS ATUAIS EM SUBSCRIPTIONS
SELECT 
  '1. POLÍTICAS ATUAIS EM SUBSCRIPTIONS' as etapa,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual as using_expression,
  with_check as with_check_expression
FROM pg_policies
WHERE tablename = 'subscriptions'
ORDER BY policyname;

-- 2️⃣ VERIFICAR SE RLS ESTÁ HABILITADO
SELECT 
  '2. STATUS RLS' as etapa,
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename IN ('subscriptions', 'user_approvals')
ORDER BY tablename;

-- 3️⃣ REMOVER TODAS AS POLÍTICAS ANTIGAS E CONFLITANTES
DROP POLICY IF EXISTS "Users can view own subscription" ON public.subscriptions;
DROP POLICY IF EXISTS "Users can update own subscription" ON public.subscriptions;
DROP POLICY IF EXISTS "Users can insert own subscription" ON public.subscriptions;
DROP POLICY IF EXISTS "Admin can view all subscriptions" ON public.subscriptions;
DROP POLICY IF EXISTS "Admin can update subscriptions" ON public.subscriptions;
DROP POLICY IF EXISTS "Admin pode ver todas assinaturas" ON public.subscriptions;
DROP POLICY IF EXISTS "Admin pode atualizar assinaturas" ON public.subscriptions;
DROP POLICY IF EXISTS "Admins podem ver todas as assinaturas" ON public.subscriptions;
DROP POLICY IF EXISTS "Admins podem atualizar assinaturas" ON public.subscriptions;
DROP POLICY IF EXISTS "service_role_all_access" ON public.subscriptions;

-- 4️⃣ CRIAR POLÍTICAS CORRETAS E FUNCIONAIS

-- POLÍTICA 1: Usuários comuns veem apenas sua própria assinatura
CREATE POLICY "users_view_own_subscription" 
ON public.subscriptions 
FOR SELECT 
USING (
  auth.uid() = user_id
);

-- POLÍTICA 2: ADMINS veem TODAS as assinaturas
CREATE POLICY "admins_view_all_subscriptions" 
ON public.subscriptions 
FOR SELECT 
USING (
  -- Verificar por email direto
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  -- Verificar por metadata
  (auth.jwt() -> 'user_metadata' ->> 'role' = 'admin')
  OR
  -- Verificar em user_approvals
  EXISTS (
    SELECT 1 FROM public.user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
);

-- POLÍTICA 3: Usuários comuns podem atualizar sua própria assinatura
CREATE POLICY "users_update_own_subscription" 
ON public.subscriptions 
FOR UPDATE 
USING (
  auth.uid() = user_id
);

-- POLÍTICA 4: ADMINS podem atualizar TODAS as assinaturas
CREATE POLICY "admins_update_all_subscriptions" 
ON public.subscriptions 
FOR UPDATE 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  (auth.jwt() -> 'user_metadata' ->> 'role' = 'admin')
  OR
  EXISTS (
    SELECT 1 FROM public.user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
);

-- POLÍTICA 5: ADMINS podem DELETAR assinaturas
CREATE POLICY "admins_delete_subscriptions" 
ON public.subscriptions 
FOR DELETE 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  (auth.jwt() -> 'user_metadata' ->> 'role' = 'admin')
  OR
  EXISTS (
    SELECT 1 FROM public.user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
);

-- POLÍTICA 6: Permitir INSERT de novas assinaturas
CREATE POLICY "users_insert_own_subscription" 
ON public.subscriptions 
FOR INSERT 
WITH CHECK (
  auth.uid() = user_id
);

-- 5️⃣ REPETIR PARA USER_APPROVALS
-- Remover políticas antigas
DROP POLICY IF EXISTS "Users can view own approval status" ON public.user_approvals;
DROP POLICY IF EXISTS "Admin can view all user_approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Admin pode ver todos user_approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Admins podem ver todos os user_approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "users_view_own_approval" ON public.user_approvals;
DROP POLICY IF EXISTS "admins_view_all_approvals" ON public.user_approvals;

-- Criar políticas corretas
CREATE POLICY "users_view_own_approval" 
ON public.user_approvals 
FOR SELECT 
USING (
  auth.uid() = user_id
);

CREATE POLICY "admins_view_all_approvals" 
ON public.user_approvals 
FOR SELECT 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  (auth.jwt() -> 'user_metadata' ->> 'role' = 'admin')
  OR
  user_role = 'admin'
);

-- 6️⃣ GARANTIR QUE RLS ESTÁ HABILITADO
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;

-- 7️⃣ VERIFICAÇÃO FINAL DAS POLÍTICAS
SELECT 
  '7. VERIFICAÇÃO FINAL DAS POLÍTICAS' as etapa,
  tablename,
  policyname,
  cmd as comando,
  CASE 
    WHEN policyname LIKE '%admin%' THEN '🔴 ADMIN'
    ELSE '🟢 USER'
  END as tipo
FROM pg_policies
WHERE tablename IN ('subscriptions', 'user_approvals')
ORDER BY tablename, policyname;

-- 8️⃣ TESTAR ACESSO COMO ADMIN
SELECT 
  '8. TESTE: Contar assinaturas visíveis' as etapa,
  COUNT(*) as total_visiveis
FROM public.subscriptions;

SELECT 
  '8. TESTE: Listar assinaturas visíveis' as etapa,
  email,
  status,
  plan_type
FROM public.subscriptions
ORDER BY created_at DESC
LIMIT 5;

-- ================================================
-- ✅ RESULTADO ESPERADO:
-- - Políticas criadas sem conflitos
-- - RLS habilitado em ambas as tabelas
-- - Admin consegue ver TODAS as assinaturas
-- - Usuários comuns veem apenas a própria
-- ================================================
