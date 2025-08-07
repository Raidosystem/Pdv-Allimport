const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://kmcaaqetxtwkdcczdomw.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'
);

async function checkClientesStructure() {
  console.log('🔍 VERIFICANDO ESTRUTURA DA TABELA CLIENTES\n');
  
  const { data: clientes } = await supabase
    .from('clientes')
    .select('*')
    .limit(1);
    
  if (clientes && clientes.length > 0) {
    const cliente = clientes[0];
    console.log('📊 ESTRUTURA DO PRIMEIRO REGISTRO:');
    Object.keys(cliente).forEach(key => {
      console.log(`   ${key}: ${typeof cliente[key]} = ${cliente[key]}`);
    });
    
    console.log('\n🔍 TIPO DO ID:');
    if (typeof cliente.id === 'string' && cliente.id.includes('-')) {
      console.log('✅ ID é UUID (string)');
      console.log('   Valor:', cliente.id);
    } else if (typeof cliente.id === 'number') {
      console.log('✅ ID é INTEGER (number)');
      console.log('   Valor:', cliente.id);
    } else {
      console.log('❓ Tipo desconhecido:', typeof cliente.id);
    }
  }
}

checkClientesStructure().catch(console.error);
