const fs = require('fs');

const backup = JSON.parse(fs.readFileSync('public/backup-allimport.json', 'utf8'));

console.log('📦 Estrutura do backup:');
console.log('- Propriedades:', Object.keys(backup));

// Tentar diferentes variações de nome
const possibleKeys = ['clients', 'clientes', 'customers', 'data'];
let clientsArray = null;
let ordersArray = null;

for (const key of possibleKeys) {
  if (backup[key]) {
    clientsArray = backup[key];
    console.log(`✅ Encontrado array de clientes em: "${key}"`);
    break;
  }
}

const orderKeys = ['service_orders', 'orders', 'ordens_servico', 'ordens'];
for (const key of orderKeys) {
  if (backup[key]) {
    ordersArray = backup[key];
    console.log(`✅ Encontrado array de ordens em: "${key}"`);
    break;
  }
}

if (!clientsArray) {
  console.log('❌ Não encontrou array de clientes!');
  process.exit(1);
}

console.log(`\n📊 Total de clientes no backup: ${clientsArray.length}`);

// Buscar EDVANIA
const edvania = clientsArray.find(c => 
  c.cpf === '37511773885' || 
  c.cpf_cnpj === '37511773885' ||
  (c.nome && c.nome.includes('EDVANIA'))
);

if (!edvania) {
  console.log('❌ EDVANIA não encontrada!');
  console.log('\n🔍 Primeiros 3 clientes como exemplo:');
  clientsArray.slice(0, 3).forEach((c, i) => {
    console.log(`\nCliente ${i + 1}:`);
    console.log(JSON.stringify(c, null, 2));
  });
} else {
  console.log('\n✅ EDVANIA encontrada!');
  console.log('ID:', edvania.id);
  console.log('Nome:', edvania.name || edvania.nome);
  console.log('CPF:', edvania.cpf || edvania.cpf_cnpj);
  
  if (ordersArray) {
    console.log(`\n📊 Total de ordens no backup: ${ordersArray.length}`);
    
    const edvaniaOrders = ordersArray.filter(o => 
      o.client_id === edvania.id || 
      o.cliente_id === edvania.id
    );
    
    console.log(`\n🔍 Ordens da EDVANIA: ${edvaniaOrders.length}`);
    edvaniaOrders.forEach((o, i) => {
      console.log(`\n📝 Ordem ${i + 1}:`);
      console.log('  ID:', o.id);
      console.log('  client_id:', o.client_id || o.cliente_id);
      console.log('  Device:', o.device_model || o.modelo);
      console.log('  Marca:', o.device_name || o.marca);
      console.log('  Defeito:', o.defect || o.descricao_problema);
    });
  }
}
