// ===================================================
// 🔍 DIAGNÓSTICO COMPLETO - ESTRUTURA DO BANCO
// ===================================================

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, supabaseKey);

async function diagnosticoCompleto() {
  console.log('🔍 DIAGNÓSTICO COMPLETO DO BANCO SUPABASE');
  console.log('═'.repeat(60));
  
  // 1. Testar conexão básica
  console.log('📡 1. Testando conexão básica...');
  try {
    const { data, error } = await supabase.auth.getSession();
    console.log('✅ Conexão com Supabase funcionando');
  } catch (error) {
    console.log('❌ Erro na conexão:', error.message);
    return;
  }

  // 2. Listar todas as tabelas que conseguimos acessar
  console.log('\n📋 2. Tentando acessar tabelas conhecidas...');
  
  const tabelas = [
    'auth.users',
    'user_approvals', 
    'usuarios',
    'clientes',
    'produtos',
    'vendas',
    'funcionarios',
    'empresas'
  ];

  for (const tabela of tabelas) {
    try {
      console.log(`\n🔍 Testando tabela: ${tabela}`);
      
      const { data, error, count } = await supabase
        .from(tabela.replace('auth.', ''))
        .select('*', { count: 'exact', head: true });

      if (error) {
        console.log(`   ❌ ${tabela}: ${error.code} - ${error.message}`);
        if (error.details) {
          console.log(`   📝 Detalhes: ${error.details}`);
        }
      } else {
        console.log(`   ✅ ${tabela}: ${count} registros`);
      }
    } catch (err) {
      console.log(`   💥 ${tabela}: Erro geral - ${err.message}`);
    }
  }

  // 3. Testar um insert simples na user_approvals
  console.log('\n📝 3. Tentando criar registro em user_approvals...');
  try {
    const { data, error } = await supabase
      .from('user_approvals')
      .insert({
        email: 'teste@exemplo.com',
        status: 'pending'
      })
      .select();

    if (error) {
      console.log('❌ Erro no insert:', error.code, '-', error.message);
      if (error.details) {
        console.log('📝 Detalhes:', error.details);
      }
    } else {
      console.log('✅ Insert funcionou! Registro criado:', data);
      
      // Tentar deletar o registro de teste
      await supabase
        .from('user_approvals')
        .delete()
        .eq('email', 'teste@exemplo.com');
      console.log('🗑️ Registro de teste removido');
    }
  } catch (err) {
    console.log('💥 Erro geral no insert:', err.message);
  }

  // 4. Verificar usuários existentes na tabela auth
  console.log('\n👥 4. Verificando usuários na tabela auth...');
  try {
    // Não podemos acessar auth.users diretamente, mas podemos verificar pela API
    const { data: { users }, error } = await supabase.auth.admin.listUsers();
    
    if (error) {
      console.log('❌ Não é possível listar usuários:', error.message);
    } else {
      console.log('✅ Usuários encontrados:', users?.length || 0);
      
      const adminUser = users?.find(u => u.email === 'novaradiosystem@outlook.com');
      if (adminUser) {
        console.log('👤 Admin encontrado:', adminUser.email, 'ID:', adminUser.id);
      } else {
        console.log('❌ Admin novaradiosystem@outlook.com não encontrado');
      }
    }
  } catch (err) {
    console.log('💥 Erro ao verificar usuários auth:', err.message);
  }

  console.log('\n🎯 DIAGNÓSTICO COMPLETO FINALIZADO');
}

diagnosticoCompleto();
