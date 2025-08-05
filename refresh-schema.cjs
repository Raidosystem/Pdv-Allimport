// Script para forçar refresh do schema cache Supabase
// Execute com: node refresh-schema.cjs

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

async function refreshSchema() {
  console.log('🔄 FORÇANDO REFRESH DO SCHEMA CACHE');
  console.log('===================================');
  console.log('');

  try {
    // 1. Verificar schema atual
    console.log('1️⃣ Verificando schema atual...');
    const schemaTest = await makeRequest('/rest/v1/?select=*');
    
    console.log(`   Status: ${schemaTest.status}`);
    console.log(`   Sucesso: ${schemaTest.success}`);

    // 2. Testar consulta simples na tabela caixa
    console.log('\n2️⃣ Testando consulta simples...');
    const simpleTest = await makeRequest('/rest/v1/caixa?select=id,usuario_id&limit=1');
    
    console.log(`   Status: ${simpleTest.status}`);
    console.log(`   Sucesso: ${simpleTest.success}`);
    
    if (simpleTest.success) {
      console.log(`   ✅ Tabela caixa acessível`);
    } else {
      console.log(`   ❌ Erro: ${simpleTest.body.substring(0, 200)}`);
    }

    // 3. Testar consulta com relacionamento
    console.log('\n3️⃣ Testando relacionamento movimentacoes_caixa...');
    const relationTest = await makeRequest('/rest/v1/caixa?select=id,movimentacoes_caixa(id)&limit=1');
    
    console.log(`   Status: ${relationTest.status}`);
    console.log(`   Sucesso: ${relationTest.success}`);
    
    if (relationTest.success) {
      console.log(`   ✅ Relacionamento funcionando`);
    } else {
      console.log(`   ❌ Erro no relacionamento: ${relationTest.body.substring(0, 300)}`);
    }

    // 4. Listar todas as tabelas disponíveis
    console.log('\n4️⃣ Listando tabelas disponíveis...');
    const tablesTest = await makeRequest('/rest/v1/');
    
    if (tablesTest.success && typeof tablesTest.body === 'string') {
      const availableTables = tablesTest.body.match(/\/([a-zA-Z_]+)\?/g) || [];
      console.log(`   📋 Tabelas encontradas: ${availableTables.length}`);
      availableTables.slice(0, 10).forEach(table => {
        console.log(`      • ${table.replace('/', '').replace('?', '')}`);
      });
    }

  } catch (error) {
    console.log('\n❌ ERRO:', error.message);
  }

  console.log('\n💡 SOLUÇÕES:');
  console.log('• Se o relacionamento falhar: Cache do Supabase pode estar antigo');
  console.log('• Espere alguns minutos ou reinicie o projeto');
  console.log('• Verificar se existe foreign key entre as tabelas');
}

// Executar teste
refreshSchema();
