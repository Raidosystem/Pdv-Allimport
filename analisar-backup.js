import fs from 'fs';

function analisarBackup(inputFile) {
  console.log(`📁 Analisando arquivo: ${inputFile}`);
  
  const conteudo = fs.readFileSync(inputFile, 'utf8');
  const data = JSON.parse(conteudo);
  
  console.log(`\n📊 Total de registros: ${data.data.length}`);
  console.log(`📝 Estrutura do backup: ${data.description || 'Não informado'}`);
  console.log(`📅 Data de exportação: ${data.exported_date || 'Não informado'}`);
  
  // Mostrar estrutura dos primeiros 3 registros
  console.log('\n🔍 ESTRUTURA DOS PRIMEIROS 3 REGISTROS:');
  console.log('=' .repeat(80));
  
  for (let i = 0; i < Math.min(3, data.data.length); i++) {
    const ordem = data.data[i];
    console.log(`\n📋 REGISTRO ${i + 1}:`);
    
    // Mostrar TODOS os campos disponíveis
    Object.entries(ordem).forEach(([chave, valor]) => {
      console.log(`  ${chave}: ${JSON.stringify(valor)}`);
    });
    
    console.log('-'.repeat(60));
  }
  
  // Analisar campos disponíveis
  console.log('\n📈 ANÁLISE DE CAMPOS DISPONÍVEIS:');
  console.log('=' .repeat(80));
  
  const campos = new Set();
  data.data.forEach(ordem => {
    Object.keys(ordem).forEach(chave => campos.add(chave));
  });
  
  console.log(`\n🏷️ Campos encontrados (${campos.size} total):`);
  Array.from(campos).sort().forEach(campo => {
    const exemplos = data.data
      .filter(ordem => ordem[campo] !== null && ordem[campo] !== '')
      .slice(0, 3)
      .map(ordem => ordem[campo]);
    
    console.log(`  ${campo}:`);
    if (exemplos.length > 0) {
      exemplos.forEach(exemplo => {
        console.log(`    └─ ${JSON.stringify(exemplo)}`);
      });
    } else {
      console.log(`    └─ (vazio em todos os registros)`);
    }
  });
  
  // Análise específica de datas
  console.log('\n📅 ANÁLISE ESPECÍFICA DE DATAS:');
  console.log('=' .repeat(80));
  
  const camposDatas = ['opening_date', 'closing_date', 'created_at', 'updated_at'];
  
  camposDatas.forEach(campo => {
    console.log(`\n📆 Campo: ${campo}`);
    
    const valores = data.data
      .filter(ordem => ordem[campo])
      .slice(0, 5)
      .map(ordem => ordem[campo]);
    
    if (valores.length > 0) {
      console.log('  Exemplos:');
      valores.forEach(valor => console.log(`    └─ ${valor}`));
    } else {
      console.log('  └─ Não encontrado ou vazio');
    }
  });
  
  // Análise de clientes
  console.log('\n👥 ANÁLISE DE CLIENTES:');
  console.log('=' .repeat(80));
  
  const clientes = new Set();
  data.data.forEach(ordem => {
    if (ordem.client_name) {
      clientes.add(ordem.client_name);
    }
  });
  
  console.log(`\n📊 Total de clientes únicos: ${clientes.size}`);
  console.log('\n👤 Primeiros 10 clientes:');
  Array.from(clientes).slice(0, 10).forEach(cliente => {
    console.log(`  └─ ${cliente}`);
  });
  
  // Análise de equipamentos
  console.log('\n🔧 ANÁLISE DE EQUIPAMENTOS:');
  console.log('=' .repeat(80));
  
  const equipamentos = {};
  data.data.forEach(ordem => {
    if (ordem.device_model) {
      equipamentos[ordem.device_model] = (equipamentos[ordem.device_model] || 0) + 1;
    }
  });
  
  console.log('\n📱 Top 10 equipamentos:');
  Object.entries(equipamentos)
    .sort(([,a], [,b]) => b - a)
    .slice(0, 10)
    .forEach(([modelo, count]) => {
      console.log(`  ${count}x ${modelo}`);
    });
  
  // Análise de status
  console.log('\n📊 ANÁLISE DE STATUS:');
  console.log('=' .repeat(80));
  
  const status = {};
  data.data.forEach(ordem => {
    if (ordem.status) {
      status[ordem.status] = (status[ordem.status] || 0) + 1;
    }
  });
  
  console.log('\n🏷️ Status encontrados:');
  Object.entries(status).forEach(([st, count]) => {
    console.log(`  ${count}x ${st}`);
  });
  
  // Análise de valores
  console.log('\n💰 ANÁLISE DE VALORES:');
  console.log('=' .repeat(80));
  
  const valores = data.data
    .map(ordem => parseFloat(ordem.total_amount) || 0)
    .filter(valor => valor > 0);
  
  if (valores.length > 0) {
    const soma = valores.reduce((a, b) => a + b, 0);
    const media = soma / valores.length;
    const maximo = Math.max(...valores);
    const minimo = Math.min(...valores);
    
    console.log(`  Total de ordens com valor: ${valores.length}`);
    console.log(`  Valor total: R$ ${soma.toFixed(2)}`);
    console.log(`  Valor médio: R$ ${media.toFixed(2)}`);
    console.log(`  Valor máximo: R$ ${maximo.toFixed(2)}`);
    console.log(`  Valor mínimo: R$ ${minimo.toFixed(2)}`);
  }
}

// Executar se chamado diretamente
if (process.argv.length < 3) {
  console.log('Uso: node analisar-backup.js <arquivo-backup>');
  process.exit(1);
}

const inputFile = process.argv[2];
analisarBackup(inputFile);
