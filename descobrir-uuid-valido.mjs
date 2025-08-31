import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { persistSession: false }
});

async function descobrirUuidValido() {
  console.log('🔍 Descobrindo UUID válido para multi-tenant...\n');

  try {
    // 1. VERIFICAR USUÁRIOS EXISTENTES
    console.log('1. Verificando usuários em auth.users...');
    
    const { data: users, error: usersError } = await supabase.auth.admin.listUsers();
    
    if (usersError) {
      console.log('⚠️ Não conseguiu acessar auth.users (normal com chave ANON)');
    } else if (users && users.users.length > 0) {
      console.log(`✅ Encontrados ${users.users.length} usuários:`);
      users.users.forEach((user, index) => {
        console.log(`   ${index + 1}. ${user.id} - ${user.email}`);
      });
    }

    // 2. VERIFICAR UUIDs NOS DADOS EXISTENTES
    console.log('\n2. Verificando UUIDs nos clientes...');
    
    const { data: clientesUuids, error: clientesError } = await supabase
      .from('clientes')
      .select('user_id')
      .not('user_id', 'is', null);

    if (!clientesError && clientesUuids) {
      const uuidCounts = {};
      clientesUuids.forEach(cliente => {
        const uuid = cliente.user_id;
        uuidCounts[uuid] = (uuidCounts[uuid] || 0) + 1;
      });
      
      console.log('📊 UUIDs encontrados nos clientes:');
      Object.entries(uuidCounts).forEach(([uuid, count]) => {
        console.log(`   ${uuid}: ${count} registros`);
      });
      
      // Encontrar o UUID mais usado
      const maisUsado = Object.entries(uuidCounts).sort((a, b) => b[1] - a[1])[0];
      if (maisUsado) {
        console.log(`\n🎯 UUID mais usado nos clientes: ${maisUsado[0]} (${maisUsado[1]} registros)`);
      }
    }

    // 3. VERIFICAR UUIDs NOS PRODUTOS
    console.log('\n3. Verificando UUIDs nos produtos...');
    
    const { data: produtosUuids, error: produtosError } = await supabase
      .from('produtos')
      .select('user_id')
      .not('user_id', 'is', null);

    if (!produtosError && produtosUuids) {
      const uuidCounts = {};
      produtosUuids.forEach(produto => {
        const uuid = produto.user_id;
        uuidCounts[uuid] = (uuidCounts[uuid] || 0) + 1;
      });
      
      console.log('📊 UUIDs encontrados nos produtos:');
      Object.entries(uuidCounts).forEach(([uuid, count]) => {
        console.log(`   ${uuid}: ${count} registros`);
      });
      
      // Encontrar o UUID mais usado
      const maisUsado = Object.entries(uuidCounts).sort((a, b) => b[1] - a[1])[0];
      if (maisUsado) {
        console.log(`\n🎯 UUID mais usado nos produtos: ${maisUsado[0]} (${maisUsado[1]} registros)`);
      }
    }

    // 4. RECOMENDAÇÃO
    console.log('\n📋 RECOMENDAÇÕES:');
    
    // Se temos dados nos clientes, usar esse UUID
    if (clientesUuids && clientesUuids.length > 0) {
      const clienteUuids = {};
      clientesUuids.forEach(c => {
        clienteUuids[c.user_id] = (clienteUuids[c.user_id] || 0) + 1;
      });
      
      const uuidRecomendado = Object.entries(clienteUuids).sort((a, b) => b[1] - a[1])[0][0];
      
      console.log(`✅ UUID RECOMENDADO: ${uuidRecomendado}`);
      console.log(`📊 Total de clientes com este UUID: ${clienteUuids[uuidRecomendado]}`);
      
      // 5. INSTRUÇÕES
      console.log('\n🔧 PRÓXIMOS PASSOS:');
      console.log('1. Execute o SQL: CORRECAO_COM_UUID_VALIDO.sql');
      console.log('2. O script usará automaticamente o primeiro usuário válido');
      console.log(`3. Ou substitua manualmente pelo UUID: ${uuidRecomendado}`);
      console.log('4. Atualize o frontend com o UUID correto');
      
      return uuidRecomendado;
    }

    console.log('⚠️ Nenhum UUID válido encontrado nos dados existentes');
    console.log('💡 Crie um usuário primeiro ou use um UUID existente do auth.users');

  } catch (error) {
    console.error('❌ Erro ao descobrir UUID:', error);
  }
}

descobrirUuidValido();
