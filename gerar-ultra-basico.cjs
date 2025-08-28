const fs = require('fs');
const path = require('path');

console.log('🔄 Gerando SQL ULTRA-BÁSICO...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;
const categories = backupData.data.categories;

console.log(`📦 Carregando ${backup.length} produtos...`);
console.log(`📋 Carregando ${categories.length} categorias...`);

// Gerar SQL com apenas colunas básicas
let sql = `-- Script SQL ULTRA-BÁSICO para inserir produtos e categorias
-- Total de produtos: ${backup.length}
-- Total de categorias: ${categories.length}
-- APENAS colunas fundamentais
-- Gerado automaticamente em: ${new Date().toISOString()}

-- Primeiro, inserir TODAS as categorias (básico)
INSERT INTO public.categorias (id, nome, descricao) VALUES
`;

// Inserir todas as categorias
categories.forEach((categoria, index) => {
  const isLast = index === categories.length - 1;
  const nome = categoria.name.replace(/'/g, "''");
  
  sql += `('${categoria.id}', '${nome}', 'Categoria importada')`;
  
  if (!isLast) {
    sql += ',\n';
  } else {
    sql += '\n';
  }
});

sql += `
ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome;

-- Inserir TODOS os produtos (ULTRA-BÁSICO)
INSERT INTO public.produtos (
  id,
  nome,
  descricao,
  preco,
  categoria_id
) VALUES
`;

// Adicionar cada produto com apenas colunas básicas
backup.forEach((produto, index) => {
  const isLast = index === backup.length - 1;
  
  // Escapar aspas simples no nome e descrição
  const nome = produto.name.replace(/'/g, "''");
  const descricao = `${produto.name}`.replace(/'/g, "''");
  
  sql += `('${produto.id}', '${nome}', '${descricao}', ${produto.sale_price}, '${produto.category_id}')`;
  
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
  preco = EXCLUDED.preco;

-- Verificar quantos produtos foram inseridos
SELECT COUNT(*) as total_produtos FROM public.produtos;

-- Verificar quantas categorias foram inseridas
SELECT COUNT(*) as total_categorias FROM public.categorias;

-- Verificar alguns produtos inseridos
SELECT p.id, p.nome, p.preco, c.nome as categoria 
FROM public.produtos p 
LEFT JOIN public.categorias c ON p.categoria_id = c.id 
LIMIT 10;
`;

// Salvar arquivo
const outputPath = path.join(__dirname, 'INSERIR_ULTRA_BASICO.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo SQL ultra-básico salvo em: INSERIR_ULTRA_BASICO.sql`);
console.log(`📊 Total de produtos: ${backup.length}`);
console.log(`📋 Total de categorias: ${categories.length}`);
console.log(`🔧 APENAS colunas: id, nome, descricao, preco, categoria_id`);
