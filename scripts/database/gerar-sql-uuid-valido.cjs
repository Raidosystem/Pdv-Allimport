const fs = require('fs');
const path = require('path');

console.log('🔄 Gerando SQL com UUID válido...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products;

console.log(`📦 Carregando ${backup.length} produtos...`);

// Usar uma categoria existente do backup ou gerar UUID válido
const categoriaExistente = backupData.data.categories && backupData.data.categories.length > 0 
  ? backupData.data.categories[0].id 
  : 'f47ac10b-58cc-4372-a567-0e02b2c3d479'; // UUID válido padrão

console.log(`📋 Usando categoria ID: ${categoriaExistente}`);

// Gerar SQL com UUID válido
let sql = `-- Script SQL para inserir TODOS os produtos do backup no Supabase
-- Total de produtos: ${backup.length}
-- Estrutura com UUID válido
-- Gerado automaticamente em: ${new Date().toISOString()}

-- Primeiro, garantir categoria padrão (com UUID válido)
INSERT INTO public.categorias (id, nome, descricao) 
VALUES (
  '${categoriaExistente}',
  'Produtos Gerais', 
  'Categoria padrão para produtos importados'
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  descricao = EXCLUDED.descricao;

-- Inserir TODOS os produtos do backup
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

// Adicionar cada produto usando UUID válido para categoria
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
  
  sql += `('${produto.id}', '${nome}', '${descricao}', '${sku}', '${barcode}', ${produto.sale_price}, ${produto.current_stock}, ${produto.minimum_stock || 1}, '${produto.unit_measure}', '${categoriaExistente}')`;
  
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

-- Verificar alguns produtos inseridos
SELECT id, nome, preco, estoque_atual FROM public.produtos 
WHERE categoria_id = '${categoriaExistente}' 
LIMIT 10;
`;

// Salvar arquivo
const outputPath = path.join(__dirname, 'INSERIR_813_PRODUTOS_UUID_VALIDO.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo SQL com UUID válido salvo em: INSERIR_813_PRODUTOS_UUID_VALIDO.sql`);
console.log(`📊 Total de produtos: ${backup.length}`);
console.log(`🔧 Categoria UUID: ${categoriaExistente}`);
