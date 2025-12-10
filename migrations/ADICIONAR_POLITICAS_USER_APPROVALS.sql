-- ================================================
-- CORREÇÃO RÁPIDA: ADICIONAR POLÍTICAS FALTANTES
-- ================================================

-- Adicionar políticas de UPDATE e INSERT para user_approvals
-- (necessárias para o AdminDashboard funcionar completamente)

DROP POLICY IF EXISTS "admins_update_approvals" ON public.user_approvals;
CREATE POLICY "admins_update_approvals" 
ON public.user_approvals 
FOR UPDATE
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  OR
  user_role = 'admin'
);

DROP POLICY IF EXISTS "admins_insert_approvals" ON public.user_approvals;
CREATE POLICY "admins_insert_approvals" 
ON public.user_approvals 
FOR INSERT
WITH CHECK (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);

-- Verificar políticas ativas
SELECT 
  'POLÍTICAS ATIVAS EM USER_APPROVALS' as etapa,
  policyname,
  cmd as tipo
FROM pg_policies
WHERE tablename = 'user_approvals'
ORDER BY policyname;

-- Testar acesso
SELECT 
  'TESTE: Contar user_approvals visíveis' as etapa,
  COUNT(*) as total
FROM public.user_approvals;

SELECT 
  'TESTE: Listar user_approvals' as etapa,
  email,
  status,
  user_role
FROM public.user_approvals
ORDER BY created_at DESC;
