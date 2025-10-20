const fs = require('fs');
const path = require('path');

console.log('🔄 Gerando SQL de RESTAURAÇÃO com UPSERT\n');

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
sql += `-- RESTAURAÇÃO COMPLETA COM UPSERT\n`;
sql += `-- ${clientes.length} clientes do backup\n`;
sql += `-- Gerado em ${new Date().toLocaleString('pt-BR')}\n`;
sql += `-- =============================================\n\n`;

sql += `SET session_replication_role = replica;\n\n`;

// PASSO 1: Deletar clientes da empresa que não estão no backup
sql += `-- PASSO 1: Limpar clientes órfãos ou duplicados\n`;
sql += `-- Deleta clientes que não estão na lista de IDs do backup\n\n`;

const clienteIds = clientes.map(c => `'${c.id}'`).join(',\n    ');
sql += `DELETE FROM clientes\n`;
sql += `WHERE empresa_id = '${EMPRESA_ID}'\n`;
sql += `  AND id NOT IN (\n    ${clienteIds}\n  );\n\n`;

sql += `-- Deletar clientes com empresa_id NULL\n`;
sql += `DELETE FROM clientes WHERE empresa_id IS NULL;\n\n`;

// PASSO 2: Inserir/Atualizar cada cliente
sql += `-- PASSO 2: Inserir ou atualizar clientes\n\n`;

clientes.forEach((client, index) => {
  const telefone = client.phone || client.telefone || '';
  const cpfCnpj = client.cpf_cnpj || '';
  const cpfDigits = cpfCnpj.replace(/\D/g, '');
  
  sql += `-- ${index + 1}/${clientes.length}: ${client.name}\n`;
  
  // Se tem CPF, deletar possíveis duplicados antes
  if (cpfDigits) {
    sql += `DELETE FROM clientes \n`;
    sql += `WHERE cpf_digits = ${escapeSql(cpfDigits)}\n`;
    sql += `  AND empresa_id = ${escapeSql(EMPRESA_ID)}\n`;
    sql += `  AND id != ${escapeSql(client.id)};\n\n`;
  }
  
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
  sql += `) ON CONFLICT (id) DO UPDATE SET\n`;
  sql += `  nome = EXCLUDED.nome,\n`;
  sql += `  telefone = EXCLUDED.telefone,\n`;
  sql += `  email = EXCLUDED.email,\n`;
  sql += `  cpf_cnpj = EXCLUDED.cpf_cnpj,\n`;
  sql += `  cpf_digits = EXCLUDED.cpf_digits,\n`;
  sql += `  endereco = EXCLUDED.endereco,\n`;
  sql += `  cidade = EXCLUDED.cidade,\n`;
  sql += `  estado = EXCLUDED.estado,\n`;
  sql += `  cep = EXCLUDED.cep,\n`;
  sql += `  tipo = EXCLUDED.tipo,\n`;
  sql += `  ativo = EXCLUDED.ativo,\n`;
  sql += `  observacoes = EXCLUDED.observacoes,\n`;
  sql += `  updated_at = NOW();\n\n`;
  
  if ((index + 1) % 20 === 0) {
    console.log(`   ✓ Processados ${index + 1}/${clientes.length} clientes...`);
  }
});

sql += `SET session_replication_role = DEFAULT;\n\n`;

sql += `-- VERIFICAÇÃO FINAL\n`;
sql += `SELECT \n`;
sql += `  'Após restauração' as momento,\n`;
sql += `  COUNT(*) as total_clientes,\n`;
sql += `  COUNT(CASE WHEN telefone IS NOT NULL AND telefone != '' THEN 1 END) as com_telefone,\n`;
sql += `  COUNT(CASE WHEN cpf_cnpj IS NOT NULL AND cpf_cnpj != '' THEN 1 END) as com_cpf,\n`;
sql += `  COUNT(CASE WHEN empresa_id IS NULL THEN 1 END) as sem_empresa\n`;
sql += `FROM clientes\n`;
sql += `WHERE empresa_id = '${EMPRESA_ID}';\n\n`;

sql += `-- =============================================\n`;
sql += `-- FIM DA RESTAURAÇÃO\n`;
sql += `-- =============================================\n`;

const outputPath = path.join(__dirname, 'RESTAURAR-FINAL.sql');
fs.writeFileSync(outputPath, sql, 'utf8');

console.log(`\n✅ SQL de restauração DEFINITIVO gerado!\n`);
console.log(`📁 Arquivo: RESTAURAR-FINAL.sql`);
console.log(`📊 Clientes: ${clientes.length}`);
console.log(`\n🔧 Este SQL:`);
console.log(`   1️⃣ Deleta clientes que NÃO estão no backup`);
console.log(`   2️⃣ Deleta clientes com empresa_id NULL`);
console.log(`   3️⃣ Para cada cliente:`);
console.log(`      → Deleta duplicados por CPF`);
console.log(`      → Insere ou atualiza (UPSERT)`);
console.log(`\n🚨 EXECUTE NO SUPABASE:\n`);
console.log(`🔗 https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/editor\n`);
