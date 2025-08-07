// Diagnóstico completo de tabelas de caixa
// Execute com: node diagnostico-tabelas-caixa.cjs

const https = require('https');

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

function makeRequest(path, method = 'GET') {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'kmcaaqetxtwkdcczdomw.supabase.co',
      port: 443,
      path: path,
      method: method,
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'Content-Type': 'application/json'
      }
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const parsed = body ? JSON.parse(body) : {};
          resolve({ 
            status: res.statusCode, 
            data: parsed, 
            success: res.statusCode >= 200 && res.statusCode < 300,
            body: body
          });
        } catch (e) {
          resolve({ 
            status: res.statusCode, 
            data: body, 
            success: res.statusCode >= 200 && res.statusCode < 300,
            body: body
          });
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

async function diagnosticarTabelas() {
  console.log('🔍 DIAGNÓSTICO DE TABELAS CAIXA');
  console.log('================================');
  console.log('');

  try {
    // 1. Verificar tabela 'caixa'
    console.log('1️⃣ Verificando tabela "caixa"...');
    const caixaTest = await makeRequest('/rest/v1/caixa?select=count');
    
    console.log(`   Status: ${caixaTest.status}`);
    console.log(`   Sucesso: ${caixaTest.success}`);
    
    if (caixaTest.success) {
      console.log(`   ✅ Tabela "caixa" existe - Total registros: ${JSON.stringify(caixaTest.data)}`);
    } else {
      console.log(`   ❌ Erro na tabela "caixa": ${caixaTest.body.substring(0, 200)}`);
    }

    // 2. Verificar tabela 'movimentacoes_caixa'
    console.log('\n2️⃣ Verificando tabela "movimentacoes_caixa"...');
    const movTest = await makeRequest('/rest/v1/movimentacoes_caixa?select=count');
    
    console.log(`   Status: ${movTest.status}`);
    console.log(`   Sucesso: ${movTest.success}`);
    
    if (movTest.success) {
      console.log(`   ✅ Tabela "movimentacoes_caixa" existe - Total registros: ${JSON.stringify(movTest.data)}`);
    } else {
      console.log(`   ❌ Erro na tabela "movimentacoes_caixa": ${movTest.body.substring(0, 200)}`);
    }

    // 3. Verificar tabela 'cash_registers' (possível duplicata)
    console.log('\n3️⃣ Verificando tabela "cash_registers" (possível duplicata)...');
    const cashRegTest = await makeRequest('/rest/v1/cash_registers?select=count');
    
    console.log(`   Status: ${cashRegTest.status}`);
    console.log(`   Sucesso: ${cashRegTest.success}`);
    
    if (cashRegTest.success) {
      console.log(`   ⚠️ DUPLICATA ENCONTRADA: "cash_registers" existe - Total registros: ${JSON.stringify(cashRegTest.data)}`);
    } else {
      console.log(`   ✅ Tabela "cash_registers" não existe (correto)`);
    }

    // 4. Testar relacionamento
    console.log('\n4️⃣ Testando relacionamento caixa → movimentacoes_caixa...');
    const relTest = await makeRequest('/rest/v1/caixa?select=id,movimentacoes_caixa(count)&limit=1');
    
    console.log(`   Status: ${relTest.status}`);
    console.log(`   Sucesso: ${relTest.success}`);
    
    if (relTest.success) {
      console.log(`   ✅ Relacionamento funcionando: ${JSON.stringify(relTest.data)}`);
    } else {
      console.log(`   ❌ Erro no relacionamento: ${relTest.body.substring(0, 300)}`);
    }

    // 5. Verificar estrutura da tabela caixa
    console.log('\n5️⃣ Verificando estrutura da tabela "caixa"...');
    const estruturaTest = await makeRequest('/rest/v1/caixa?select=*&limit=1');
    
    if (estruturaTest.success && estruturaTest.data.length > 0) {
      console.log(`   ✅ Estrutura da tabela "caixa":`);
      const colunas = Object.keys(estruturaTest.data[0]);
      colunas.forEach(col => console.log(`      • ${col}`));
    }

    // 6. Verificar estrutura da tabela movimentacoes_caixa
    console.log('\n6️⃣ Verificando estrutura da tabela "movimentacoes_caixa"...');
    const estruturaMovTest = await makeRequest('/rest/v1/movimentacoes_caixa?select=*&limit=1');
    
    if (estruturaMovTest.success && estruturaMovTest.data.length > 0) {
      console.log(`   ✅ Estrutura da tabela "movimentacoes_caixa":`);
      const colunasMovTest = Object.keys(estruturaMovTest.data[0]);
      colunasMovTest.forEach(col => console.log(`      • ${col}`));
    } else {
      console.log(`   ⚠️ Tabela "movimentacoes_caixa" vazia ou com erro`);
    }

  } catch (error) {
    console.log('\n❌ ERRO NO DIAGNÓSTICO:', error.message);
  }

  console.log('\n🎯 RESUMO:');
  console.log('==========');
  console.log('• Se existe "cash_registers": PROBLEMA - tabela duplicada');
  console.log('• Se existe apenas "caixa" e "movimentacoes_caixa": OK');
  console.log('• Se relacionamento funciona: Schema correto');
  console.log('• Se estruturas estão completas: Tabelas OK');
}

// Executar diagnóstico
diagnosticarTabelas();
