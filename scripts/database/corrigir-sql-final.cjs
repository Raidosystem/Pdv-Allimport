const fs = require('fs');
const path = require('path');

console.log('🔄 Corrigindo arquivo SQL para estrutura correta...');

// Ler o backup original
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));
const backup = backupData.data.products; // Acessar produtos na estrutura correta

console.log(`📦 Carregando ${backup.length} produtos...`);

// Gerar SQL correto
let sql = `-- Script SQL para inserir TODOS os produtos do backup no Supabase
-- Total de produtos: ${backup.length}
-- Data do backup: 2025-08-25
-- Gerado automaticamente em: ${new Date().toISOString()}

-- Primeiro, garantir categoria padrão
INSERT INTO public.categorias (id, nome, descricao, criado_em, atualizado_em) 
VALUES (
  'cat-default',
  'Produtos Gerais', 
  'Categoria padrão para produtos importados',
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  descricao = EXCLUDED.descricao,
  atualizado_em = NOW();

-- Inserir TODOS os produtos do backup (SEM coluna ativo)
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
  categoria_id,
  criado_em,
  atualizado_em
) VALUES
`;

// Adicionar cada produto
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
  
  sql += `('${produto.id}', '${nome}', '${descricao}', '${sku}', '${barcode}', ${produto.sale_price}, ${produto.current_stock}, ${produto.minimum_stock || 1}, '${produto.unit_measure}', 'cat-default', NOW(), NOW())`;
  
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
  estoque_atual = EXCLUDED.estoque_atual,
  atualizado_em = NOW();

-- Verificar quantos produtos foram inseridos
SELECT COUNT(*) as total_produtos FROM public.produtos;

-- Verificar alguns produtos inseridos
SELECT id, nome, preco, estoque_atual FROM public.produtos 
WHERE categoria_id = 'cat-default' 
ORDER BY criado_em DESC 
LIMIT 10;
`;

// Salvar arquivo
const outputPath = path.join(__dirname, 'INSERIR_TODOS_OS_813_PRODUTOS_CORRIGIDO.sql');
fs.writeFileSync(outputPath, sql);

console.log(`✅ Arquivo SQL corrigido salvo em: INSERIR_TODOS_OS_813_PRODUTOS_CORRIGIDO.sql`);
console.log(`📊 Total de produtos: ${backup.length}`);
console.log(`🔧 Estrutura: SEM coluna 'ativo' para compatibilidade`);
