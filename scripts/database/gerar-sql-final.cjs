const fs = require('fs');

// Ler o backup
const backup = JSON.parse(fs.readFileSync('public/backup-allimport.json', 'utf8'));
const userId = '28e56a69-90df-4852-b663-9b02f4358c6f';

console.log(`📊 Gerando SQL FINAL para ${backup.data.products.length} produtos...`);

let sql = `-- INSERIR TODOS OS 813 PRODUTOS - MÉTODO QUE FUNCIONA
-- User ID: ${userId}
-- Data: ${new Date().toISOString()}

-- Entrar em modo replica (FUNCIONA!)
SET session_replication_role = replica;

-- PRIMEIRO: Inserir TODAS as 69 categorias
INSERT INTO public.categorias (id, user_id, nome) VALUES\n`;

// Gerar INSERT das categorias
const categoriaValues = backup.data.categories.map(cat => 
    `('${cat.id}', '${userId}', '${cat.name.replace(/'/g, "''")}')`
).join(',\n');

sql += categoriaValues + '\nON CONFLICT (id) DO NOTHING;\n\n';

// Gerar INSERT dos produtos em lotes de 50
sql += `-- SEGUNDO: Inserir TODOS os ${backup.data.products.length} produtos\n`;

const batchSize = 50;
for (let i = 0; i < backup.data.products.length; i += batchSize) {
    const batch = backup.data.products.slice(i, i + batchSize);
    
    sql += `-- Lote ${Math.floor(i/batchSize) + 1} (produtos ${i + 1} a ${Math.min(i + batchSize, backup.data.products.length)})\n`;
    sql += `INSERT INTO public.produtos (id, user_id, nome, preco) VALUES\n`;
    
    const productValues = batch.map(produto => {
        const nome = produto.name.replace(/'/g, "''");
        const preco = parseFloat(produto.price) || 0;
        return `('${produto.id}', '${userId}', '${nome}', ${preco})`;
    }).join(',\n');
    
    sql += productValues + '\nON CONFLICT (id) DO NOTHING;\n\n';
}

sql += `-- Voltar ao modo normal
SET session_replication_role = DEFAULT;

-- VERIFICAÇÃO FINAL
SELECT '🎉 IMPORTAÇÃO CONCLUÍDA!' as status;
SELECT 'Categorias inseridas:' as tipo, COUNT(*) as total FROM public.categorias WHERE user_id = '${userId}';
SELECT 'Produtos inseridos:' as tipo, COUNT(*) as total FROM public.produtos WHERE user_id = '${userId}';
SELECT 'Primeiros 10 produtos:' as lista, nome, preco FROM public.produtos WHERE user_id = '${userId}' ORDER BY nome LIMIT 10;`;

// Salvar o arquivo
fs.writeFileSync('INSERIR_TODOS_OS_813_PRODUTOS_FINAL.sql', sql);

console.log('✅ Arquivo gerado: INSERIR_TODOS_OS_813_PRODUTOS_FINAL.sql');
console.log(`📈 Total de categorias: ${backup.data.categories.length}`);
console.log(`📦 Total de produtos: ${backup.data.products.length}`);
console.log(`🔢 Total de lotes: ${Math.ceil(backup.data.products.length / batchSize)}`);
