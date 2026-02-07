#!/usr/bin/env node
/**
 * GERADOR DE SQL PARA IMPORTAÇÃO MANUAL NO SUPABASE
 * 
 * Gera arquivo SQL com INSERT statements para importar dados do backup
 */

const fs = require('fs');
const path = require('path');

// Carregar backup
const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
const backup = JSON.parse(fs.readFileSync(backupPath, 'utf-8'));

// ID da empresa (ajustar conforme necessário)
const EMPRESA_ID = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

let sql = `-- =============================================
-- IMPORTAÇÃO DE DADOS DO BACKUP PARA SUPABASE
-- Gerado automaticamente em ${new Date().toLocaleString('pt-BR')}
-- =============================================

-- Desabilitar triggers temporariamente (opcional)
SET session_replication_role = replica;

`;

// Função para escapar strings SQL
function escapeSql(str) {
  if (str === null || str === undefined) return 'NULL';
  if (typeof str === 'number') return str;
  if (typeof str === 'boolean') return str;
  return `'${String(str).replace(/'/g, "''")}'`;
}

// Função para formatar data
function formatDate(date) {
  if (!date) return 'NOW()';
  return escapeSql(date);
}

// =============================================
// 1. CLIENTES
// =============================================
sql += `\n-- =============================================
-- CLIENTES (${backup.data.clients?.length || 0} registros)
-- =============================================\n\n`;

if (backup.data.clients && backup.data.clients.length > 0) {
  sql += `INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES\n`;

  const clientesSQL = backup.data.clients.map((cliente, index) => {
    const cpfDigits = cliente.cpf_cnpj ? String(cliente.cpf_cnpj).replace(/\D/g, '') : null;
    
    return `  (
    ${escapeSql(cliente.id || null)},
    ${escapeSql(EMPRESA_ID)},
    ${escapeSql(cliente.name || 'Cliente')},
    ${escapeSql(cliente.phone || '')},
    ${escapeSql(cliente.email || null)},
    ${escapeSql(cliente.cpf_cnpj || null)},
    ${escapeSql(cpfDigits)},
    ${escapeSql(cliente.address || null)},
    ${escapeSql(cliente.city || null)},
    ${escapeSql(cliente.state || null)},
    ${escapeSql(cliente.zip_code || null)},
    'Física',
    true,
    NULL,
    ${formatDate(cliente.created_at)},
    NOW()
  )${index < backup.data.clients.length - 1 ? ',' : ';'}`;
  });

  sql += clientesSQL.join('\n') + '\n\n';
}

// =============================================
// 2. PRODUTOS
// =============================================
sql += `\n-- =============================================
-- PRODUTOS (${backup.data.products?.length || 0} registros)
-- =============================================\n\n`;

if (backup.data.products && backup.data.products.length > 0) {
  // Dividir em lotes de 100 para evitar SQL muito grande
  const loteSize = 100;
  const totalLotes = Math.ceil(backup.data.products.length / loteSize);

  for (let lote = 0; lote < totalLotes; lote++) {
    const inicio = lote * loteSize;
    const fim = Math.min((lote + 1) * loteSize, backup.data.products.length);
    const produtosLote = backup.data.products.slice(inicio, fim);

    sql += `-- Lote ${lote + 1}/${totalLotes}\n`;
    sql += `INSERT INTO produtos (
  id, empresa_id, nome, preco, custo, estoque, estoque_minimo,
  unidade, codigo_barras, categoria_id, ativo, created_at, updated_at
) VALUES\n`;

    const produtosSQL = produtosLote.map((produto, index) => {
      return `  (
    ${escapeSql(produto.id || null)},
    ${escapeSql(EMPRESA_ID)},
    ${escapeSql(produto.name || 'Produto')},
    ${Number(produto.sale_price || produto.price || 0)},
    ${Number(produto.cost_price || 0)},
    ${Number(produto.current_stock || produto.stock || 0)},
    ${Number(produto.minimum_stock || 0)},
    ${escapeSql(produto.unit_measure || 'un')},
    ${escapeSql(produto.barcode || null)},
    ${escapeSql(produto.category_id || null)},
    ${produto.active !== false},
    ${formatDate(produto.created_at)},
    NOW()
  )${index < produtosLote.length - 1 ? ',' : ';'}`;
    });

    sql += produtosSQL.join('\n') + '\n\n';
  }
}

