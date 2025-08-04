import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://hkbrcnacgcxqkjjgdpsq.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhrYnJjbmFjZ2N4cWtqamdkcHNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzNTkzNjQsImV4cCI6MjA0NjkzNTM2NH0.Kg5vkOgjkkGU20b5p-LtIu-7W9kL3BPHL6AE9z-MG2Y';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testApprovalSystem() {
  console.log('🧪 Testando sistema de aprovação...');

  try {
    // Teste 1: Verificar se a tabela existe
    console.log('\n1. Verificando se a tabela user_approvals existe...');
    const { data, error } = await supabase
      .from('user_approvals')
      .select('count')
      .limit(1);

    if (error) {
      console.log('❌ Tabela user_approvals não encontrada:', error.message);
      console.log('📋 Por favor, execute o SQL no Supabase Dashboard primeiro.');
      return;
    } else {
      console.log('✅ Tabela user_approvals encontrada!');
    }

    // Teste 2: Verificar registros existentes
    console.log('\n2. Verificando registros de aprovação existentes...');
    const { data: approvals, error: approvalsError } = await supabase
      .from('user_approvals')
      .select('*')
      .order('created_at', { ascending: false });

    if (approvalsError) {
      console.log('❌ Erro ao buscar aprovações:', approvalsError.message);
    } else {
      console.log(`✅ Encontrados ${approvals.length} registros de aprovação:`);
      approvals.forEach((approval, index) => {
        console.log(`   ${index + 1}. ${approval.email} - Status: ${approval.status} (${approval.created_at})`);
      });
    }

    // Teste 3: Testar função de verificação (se existir)
    console.log('\n3. Testando funções do sistema...');
    try {
      const { data: functionTest, error: functionError } = await supabase
        .rpc('check_user_approval_status', { user_uuid: '00000000-0000-0000-0000-000000000000' });

      if (functionError) {
        console.log('❌ Função check_user_approval_status não encontrada:', functionError.message);
      } else {
        console.log('✅ Função check_user_approval_status funcionando!');
      }
    } catch (err) {
      console.log('❌ Erro ao testar função:', err.message);
    }

    console.log('\n🎉 Sistema de aprovação testado!');
    console.log('\n📋 Próximos passos:');
    console.log('   1. Faça um teste de cadastro de usuário');
    console.log('   2. Verifique se o registro de aprovação é criado automaticamente');
    console.log('   3. Teste o login com usuário pendente de aprovação');
    console.log('   4. Use o painel admin para aprovar/rejeitar usuários');

  } catch (error) {
    console.log('❌ Erro durante os testes:', error.message);
  }
}

testApprovalSystem();
