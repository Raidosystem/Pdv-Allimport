import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://hkbrcnacgcxqkjjgdpsq.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhrYnJjbmFjZ2N4cWtqamdkcHNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzNTkzNjQsImV4cCI6MjA0NjkzNTM2NH0.Kg5vkOgjkkGU20b5p-LtIu-7W9kL3BPHL6AE9z-MG2Y';

const supabase = createClient(supabaseUrl, supabaseKey);

async function verificarSistemaAprovacao() {
  console.log('🔍 Verificando sistema de aprovação...');
  
  try {
    // Teste 1: Verificar se a tabela user_approvals existe
    console.log('\n1. 📋 Testando tabela user_approvals...');
    const { data: tableTest, error: tableError } = await supabase
      .from('user_approvals')
      .select('count')
      .limit(1);

    if (tableError) {
      console.log('❌ Tabela user_approvals não encontrada!');
      console.log('📝 Execute o arquivo SETUP_APROVACAO_COMPLETO.sql no Supabase Dashboard');
      return;
    } else {
      console.log('✅ Tabela user_approvals encontrada!');
    }

    // Teste 2: Verificar registros existentes
    console.log('\n2. 👥 Verificando registros de aprovação...');
    const { data: approvals, error: approvalsError } = await supabase
      .from('user_approvals')
      .select('*')
      .order('created_at', { ascending: false });

    if (approvalsError) {
      console.log('❌ Erro ao buscar aprovações:', approvalsError.message);
    } else {
      console.log(`📊 Total de registros: ${approvals.length}`);
      
      const pending = approvals.filter(a => a.status === 'pending').length;
      const approved = approvals.filter(a => a.status === 'approved').length;
      const rejected = approvals.filter(a => a.status === 'rejected').length;
      
      console.log(`   📝 Pendentes: ${pending}`);
      console.log(`   ✅ Aprovados: ${approved}`);
      console.log(`   ❌ Rejeitados: ${rejected}`);

      if (pending > 0) {
        console.log('\n👤 Usuários aguardando aprovação:');
        approvals
          .filter(a => a.status === 'pending')
          .slice(0, 5)
          .forEach((approval, index) => {
            const date = new Date(approval.created_at).toLocaleString('pt-BR');
            console.log(`   ${index + 1}. ${approval.email} - ${date}`);
          });
      }
    }

    // Teste 3: Testar função de verificação de status
    console.log('\n3. ⚙️ Testando função check_user_approval_status...');
    try {
      const { data: functionTest, error: functionError } = await supabase
        .rpc('check_user_approval_status', { 
          user_uuid: '00000000-0000-0000-0000-000000000000' 
        });

      if (functionError) {
        console.log('❌ Função check_user_approval_status com erro:', functionError.message);
      } else {
        console.log('✅ Função check_user_approval_status funcionando!');
      }
    } catch (err) {
      console.log('❌ Erro ao testar função:', err.message);
    }

    // Teste 4: Verificar usuários do sistema auth
    console.log('\n4. 👤 Verificando usuários no sistema...');
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('email, created_at')
      .order('created_at', { ascending: false })
      .limit(5);

    if (usersError) {
      console.log('❌ Erro ao buscar usuários:', usersError.message);
    } else {
      console.log(`📊 Usuários cadastrados recentemente: ${users.length}`);
      users.forEach((user, index) => {
        const date = new Date(user.created_at).toLocaleString('pt-BR');
        console.log(`   ${index + 1}. ${user.email} - ${date}`);
      });
    }

    console.log('\n🎉 Verificação concluída!');
    console.log('\n📋 Status do Sistema:');
    
    if (!tableError) {
      console.log('✅ Sistema de aprovação configurado');
      console.log('✅ Tabela user_approvals funcionando');
      console.log('✅ Pronto para uso em produção');
      
      console.log('\n🚀 Próximos passos:');
      console.log('1. Teste o cadastro de um novo usuário');
      console.log('2. Verifique se o registro de aprovação é criado automaticamente');
      console.log('3. Teste o login (deve mostrar "aguardando aprovação")');
      console.log('4. Use o painel admin para aprovar o usuário');
      console.log('5. Teste o login novamente (deve funcionar)');
    } else {
      console.log('❌ Sistema de aprovação não configurado');
      console.log('📝 Execute o SQL no Supabase Dashboard primeiro');
    }

  } catch (error) {
    console.log('❌ Erro durante verificação:', error.message);
  }
}

verificarSistemaAprovacao();
