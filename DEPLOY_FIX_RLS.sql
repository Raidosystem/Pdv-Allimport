-- ================================
-- 🔧 CORREÇÃO DO ERRO DE POLÍTICAS RLS
-- Execute este SQL no Supabase Dashboard SQL Editor
-- Data: 04/08/2025
-- ================================

-- REMOVER TODAS AS POLÍTICAS EXISTENTES PARA user_approvals
DROP POLICY IF EXISTS "Users can view own approval status" ON public.user_approvals;
DROP POLICY IF EXISTS "Admins can view all approvals" ON public.user_approvals;  
DROP POLICY IF EXISTS "Admins can update approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "System can insert approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Authenticated users can view approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Allow insert for system" ON public.user_approvals;
DROP POLICY IF EXISTS "Allow updates for authenticated users" ON public.user_approvals;
DROP POLICY IF EXISTS "Users can view own status" ON public.user_approvals;

-- AGORA CRIAR AS POLÍTICAS CORRETAS
CREATE POLICY "Authenticated users can view approvals" ON public.user_approvals
  FOR SELECT USING (true);

CREATE POLICY "Allow insert for system" ON public.user_approvals  
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow updates for authenticated users" ON public.user_approvals
  FOR UPDATE USING (true);

-- VERIFICAR SE AS POLÍTICAS FORAM CRIADAS
SELECT 
  'Políticas RLS Criadas' as status,
  policyname,
  cmd
FROM pg_policies 
WHERE tablename = 'user_approvals';

SELECT '✅ Erro de políticas RLS corrigido!' as resultado;
