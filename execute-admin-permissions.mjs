import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://pbbrrsjafunvuupngjxv.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBiYnJyc2phZnVudnV1cG5nanh2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNTY1NTQxNiwiZXhwIjoyMDUxMjMxNDE2fQ.Jqdk7aq_Jfs_KFTF7kpcVt8NNFVAWJl7n77TdT37jII'

const supabase = createClient(supabaseUrl, supabaseKey)

async function executeAdminPermissions() {
  console.log('🔓 Configurando permissões de admin...\n')

  const sql = `
-- 1. Permitir admin ver TODAS as assinaturas
DROP POLICY IF EXISTS "Admin can view all subscriptions" ON public.subscriptions;
CREATE POLICY "Admin can view all subscriptions" 
ON public.subscriptions 
FOR SELECT 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR EXISTS (
    SELECT 1 FROM user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
);

-- 2. Permitir admin ATUALIZAR assinaturas (adicionar dias, pausar)
DROP POLICY IF EXISTS "Admin can update subscriptions" ON public.subscriptions;
CREATE POLICY "Admin can update subscriptions" 
ON public.subscriptions 
FOR UPDATE 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR EXISTS (
    SELECT 1 FROM user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
);

-- 3. Permitir admin ver TODOS os user_approvals
DROP POLICY IF EXISTS "Admin can view all user_approvals" ON public.user_approvals;
CREATE POLICY "Admin can view all user_approvals" 
ON public.user_approvals 
FOR SELECT 
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR user_role = 'admin'
);
  `

  try {
    const { data, error } = await supabase.rpc('exec_sql', { sql_query: sql })
    
    if (error) {
      console.log('⚠️  RPC não disponível, tentando método alternativo...\n')
      
      // Método alternativo: executar policies uma por uma
      const policies = [
        {
          name: 'Admin can view all subscriptions',
          table: 'subscriptions',
          sql: `
            DROP POLICY IF EXISTS "Admin can view all subscriptions" ON public.subscriptions;
            CREATE POLICY "Admin can view all subscriptions" 
            ON public.subscriptions FOR SELECT 
            USING (
              auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
              OR EXISTS (
                SELECT 1 FROM user_approvals 
                WHERE user_approvals.user_id = auth.uid() 
                AND user_approvals.user_role = 'admin'
              )
            );
          `
        },
        {
          name: 'Admin can update subscriptions',
          table: 'subscriptions',
          sql: `
            DROP POLICY IF EXISTS "Admin can update subscriptions" ON public.subscriptions;
            CREATE POLICY "Admin can update subscriptions" 
            ON public.subscriptions FOR UPDATE 
            USING (
              auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
              OR EXISTS (
                SELECT 1 FROM user_approvals 
                WHERE user_approvals.user_id = auth.uid() 
                AND user_approvals.user_role = 'admin'
              )
            );
          `
        },
        {
          name: 'Admin can view all user_approvals',
          table: 'user_approvals',
          sql: `
            DROP POLICY IF EXISTS "Admin can view all user_approvals" ON public.user_approvals;
            CREATE POLICY "Admin can view all user_approvals" 
            ON public.user_approvals FOR SELECT 
            USING (
              auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
              OR user_role = 'admin'
            );
          `
        }
      ]

      console.log('📋 Você precisa executar este SQL manualmente no Supabase:\n')
      console.log('1. Abra: https://pbbrrsjafunvuupngjxv.supabase.co/project/pbbrrsjafunvuupngjxv/sql/new')
      console.log('2. Cole o SQL abaixo:\n')
      console.log('----------------------------------------')
      console.log(sql)
      console.log('----------------------------------------\n')
      console.log('3. Clique em "RUN" para executar\n')
      
      // Verificar se conseguimos ver as assinaturas atuais
      console.log('📊 Verificando assinaturas visíveis atualmente...\n')
      const { data: subs, error: subsError } = await supabase
        .from('subscriptions')
        .select('*')
        
      if (subsError) {
        console.log('❌ Erro ao buscar assinaturas:', subsError.message)
        console.log('   Isso confirma que você precisa executar o SQL acima!\n')
      } else {
        console.log(`✅ Encontradas ${subs?.length || 0} assinaturas visíveis`)
        if (subs && subs.length > 0) {
          console.log('\n📋 Assinaturas atuais:')
          subs.forEach((sub, i) => {
            console.log(`   ${i + 1}. User ID: ${sub.user_id?.substring(0, 8)}... | Status: ${sub.status}`)
          })
        }
      }
      
    } else {
      console.log('✅ Permissões configuradas com sucesso!')
      console.log(data)
    }
    
  } catch (err) {
    console.error('❌ Erro:', err.message)
    console.log('\n📋 Execute manualmente no Supabase SQL Editor:')
    console.log('https://pbbrrsjafunvuupngjxv.supabase.co/project/pbbrrsjafunvuupngjxv/sql/new\n')
    console.log(sql)
  }
}

executeAdminPermissions()
