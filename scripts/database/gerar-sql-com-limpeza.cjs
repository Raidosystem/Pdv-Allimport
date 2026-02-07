const fs = require('fs');
const path = require('path');

console.log('🔄 Gerando SQL com UPSERT APRIMORADO...\n');

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

// Empresa ID
const EMPRESA_ID = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

// Função para escapar strings SQL
function escapeSql(str) {
  if (str === null || str === undefined) return 'NULL';
  return `'${String(str).replace(/'/g, "''")}'`;
}

// Função para formatar data
function formatDate(date) {
  if (!date) return 'NOW()';
  return `'${date}'`;
}

let sql = '';

// Cabeçalho
sql += `-- =============================================\n`;
sql += `-- ATUALIZAÇÃO COMPLETA DE DADOS (UPSERT)\n`;
sql += `-- Gerado automaticamente em ${new Date().toLocaleString('pt-BR')}\n`;
sql += `-- Trata conflitos de ID e CPF duplicados\n`;
sql += `-- =============================================\n\n`;

sql += `-- Desabilitar triggers temporariamente\n`;
sql += `SET session_replication_role = replica;\n\n`;

// =============================================
// CLIENTES (com UPSERT duplo - ID e CPF)
// =============================================
sql += `-- =============================================\n`;
sql += `-- CLIENTES (${clientes.length} registros) - UPSERT\n`;
sql += `-- Trata conflitos de ID e CPF_DIGITS\n`;
sql += `-- =============================================\n\n`;

