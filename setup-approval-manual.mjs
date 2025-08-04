import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://hkbrcnacgcxqkjjgdpsq.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhrYnJjbmFjZ2N4cWtqamdkcHNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzNTkzNjQsImV4cCI6MjA0NjkzNTM2NH0.Kg5vkOgjkkGU20b5p-LtIu-7W9kL3BPHL6AE9z-MG2Y';

const supabase = createClient(supabaseUrl, supabaseKey);

async function createApprovalSystemManual() {
  console.log('🚀 Criando sistema de aprovação manualmente...');
  
  try {
    // Primeiro, vamos tentar uma operação simples para testar conectividade
    console.log('🔍 Testando conectividade...');
    const { data: users, error: testError } = await supabase
      .from('users')
      .select('count')
      .limit(1);
    
    if (testError) {
      console.log('❌ Erro de conectividade:', testError);
      
      // Vamos tentar criar a tabela diretamente através da interface web
      console.log('\n📋 Para criar o sistema de aprovação, execute os seguintes comandos no SQL Editor do Supabase:');
      console.log('\n1. Acesse: https://supabase.com/dashboard/project/hkbrcnacgcxqkjjgdpsq/sql');
      console.log('\n2. Execute este SQL:');
      console.log(`
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

-- 2. Criar índices
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);

-- 3. Habilitar RLS
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;

-- 4. Criar políticas RLS
CREATE POLICY "Users can view own approval status" ON public.user_approvals
  FOR SELECT USING (auth.uid() = user_id);

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

CREATE POLICY "Admins can insert approvals" ON public.user_approvals
  FOR INSERT WITH CHECK (
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

-- 5. Criar função e trigger para aprovação automática
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_user_approval();

-- 6. Função para verificar status de aprovação
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
      `);
      
      console.log('\n3. Após executar, o sistema estará pronto!');
      
    } else {
      console.log('✅ Conectividade OK');
    }
    
  } catch (error) {
    console.log('❌ Erro:', error.message);
  }
}

createApprovalSystemManual();
