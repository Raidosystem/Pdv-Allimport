// ===================================================
// 🧪 TESTE RÁPIDO - VERIFICAR TABELA USER_APPROVALS
// ===================================================
// Execute com: node testar-tabela-user-approvals.js

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testarTabelaUserApprovals() {
  console.log('🧪 TESTANDO ACESSO À TABELA USER_APPROVALS');
  console.log('═'.repeat(50));

  try {
    // 1. Testar se a tabela existe
    console.log('📋 1. Testando se a tabela existe...');
    const { data, error, count } = await supabase
      .from('user_approvals')
      .select('*', { count: 'exact', head: true });

    if (error) {
      console.log('❌ Erro ao acessar tabela:', error.code, error.message);
      if (error.code === 'PGRST116') {
        console.log('🚨 TABELA NÃO EXISTE - Execute o script SQL primeiro!');
      } else if (error.code === '42P01') {
        console.log('🚨 TABELA NÃO ENCONTRADA - Execute o script SQL!');
      } else {
        console.log('🔧 Outro erro:', error.details);
      }
      return;
    }

    console.log('✅ Tabela existe!');
    console.log('📊 Total de registros:', count);

    // 2. Testar select simples
    console.log('\n📋 2. Fazendo select simples...');
    const { data: simpleData, error: simpleError } = await supabase
      .from('user_approvals')
      .select('email, status')
      .limit(5);

    if (simpleError) {
      console.log('❌ Erro no select simples:', simpleError.message);
      return;
    }

    console.log('✅ Select funcionou!');
    console.log('👥 Usuários encontrados:', simpleData?.length || 0);

    if (simpleData && simpleData.length > 0) {
      console.log('\n📋 Primeiros usuários:');
      simpleData.forEach((user, index) => {
        console.log(`  ${index + 1}. ${user.email} - ${user.status}`);
      });
    }

    // 3. Testar o admin específico
    console.log('\n📋 3. Verificando admin específico...');
    const { data: adminData, error: adminError } = await supabase
      .from('user_approvals')
      .select('*')
      .eq('email', 'novaradiosystem@outlook.com')
      .single();

    if (adminError) {
      if (adminError.code === 'PGRST116') {
        console.log('❌ Admin não encontrado na tabela');
      } else {
        console.log('❌ Erro ao buscar admin:', adminError.message);
      }
    } else {
      console.log('✅ Admin encontrado!');
      console.log('👤 Status:', adminData.status);
      console.log('📅 Criado em:', adminData.created_at);
    }

    console.log('\n🎉 TESTE COMPLETO!');
    console.log('✅ Tabela user_approvals está funcionando corretamente');

  } catch (error) {
    console.log('❌ Erro geral:', error.message);
  }
}

testarTabelaUserApprovals();
