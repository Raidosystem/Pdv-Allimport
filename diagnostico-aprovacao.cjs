const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://vfuglqcyrmgwvrlmmotm.supabase.co',
  'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdWdscWN5cm1nd3ZybG1tb3RtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNzc0MDkwNiwiZXhwIjoyMDUzMzE2OTA2fQ.jWHBh2_U7q12QrLwsJ2jqcHbONlJLHh85sOI1_HUJCo'
);

async function tentarCriarTabelaSimples() {
  console.log('🔧 Tentando criar sistema de aprovação de forma simples...');
  
  try {
    // Primeiro, tentar inserir um registro de teste para ver se a tabela existe
    const { data: testData, error: testError } = await supabase
      .from('user_approvals')
      .select('id')
      .limit(1);
    
    if (testError && testError.code === 'PGRST116') {
      console.log('❌ Tabela user_approvals não existe');
      console.log('\n📋 SOLUÇÃO MANUAL NECESSÁRIA:');
      console.log('1. Acesse: https://supabase.com/dashboard/project/vfuglqcyrmgwvrlmmotm/sql');
      console.log('2. Execute o script fix-approval-system.sql');
      console.log('3. Ou copie e cole este código no SQL Editor:');
      console.log('\n--- COPIE A PARTIR DAQUI ---');
      console.log(`
-- Criar tabela de aprovação de usuários
CREATE TABLE IF NOT EXISTS public.user_approvals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  email TEXT NOT NULL,
  full_name TEXT,
  company_name TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_by UUID,
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);

-- Habilitar RLS
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;

-- Política para usuários verem próprio status
CREATE POLICY "Users can view own approval status" ON public.user_approvals
  FOR SELECT USING (auth.uid() = user_id);

-- Política para admins verem todos os registros
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

-- Política para admins atualizarem status
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

-- Política para permitir inserção
CREATE POLICY "Allow insert on signup" ON public.user_approvals
  FOR INSERT WITH CHECK (true);

-- Função trigger para criar registro automaticamente
CREATE OR REPLACE FUNCTION public.handle_new_user_approval()
RETURNS TRIGGER AS $trigger$
BEGIN
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
$trigger$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para executar automaticamente
DROP TRIGGER IF EXISTS on_auth_user_created_approval ON auth.users;
CREATE TRIGGER on_auth_user_created_approval
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_approval();

-- Inserir registros para usuários existentes que não têm registro
INSERT INTO public.user_approvals (user_id, email, full_name, company_name, status, approved_at)
SELECT 
  au.id,
  au.email,
  au.raw_user_meta_data->>'full_name',
  au.raw_user_meta_data->>'company_name',
  CASE 
    WHEN au.email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com') 
    THEN 'approved' 
    ELSE 'pending' 
  END as status,
  CASE 
    WHEN au.email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com') 
    THEN NOW() 
    ELSE NULL 
  END as approved_at
FROM auth.users au
WHERE au.id NOT IN (SELECT user_id FROM public.user_approvals WHERE user_id IS NOT NULL)
ON CONFLICT (user_id) DO NOTHING;

-- Verificar criação
SELECT 'Sistema de aprovacao criado!' as message;
SELECT status, COUNT(*) as total FROM public.user_approvals GROUP BY status;
      `);
      console.log('\n--- ATÉ AQUI ---\n');
      console.log('4. Clique em "RUN" para executar');
      console.log('5. Depois execute: node verificar-aprovacao.cjs');
      
      return;
    }
    
    console.log('✅ Tabela user_approvals já existe!');
    
    // Verificar se há registros pendentes
    const { data: pending } = await supabase
      .from('user_approvals')
      .select('*')
      .eq('status', 'pending');
    
    console.log(`📋 Usuários pendentes: ${pending?.length || 0}`);
    
    if (pending && pending.length > 0) {
      console.log('👤 Usuários esperando aprovação:');
      pending.forEach((user, index) => {
        console.log(`  ${index + 1}. ${user.email} - ${new Date(user.created_at).toLocaleString('pt-BR')}`);
      });
    }
    
  } catch (error) {
    console.log('❌ Erro ao verificar sistema:', error.message);
  }
}

tentarCriarTabelaSimples();
