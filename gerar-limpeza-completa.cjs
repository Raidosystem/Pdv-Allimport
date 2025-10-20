const fs = require('fs');
const path = require('path');

console.log('🧹 Gerando SQL de LIMPEZA COMPLETA...\n');

// Ler o backup
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backup = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

const clientes = backup.data.clients || [];
const produtos = backup.data.products || [];
const ordens = backup.data.service_orders || [];

console.log(`📊 Dados do backup:`);
console.log(`   - Clientes: ${clientes.length}`);
console.log(`   - Produtos: ${produtos.length}`);
console.log(`   - Ordens de Serviço: ${ordens.length}\n`);

const EMPRESA_ID = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

// Coletar todos os IDs válidos
const clienteIds = clientes.map(c => c.id);
const produtoIds = produtos.map(p => p.id);
const ordemIds = ordens.map(o => o.id);

let sql = '';

// Cabeçalho
sql += `-- =============================================\n`;
sql += `-- LIMPEZA COMPLETA ANTES DA IMPORTAÇÃO\n`;
sql += `-- Gerado em ${new Date().toLocaleString('pt-BR')}\n`;
sql += `-- =============================================\n\n`;

sql += `SET session_replication_role = replica;\n\n`;

sql += `-- =============================================\n`;
sql += `-- PASSO 1: DELETAR REGISTROS ÓRFÃOS (empresa_id NULL)\n`;
sql += `-- =============================================\n\n`;

sql += `DELETE FROM clientes WHERE empresa_id IS NULL;\n`;
sql += `DELETE FROM produtos WHERE empresa_id IS NULL;\n`;
sql += `DELETE FROM ordens_servico WHERE empresa_id IS NULL;\n\n`;

sql += `-- =============================================\n`;
sql += `-- PASSO 2: DELETAR CLIENTES QUE NÃO ESTÃO NO BACKUP\n`;
sql += `-- (mantém apenas os ${clientes.length} clientes válidos)\n`;
sql += `-- =============================================\n\n`;

sql += `DELETE FROM clientes \n`;
sql += `WHERE empresa_id = '${EMPRESA_ID}'\n`;
sql += `  AND id NOT IN (\n`;
clienteIds.forEach((id, index) => {
  sql += `    '${id}'${index < clienteIds.length - 1 ? ',' : ''}\n`;
});
sql += `  );\n\n`;

sql += `-- =============================================\n`;
sql += `-- PASSO 3: DELETAR PRODUTOS QUE NÃO ESTÃO NO BACKUP\n`;
sql += `-- (mantém apenas os ${produtos.length} produtos válidos)\n`;
sql += `-- =============================================\n\n`;

sql += `DELETE FROM produtos \n`;
sql += `WHERE empresa_id = '${EMPRESA_ID}'\n`;
sql += `  AND id NOT IN (\n`;

// Dividir em chunks para não ficar muito grande
const produtoChunkSize = 100;
for (let i = 0; i < produtoIds.length; i += produtoChunkSize) {
  const chunk = produtoIds.slice(i, i + produtoChunkSize);
  chunk.forEach((id, index) => {
    const isLast = i + index === produtoIds.length - 1;
    sql += `    '${id}'${isLast ? '' : ','}\n`;
  });
}
sql += `  );\n\n`;

sql += `-- =============================================\n`;
sql += `-- PASSO 4: DELETAR ORDENS QUE NÃO ESTÃO NO BACKUP\n`;
sql += `-- (mantém apenas as ${ordens.length} ordens válidas)\n`;
sql += `-- =============================================\n\n`;

sql += `DELETE FROM ordens_servico \n`;
sql += `WHERE empresa_id = '${EMPRESA_ID}'\n`;
sql += `  AND id NOT IN (\n`;
ordemIds.forEach((id, index) => {
  sql += `    '${id}'${index < ordemIds.length - 1 ? ',' : ''}\n`;
});
sql += `  );\n\n`;

sql += `SET session_replication_role = DEFAULT;\n\n`;

sql += `-- =============================================\n`;
sql += `-- VERIFICAÇÃO APÓS LIMPEZA\n`;
sql += `-- =============================================\n\n`;

sql += `SELECT \n`;
sql += `  'Após limpeza' as momento,\n`;
sql += `  'clientes' as tabela,\n`;
sql += `  COUNT(*) as total,\n`;
sql += `  COUNT(CASE WHEN empresa_id IS NULL THEN 1 END) as com_empresa_null,\n`;
sql += `  COUNT(CASE WHEN empresa_id = '${EMPRESA_ID}' THEN 1 END) as da_empresa\n`;
sql += `FROM clientes\n`;
sql += `UNION ALL\n`;
sql += `SELECT 'Após limpeza', 'produtos', COUNT(*), COUNT(CASE WHEN empresa_id IS NULL THEN 1 END), COUNT(CASE WHEN empresa_id = '${EMPRESA_ID}' THEN 1 END)\n`;
sql += `FROM produtos\n`;
sql += `UNION ALL\n`;
sql += `SELECT 'Após limpeza', 'ordens_servico', COUNT(*), COUNT(CASE WHEN empresa_id IS NULL THEN 1 END), COUNT(CASE WHEN empresa_id = '${EMPRESA_ID}' THEN 1 END)\n`;
sql += `FROM ordens_servico;\n\n`;

sql += `-- =============================================\n`;
sql += `-- PRÓXIMO PASSO:\n`;
sql += `-- Execute o arquivo: atualizar-com-limpeza.sql\n`;
sql += `-- =============================================\n`;

// Salvar arquivo
const outputPath = path.join(__dirname, '1-LIMPAR-PRIMEIRO.sql');
fs.writeFileSync(outputPath, sql, 'utf8');

console.log(`✅ Arquivo de limpeza gerado!\n`);
console.log(`📁 Local: ${outputPath}`);
console.log(`\n🔧 Este SQL vai:`);
console.log(`   1️⃣ Deletar todos com empresa_id NULL`);
console.log(`   2️⃣ Deletar clientes que NÃO estão no backup (${clientes.length} válidos)`);
console.log(`   3️⃣ Deletar produtos que NÃO estão no backup (${produtos.length} válidos)`);
console.log(`   4️⃣ Deletar ordens que NÃO estão no backup (${ordens.length} válidas)`);
console.log(`\n📋 ORDEM DE EXECUÇÃO:`);
console.log(`   1º → Execute: 1-LIMPAR-PRIMEIRO.sql`);
console.log(`   2º → Execute: atualizar-com-limpeza.sql`);
console.log(`\n✅ Depois disso, não haverá mais duplicados!\n`);