// =============================================
// 3. ORDENS DE SERVIÇO
// =============================================
sql += `\n-- =============================================
-- ORDENS DE SERVIÇO (${backup.data.service_orders?.length || 0} registros)
-- =============================================\n\n`;

if (backup.data.service_orders && backup.data.service_orders.length > 0) {
  sql += `INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, nome_cliente, equipamento, modelo,
  defeito_relatado, status, valor_total, valor_mao_obra,
  forma_pagamento, data_abertura, data_fechamento, observacoes,
  created_at, updated_at
) VALUES\n`;

  const ordensSQL = backup.data.service_orders.map((ordem, index) => {
    return `  (
    ${escapeSql(ordem.id || null)},
    ${escapeSql(EMPRESA_ID)},
    ${escapeSql(ordem.client_id || null)},
    ${escapeSql(ordem.client_name || null)},
    ${escapeSql(ordem.equipment || ordem.device_name || 'Equipamento')},
    ${escapeSql(ordem.device_model || null)},
    ${escapeSql(ordem.defect || 'Defeito')},
    ${escapeSql(ordem.status || 'Aguardando')},
    ${Number(ordem.total || ordem.total_amount || 0)},
    ${Number(ordem.labor_cost || 0)},
    ${escapeSql(ordem.payment_method || null)},
    ${escapeSql(ordem.opening_date || null)},
    ${escapeSql(ordem.closing_date || null)},
    ${escapeSql(ordem.observations || null)},
    ${formatDate(ordem.created_at)},
    NOW()
  )${index < backup.data.service_orders.length - 1 ? ',' : ';'}`;
  });

  sql += ordensSQL.join('\n') + '\n\n';
}

// Reabilitar triggers
sql += `\n-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- Atualizar sequences (se necessário)
SELECT setval('clientes_id_seq', (SELECT MAX(id)::bigint FROM clientes WHERE id ~ '^[0-9]+$'), true);
SELECT setval('produtos_id_seq', (SELECT MAX(id)::bigint FROM produtos WHERE id ~ '^[0-9]+$'), true);
SELECT setval('ordens_servico_id_seq', (SELECT MAX(id)::bigint FROM ordens_servico WHERE id ~ '^[0-9]+$'), true);

-- Verificar importação
SELECT 'clientes' as tabela, COUNT(*) as total FROM clientes WHERE empresa_id = '${EMPRESA_ID}'
UNION ALL
SELECT 'produtos', COUNT(*) FROM produtos WHERE empresa_id = '${EMPRESA_ID}'
UNION ALL
SELECT 'ordens_servico', COUNT(*) FROM ordens_servico WHERE empresa_id = '${EMPRESA_ID}';

-- =============================================
-- FIM DA IMPORTAÇÃO
-- =============================================
`;

// Salvar arquivo SQL
const outputPath = path.join(__dirname, 'importar-dados.sql');
fs.writeFileSync(outputPath, sql, 'utf-8');

console.log('✅ Arquivo SQL gerado com sucesso!');
console.log(`📁 Local: ${outputPath}`);
console.log(`\n📊 Estatísticas:`);
console.log(`   - Clientes: ${backup.data.clients?.length || 0}`);
console.log(`   - Produtos: ${backup.data.products?.length || 0}`);
console.log(`   - Ordens de Serviço: ${backup.data.service_orders?.length || 0}`);
console.log(`\n📝 Como usar:`);
console.log(`   1. Abra o Supabase SQL Editor`);
console.log(`   2. Cole o conteúdo de importar-dados.sql`);
console.log(`   3. Execute o script`);
console.log(`   4. Verifique os dados importados`);