clientes.forEach((client, index) => {
  const telefone = client.phone || client.telefone || '';
  const cpfCnpj = client.cpf_cnpj || '';
  const cpfDigits = cpfCnpj.replace(/\D/g, '');
  
  sql += `-- Cliente: ${client.name}\n`;
  
  // Se tem CPF, deletar possíveis duplicados primeiro
  if (cpfDigits) {
    sql += `-- Deletar duplicados por CPF (se existirem)\n`;
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
  sql += `  ativo = EXCLUDED.ativo,\n`;
  sql += `  updated_at = NOW();\n\n`;
  
  if ((index + 1) % 20 === 0) {
    console.log(`   ✓ Processados ${index + 1}/${clientes.length} clientes...`);
  }
});

console.log(`   ✅ ${clientes.length} clientes processados\n`);

// =============================================
// PRODUTOS (com UPSERT)
// =============================================
sql += `\n-- =============================================\n`;
sql += `-- PRODUTOS (${produtos.length} registros) - UPSERT\n`;
sql += `-- =============================================\n\n`;

produtos.forEach((produto, index) => {
  sql += `INSERT INTO produtos (\n`;
  sql += `  id, empresa_id, nome, codigo, preco, custo, estoque,\n`;
  sql += `  estoque_minimo, categoria, ativo, observacoes,\n`;
  sql += `  created_at, updated_at\n`;
  sql += `) VALUES (\n`;
  sql += `  ${escapeSql(produto.id)},\n`;
  sql += `  ${escapeSql(EMPRESA_ID)},\n`;
  sql += `  ${escapeSql(produto.name)},\n`;
  sql += `  ${escapeSql(produto.code || produto.codigo)},\n`;
  sql += `  ${produto.price || 0},\n`;
  sql += `  ${produto.cost || produto.custo || 0},\n`;
  sql += `  ${produto.stock || produto.estoque || 0},\n`;
  sql += `  ${produto.min_stock || produto.estoque_minimo || 0},\n`;
  sql += `  ${escapeSql(produto.category || produto.categoria)},\n`;
  sql += `  ${produto.active !== false ? 'true' : 'false'},\n`;
  sql += `  ${escapeSql(produto.notes || produto.observacoes)},\n`;
  sql += `  ${formatDate(produto.created_at)},\n`;
  sql += `  NOW()\n`;
  sql += `) ON CONFLICT (id) DO UPDATE SET\n`;
  sql += `  nome = EXCLUDED.nome,\n`;
  sql += `  codigo = EXCLUDED.codigo,\n`;
  sql += `  preco = EXCLUDED.preco,\n`;
  sql += `  custo = EXCLUDED.custo,\n`;
  sql += `  estoque = EXCLUDED.estoque,\n`;
  sql += `  estoque_minimo = EXCLUDED.estoque_minimo,\n`;
  sql += `  categoria = EXCLUDED.categoria,\n`;
  sql += `  ativo = EXCLUDED.ativo,\n`;
  sql += `  updated_at = NOW();\n\n`;
  
  if ((index + 1) % 100 === 0) {
    console.log(`   ✓ Processados ${index + 1}/${produtos.length} produtos...`);
  }
});

console.log(`   ✅ ${produtos.length} produtos processados\n`);

// =============================================
// ORDENS DE SERVIÇO (com UPSERT)
// =============================================
sql += `\n-- =============================================\n`;
sql += `-- ORDENS DE SERVIÇO (${ordens.length} registros) - UPSERT\n`;
sql += `-- =============================================\n\n`;

ordens.forEach((ordem, index) => {
  sql += `INSERT INTO ordens_servico (\n`;
  sql += `  id, empresa_id, cliente_id, equipamento, marca, modelo,\n`;
  sql += `  numero_serie, defeito_relatado, observacoes_tecnico,\n`;
  sql += `  status, valor_servico, valor_pecas, data_entrada,\n`;
  sql += `  data_prevista, laudo_tecnico, created_at, updated_at\n`;
  sql += `) VALUES (\n`;
  sql += `  ${escapeSql(ordem.id)},\n`;
  sql += `  ${escapeSql(EMPRESA_ID)},\n`;
  sql += `  ${escapeSql(ordem.client_id || ordem.cliente_id)},\n`;
  sql += `  ${escapeSql(ordem.equipment || ordem.equipamento)},\n`;
  sql += `  ${escapeSql(ordem.brand || ordem.marca)},\n`;
  sql += `  ${escapeSql(ordem.model || ordem.modelo)},\n`;
  sql += `  ${escapeSql(ordem.serial_number || ordem.numero_serie)},\n`;
  sql += `  ${escapeSql(ordem.reported_issue || ordem.defeito_relatado)},\n`;
  sql += `  ${escapeSql(ordem.tech_notes || ordem.observacoes_tecnico)},\n`;
  sql += `  ${escapeSql(ordem.status)},\n`;
  sql += `  ${ordem.service_value || ordem.valor_servico || 0},\n`;
  sql += `  ${ordem.parts_value || ordem.valor_pecas || 0},\n`;
  sql += `  ${escapeSql(ordem.entry_date || ordem.data_entrada)},\n`;
  sql += `  ${escapeSql(ordem.expected_date || ordem.data_prevista)},\n`;
  sql += `  ${escapeSql(ordem.tech_report || ordem.laudo_tecnico)},\n`;
  sql += `  ${formatDate(ordem.created_at)},\n`;
  sql += `  NOW()\n`;
  sql += `) ON CONFLICT (id) DO UPDATE SET\n`;
  sql += `  status = EXCLUDED.status,\n`;
  sql += `  valor_servico = EXCLUDED.valor_servico,\n`;
  sql += `  valor_pecas = EXCLUDED.valor_pecas,\n`;
  sql += `  observacoes_tecnico = EXCLUDED.observacoes_tecnico,\n`;
  sql += `  laudo_tecnico = EXCLUDED.laudo_tecnico,\n`;
  sql += `  data_prevista = EXCLUDED.data_prevista,\n`;
  sql += `  updated_at = NOW();\n\n`;
  
  if ((index + 1) % 20 === 0) {
    console.log(`   ✓ Processados ${index + 1}/${ordens.length} ordens...`);
  }
});

console.log(`   ✅ ${ordens.length} ordens processadas\n`);

// Rodapé
sql += `\n-- Reabilitar triggers\n`;
sql += `SET session_replication_role = DEFAULT;\n\n`;

sql += `-- Verificar dados atualizados\n`;
sql += `SELECT 'clientes' as tabela, COUNT(*) as total, \n`;
sql += `       COUNT(CASE WHEN telefone IS NOT NULL AND telefone != '' THEN 1 END) as com_telefone,\n`;
sql += `       COUNT(CASE WHEN cpf_cnpj IS NOT NULL AND cpf_cnpj != '' THEN 1 END) as com_cpf\n`;
sql += `FROM clientes WHERE empresa_id = '${EMPRESA_ID}'\n`;
sql += `UNION ALL\n`;
sql += `SELECT 'produtos', COUNT(*), 0, 0 FROM produtos WHERE empresa_id = '${EMPRESA_ID}'\n`;
sql += `UNION ALL\n`;
sql += `SELECT 'ordens_servico', COUNT(*), 0, 0 FROM ordens_servico WHERE empresa_id = '${EMPRESA_ID}';\n\n`;

sql += `-- =============================================\n`;
sql += `-- FIM DA ATUALIZAÇÃO\n`;
sql += `-- =============================================\n`;

// Salvar arquivo
const outputPath = path.join(__dirname, 'atualizar-com-limpeza.sql');
fs.writeFileSync(outputPath, sql, 'utf8');

console.log(`✅ Arquivo SQL gerado com sucesso!\n`);
console.log(`📁 Local: ${outputPath}`);
console.log(`📊 Estatísticas:`);
console.log(`   - Clientes: ${clientes.length}`);
console.log(`   - Produtos: ${produtos.length}`);
console.log(`   - Ordens de Serviço: ${ordens.length}\n`);
console.log(`🔧 Este arquivo:`);
console.log(`   → Deleta duplicados por CPF antes de inserir`);
console.log(`   → Usa UPSERT (ON CONFLICT) para conflitos de ID`);
console.log(`   → Garante dados únicos por empresa\n`);
console.log(`📋 Para executar:`);
console.log(`   1. Abra: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw`);
console.log(`   2. Vá em SQL Editor`);
console.log(`   3. Cole o conteúdo de atualizar-com-limpeza.sql`);
console.log(`   4. Execute\n`);
