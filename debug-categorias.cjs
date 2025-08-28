const fs = require('fs');
const path = require('path');

console.log('🔍 Analisando categorias do backup...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

console.log('📋 Categorias disponíveis:', backupData.data.categories?.length || 0);
if (backupData.data.categories && backupData.data.categories.length > 0) {
  console.log('🔍 Primeira categoria:', backupData.data.categories[0]);
}

console.log('📦 Primeiro produto:', backupData.data.products[0]);
console.log('🏷️ Category ID do primeiro produto:', backupData.data.products[0].category_id);
