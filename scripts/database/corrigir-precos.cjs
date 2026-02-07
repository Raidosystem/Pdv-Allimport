const fs = require('fs');

// Ler o backup
const backup = JSON.parse(fs.readFileSync('public/backup-allimport.json', 'utf8'));
const userId = '28e56a69-90df-4852-b663-9b02f4358c6f';

console.log(`🔧 Corrigindo preços de ${backup.data.products.length} produtos...`);

let sql = `-- CORRIGIR PREÇOS DOS PRODUTOS
-- User ID: ${userId}
-- Data: ${new Date().toISOString()}

-- Entrar em modo replica
SET session_replication_role = replica;

-- Atualizar preços em lotes de 50
`;

// Gerar UPDATEs dos preços em lotes de 50
const batchSize = 50;
for (let i = 0; i < backup.data.products.length; i += batchSize) {
    const batch = backup.data.products.slice(i, i + batchSize);
    
    sql += `-- Lote ${Math.floor(i/batchSize) + 1} (produtos ${i + 1} a ${Math.min(i + batchSize, backup.data.products.length)})\n`;
    
    for (const produto of batch) {
        const preco = parseFloat(produto.sale_price) || 0;
        if (preco > 0) {
            sql += `UPDATE public.produtos SET preco = ${preco} WHERE id = '${produto.id}' AND user_id = '${userId}';\n`;
        }
    }
    sql += '\n';
}

sql += `-- Voltar ao modo normal
SET session_replication_role = DEFAULT;

-- VERIFICAÇÃO
SELECT 'Produtos com preço > 0:' as status, COUNT(*) as total 
FROM public.produtos 
WHERE user_id = '${userId}' AND preco > 0;

SELECT 'Exemplos de preços:' as lista, nome, preco 
FROM public.produtos 
WHERE user_id = '${userId}' AND preco > 0 
ORDER BY preco DESC 
LIMIT 10;`;

// Salvar o arquivo
fs.writeFileSync('CORRIGIR_PRECOS_PRODUTOS.sql', sql);

// Estatísticas
const produtosComPreco = backup.data.products.filter(p => parseFloat(p.sale_price) > 0);

console.log('✅ Arquivo gerado: CORRIGIR_PRECOS_PRODUTOS.sql');
console.log(`📦 Total de produtos: ${backup.data.products.length}`);
console.log(`💰 Produtos com preço > 0: ${produtosComPreco.length}`);
console.log(`🔢 Maior preço encontrado: R$ ${Math.max(...produtosComPreco.map(p => parseFloat(p.sale_price)))}`);
console.log(`🔢 Menor preço encontrado: R$ ${Math.min(...produtosComPreco.map(p => parseFloat(p.sale_price)))}`);
