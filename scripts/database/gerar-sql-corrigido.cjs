const fs = require('fs');
const path = require('path');

console.log('🔄 Gerando SQL CORRIGIDO sem timestamps em categorias...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;
const categories = backupData.data.categories;

// Pegar o user_id do primeiro produto
const USER_ID = backup[0].user_id;
console.log(`👤 User ID encontrado: ${USER_ID}`);

console.log(`📦 Carregando ${backup.length} produtos...`);
console.log(`📋 Carregando ${categories.length} categorias...`);

// Gerar SQL CORRIGIDO
let sql = `-- Script SQL CORRIGIDO - sem timestamps em categorias
-- User ID: ${USER_ID}
-- Total de produtos: ${backup.length}
-- Total de categorias: ${categories.length}
-- Estrutura compatível com Supabase atual
-- Gerado automaticamente em: ${new Date().toISOString()}

-- Primeiro, inserir TODAS as categorias (SEM timestamps)
INSERT INTO public.categorias (id, user_id, nome) VALUES
`;

// Inserir categorias SEM timestamps
categories.forEach((categoria, index) => {
  const isLast = index === categories.length - 1;
  const nome = categoria.name.replace(/'/g, "''");
  
  sql += `('${categoria.id}', '${categoria.user_id}', '${nome}')`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

sql += `
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome;

-- Agora verificar se produtos precisam de correção também
-- Vamos testar com estrutura básica primeiro
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
  ativo
) VALUES
`;

// Adicionar produtos SEM timestamps
backup.forEach((produto, index) => {
  const isLast = index === backup.length - 1;
  
  // Escapar aspas simples
  let barcode = produto.barcode || '';
  barcode = barcode.replace(/'/g, "''");
  const nome = produto.name.replace(/'/g, "''");
  
  sql += `('${produto.id}', '${produto.user_id}', '${nome}', '${barcode}', '${produto.category_id}', ${produto.sale_price}, ${produto.cost_price}, ${produto.current_stock}, ${produto.minimum_stock}, '${produto.unit_measure}', ${produto.active})`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

// ON CONFLICT e verificações
sql += `
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo_barras = EXCLUDED.codigo_barras,
  preco = EXCLUDED.preco,
  estoque_atual = EXCLUDED.estoque_atual;

-- Verificar quantos produtos foram inseridos
SELECT COUNT(*) as total_produtos FROM public.produtos WHERE user_id = '${USER_ID}';

-- Verificar quantas categorias foram inseridas
SELECT COUNT(*) as total_categorias FROM public.categorias WHERE user_id = '${USER_ID}';

-- Verificar alguns produtos inseridos
SELECT p.id, p.nome, p.preco, p.estoque_atual, c.nome as categoria 
FROM public.produtos p 
LEFT JOIN public.categorias c ON p.categoria_id = c.id 
WHERE p.user_id = '${USER_ID}'
LIMIT 10;
`;

// Salvar arquivo
const outputPath = path.join(__dirname, 'INSERIR_CORRIGIDO_SEM_TIMESTAMPS.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo SQL corrigido salvo em: INSERIR_CORRIGIDO_SEM_TIMESTAMPS.sql`);
console.log(`📊 Total de produtos: ${backup.length}`);
console.log(`📋 Total de categorias: ${categories.length}`);
console.log(`👤 User ID: ${USER_ID}`);
console.log(`🔧 SEM timestamps em categorias, estrutura básica em produtos`);
