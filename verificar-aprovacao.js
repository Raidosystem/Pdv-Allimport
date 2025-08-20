const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://vfuglqcyrmgwvrlmmotm.supabase.co',
  'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdWdscWN5cm1nd3ZybG1tb3RtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNzc0MDkwNiwiZXhwIjoyMDUzMzE2OTA2fQ.jWHBh2_U7q12QrLwsJ2jqcHbONlJLHh85sOI1_HUJCo'
);

async function verificarSistema() {
  console.log('🔍 Verificando sistema de aprovação...');
  
  try {
    // Testar se tabela existe
    const { data, error } = await supabase
      .from('user_approvals')
      .select('*')
      .limit(5);
    
    if (error) {
      console.log('❌ Tabela user_approvals não existe');
      console.log('Código de erro:', error.code);
      console.log('Mensagem:', error.message);
      
      console.log('\n📋 INSTRUÇÕES PARA CORRIGIR:');
      console.log('1. Abra o Supabase Dashboard: https://supabase.com/dashboard/project/vfuglqcyrmgwvrlmmotm');
      console.log('2. Vá em SQL Editor');
      console.log('3. Execute o conteúdo do arquivo fix-approval-system.sql');
      console.log('4. Aguarde a execução completa');
      console.log('5. Teste novamente o sistema de aprovação');
      
      return;
    }
    
    console.log('✅ Tabela user_approvals existe!');
    console.log('Total de registros:', data?.length || 0);
    
    // Verificar usuários pendentes
    const { data: pending, error: pendingError } = await supabase
      .from('user_approvals')
      .select('*')
      .eq('status', 'pending')
      .order('created_at', { ascending: false });
    
    if (pendingError) {
      console.log('❌ Erro ao buscar usuários pendentes:', pendingError.message);
      return;
    }
    
    console.log(`\n📋 Usuários pendentes de aprovação: ${pending?.length || 0}`);
    
    if (pending && pending.length > 0) {
      console.log('\n👤 Lista de usuários pendentes:');
      pending.forEach((user, index) => {
        console.log(`  ${index + 1}. ${user.email}`);
        console.log(`     Nome: ${user.full_name || 'N/A'}`);
        console.log(`     Empresa: ${user.company_name || 'N/A'}`);
        console.log(`     Cadastrado: ${new Date(user.created_at).toLocaleDateString('pt-BR')} às ${new Date(user.created_at).toLocaleTimeString('pt-BR')}`);
        console.log('');
      });
    } else {
      console.log('ℹ️ Nenhum usuário pendente encontrado');
    }
    
    // Verificar usuários cadastrados hoje
    const hoje = new Date().toISOString().split('T')[0];
    const { data: todayUsers, error: todayError } = await supabase
      .from('user_approvals')
      .select('*')
      .gte('created_at', `${hoje}T00:00:00.000Z`)
      .order('created_at', { ascending: false });
    
    if (todayError) {
      console.log('❌ Erro ao buscar usuários de hoje:', todayError.message);
      return;
    }
    
    console.log(`\n📅 Usuários cadastrados hoje (${new Date().toLocaleDateString('pt-BR')}): ${todayUsers?.length || 0}`);
    
    if (todayUsers && todayUsers.length > 0) {
      console.log('\n👤 Cadastros de hoje:');
      todayUsers.forEach((user, index) => {
        console.log(`  ${index + 1}. ${user.email} - Status: ${user.status}`);
        console.log(`     Horário: ${new Date(user.created_at).toLocaleTimeString('pt-BR')}`);
        console.log(`     Nome: ${user.full_name || 'N/A'}`);
        console.log('');
      });
    } else {
      console.log('ℹ️ Nenhum usuário cadastrado hoje');
    }
    
  } catch (error) {
    console.log('❌ Erro inesperado:', error.message);
  }
}

verificarSistema();
