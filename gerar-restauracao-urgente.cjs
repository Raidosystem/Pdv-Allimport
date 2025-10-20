const fs = require('fs');
const path = require('path');

console.log('🚨 RESTAURAÇÃO DE EMERGÊNCIA DO BACKUP\n');

// Ler o backup
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backup = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

const clientes = backup.data.clients || [];

console.log(`📊 Clientes no backup: ${clientes.length}\n`);

const EMPRESA_ID = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

function escapeSql(str) {
  if (str === null || str === undefined) return 'NULL';
  return `'${String(str).replace(/'/g, "''")}'`;
}

function formatDate(date) {
  if (!date) return 'NOW()';
  return `'${date}'`;
}

let sql = '';

sql += `-- =============================================\n`;
sql += `-- RESTAURAÇÃO COMPLETA DE CLIENTES\n`;
sql += `-- ${clientes.length} clientes do backup\n`;
sql += `-- Gerado em ${new Date().toLocaleString('pt-BR')}\n`;
sql += `-- =============================================\n\n`;

sql += `SET session_replication_role = replica;\n\n`;

clientes.forEach((client, index) => {
  const telefone = client.phone || client.telefone || '';
  const cpfCnpj = client.cpf_cnpj || '';
  const cpfDigits = cpfCnpj.replace(/\D/g, '');
  
  sql += `-- ${index + 1}/${clientes.length}: ${client.name}\n`;
  sql += `INSERT INTO clientes (\n`;
  sql += `  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,\n`;
  sql += `  endereco, cidade, estado, cep, tipo, ativo, observacoes,\n`;
  sql += `  created_at, updated_at\n`;
  sql += `) VALUES (\n`;
  sql += `  ${escapeSql(client.id)},\n`;
  sql += `  ${escapeSql(EMPRESA_ID)},\n`;
  sql += `  ${escapeSql(client.name)},\n`;
  sql += `  ${escapeSql(telefone)},\n`;
  sql += `  ${escapeSql(client.email)},\n`;
  sql += `  ${escapeSql(cpfCnpj)},\n`;
  sql += `  ${escapeSql(cpfDigits)},\n`;
  sql += `  ${escapeSql(client.address)},\n`;
  sql += `  ${escapeSql(client.city)},\n`;
  sql += `  ${escapeSql(client.state)},\n`;
  sql += `  ${escapeSql(client.zip_code)},\n`;
  sql += `  ${escapeSql(client.type || 'Física')},\n`;
  sql += `  ${client.active !== false ? 'true' : 'false'},\n`;
  sql += `  ${escapeSql(client.notes)},\n`;
  sql += `  ${formatDate(client.created_at)},\n`;
  sql += `  NOW()\n`;
  sql += `);\n\n`;
  
  if ((index + 1) % 20 === 0) {
    console.log(`   ✓ Processados ${index + 1}/${clientes.length} clientes...`);
  }
});

sql += `SET session_replication_role = DEFAULT;\n\n`;

sql += `-- Verificar restauração\n`;
sql += `SELECT \n`;
sql += `  'Após restauração' as momento,\n`;
sql += `  COUNT(*) as total_clientes,\n`;
sql += `  COUNT(CASE WHEN telefone IS NOT NULL AND telefone != '' THEN 1 END) as com_telefone,\n`;
sql += `  COUNT(CASE WHEN cpf_cnpj IS NOT NULL AND cpf_cnpj != '' THEN 1 END) as com_cpf\n`;
sql += `FROM clientes\n`;
sql += `WHERE empresa_id = '${EMPRESA_ID}';\n`;

const outputPath = path.join(__dirname, 'RESTAURAR-CLIENTES-URGENTE.sql');
fs.writeFileSync(outputPath, sql, 'utf8');

console.log(`\n✅ SQL de restauração gerado!\n`);
console.log(`📁 Arquivo: RESTAURAR-CLIENTES-URGENTE.sql`);
console.log(`📊 Clientes: ${clientes.length}`);
console.log(`\n🚨 EXECUTE IMEDIATAMENTE NO SUPABASE!\n`);
console.log(`🔗 https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/editor\n`);
