const fs = require('fs');

console.log('🚀 Gerando script SQL com todos os produtos do backup...');

// Ler o backup
const backupPath = 'c:/Users/crism/Desktop/backup/backup-limpo-products.json';
const backup = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

console.log(`📦 Total de produtos encontrados: ${backup.data.length}`);

// Cabeçalho do SQL
let sqlScript = `-- Script SQL para inserir TODOS os produtos do backup no Supabase
-- Total de produtos: ${backup.data.length}
-- Data do backup: ${backup.exported_date}
-- Gerado automaticamente em: ${new Date().toISOString()}

-- Primeiro, garantir categoria padrão
INSERT INTO public.categorias (id, nome, descricao, ativo, criado_em, atualizado_em) 
VALUES (
  'cat-default',
  'Produtos Gerais', 
  'Categoria padrão para produtos importados',
  true,
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;

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
  categoria_id,
  ativo,
  criado_em,
  atualizado_em
) VALUES
`;

// Gerar VALUES para todos os produtos
const values = backup.data.map((produto, index) => {
  const id = produto.id || `backup-prod-${index + 1}`;
  const nome = (produto.name || `Produto ${index + 1}`).replace(/'/g, "''"); // Escape aspas simples
  const descricao = `Produto importado do backup - ${nome}`.replace(/'/g, "''");
  const sku = produto.sku || `SKU-${String(index + 1).padStart(4, '0')}`;
  const codigoBarras = produto.barcode || '';
  const preco = produto.sale_price || 0;
  const estoque = produto.current_stock || 0;
  const estoqueMin = produto.minimum_stock || 1;
  const unidade = produto.unit_measure || 'un';
  const ativo = produto.active !== false ? 'true' : 'false';
  
  return `('${id}', '${nome}', '${descricao}', '${sku}', '${codigoBarras}', ${preco}, ${estoque}, ${estoqueMin}, '${unidade}', 'cat-default', ${ativo}, NOW(), NOW())`;
}).join(',\n');

sqlScript += values;

// Rodapé do SQL
sqlScript += `

ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  descricao = EXCLUDED.descricao,
  sku = EXCLUDED.sku,
  codigo_barras = EXCLUDED.codigo_barras,
  preco = EXCLUDED.preco,
  estoque_atual = EXCLUDED.estoque_atual,
  atualizado_em = NOW();

-- Verificar quantos produtos foram inseridos
SELECT COUNT(*) as total_produtos FROM public.produtos WHERE ativo = true;

-- Verificar alguns produtos inseridos
SELECT id, nome, preco, estoque_atual FROM public.produtos 
WHERE categoria_id = 'cat-default' 
ORDER BY criado_em DESC 
LIMIT 10;`;

// Salvar arquivo SQL
const outputFile = 'INSERIR_TODOS_OS_813_PRODUTOS.sql';
fs.writeFileSync(outputFile, sqlScript);

console.log(`✅ Script SQL criado: ${outputFile}`);
console.log(`📊 Total de produtos no script: ${backup.data.length}`);
console.log(`💾 Tamanho do arquivo: ${Math.round(sqlScript.length / 1024)} KB`);

// Mostrar alguns exemplos dos produtos
console.log('\n🔍 Primeiros 5 produtos que serão inseridos:');
backup.data.slice(0, 5).forEach((produto, i) => {
  console.log(`${i + 1}. ${produto.name} - R$ ${produto.sale_price} - Estoque: ${produto.current_stock}`);
});

console.log('\n📋 INSTRUÇÕES:');
console.log('1. Abra o Supabase Dashboard');
console.log('2. Vá em SQL Editor');
console.log('3. Cole e execute o conteúdo do arquivo INSERIR_TODOS_OS_813_PRODUTOS.sql');
console.log('4. Aguarde a execução (pode levar alguns minutos)');
console.log('5. Verifique se os produtos aparecem no sistema PDV');
