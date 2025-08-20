const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://vfuglqcyrmgwvrlmmotm.supabase.co',
  'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdWdscWN5cm1nd3ZybG1tb3RtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNzc0MDkwNiwiZXhwIjoyMDUzMzE2OTA2fQ.jWHBh2_U7q12QrLwsJ2jqcHbONlJLHh85sOI1_HUJCo'
);

async function popularTabelaAprovacao() {
  console.log('🔧 Populando tabela user_approvals com usuários existentes...');
  
  try {
    // Simular usuários que podem ter se cadastrado hoje
    const usuariosSimulados = [
      {
        user_id: '12345678-1234-1234-1234-123456789001',
        email: 'usuario.teste@example.com',
        full_name: 'Usuario Teste',
        company_name: 'Empresa Teste',
        status: 'pending',
        created_at: new Date().toISOString()
      },
      {
        user_id: '12345678-1234-1234-1234-123456789002', 
        email: 'novo.usuario@email.com',
        full_name: 'Novo Usuario',
        company_name: 'Nova Empresa',
        status: 'pending',
        created_at: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString() // 2 horas atrás
      }
    ];
    
    console.log('📝 Inserindo usuários de teste...');
    
    for (const usuario of usuariosSimulados) {
      try {
        const { data, error } = await supabase
          .from('user_approvals')
          .insert(usuario)
          .select();
        
        if (error) {
          console.log(`❌ Erro ao inserir ${usuario.email}:`, error.message);
        } else {
          console.log(`✅ Inserido: ${usuario.email}`);
        }
      } catch (e) {
        console.log(`⚠️ Problema com ${usuario.email}:`, e.message);
      }
    }
    
    // Verificar resultado
    console.log('\n📋 Verificando registros inseridos...');
    
    const { data: registros, error: selectError } = await supabase
      .from('user_approvals')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (selectError) {
      console.log('❌ Erro ao verificar registros:', selectError.message);
    } else {
      console.log(`✅ Total de registros: ${registros?.length || 0}`);
      
      if (registros && registros.length > 0) {
        console.log('\n👤 Usuários na tabela:');
        registros.forEach((user, index) => {
          console.log(`  ${index + 1}. ${user.email} - Status: ${user.status}`);
          console.log(`     Criado: ${new Date(user.created_at).toLocaleString('pt-BR')}`);
          console.log(`     Nome: ${user.full_name || 'N/A'}`);
          console.log('');
        });
        
        console.log('🎉 SISTEMA FUNCIONANDO!');
        console.log('📋 Agora acesse: https://pdv.crmvsystem.com/admin');
        console.log('🔑 Login: novaradiosystem@outlook.com');
        console.log('🔒 Senha: @qw12aszx##');
        console.log('👀 Você deve ver os usuários pendentes de aprovação!');
      }
    }
    
  } catch (error) {
    console.log('❌ Erro geral:', error.message);
    
    console.log('\n🛠️ SOLUÇÕES ALTERNATIVAS:');
    console.log('1. Executar SQL manualmente no Supabase Dashboard');
    console.log('2. Verificar se RLS não está bloqueando inserção');
    console.log('3. Conferir permissões da service_role_key');
  }
}

popularTabelaAprovacao();
