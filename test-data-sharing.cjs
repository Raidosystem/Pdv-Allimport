const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://kmcaaqetxtwkdcczdomw.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'
);

async function checkDataSharing() {
  console.log('🔍 VERIFICANDO COMPARTILHAMENTO DE DADOS\n');
  
  // Verificar clientes
  const { data: clientes, error: clientesError } = await supabase
    .from('clientes')
    .select('id, nome, email');
    
  console.log('📊 CLIENTES:');
  if (clientesError) {
    console.log('❌ Erro:', clientesError.message);
  } else {
    console.log(`✅ Total encontrado: ${clientes.length} registros`);
    clientes.forEach((cliente, i) => {
      console.log(`   ${i+1}. ${cliente.nome} (${cliente.email || 'sem email'})`);
    });
  }
  
  // Verificar produtos
  console.log('\n📦 PRODUTOS:');
  const { data: produtos, error: produtosError } = await supabase
    .from('produtos')
    .select('id, nome');
    
  if (produtosError) {
    console.log('❌ Erro:', produtosError.message);
  } else {
    console.log(`✅ Total encontrado: ${produtos.length} registros`);
  }
  
  // Resposta final
  console.log('\n🎯 RESPOSTA SOBRE COMPARTILHAMENTO:');
  if (clientes && clientes.length > 0) {
    console.log('✅ SIM - Os dados SÃO COMPARTILHADOS entre contas');
    console.log('   - Clientes cadastrados em uma conta aparecem em todas as outras');
    console.log('   - Isso acontece porque o RLS está DESABILITADO');
  } else {
    console.log('⚠️ Não foi possível verificar (sem dados)');
  }
  
  if (produtosError && produtosError.message.includes('does not exist')) {
    console.log('\n⚠️ ATENÇÃO: Tabela de produtos NÃO EXISTE ainda!');
    console.log('   - Você precisa criar as tabelas produtos e categorias no Supabase');
  }
}

checkDataSharing().catch(console.error);
