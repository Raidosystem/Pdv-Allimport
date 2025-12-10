-- 🔒 CORREÇÃO DAS POLÍTICAS RLS PARA user_approvals

-- 1. Remover políticas antigas que podem estar causando problema
DROP POLICY IF EXISTS "Permitir leitura de user_approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Permitir inserção de user_approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Permitir atualização de user_approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Permitir exclusão de user_approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "users_can_read_own_approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "owners_can_manage_employees" ON public.user_approvals;
DROP POLICY IF EXISTS "employees_can_read_own_data" ON public.user_approvals;

-- 2. Verificar se RLS está ativo (deve estar)
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'user_approvals';

-- 3. Criar políticas PERMISSIVAS para resolver o problema

-- Política 1: Permitir que usuários vejam seus próprios dados
CREATE POLICY "users_can_view_own_data" ON public.user_approvals
  FOR ALL
  TO authenticated
  USING (
    auth.uid()::text IN (
      SELECT id::text FROM auth.users WHERE email = user_approvals.email
    )
  );

-- Política 2: Proprietários podem ver todos os seus funcionários
CREATE POLICY "owners_can_view_employees" ON public.user_approvals
  FOR ALL
  TO authenticated
  USING (
    -- Proprietário pode ver seus funcionários
    parent_user_id = auth.uid()
    OR
    -- Ou é o próprio usuário vendo seus dados
    auth.uid()::text IN (
      SELECT id::text FROM auth.users WHERE email = user_approvals.email
    )
  );

-- Política 3: Permitir inserção de novos registros (para cadastro)
CREATE POLICY "allow_insert_user_approvals" ON public.user_approvals
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Política 4: Permitir que admins vejam tudo (para o painel admin)
CREATE POLICY "admins_can_view_all" ON public.user_approvals
  FOR ALL
  TO authenticated
  USING (
    auth.uid()::text IN (
      SELECT id::text FROM auth.users 
      WHERE email IN (
        'assistenciaallimport10@gmail.com',
        'admin@allimport.com'
      )
    )
  );

-- 4. Verificar as políticas criadas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'user_approvals';

-- 5. Teste final - verificar se conseguimos acessar os dados
SELECT 
  email, 
  status, 
  user_role, 
  full_name,
  parent_user_id,
  created_at
FROM public.user_approvals 
WHERE user_role = 'employee'
LIMIT 5;
