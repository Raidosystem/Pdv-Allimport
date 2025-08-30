// ===================================================
// 🔧 CORREÇÃO PERMISSÕES USER_APPROVALS VIA JS
// ===================================================

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, supabaseKey);

async function corrigirPermissoes() {
  console.log('🔧 CORRIGINDO PERMISSÕES USER_APPROVALS');
  console.log('═'.repeat(50));

  // Estratégia alternativa: Usar RPC (Remote Procedure Call)
  console.log('📋 1. Tentando criar RPC para acessar user_approvals...');
  
  try {
    // Verificar se podemos criar um RPC
    const { data, error } = await supabase.rpc('get_user_approvals');
    
    if (error) {
      console.log('❌ RPC não existe:', error.message);
      console.log('💡 Precisamos criar o RPC no Supabase Dashboard');
    } else {
      console.log('✅ RPC funcionando!');
    }
  } catch (err) {
    console.log('❌ Erro no RPC:', err.message);
  }

  // Estratégia 2: Testar diferentes approaches
  console.log('\n📋 2. Testando diferentes estratégias...');
  
  // 2a. Tentar com different schemas
  const strategies = [
    { schema: 'public', table: 'user_approvals' },
    { schema: null, table: 'user_approvals' }
  ];

  for (const strategy of strategies) {
    try {
      console.log(`🔍 Testando schema: ${strategy.schema || 'default'}`);
      
      const query = supabase.from(strategy.table);
      if (strategy.schema) {
        query.schema(strategy.schema);
      }
      
      const { data, error } = await query
        .select('email, status')
        .limit(1);

      if (error) {
        console.log(`   ❌ ${error.code}: ${error.message}`);
      } else {
        console.log(`   ✅ Funcionou! Registros: ${data?.length || 0}`);
        
        // Se funcionou, tentar inserir admin
        console.log('   📝 Tentando inserir admin...');
        const { data: insertData, error: insertError } = await query
          .insert({
            email: 'novaradiosystem@outlook.com',
            status: 'approved'
          })
          .select();

        if (insertError) {
          console.log(`   ❌ Insert: ${insertError.message}`);
        } else {
          console.log(`   ✅ Admin inserido com sucesso!`);
        }
        break;
      }
    } catch (err) {
      console.log(`   💥 Erro: ${err.message}`);
    }
  }

  console.log('\n🎯 CORREÇÃO FINALIZADA');
  console.log('\n📋 PRÓXIMOS PASSOS:');
  console.log('1. Execute o arquivo CORRIGIR_PERMISSOES_USER_APPROVALS.sql no Supabase Dashboard');
  console.log('2. Vá em SQL Editor e cole o conteúdo do arquivo');
  console.log('3. Execute o script');
  console.log('4. Teste novamente o login no AdminPanel');
}

corrigirPermissoes();
