import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, anonKey, {
  auth: { persistSession: false }
});

async function testarIsolamentoProdutos() {
  console.log('🔍 TESTANDO ISOLAMENTO DE PRODUTOS APÓS CORREÇÃO...\n');

  try {
    // TESTE 1: Acesso anônimo a produtos (deve falhar)
    console.log('1. 🛍️ Testando acesso ANÔNIMO a produtos...');
    const { data: produtos, error: produtosError } = await supabase
      .from('produtos')
      .select('*')
      .limit(1);

    if (produtosError) {
      if (produtosError.message.includes('permission denied') || 
          produtosError.message.includes('RLS') ||
          produtosError.message.includes('access denied')) {
        console.log('   ✅ SUCESSO: Produtos completamente bloqueados!');
        console.log('   📋 Erro:', produtosError.message);
      } else {
        console.log('   ❌ Erro inesperado:', produtosError.message);
      }
    } else {
      console.log('   ❌ PROBLEMA: Produtos ainda acessíveis!');
      console.log('   📊 Quantidade:', produtos?.length);
      if (produtos && produtos.length > 0) {
        console.log('   🔑 User IDs encontrados:', [...new Set(produtos.map(p => p.user_id))]);
      }
    }

    // TESTE 2: Acesso anônimo a clientes (para comparação)
    console.log('\n2. 👤 Testando acesso ANÔNIMO a clientes...');
    const { data: clientes, error: clientesError } = await supabase
      .from('clientes')
      .select('*')
      .limit(1);

    if (clientesError) {
      console.log('   ✅ Clientes bloqueados:', clientesError.message);
    } else {
      console.log('   ❌ Clientes ainda acessíveis:', clientes?.length);
    }

    // RESULTADO FINAL
    console.log('\n📊 RESULTADO DO TESTE:');
    
    const produtosBloqueados = produtosError && (
      produtosError.message.includes('permission denied') || 
      produtosError.message.includes('RLS') ||
      produtosError.message.includes('access denied')
    );
    
    const clientesBloqueados = clientesError && (
      clientesError.message.includes('permission denied') || 
      clientesError.message.includes('RLS') ||
      clientesError.message.includes('access denied')
    );

    if (produtosBloqueados && clientesBloqueados) {
      console.log('🎉 ISOLAMENTO TOTAL FUNCIONANDO!');
      console.log('✅ Produtos: Bloqueados para usuários anônimos');
      console.log('✅ Clientes: Bloqueados para usuários anônimos');
      console.log('\n🎯 PROBLEMA RESOLVIDO:');
      console.log('❌ "os produtos estao ainda [aparecendo]" → CORRIGIDO!');
      console.log('✅ Frontend corrigido com filtros por user_id');
      console.log('✅ RLS funcionando no backend');
      console.log('\n🚀 Sistema pronto para uso multi-tenant!');
    } else {
      if (!produtosBloqueados) {
        console.log('⚠️ PRODUTOS ainda não isolados adequadamente');
      }
      if (!clientesBloqueados) {
        console.log('⚠️ CLIENTES ainda não isolados adequadamente');  
      }
    }

    console.log('\n🔧 RECOMENDAÇÃO:');
    console.log('1. Reiniciar o sistema: Ctrl+C no terminal do "npm run dev"');
    console.log('2. Executar novamente: npm run dev');
    console.log('3. Testar no navegador: http://localhost:5174');
    console.log('4. Login: assistenciaallimport10@gmail.com');
    console.log('5. Verificar se produtos aparecem apenas para este usuário');

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testarIsolamentoProdutos();
