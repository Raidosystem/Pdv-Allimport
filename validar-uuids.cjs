const fs = require('fs');
const path = require('path');

console.log('🔍 Validando TODOS os UUIDs...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;
const categories = backupData.data.categories;

// Função para validar UUID
function isValidUUID(uuid) {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return uuidRegex.test(uuid);
}

console.log('🔍 Validando UUIDs dos produtos...');
let invalidProducts = [];
backup.forEach((produto, index) => {
  if (!isValidUUID(produto.id)) {
    invalidProducts.push({ index, id: produto.id, name: produto.name });
  }
  if (!isValidUUID(produto.category_id)) {
    invalidProducts.push({ index, id: produto.category_id, name: `${produto.name} - category_id` });
  }
});

console.log('🔍 Validando UUIDs das categorias...');
let invalidCategories = [];
categories.forEach((categoria, index) => {
  if (!isValidUUID(categoria.id)) {
    invalidCategories.push({ index, id: categoria.id, name: categoria.name });
  }
});

if (invalidProducts.length > 0) {
  console.log('❌ Produtos com UUIDs inválidos:');
  invalidProducts.forEach(item => {
    console.log(`  - ${item.name}: ${item.id}`);
  });
} else {
  console.log('✅ Todos os UUIDs dos produtos são válidos');
}

if (invalidCategories.length > 0) {
  console.log('❌ Categorias com UUIDs inválidos:');
  invalidCategories.forEach(item => {
    console.log(`  - ${item.name}: ${item.id}`);
  });
} else {
  console.log('✅ Todos os UUIDs das categorias são válidos');
}

// Se tudo estiver válido, gerar arquivo
if (invalidProducts.length === 0 && invalidCategories.length === 0) {
  console.log('🔄 Gerando SQL com UUIDs validados...');
  
  const USER_ID = backup[0].user_id;
  
  let sql = `-- SQL VALIDADO - todos os UUIDs são válidos
-- User ID: ${USER_ID}
-- Total: ${backup.length} produtos + ${categories.length} categorias
-- Gerado em: ${new Date().toISOString()}

-- Inserir categorias
INSERT INTO public.categorias (id, user_id, nome) VALUES
`;

  // Categorias
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

-- Inserir produtos (estrutura mínima)
INSERT INTO public.produtos (id, user_id, nome, preco) VALUES
`;

  // Produtos
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

-- Verificações
SELECT COUNT(*) as total_inserido FROM public.produtos WHERE user_id = '${USER_ID}';
SELECT id, nome, preco FROM public.produtos WHERE user_id = '${USER_ID}' ORDER BY nome LIMIT 10;
`;

  const outputPath = path.join(__dirname, 'INSERIR_UUIDS_VALIDADOS.sql');
  fs.writeFileSync(outputPath, sql);
  
  console.log(`✅ Arquivo com UUIDs validados: INSERIR_UUIDS_VALIDADOS.sql`);
} else {
  console.log('❌ Não é possível gerar SQL devido a UUIDs inválidos');
}
