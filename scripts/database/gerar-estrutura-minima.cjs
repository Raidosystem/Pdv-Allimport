const fs = require('fs');
const path = require('path');

console.log('🎯 Adicionando produtos na estrutura dos que JÁ FUNCIONAM...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;
const categories = backupData.data.categories;

const USER_ID = backup[0].user_id;
console.log(`👤 User ID: ${USER_ID}`);
console.log(`📦 Produtos: ${backup.length}`);
console.log(`📋 Categorias: ${categories.length}`);

// Baseado nos produtos mock que funcionam no sistema:
// - id, name, description, sku, barcode, price, stock_quantity, min_stock, unit, active

let sql = `-- INSERIR produtos na estrutura que JÁ FUNCIONA no sistema
-- Baseado nos produtos mock que aparecem nas vendas
-- User ID: ${USER_ID}
-- Total: ${backup.length} produtos + ${categories.length} categorias

-- Primeira tentativa: estrutura mais simples dos categorias
INSERT INTO public.categorias (id, user_id, nome) VALUES
`;

// Adicionar categorias
categories.forEach((categoria, index) => {
  const isLast = index === categories.length - 1;
  const nome = categoria.name.replace(/'/g, "''");
  
  sql += `('${categoria.id}', '${USER_ID}', '${nome}')`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

sql += `
ON CONFLICT (id) DO NOTHING;

-- Estrutura MÍNIMA baseada nos produtos que funcionam
-- Testando primeiro com apenas: id, user_id, nome, preco
INSERT INTO public.produtos (id, user_id, nome, preco) VALUES
`;

// Adicionar produtos com estrutura mínima
backup.forEach((produto, index) => {
  const isLast = index === backup.length - 1;
  const nome = produto.name.replace(/'/g, "''");
  
  sql += `('${produto.id}', '${USER_ID}', '${nome}', ${produto.sale_price})`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

sql += `
ON CONFLICT (id) DO NOTHING;

-- Verificar se funcionou
SELECT COUNT(*) as total_inserido FROM public.produtos WHERE user_id = '${USER_ID}';

-- Ver alguns produtos
SELECT id, nome, preco FROM public.produtos WHERE user_id = '${USER_ID}' ORDER BY nome LIMIT 10;
`;

// Salvar arquivo
const outputPath = path.join(__dirname, 'ADICIONAR_NA_ESTRUTURA_FUNCIONAM.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo salvo: ADICIONAR_NA_ESTRUTURA_FUNCIONAM.sql`);
console.log(`🔧 Estrutura MÍNIMA: apenas id, user_id, nome, preco`);
console.log(`📝 Se funcionar, expando para mais colunas!`);
