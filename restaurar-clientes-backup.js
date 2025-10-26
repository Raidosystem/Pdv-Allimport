/**
 * Script para restaurar clientes do backup JSON
 * Extrai clientes do backup-allimport.json e gera SQL para restauração
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function restaurarClientes() {
  console.log('🔄 Iniciando restauração de clientes do backup...\n');

  // 1. Ler arquivo de backup
  const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
  
  if (!fs.existsSync(backupPath)) {
    console.error('❌ Arquivo de backup não encontrado:', backupPath);
    return;
  }

  console.log('✅ Arquivo de backup encontrado');
  const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

  // 2. Extrair clientes
  const clientes = backupData.data.clients || [];
  console.log(`\n📊 Total de clientes no backup: ${clientes.length}`);

  if (clientes.length === 0) {
    console.error('❌ Nenhum cliente encontrado no backup!');
    return;
  }

  // 3. Mostrar alguns exemplos
  console.log('\n📋 Primeiros 5 clientes do backup:');
  clientes.slice(0, 5).forEach((cliente, i) => {
    console.log(`${i + 1}. ${cliente.name} (CPF: ${cliente.cpf_cnpj}) - ID: ${cliente.id}`);
  });

  // 4. Buscar EDVANIA no backup
  const edvania = clientes.find(c => c.cpf_cnpj === '37511773885');
  if (edvania) {
    console.log('\n🎯 EDVANIA DA SILVA encontrada no backup:');
    console.log('   ID no backup:', edvania.id);
    console.log('   Nome:', edvania.name);
    console.log('   Telefone:', edvania.phone);
    console.log('   Data criação:', edvania.created_at);
  }

  // 5. Gerar SQL de INSERT para restauração
  console.log('\n📝 Gerando SQL de restauração...');
  
  let sqlStatements = [];
  sqlStatements.push('-- ============================================');
  sqlStatements.push('-- SQL PARA RESTAURAR CLIENTES DO BACKUP');
  sqlStatements.push('-- Backup de: ' + backupData.metadata.created_at);
  sqlStatements.push('-- Total de clientes: ' + clientes.length);
  sqlStatements.push('-- ============================================\n');
  
  sqlStatements.push('-- IMPORTANTE: Execute este comando ANTES de importar os clientes');
  sqlStatements.push('-- Salvar clientes atuais para não perder novos cadastros\n');
  sqlStatements.push('CREATE TABLE IF NOT EXISTS clientes_backup_atual AS SELECT * FROM clientes;\n');
  
  sqlStatements.push('-- Limpar tabela clientes (cuidado!)\n');
  sqlStatements.push('TRUNCATE TABLE clientes CASCADE;\n');
  
  sqlStatements.push('-- Restaurar clientes do backup\n');
  sqlStatements.push('INSERT INTO clientes (id, user_id, nome, cpf_cnpj, telefone, email, endereco, cidade, estado, cep, tipo, ativo, created_at, updated_at, criado_em, atualizado_em)');
  sqlStatements.push('VALUES');

  const values = clientes.map((cliente, index) => {
    const isLast = index === clientes.length - 1;
    // Determinar tipo baseado no CPF/CNPJ
    const tipo = (cliente.cpf_cnpj && cliente.cpf_cnpj.length > 11) ? 'juridica' : 'fisica';
    return `  ('${cliente.id}', ${escapeSql(cliente.user_id)}, ${escapeSql(cliente.name)}, ${escapeSql(cliente.cpf_cnpj)}, ${escapeSql(cliente.phone)}, ${escapeSql(cliente.email)}, ${escapeSql(cliente.address)}, ${escapeSql(cliente.city)}, ${escapeSql(cliente.state)}, ${escapeSql(cliente.zip_code)}, '${tipo}', true, ${escapeSql(cliente.created_at)}, ${escapeSql(cliente.updated_at)}, ${escapeSql(cliente.created_at)}, ${escapeSql(cliente.updated_at)})${isLast ? ';' : ','}`;
  });

  sqlStatements.push(...values);
  
  sqlStatements.push('\n-- Verificar resultado');
  sqlStatements.push('SELECT COUNT(*) as total_restaurado FROM clientes;');
  
  sqlStatements.push('\n-- Verificar ordens órfãs restantes');
  sqlStatements.push('SELECT COUNT(*) as orfaos_restantes');
  sqlStatements.push('FROM ordens_servico os');
  sqlStatements.push('LEFT JOIN clientes c ON os.cliente_id = c.id');
  sqlStatements.push('WHERE c.id IS NULL;');

  // 6. Salvar SQL em arquivo
  const sqlPath = path.join(__dirname, 'RESTAURAR_CLIENTES_SQL_GERADO.sql');
  fs.writeFileSync(sqlPath, sqlStatements.join('\n'), 'utf8');
  
  console.log('\n✅ SQL gerado com sucesso!');
  console.log('📄 Arquivo:', sqlPath);
  console.log('\n🚀 PRÓXIMOS PASSOS:');
  console.log('1. Abra o arquivo RESTAURAR_CLIENTES_SQL_GERADO.sql');
  console.log('2. Execute no Supabase SQL Editor');
  console.log('3. Verifique se as ordens órfãs foram resolvidas');
  console.log('4. Teste buscar equipamentos anteriores da EDVANIA');

  // 7. Análise adicional
  console.log('\n📊 ANÁLISE DO BACKUP:');
  console.log(`   Data do backup: ${backupData.metadata.created_at}`);
  console.log(`   Total de clientes: ${clientes.length}`);
  
  const clientesComCPF = clientes.filter(c => c.cpf_cnpj && c.cpf_cnpj.length > 0);
  console.log(`   Clientes com CPF: ${clientesComCPF.length}`);
  
  const clientesComTelefone = clientes.filter(c => c.phone && c.phone.length > 0);
  console.log(`   Clientes com telefone: ${clientesComTelefone.length}`);
  
  const clientesJunho = clientes.filter(c => c.created_at && c.created_at.startsWith('2025-06'));
  console.log(`   Clientes cadastrados em junho/2025: ${clientesJunho.length}`);
  
  const clientesJulho = clientes.filter(c => c.created_at && c.created_at.startsWith('2025-07'));
  console.log(`   Clientes cadastrados em julho/2025: ${clientesJulho.length}`);
}

function escapeSql(value) {
  if (value === null || value === undefined || value === '') return 'NULL';
  // Escapar aspas simples E remover quebras de linha
  const limpo = String(value).replace(/'/g, "''").replace(/\n/g, ' ').replace(/\r/g, '');
  return `'${limpo}'`;
}

// Executar
restaurarClientes().catch(console.error);
