-- Script para implementar sistema de aprovação administrativa
-- Criar tabela para controlar status de aprovação dos usuários

-- 1. Criar tabela user_approvals
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

-- 2. Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);

-- 3. Habilitar RLS (Row Level Security)
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;

-- 4. Políticas RLS para user_approvals
-- Usuários podem ver apenas seu próprio registro
CREATE POLICY "Users can view own approval status" ON public.user_approvals
  FOR SELECT USING (auth.uid() = user_id);

-- Admins podem ver todos os registros
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

-- Admins podem atualizar status de aprovação
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

-- Sistema pode inserir novos registros (para cadastros)
CREATE POLICY "Allow insert on signup" ON public.user_approvals
  FOR INSERT WITH CHECK (true);

-- 5. Função para criar registro de aprovação automaticamente após cadastro
CREATE OR REPLACE FUNCTION public.handle_new_user_approval()
RETURNS TRIGGER AS $$
BEGIN
  -- Inserir registro na tabela user_approvals para novos usuários
  INSERT INTO public.user_approvals (
    user_id, 
    email, 
    full_name, 
    company_name, 
    status
  ) VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'company_name',
    'pending'
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Trigger para executar função automaticamente
DROP TRIGGER IF EXISTS on_auth_user_created_approval ON auth.users;
CREATE TRIGGER on_auth_user_created_approval
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_approval();

-- 7. Função para verificar se usuário está aprovado
CREATE OR REPLACE FUNCTION public.is_user_approved(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_approvals 
    WHERE user_approvals.user_id = is_user_approved.user_id 
    AND status = 'approved'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Aprovar automaticamente usuários admin existentes
INSERT INTO public.user_approvals (user_id, email, full_name, status, approved_at, approved_by)
SELECT 
  id, 
  email, 
  COALESCE(raw_user_meta_data->>'full_name', 'Admin'), 
  'approved',
  NOW(),
  id
FROM auth.users 
WHERE email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com')
ON CONFLICT (user_id) DO UPDATE SET 
  status = 'approved', 
  approved_at = NOW();

-- 9. Comentários sobre o sistema
/*
Sistema de Aprovação Administrativa:

1. Fluxo de Cadastro:
   - Usuário se cadastra normalmente
   - Trigger cria registro em user_approvals com status 'pending'
   - Usuário consegue fazer login mas com acesso limitado

2. Painel Admin:
   - Admin vê lista de usuários pendentes
   - Pode aprovar/rejeitar usuários
   - Usuários aprovados ganham acesso completo

3. Verificação de Status:
   - Função is_user_approved() verifica se usuário está aprovado
   - Sistema frontend verifica status antes de permitir acesso
   - Usuários não aprovados veem mensagem "Pendente de aprovação"

4. Segurança:
   - RLS garante que usuários só vejam próprio status
   - Apenas admins podem aprovar/rejeitar
   - Trigger automático para novos cadastros
*/
