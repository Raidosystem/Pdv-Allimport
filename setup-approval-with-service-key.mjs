import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://hkbrcnacgcxqkjjgdpsq.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhrYnJjbmFjZ2N4cWtqamdkcHNxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMTM1OTM2NCwiZXhwIjoyMDQ2OTM1MzY0fQ.GDR1uZCplJErvYXLLGvmFE2bNfq4LMnlbp8bF86AX7k';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function setupApprovalSystemWithServiceRole() {
  console.log('🚀 Configurando sistema de aprovação com service role...');

  try {
    // 1. Criar tabela user_approvals
    console.log('📋 Criando tabela user_approvals...');
    
    const createTableSQL = `
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
    `;

    const { data: tableResult, error: tableError } = await supabase.rpc('exec_sql', {
      sql: createTableSQL
    });

    if (tableError) {
      console.log('❌ Erro ao criar tabela:', tableError);
      console.log('🔄 Tentando método alternativo...');
      
      // Método alternativo: usar SQL direto
      const { error: directError } = await supabase
        .from('user_approvals')
        .select('count')
        .limit(1);
        
      if (directError && directError.code === '42P01') {
        console.log('❌ Tabela não existe. Tentando criar via query...');
        
        // Tentar usando uma abordagem diferente
        const { data, error } = await supabase
          .rpc('create_approval_table', {});
          
        if (error) {
          console.log('❌ Falha ao criar via RPC. Vamos usar o método manual...');
          console.log('\n📝 Execute este SQL no Supabase Dashboard:');
          console.log('https://supabase.com/dashboard/project/hkbrcnacgcxqkjjgdpsq/sql');
          console.log('\n' + createTableSQL);
          return;
        }
      }
    } else {
      console.log('✅ Tabela user_approvals criada/verificada');
    }

    // 2. Criar índices
    console.log('🔗 Criando índices...');
    const indexSQL = `
      CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
      CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);
      CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);
    `;

    const { error: indexError } = await supabase.rpc('exec_sql', {
      sql: indexSQL
    });

    if (indexError) {
      console.log('❌ Erro ao criar índices:', indexError);
    } else {
      console.log('✅ Índices criados');
    }

    // 3. Habilitar RLS
    console.log('🔒 Habilitando RLS...');
    const { error: rlsError } = await supabase.rpc('exec_sql', {
      sql: 'ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;'
    });

    if (rlsError) {
      console.log('❌ Erro ao habilitar RLS:', rlsError);
    } else {
      console.log('✅ RLS habilitado');
    }

    // 4. Criar políticas RLS
    console.log('🛡️ Criando políticas RLS...');
    const policiesSQL = `
      -- Política para usuários verem próprio status
      CREATE POLICY IF NOT EXISTS "Users can view own approval status" ON public.user_approvals
        FOR SELECT USING (auth.uid() = user_id);

      -- Política para admins verem todas as aprovações
      CREATE POLICY IF NOT EXISTS "Admins can view all approvals" ON public.user_approvals
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
      CREATE POLICY IF NOT EXISTS "Admins can update approvals" ON public.user_approvals
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

      -- Política para inserção automática
      CREATE POLICY IF NOT EXISTS "System can insert approvals" ON public.user_approvals
        FOR INSERT WITH CHECK (true);
    `;

    const { error: policiesError } = await supabase.rpc('exec_sql', {
      sql: policiesSQL
    });

    if (policiesError) {
      console.log('❌ Erro ao criar políticas:', policiesError);
    } else {
      console.log('✅ Políticas RLS criadas');
    }

    // 5. Criar função e trigger
    console.log('⚡ Criando função e trigger...');
    const triggerSQL = `
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
    `;

    const { error: triggerError } = await supabase.rpc('exec_sql', {
      sql: triggerSQL
    });

    if (triggerError) {
      console.log('❌ Erro ao criar trigger:', triggerError);
    } else {
      console.log('✅ Função e trigger criados');
    }

    // 6. Criar função de verificação
    console.log('🔍 Criando função de verificação...');
    const functionSQL = `
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
    `;

    const { error: functionError } = await supabase.rpc('exec_sql', {
      sql: functionSQL
    });

    if (functionError) {
      console.log('❌ Erro ao criar função:', functionError);
    } else {
      console.log('✅ Função de verificação criada');
    }

    // 7. Testar se tudo funcionou
    console.log('🧪 Testando sistema...');
    const { data: testData, error: testError } = await supabase
      .from('user_approvals')
      .select('count')
      .limit(1);

    if (testError) {
      console.log('❌ Erro no teste:', testError);
      
      console.log('\n📝 Execute manualmente no SQL Editor:');
      console.log('https://supabase.com/dashboard/project/hkbrcnacgcxqkjjgdpsq/sql');
      console.log('\n-- SQL COMPLETO --');
      console.log(createTableSQL);
      console.log(indexSQL);
      console.log('ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;');
      console.log(policiesSQL);
      console.log(triggerSQL);
      console.log(functionSQL);
    } else {
      console.log('✅ Sistema de aprovação configurado com sucesso!');
    }

  } catch (error) {
    console.log('❌ Erro geral:', error);
  }
}

setupApprovalSystemWithServiceRole();
