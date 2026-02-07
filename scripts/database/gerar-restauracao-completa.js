/**
 * Script para gerar SQL de restauração COMPLETA do backup
 * Restaura clientes E ordens de serviço com relacionamentos corretos
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function gerarRestauracaoCompleta() {
  console.log('🔄 Gerando SQL de restauração completa...\n');

  // 1. Ler backup
  const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
  const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

  const clientes = backupData.data.clients || [];
  
  // 2. Procurar ordens de serviço no backup
  let ordens = [];
  
  // Verificar possíveis nomes de chaves para ordens
  const possiveisChaves = [
    'service_orders', 
    'ordens_servico', 
    'orders', 
    'serviceOrders',
    'ordem_servico'
  ];
  
  for (const chave of possiveisChaves) {
    if (backupData.data[chave]) {
      ordens = backupData.data[chave];
      console.log(`✅ Encontradas ${ordens.length} ordens em: "${chave}"`);
      break;
    }
  }

  if (ordens.length === 0) {
    console.log('⚠️ Nenhuma ordem encontrada no backup');
    console.log('📋 Chaves disponíveis no backup:');
    Object.keys(backupData.data).forEach(key => {
      const items = Array.isArray(backupData.data[key]) ? backupData.data[key].length : 'objeto';
      console.log(`   - ${key}: ${items}`);
    });
  }

  console.log(`\n📊 Resumo:`);
  console.log(`   Clientes: ${clientes.length}`);
  console.log(`   Ordens: ${ordens.length}`);

  // 3. Gerar SQL
  let sql = [];
  
  sql.push('-- ============================================');
  sql.push('-- RESTAURAÇÃO COMPLETA DO BACKUP');
  sql.push(`-- Data do backup: ${backupData.metadata.created_at}`);
  sql.push(`-- Clientes: ${clientes.length}`);
  sql.push(`-- Ordens: ${ordens.length}`);
  sql.push('-- ============================================\n');

  // 3.1 PRIMEIRO: Inserir clientes (para satisfazer foreign keys)
  sql.push('-- PASSO 1: Inserir clientes do backup JSON');
  sql.push('INSERT INTO clientes (id, user_id, nome, cpf_cnpj, telefone, email, endereco, cidade, estado, cep, created_at, updated_at)');
  sql.push('VALUES');

  const valoresClientes = clientes.map((c, i) => {
    const ultimo = i === clientes.length - 1;
    return `  ('${c.id}', '${c.user_id}', ${esc(c.name)}, ${esc(c.cpf_cnpj)}, ${esc(c.phone)}, ${esc(c.email)}, ${esc(c.address)}, ${esc(c.city)}, ${esc(c.state)}, ${esc(c.zip_code)}, '${c.created_at}', '${c.updated_at}')${ultimo ? ';' : ','}`;
  });

  sql.push(...valoresClientes);

  sql.push('\n-- PASSO 2: Restaurar ordens (do backup de segurança)');
  sql.push('INSERT INTO ordens_servico');
  sql.push('SELECT * FROM ordens_backup_seguranca_completo');
  sql.push('ON CONFLICT (id) DO NOTHING;\n');

  sql.push('\n-- Verificar resultado');
  sql.push('SELECT');
  sql.push("  'Clientes' as tabela,");
  sql.push('  COUNT(*) as total');
  sql.push('FROM clientes');
  sql.push('UNION ALL');
  sql.push('SELECT');
  sql.push("  'Ordens' as tabela,");
  sql.push('  COUNT(*) as total');
  sql.push('FROM ordens_servico;');

  sql.push('\n-- Verificar órfãos');
  sql.push('SELECT COUNT(*) as orfaos_restantes');
  sql.push('FROM ordens_servico os');
  sql.push('LEFT JOIN clientes c ON os.cliente_id = c.id');
  sql.push('WHERE c.id IS NULL;');

  sql.push('\n-- Testar EDVANIA');
  sql.push('SELECT');
  sql.push('  os.numero_os,');
  sql.push('  os.marca,');
  sql.push('  os.modelo,');
  sql.push('  os.data_entrada,');
  sql.push('  c.nome');
  sql.push('FROM ordens_servico os');
  sql.push('INNER JOIN clientes c ON os.cliente_id = c.id');
  sql.push("WHERE c.cpf_cnpj = '37511773885'");
  sql.push('ORDER BY os.data_entrada DESC;');

  // 4. Salvar
  const sqlPath = path.join(__dirname, 'RESTAURACAO_COMPLETA_FINAL.sql');
  fs.writeFileSync(sqlPath, sql.join('\n'), 'utf8');

  console.log(`\n✅ SQL gerado: ${sqlPath}`);
  console.log('\n🚀 EXECUTE ESTE ARQUIVO NO SUPABASE!');
}

function esc(valor) {
  if (!valor || valor === '') return 'NULL';
  return `'${String(valor).replace(/'/g, "''")}'`;
}

gerarRestauracaoCompleta().catch(console.error);
