-- ============================================
-- 🔓 DAR ACESSO TOTAL AO ADMIN
-- Execute APENAS este SQL no Supabase
-- ============================================

-- ⚠️ IMPORTANTE: Isto NÃO mexe em assinaturas!
-- Apenas dá permissão para o ADMIN ver tudo

-- 1. Permitir admin ver TODAS as assinaturas
DROP POLICY IF EXISTS "Admin can view all subscriptions" ON public.subscriptions;
CREATE POLICY "Admin can view all subscriptions" 
ON public.subscriptions 
FOR SELECT 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR EXISTS (
    SELECT 1 FROM user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
);

-- 2. Permitir admin ATUALIZAR assinaturas (adicionar dias, pausar)
DROP POLICY IF EXISTS "Admin can update subscriptions" ON public.subscriptions;
CREATE POLICY "Admin can update subscriptions" 
ON public.subscriptions 
FOR UPDATE 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR EXISTS (
    SELECT 1 FROM user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
);

-- 3. Permitir admin ver TODOS os user_approvals
DROP POLICY IF EXISTS "Admin can view all user_approvals" ON public.user_approvals;
CREATE POLICY "Admin can view all user_approvals" 
ON public.user_approvals 
FOR SELECT 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR user_role = 'admin'
);

-- ============================================
-- ✅ PRONTO! Agora o admin pode:
-- - Ver TODAS as assinaturas
-- - Atualizar assinaturas (adicionar dias, pausar)
-- - Ver todos os usuários
-- ============================================

SELECT 
  '✅ PERMISSÕES CONFIGURADAS!' as status,
  'O admin agora tem acesso total' as mensagem;
