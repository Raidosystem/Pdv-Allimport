import fs from 'fs';

console.log('🔍 ANÁLISE DO BACKUP DOS CLIENTES');
console.log('=====================================');

try {
  const backup = JSON.parse(fs.readFileSync('./public/backup-allimport.json', 'utf8'));
  const clients = backup.data?.clients || [];

  console.log('📊 Total de clientes no backup:', clients.length);

  const ativosBackup = clients.filter(c => c.active !== false);
  const inativosBackup = clients.filter(c => c.active === false);

  console.log('✅ Clientes ATIVOS no backup:', ativosBackup.length);
  console.log('❌ Clientes INATIVOS no backup:', inativosBackup.length);

  console.log('\n📋 Amostra de clientes do backup:');
  clients.slice(0, 10).forEach((client, index) => {
    console.log(`${index + 1}. ${client.name} - Ativo: ${client.active !== false ? 'SIM' : 'NÃO'} - ID: ${client.id}`);
  });

  if (inativosBackup.length > 0) {
    console.log('\n❌ Clientes inativos no backup:');
    inativosBackup.slice(0, 5).forEach((client, index) => {
      console.log(`${index + 1}. ${client.name} - Status: ${client.active}`);
    });
  }

  // Verificar estrutura dos dados
  if (clients.length > 0) {
    console.log('\n🏗️ Estrutura do primeiro cliente:');
    console.log('Campos disponíveis:', Object.keys(clients[0]));
  }

} catch (error) {
  console.error('❌ Erro ao ler backup:', error.message);
}