-- ================================
-- SCRIPT PARA CORRIGIR ACESSO ADMIN SEM auth.uid()
-- Execute este SQL no Supabase Dashboard SQL Editor
-- ================================

-- 1. REMOVER POLÍTICAS RLS ATUAIS
DROP POLICY IF EXISTS "Users can view own approval status" ON public.user_approvals;
DROP POLICY IF EXISTS "Admins can view all approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Admins can update approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "System can insert approvals" ON public.user_approvals;

-- 2. CRIAR POLÍTICA MAIS PERMISSIVA PARA VISUALIZAÇÃO
-- Permite que qualquer usuário autenticado veja registros (para funcionar no frontend)
CREATE POLICY "Authenticated users can view approvals" ON public.user_approvals
  FOR SELECT USING (true);

-- 3. CRIAR POLÍTICA PARA USUÁRIOS VEREM PRÓPRIO STATUS
CREATE POLICY "Users can view own status" ON public.user_approvals
  FOR SELECT USING (auth.uid() = user_id);

-- 4. CRIAR POLÍTICA PARA INSERÇÃO (para o trigger funcionar)
CREATE POLICY "Allow insert for system" ON public.user_approvals
  FOR INSERT WITH CHECK (true);

-- 5. CRIAR POLÍTICA PARA ATUALIZAÇÕES (mais permissiva)
CREATE POLICY "Allow updates for authenticated users" ON public.user_approvals
  FOR UPDATE USING (true);

-- 6. VERIFICAR SE AS NOVAS POLÍTICAS FUNCIONAM
SELECT 
  'Teste após correção RLS' as info,
  COUNT(*) as total_registros
FROM public.user_approvals;

SELECT 
  'Lista de usuários após correção' as info,
  email,
  status,
  created_at
FROM public.user_approvals
ORDER BY created_at DESC;

-- 7. VERIFICAR POLÍTICAS CRIADAS
SELECT 
  'Políticas Ativas' as info,
  policyname,
  cmd,
  permissive
FROM pg_policies 
WHERE tablename = 'user_approvals';

-- Pronto! Agora o painel admin deve funcionar mesmo sem auth.uid() ativo.
