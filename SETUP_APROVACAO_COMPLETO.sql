-- ================================
-- SCRIPT COMPLETO PARA SISTEMA DE APROVAÇÃO
-- Execute este SQL no Supabase Dashboard SQL Editor
-- ================================

-- 1. CRIAR TABELA user_approvals
CREATE TABLE IF NOT EXISTS public.user_approvals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  company_name TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 2. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);

-- 3. HABILITAR ROW LEVEL SECURITY
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS RLS (removendo políticas existentes primeiro)

-- Remover políticas se existirem
DROP POLICY IF EXISTS "Users can view own approval status" ON public.user_approvals;
DROP POLICY IF EXISTS "Admins can view all approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Admins can update approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "System can insert approvals" ON public.user_approvals;

-- Política para usuários verem próprio status
CREATE POLICY "Users can view own approval status" ON public.user_approvals
  FOR SELECT USING (auth.uid() = user_id);

-- Política para admins verem todas as aprovações
CREATE POLICY "Admins can view all approvals" ON public.user_approvals
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.uid() = id 
      AND (
        email = 'admin@pdvallimport.com' 
        OR email = 'novaradiosystem@outlook.com'
        OR email = 'teste@teste.com'
        OR raw_user_meta_data->>'role' = 'admin'
      )
    )
  );

-- Política para admins atualizarem aprovações
CREATE POLICY "Admins can update approvals" ON public.user_approvals
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.uid() = id 
      AND (
        email = 'admin@pdvallimport.com' 
        OR email = 'novaradiosystem@outlook.com'
        OR email = 'teste@teste.com'
        OR raw_user_meta_data->>'role' = 'admin'
      )
    )
  );

-- Política para inserção automática pelo sistema
CREATE POLICY "System can insert approvals" ON public.user_approvals
  FOR INSERT WITH CHECK (true);

-- 5. CRIAR FUNÇÃO PARA CRIAR APROVAÇÃO AUTOMATICAMENTE
CREATE OR REPLACE FUNCTION create_user_approval()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_approvals (user_id, email, full_name, company_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'company_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. CRIAR TRIGGER PARA EXECUÇÃO AUTOMÁTICA
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_user_approval();

-- 7. CRIAR FUNÇÃO PARA VERIFICAR STATUS DE APROVAÇÃO
CREATE OR REPLACE FUNCTION check_user_approval_status(user_uuid UUID)
RETURNS TABLE(
  is_approved BOOLEAN,
  status TEXT,
  approved_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (ua.status = 'approved') as is_approved,
    ua.status,
    ua.approved_at
  FROM public.user_approvals ua
  WHERE ua.user_id = user_uuid;
END;
$$;

-- 8. CRIAR FUNÇÃO PARA APROVAR USUÁRIO (OPCIONAL)
CREATE OR REPLACE FUNCTION approve_user(user_email TEXT, admin_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  target_user_id UUID;
BEGIN
  -- Verificar se quem está executando é admin
  IF NOT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = admin_user_id 
    AND (
      email = 'admin@pdvallimport.com' 
      OR email = 'novaradiosystem@outlook.com'
      OR email = 'teste@teste.com'
      OR raw_user_meta_data->>'role' = 'admin'
    )
  ) THEN
    RETURN FALSE;
  END IF;

  -- Buscar o user_id pelo email
  SELECT au.id INTO target_user_id
  FROM auth.users au
  WHERE au.email = user_email;

  IF target_user_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Atualizar status para aprovado
  UPDATE public.user_approvals 
  SET 
    status = 'approved',
    approved_by = admin_user_id,
    approved_at = NOW(),
    updated_at = NOW()
  WHERE user_id = target_user_id;

  RETURN TRUE;
END;
$$;

-- 9. CRIAR FUNÇÃO PARA REJEITAR USUÁRIO (OPCIONAL)
CREATE OR REPLACE FUNCTION reject_user(user_email TEXT, admin_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  target_user_id UUID;
BEGIN
  -- Verificar se quem está executando é admin
  IF NOT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = admin_user_id 
    AND (
      email = 'admin@pdvallimport.com' 
      OR email = 'novaradiosystem@outlook.com'
      OR email = 'teste@teste.com'
      OR raw_user_meta_data->>'role' = 'admin'
    )
  ) THEN
    RETURN FALSE;
  END IF;

  -- Buscar o user_id pelo email
  SELECT au.id INTO target_user_id
  FROM auth.users au
  WHERE au.email = user_email;

  IF target_user_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Atualizar status para rejeitado
  UPDATE public.user_approvals 
  SET 
    status = 'rejected',
    approved_by = admin_user_id,
    approved_at = NOW(),
    updated_at = NOW()
  WHERE user_id = target_user_id;

  RETURN TRUE;
END;
$$;

-- 10. VERIFICAR SE TUDO FOI CRIADO CORRETAMENTE
SELECT 
  'Tabela user_approvals criada' as status,
  EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'user_approvals') as exists;

SELECT 
  'Trigger criado' as status,
  EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'on_auth_user_created') as exists;

-- Pronto! Sistema de aprovação configurado com sucesso.
-- 
-- COMO USAR:
-- 1. Usuários se cadastram normalmente
-- 2. O trigger cria automaticamente um registro na tabela user_approvals
-- 3. Admins podem aprovar/rejeitar usando o painel ou as funções SQL
-- 4. O sistema verifica o status antes de permitir login
--
-- FUNÇÕES DISPONÍVEIS:
-- - check_user_approval_status(user_uuid) - Verifica status de aprovação
-- - approve_user(email) - Aprova usuário (só admins)
-- - reject_user(email) - Rejeita usuário (só admins)
