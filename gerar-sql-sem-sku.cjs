const fs = require('fs');
const path = require('path');

console.log('🔄 Gerando SQL SEM coluna sku...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;
const categories = backupData.data.categories;

console.log(`📦 Carregando ${backup.length} produtos...`);
console.log(`📋 Carregando ${categories.length} categorias...`);

// Gerar SQL sem coluna SKU
let sql = `-- Script SQL para inserir TODOS os produtos e categorias do backup no Supabase
-- Total de produtos: ${backup.length}
-- Total de categorias: ${categories.length}
-- SEM coluna SKU (não existe na tabela)
-- Gerado automaticamente em: ${new Date().toISOString()}

-- Primeiro, inserir TODAS as categorias originais
INSERT INTO public.categorias (id, nome, descricao) VALUES
`;

// Inserir todas as categorias
categories.forEach((categoria, index) => {
  const isLast = index === categories.length - 1;
  const nome = categoria.name.replace(/'/g, "''");
  
  sql += `('${categoria.id}', '${nome}', 'Categoria importada do backup - ${nome}')`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

sql += `
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  descricao = EXCLUDED.descricao;

-- Inserir TODOS os produtos do backup (SEM coluna SKU)
INSERT INTO public.produtos (
  id,
  nome,
  descricao, 
  codigo_barras,
  preco,
  estoque_atual,
  estoque_minimo,
  unidade,
  categoria_id
) VALUES
`;

// Adicionar cada produto SEM SKU
backup.forEach((produto, index) => {
  const isLast = index === backup.length - 1;
  
  // Escapar aspas simples no código de barras
  let barcode = produto.barcode || '';
  barcode = barcode.replace(/'/g, "''");
  
  // Escapar aspas simples no nome e descrição
  const nome = produto.name.replace(/'/g, "''");
  const descricao = `Produto importado do backup - ${produto.name}`.replace(/'/g, "''");
  
  sql += `('${produto.id}', '${nome}', '${descricao}', '${barcode}', ${produto.sale_price}, ${produto.current_stock}, ${produto.minimum_stock || 1}, '${produto.unit_measure}', '${produto.category_id}')`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

// Adicionar ON CONFLICT e queries de verificação
sql += `
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  descricao = EXCLUDED.descricao,
  codigo_barras = EXCLUDED.codigo_barras,
  preco = EXCLUDED.preco,
  estoque_atual = EXCLUDED.estoque_atual;

-- Verificar quantos produtos foram inseridos
SELECT COUNT(*) as total_produtos FROM public.produtos;

-- Verificar quantas categorias foram inseridas
SELECT COUNT(*) as total_categorias FROM public.categorias;

-- Verificar alguns produtos inseridos
SELECT p.id, p.nome, p.preco, p.estoque_atual, c.nome as categoria 
FROM public.produtos p 
LEFT JOIN public.categorias c ON p.categoria_id = c.id 
LIMIT 10;
`;

// Salvar arquivo
const outputPath = path.join(__dirname, 'INSERIR_SEM_SKU_FINAL.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo SQL sem SKU salvo em: INSERIR_SEM_SKU_FINAL.sql`);
console.log(`📊 Total de produtos: ${backup.length}`);
console.log(`📋 Total de categorias: ${categories.length}`);
console.log(`🔧 SEM coluna SKU para compatibilidade total`);
