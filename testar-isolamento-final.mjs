import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { persistSession: false }
});

// UUID correto obtido do banco
const USER_ID_CORRETO = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

async function testarIsolamento() {
  console.log('🔒 Testando isolamento multi-tenant após correção...\n');

  try {
    // 1. TESTE DE CLIENTES
    console.log('1. Testando clientes...');
    
    const { data: clientes, error: clientesError } = await supabase
      .from('clientes')
      .select('*')
      .limit(5);

    if (clientesError) {
      console.log('❌ Erro ao buscar clientes:', clientesError.message);
      if (clientesError.message.includes('RLS')) {
        console.log('✅ RLS está funcionando corretamente (bloqueou acesso)');
      }
    } else if (clientes && clientes.length > 0) {
      console.log(`⚠️ PROBLEMA: ${clientes.length} clientes visíveis sem filtro!`);
      console.log('📋 User_IDs encontrados:', [...new Set(clientes.map(c => c.user_id))]);
    } else {
      console.log('✅ RLS funcionando: Nenhum cliente visível sem filtro');
    }

    // 2. TESTE DE PRODUTOS
    console.log('\n2. Testando produtos...');
    
    const { data: produtos, error: produtosError } = await supabase
      .from('produtos')
      .select('*')
      .limit(5);

    if (produtosError) {
      console.log('❌ Erro ao buscar produtos:', produtosError.message);
      if (produtosError.message.includes('RLS')) {
        console.log('✅ RLS está funcionando corretamente (bloqueou acesso)');
      }
    } else if (produtos && produtos.length > 0) {
      console.log(`⚠️ PROBLEMA: ${produtos.length} produtos visíveis sem filtro!`);
      console.log('📋 User_IDs encontrados:', [...new Set(produtos.map(p => p.user_id))]);
    } else {
      console.log('✅ RLS funcionando: Nenhum produto visível sem filtro');
    }

    // 3. TESTE COM FILTRO CORRETO
    console.log('\n3. Testando com filtro por user_id...');
    
    const { data: clientesFiltrados, error: clientesFiltError } = await supabase
      .from('clientes')
      .select('*')
      .eq('user_id', USER_ID_CORRETO)
      .limit(5);

    if (!clientesFiltError && clientesFiltrados) {
      console.log(`✅ Clientes com filtro: ${clientesFiltrados.length} encontrados`);
    } else {
      console.log('❌ Erro ao buscar clientes com filtro:', clientesFiltError?.message);
    }

    const { data: produtosFiltrados, error: produtosFiltError } = await supabase
      .from('produtos')
      .select('*')
      .eq('user_id', USER_ID_CORRETO)
      .limit(5);

    if (!produtosFiltError && produtosFiltrados) {
      console.log(`✅ Produtos com filtro: ${produtosFiltrados.length} encontrados`);
    } else {
      console.log('❌ Erro ao buscar produtos com filtro:', produtosFiltError?.message);
    }

    // 4. RESUMO FINAL
    console.log('\n📊 RESUMO DO TESTE:');
    console.log(`🔑 UUID utilizado: ${USER_ID_CORRETO}`);
    
    if ((clientesError && clientesError.message.includes('RLS')) || 
        (produtosError && produtosError.message.includes('RLS'))) {
      console.log('✅ ISOLAMENTO FUNCIONANDO: RLS está bloqueando acesso não autorizado');
    } else if ((clientes && clientes.length === 0) && (produtos && produtos.length === 0)) {
      console.log('✅ ISOLAMENTO FUNCIONANDO: Dados não visíveis sem filtro');
    } else {
      console.log('⚠️ ISOLAMENTO PARCIAL: Alguns dados ainda visíveis');
    }

    console.log('\n🚀 Frontend atualizado com UUID correto!');
    console.log('🔧 Teste o sistema agora: http://localhost:5174');

  } catch (error) {
    console.error('❌ Erro geral:', error);
  }
}

testarIsolamento();
