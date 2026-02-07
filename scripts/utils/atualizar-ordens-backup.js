/**
 * Script para ATUALIZAR ordens existentes com dados completos do backup
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function atualizarOrdensComBackup() {
  console.log('🔄 Carregando backup JSON...\n');

  const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
  const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

  const ordens = backupData.data.service_orders || [];

  console.log(`📊 Backup contém: ${ordens.length} ordens de serviço`);

  // Criar SQL para atualizar ordens
  let sql = [];
  
  sql.push('-- ============================================');
  sql.push('-- ATUALIZAR ORDENS COM DADOS DO BACKUP');
  sql.push(`-- Total: ${ordens.length} ordens`);
  sql.push('-- Campos: data_entrega, garantia_dias, observacoes');
  sql.push('-- ============================================\n');

  // Gerar UPDATE para cada ordem
  ordens.forEach((ordem, index) => {
    const id = ordem.id;
    const dataEntrega = ordem.closing_date || null; // closing_date = data_entrega
    const garantiaDias = ordem.warranty_days || 90;
    const observacoes = ordem.observations || '';
    const totalAmount = ordem.total_amount || 0;
    
    sql.push(`-- Ordem ${index + 1}/${ordens.length}: ${ordem.client_name || 'Sem nome'}`);
    sql.push(`UPDATE ordens_servico SET`);
    sql.push(`  data_entrega = ${esc(dataEntrega)},`);
    sql.push(`  garantia_dias = ${garantiaDias},`);
    sql.push(`  observacoes = ${esc(observacoes)},`);
    sql.push(`  valor_final = ${totalAmount}`);
    sql.push(`WHERE id = '${id}';`);
    sql.push('');
  });

  sql.push('\n-- VERIFICAR RESULTADO');
  sql.push('SELECT');
  sql.push('  COUNT(*) as total,');
  sql.push('  COUNT(data_entrega) as tem_data_entrega,');
  sql.push('  COUNT(garantia_dias) as tem_garantia_dias,');
  sql.push('  COUNT(observacoes) as tem_observacoes');
  sql.push('FROM ordens_servico;');

  // Salvar
  const sqlPath = path.join(__dirname, 'ATUALIZAR_ORDENS_BACKUP.sql');
  fs.writeFileSync(sqlPath, sql.join('\n'), 'utf8');

  console.log(`\n✅ SQL gerado: ${sqlPath}`);
  console.log(`\n🚀 Execute este arquivo no Supabase!`);

  // Análise
  console.log('\n📊 ANÁLISE:');
  const comDataEntrega = ordens.filter(o => o.closing_date).length;
  const comGarantia = ordens.filter(o => o.warranty_days && o.warranty_days > 0).length;
  const comObservacoes = ordens.filter(o => o.observations && o.observations.trim()).length;
  
  console.log(`   - ${comDataEntrega} ordens têm data_entrega (closing_date)`);
  console.log(`   - ${comGarantia} ordens têm garantia_dias`);
  console.log(`   - ${comObservacoes} ordens têm observações`);
}

function esc(valor) {
  if (!valor || valor === '' || valor === null || valor === undefined) return 'NULL';
  if (typeof valor === 'string') {
    // Escapar aspas simples E remover quebras de linha
    const limpo = valor.replace(/'/g, "''").replace(/\n/g, ' ').replace(/\r/g, '');
    return `'${limpo}'`;
  }
  return `'${String(valor).replace(/'/g, "''")}'`;
}

atualizarOrdensComBackup().catch(console.error);
