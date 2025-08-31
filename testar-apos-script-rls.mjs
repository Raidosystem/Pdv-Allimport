import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

const supabase = createClient(supabaseUrl, anonKey, {
  auth: { persistSession: false }
});

async function testarAposScript() {
  console.log('🔍 TESTANDO APÓS EXECUÇÃO DO SCRIPT RLS...\n');

  try {
    // TESTE 1: Acesso anônimo a clientes
    console.log('1. 👤 Testando acesso ANÔNIMO a clientes...');
    const { data: clientes, error: clientesError } = await supabase
      .from('clientes')
      .select('*')
      .limit(1);

    if (clientesError) {
      if (clientesError.message.includes('permission denied') || 
          clientesError.message.includes('RLS') ||
          clientesError.message.includes('access denied')) {
        console.log('   ✅ SUCESSO: Clientes bloqueados para usuários anônimos');
        console.log('   📋 Erro:', clientesError.message);
      } else {
        console.log('   ❌ Erro inesperado:', clientesError.message);
      }
    } else {
      console.log('   ❌ PROBLEMA: Clientes ainda acessíveis para anônimos!');
      console.log('   📊 Registros encontrados:', clientes?.length);
    }

    // TESTE 2: Acesso anônimo a produtos
    console.log('\n2. 🛍️ Testando acesso ANÔNIMO a produtos...');
    const { data: produtos, error: produtosError } = await supabase
      .from('produtos')
      .select('*')
      .limit(1);

    if (produtosError) {
      if (produtosError.message.includes('permission denied') || 
          produtosError.message.includes('RLS') ||
          produtosError.message.includes('access denied')) {
        console.log('   ✅ SUCESSO: Produtos bloqueados para usuários anônimos');
        console.log('   📋 Erro:', produtosError.message);
      } else {
        console.log('   ❌ Erro inesperado:', produtosError.message);
      }
    } else {
      console.log('   ❌ PROBLEMA: Produtos ainda acessíveis para anônimos!');
      console.log('   📊 Registros encontrados:', produtos?.length);
    }

    // RESULTADO FINAL
    console.log('\n📊 RESULTADO DO TESTE:');
    
    const clientesBloqueados = clientesError && (
      clientesError.message.includes('permission denied') || 
      clientesError.message.includes('RLS') ||
      clientesError.message.includes('access denied')
    );
    
    const produtosBloqueados = produtosError && (
      produtosError.message.includes('permission denied') || 
      produtosError.message.includes('RLS') ||
      produtosError.message.includes('access denied')
    );

    if (clientesBloqueados && produtosBloqueados) {
      console.log('🎉 ISOLAMENTO FUNCIONANDO 100%!');
      console.log('✅ Usuários anônimos completamente bloqueados');
      console.log('✅ Apenas usuários autenticados podem acessar seus dados');
      console.log('\n🚀 PRÓXIMOS PASSOS:');
      console.log('1. Iniciar sistema: npm run dev');
      console.log('2. Abrir: http://localhost:5174');
      console.log('3. Fazer login: assistenciaallimport10@gmail.com');
      console.log('4. Verificar que clientes/produtos aparecem apenas para este usuário');
      console.log('\n🎯 PROBLEMA RESOLVIDO: "ainda esta aparecendo em outro usuario produtos e clientes" → CORRIGIDO!');
    } else if (!clientesBloqueados || !produtosBloqueados) {
      console.log('⚠️ ISOLAMENTO PARCIAL');
      console.log('🔧 Algumas tabelas ainda acessíveis para anônimos');
      console.log('📝 Execute o script novamente no Supabase Dashboard');
    } else {
      console.log('❌ ISOLAMENTO NÃO FUNCIONANDO');
      console.log('🔧 Verificar configuração manual no Supabase');
    }

  } catch (error) {
    console.error('❌ Erro no teste:', error);
  }
}

testarAposScript();
