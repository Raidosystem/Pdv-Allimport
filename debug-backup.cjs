const fs = require('fs');
const path = require('path');

console.log('🔍 Debugando estrutura do backup...');

const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

console.log('📋 Chaves principais:', Object.keys(backupData));

if (backupData.data) {
  console.log('📋 Chaves de data:', Object.keys(backupData.data));
  
  if (backupData.data.products) {
    console.log(`📦 Encontrados ${backupData.data.products.length} produtos`);
    console.log('🔍 Primeiro produto:', JSON.stringify(backupData.data.products[0], null, 2));
  }
}

if (backupData.products) {
  console.log(`📦 Encontrados ${backupData.products.length} produtos`);
  console.log('🔍 Primeiro produto:', JSON.stringify(backupData.products[0], null, 2));
} else {
  console.log('❌ Não encontrou array de produtos');
  console.log('📄 Estrutura:', typeof backupData, Array.isArray(backupData));
}
