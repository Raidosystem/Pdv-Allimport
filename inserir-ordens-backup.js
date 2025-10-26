/**
 * Script para inserir ordens do backup JSON manualmente
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function inserirOrdensManualmente() {
  console.log('🔄 Carregando backup JSON...\n');

  const backupPath = path.join(__dirname, 'public', 'backup-allimport.json');
  const backupData = JSON.parse(fs.readFileSync(backupPath, 'utf8'));

  const ordens = backupData.data.service_orders || [];
  const clientes = backupData.data.clients || [];

  console.log(`📊 Backup contém:`);
  console.log(`   - ${clientes.length} clientes`);
  console.log(`   - ${ordens.length} ordens de serviço`);

  // Criar SQL para inserir ordens
  let sql = [];
  
  sql.push('-- ============================================');
  sql.push('-- INSERIR ORDENS DO BACKUP JSON');
  sql.push(`-- Total: ${ordens.length} ordens`);
  sql.push('-- ============================================\n');

  sql.push('-- PASSO 1: Inserir ordens');
  sql.push('INSERT INTO ordens_servico (');
  sql.push('  id, cliente_id, usuario_id, numero_os, descricao_problema,');
  sql.push('  marca, modelo, tipo, status, data_entrada, data_finalizacao,');
  sql.push('  valor_final, garantia_dias, observacoes, created_at, updated_at');
  sql.push(')');
  sql.push('VALUES');

  const values = ordens.map((ordem, index) => {
    const isLast = index === ordens.length - 1;
    // Gerar número de OS se não existir
    const numeroOs = ordem.service_order_number || `OS-${ordem.opening_date || '2025'}-${String(index + 1).padStart(3, '0')}`;
    const marca = (ordem.device_name || '').split(' ')[0] || 'N/A';
    const modelo = ordem.device_model || 'N/A';
    const tipo = 'Celular'; // Assumir celular por padrão
    
    return `  ('${ordem.id}', ${esc(ordem.client_id)}, ${esc(ordem.user_id)}, ${esc(numeroOs)}, ${esc(ordem.defect)}, ${esc(marca)}, ${esc(modelo)}, ${esc(tipo)}, ${esc(ordem.status)}, ${esc(ordem.opening_date)}, ${esc(ordem.closing_date)}, ${ordem.total_amount || 0}, ${ordem.warranty_days || 90}, ${esc(ordem.observations)}, ${esc(ordem.created_at)}, ${esc(ordem.updated_at)})${isLast ? ';' : ','}`;
  });

  sql.push(...values);

  sql.push('\n-- PASSO 2: Verificar resultado');
  sql.push('SELECT COUNT(*) as total_ordens_inseridas FROM ordens_servico;');

  sql.push('\n-- PASSO 3: Verificar órfãos');
  sql.push('SELECT COUNT(*) as orfaos');
  sql.push('FROM ordens_servico os');
  sql.push('LEFT JOIN clientes c ON os.cliente_id = c.id');
  sql.push('WHERE c.id IS NULL;');

  sql.push('\n-- PASSO 4: Ver clientes com mais ordens');
  sql.push('SELECT');
  sql.push('  c.nome,');
  sql.push('  c.cpf_cnpj,');
  sql.push('  COUNT(os.id) as total_ordens');
  sql.push('FROM clientes c');
  sql.push('INNER JOIN ordens_servico os ON os.cliente_id = c.id');
  sql.push('GROUP BY c.id, c.nome, c.cpf_cnpj');
  sql.push('ORDER BY total_ordens DESC');
  sql.push('LIMIT 10;');

  // Salvar
  const sqlPath = path.join(__dirname, 'INSERIR_ORDENS_BACKUP_JSON.sql');
  fs.writeFileSync(sqlPath, sql.join('\n'), 'utf8');

  console.log(`\n✅ SQL gerado: ${sqlPath}`);
  console.log(`\n🚀 Execute este arquivo no Supabase!`);

  // Análise
  console.log('\n📊 ANÁLISE DAS ORDENS:');
  const ordensComCliente = ordens.filter(o => o.client_id);
  console.log(`   - ${ordensComCliente.length} ordens têm client_id`);
  
  const clientIdsUnicos = [...new Set(ordens.map(o => o.client_id).filter(Boolean))];
  console.log(`   - ${clientIdsUnicos.length} client_id únicos`);

  // Ver alguns exemplos
  console.log('\n📋 Primeiras 5 ordens:');
  ordens.slice(0, 5).forEach((o, i) => {
    const numeroOs = o.service_order_number || `OS-${o.opening_date || '2025'}-${String(i + 1).padStart(3, '0')}`;
    console.log(`${i + 1}. ${numeroOs} - ${o.device_name} ${o.device_model} (Cliente: ${o.client_name})`);
  });
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

inserirOrdensManualmente().catch(console.error);
