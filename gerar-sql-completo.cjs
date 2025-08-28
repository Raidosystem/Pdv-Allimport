const fs = require('fs');
const path = require('path');

console.log('🔄 Gerando SQL com categorias originais...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;
const categories = backupData.data.categories;

console.log(`📦 Carregando ${backup.length} produtos...`);
console.log(`📋 Carregando ${categories.length} categorias...`);

// Gerar SQL com categorias originais
let sql = `-- Script SQL para inserir TODOS os produtos e categorias do backup no Supabase
-- Total de produtos: ${backup.length}
-- Total de categorias: ${categories.length}
-- Usando categorias originais do backup
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

-- Inserir TODOS os produtos do backup (com categorias originais)
INSERT INTO public.produtos (
  id,
  nome,
  descricao, 
  sku,
  codigo_barras,
  preco,
  estoque_atual,
  estoque_minimo,
  unidade,
  categoria_id
) VALUES
`;

// Adicionar cada produto com sua categoria original
backup.forEach((produto, index) => {
  const isLast = index === backup.length - 1;
  
  // Escapar aspas simples no código de barras
  let barcode = produto.barcode || '';
  barcode = barcode.replace(/'/g, "''");
  
  // Escapar aspas simples no nome e descrição
  const nome = produto.name.replace(/'/g, "''");
  const descricao = `Produto importado do backup - ${produto.name}`.replace(/'/g, "''");
  
  // Gerar SKU baseado no índice
  const sku = `SKU-${String(index + 1).padStart(4, '0')}`;
  
  sql += `('${produto.id}', '${nome}', '${descricao}', '${sku}', '${barcode}', ${produto.sale_price}, ${produto.current_stock}, ${produto.minimum_stock || 1}, '${produto.unit_measure}', '${produto.category_id}')`;
  
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
  sku = EXCLUDED.sku,
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
const outputPath = path.join(__dirname, 'INSERIR_COMPLETO_COM_CATEGORIAS.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo SQL completo salvo em: INSERIR_COMPLETO_COM_CATEGORIAS.sql`);
console.log(`📊 Total de produtos: ${backup.length}`);
console.log(`📋 Total de categorias: ${categories.length}`);
console.log(`🔧 Usando categorias e IDs originais do backup`);
