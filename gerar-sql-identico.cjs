const fs = require('fs');
const path = require('path');

console.log('🔄 Gerando SQL IDÊNTICO aos produtos funcionais...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;
const categories = backupData.data.categories;

// Pegar o user_id do primeiro produto (todos têm o mesmo user_id)
const USER_ID = backup[0].user_id;
console.log(`👤 User ID encontrado: ${USER_ID}`);

console.log(`📦 Carregando ${backup.length} produtos...`);
console.log(`📋 Carregando ${categories.length} categorias...`);

// Gerar SQL IDÊNTICO aos produtos que já funcionam
let sql = `-- Script SQL IDÊNTICO aos produtos que já funcionam
-- User ID: ${USER_ID}
-- Total de produtos: ${backup.length}
-- Total de categorias: ${categories.length}
-- Estrutura EXATA do backup original
-- Gerado automaticamente em: ${new Date().toISOString()}

-- Primeiro, inserir TODAS as categorias (estrutura original)
INSERT INTO public.categorias (id, user_id, nome, criado_em, atualizado_em) VALUES
`;

// Inserir todas as categorias com user_id
categories.forEach((categoria, index) => {
  const isLast = index === categories.length - 1;
  const nome = categoria.name.replace(/'/g, "''");
  
  sql += `('${categoria.id}', '${categoria.user_id}', '${nome}', '${categoria.created_at}', '${categoria.updated_at}')`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

sql += `
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  atualizado_em = EXCLUDED.atualizado_em;

-- Inserir TODOS os produtos (estrutura EXATA do backup)
INSERT INTO public.produtos (
  id,
  user_id,
  nome,
  codigo_barras,
  categoria_id,
  preco,
  preco_custo,
  estoque_atual,
  estoque_minimo,
  unidade,
  ativo,
  data_validade,
  criado_em,
  atualizado_em
) VALUES
`;

// Adicionar cada produto com EXATA estrutura do backup
backup.forEach((produto, index) => {
  const isLast = index === backup.length - 1;
  
  // Escapar aspas simples no código de barras
  let barcode = produto.barcode || '';
  barcode = barcode.replace(/'/g, "''");
  
  // Escapar aspas simples no nome
  const nome = produto.name.replace(/'/g, "''");
  
  // Usar valores EXATOS do backup
  const dataValidade = produto.expiry_date ? `'${produto.expiry_date}'` : 'NULL';
  
  sql += `('${produto.id}', '${produto.user_id}', '${nome}', '${barcode}', '${produto.category_id}', ${produto.sale_price}, ${produto.cost_price}, ${produto.current_stock}, ${produto.minimum_stock}, '${produto.unit_measure}', ${produto.active}, ${dataValidade}, '${produto.created_at}', '${produto.updated_at}')`;
  
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
  codigo_barras = EXCLUDED.codigo_barras,
  preco = EXCLUDED.preco,
  estoque_atual = EXCLUDED.estoque_atual,
  atualizado_em = EXCLUDED.atualizado_em;

-- Verificar quantos produtos foram inseridos
SELECT COUNT(*) as total_produtos FROM public.produtos WHERE user_id = '${USER_ID}';

-- Verificar quantas categorias foram inseridas
SELECT COUNT(*) as total_categorias FROM public.categorias WHERE user_id = '${USER_ID}';

-- Verificar alguns produtos inseridos
SELECT p.id, p.nome, p.preco, p.estoque_atual, c.nome as categoria 
FROM public.produtos p 
LEFT JOIN public.categorias c ON p.categoria_id = c.id 
WHERE p.user_id = '${USER_ID}'
ORDER BY p.criado_em DESC
LIMIT 10;
`;

// Salvar arquivo
const outputPath = path.join(__dirname, 'INSERIR_IDENTICO_AOS_FUNCIONAIS.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo SQL idêntico salvo em: INSERIR_IDENTICO_AOS_FUNCIONAIS.sql`);
console.log(`📊 Total de produtos: ${backup.length}`);
console.log(`📋 Total de categorias: ${categories.length}`);
console.log(`👤 User ID: ${USER_ID}`);
console.log(`🔧 Estrutura EXATA do backup original com todas as colunas`);
