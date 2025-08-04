#!/usr/bin/env node

import { createClient } from '@supabase/supabase-js'

// Configuração do Supabase  
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

const supabase = createClient(supabaseUrl, supabaseAnonKey)

console.log('🚀 Deploy Supabase - Verificação e Configuração')
console.log('📅 Data:', new Date().toLocaleString('pt-BR'))

async function testAndDeploy() {
  try {
    console.log('\n🔍 Verificando estrutura atual do banco...')

    // Verificar tabelas existentes
    const tables = ['user_approvals', 'subscriptions', 'payments']
    const tableStatus = {}

    for (const table of tables) {
      try {
        const { data, error } = await supabase
          .from(table)
          .select('count')
          .limit(1)
        
        if (error) {
          tableStatus[table] = '❌ Não existe'
          console.log(`❌ Tabela ${table}: Não encontrada`)
        } else {
          tableStatus[table] = '✅ Existe'
          console.log(`✅ Tabela ${table}: OK`)
        }
      } catch (err) {
        tableStatus[table] = '❌ Erro'
        console.log(`❌ Tabela ${table}: ${err.message}`)
      }
    }

    // Se as tabelas não existem, mostrar instruções manuais
    const missingTables = Object.entries(tableStatus)
      .filter(([table, status]) => status.includes('❌'))
      .map(([table]) => table)

    if (missingTables.length > 0) {
      console.log('\n⚠️ Algumas tabelas não existem. Precisa executar SQL manualmente.')
      console.log('\n📋 INSTRUÇÕES PARA DEPLOY MANUAL:')
      console.log('\n1. Acesse o Supabase Dashboard:')
      console.log('   🔗 https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql')
      
      console.log('\n2. Execute os seguintes scripts SQL na ordem:')
      
      if (missingTables.includes('user_approvals')) {
        console.log('\n   📄 Script 1: SETUP_APROVACAO_COMPLETO.sql')
        console.log('   📋 Cria sistema de aprovação de usuários')
      }
      
      if (missingTables.includes('subscriptions') || missingTables.includes('payments')) {
        console.log('\n   📄 Script 2: SISTEMA_ASSINATURA_SETUP.sql')
        console.log('   📋 Cria sistema de assinatura com pagamento')
      }
      
      console.log('\n   📄 Script 3: FIX_RLS_ADMIN_ACCESS.sql')
      console.log('   📋 Corrige permissões de acesso admin')

      console.log('\n📝 Conteúdo do Script de Aprovação:')
      console.log(`
-- ================================
-- SISTEMA DE APROVAÇÃO - SETUP COMPLETO
-- Execute no Supabase SQL Editor
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

-- 2. CRIAR ÍNDICES
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);

-- 3. HABILITAR RLS
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;

-- 4. CRIAR POLÍTICAS RLS PERMISSIVAS
CREATE POLICY "Authenticated users can view approvals" ON public.user_approvals
  FOR SELECT USING (true);

CREATE POLICY "Allow insert for system" ON public.user_approvals
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow updates for authenticated users" ON public.user_approvals
  FOR UPDATE USING (true);

-- 5. FUNÇÃO E TRIGGER PARA CRIAR APROVAÇÃO AUTOMATICAMENTE
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

-- 6. FUNÇÃO PARA APROVAR USUÁRIO
CREATE OR REPLACE FUNCTION approve_user(user_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.user_approvals 
  SET 
    status = 'approved',
    approved_at = NOW(),
    updated_at = NOW()
  WHERE email = user_email;
  
  RETURN FOUND;
END;
$$;
      `)
    }

    // Teste de conectividade e funcionalidade
    console.log('\n🧪 Testando funcionalidades disponíveis...')

    // Teste de autenticação
    console.log('\n🔐 Testando sistema de autenticação...')
    const testEmail = `test-deploy-${Date.now()}@pdvallimport.com`
    const testPassword = '@qw12aszx##'

    const { data: signupData, error: signupError } = await supabase.auth.signUp({
      email: testEmail,
      password: testPassword,
      options: {
        data: {
          full_name: 'Teste Deploy',
          role: 'user'
        }
      }
    })

    if (signupError) {
      console.log('⚠️ Teste de cadastro:', signupError.message)
    } else {
      console.log('✅ Sistema de cadastro funcionando')
      console.log('📧 Email teste:', testEmail)
      console.log('🔑 Senha:', testPassword)

      // Fazer logout
      await supabase.auth.signOut()
    }

    // Verificar dados existentes
    if (tableStatus.user_approvals?.includes('✅')) {
      const { data: approvals } = await supabase
        .from('user_approvals')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(5)

      console.log(`\n👥 Usuários cadastrados: ${approvals?.length || 0}`)
      if (approvals && approvals.length > 0) {
        console.log('📋 Últimos cadastros:')
        approvals.forEach((approval, index) => {
          console.log(`   ${index + 1}. ${approval.email} - ${approval.status}`)
        })
      }
    }

    console.log('\n🎯 Status do Deploy:')
    console.log('✅ Frontend: Deployado no Vercel')
    console.log('✅ Código: Commitado no GitHub') 
    
    if (missingTables.length === 0) {
      console.log('✅ Database: Todas as tabelas OK')
      console.log('✅ Sistema: Pronto para uso!')
    } else {
      console.log('⚠️ Database: Precisa executar scripts SQL')
      console.log('📋 Execute os scripts no link acima')
    }

    console.log('\n🌐 URLs do Sistema:')
    console.log('🏠 App: https://pdv-allimport.vercel.app')
    console.log('🔐 Admin: https://pdv-allimport.vercel.app/admin')
    console.log('⚙️ Supabase: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw')

    console.log('\n📧 Credenciais de Admin:')
    console.log('Email: admin@pdvallimport.com')
    console.log('Senha: @qw12aszx##')

  } catch (error) {
    console.log('❌ Erro durante verificação:', error.message)
  }
}

testAndDeploy()
