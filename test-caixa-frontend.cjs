// Teste do módulo Caixa - Simular ação do frontend
// Execute com: node test-caixa-frontend.cjs

const https = require('https');

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

function makeSupabaseRequest(path, method = 'GET', data = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const defaultHeaders = {
      'apikey': supabaseAnonKey,
      'Authorization': `Bearer ${supabaseAnonKey}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
      ...headers
    };

    const options = {
      hostname: 'kmcaaqetxtwkdcczdomw.supabase.co',
      port: 443,
      path: path,
      method: method,
      headers: defaultHeaders
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

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function testarModuloCaixa() {
  console.log('🧪 TESTANDO MÓDULO CAIXA - SIMULAÇÃO FRONTEND');
  console.log('=============================================');
  console.log('');

  try {
    // 1. Testar busca de caixa atual
    console.log('1️⃣ Testando busca de caixa atual...');
    const caixaAtual = await makeSupabaseRequest('/rest/v1/caixa?status=eq.aberto&select=*,movimentacoes_caixa(*)&limit=1');
    
    console.log(`   Status: ${caixaAtual.status}`);
    console.log(`   Sucesso: ${caixaAtual.success}`);
    
    if (caixaAtual.success) {
      console.log(`   ✅ Dados recebidos: ${JSON.stringify(caixaAtual.data).substring(0, 100)}...`);
    } else {
      console.log(`   ❌ Erro: ${caixaAtual.body.substring(0, 200)}`);
    }

    // 2. Testar inserção de caixa (sem autenticação)
    console.log('\n2️⃣ Testando inserção de caixa...');
    const novoCaixa = await makeSupabaseRequest('/rest/v1/caixa', 'POST', {
      valor_inicial: 50.00,
      observacoes: 'Teste via API',
      status: 'aberto'
    });
    
    console.log(`   Status: ${novoCaixa.status}`);
    console.log(`   Sucesso: ${novoCaixa.success}`);
    
    if (novoCaixa.success) {
      console.log(`   ✅ Caixa criado: ${JSON.stringify(novoCaixa.data)}`);
    } else {
      console.log(`   ❌ Erro: ${novoCaixa.body.substring(0, 200)}`);
    }

    // 3. Testar listagem de caixas
    console.log('\n3️⃣ Testando listagem de caixas...');
    const listaCaixas = await makeSupabaseRequest('/rest/v1/caixa?select=*&limit=5');
    
    console.log(`   Status: ${listaCaixas.status}`);
    console.log(`   Sucesso: ${listaCaixas.success}`);
    
    if (listaCaixas.success) {
      console.log(`   ✅ Caixas encontrados: ${Array.isArray(listaCaixas.data) ? listaCaixas.data.length : 0}`);
      if (Array.isArray(listaCaixas.data) && listaCaixas.data.length > 0) {
        console.log(`   📋 Primeiro caixa: ${JSON.stringify(listaCaixas.data[0])}`);
      }
    } else {
      console.log(`   ❌ Erro: ${listaCaixas.body.substring(0, 200)}`);
    }

    // 4. Verificar estrutura das tabelas
    console.log('\n4️⃣ Verificando estrutura via REST...');
    const estrutura = await makeSupabaseRequest('/rest/v1/caixa?select=id&limit=0');
    console.log(`   Status estrutura: ${estrutura.status}`);
    console.log(`   Headers: ${JSON.stringify(estrutura.data)}`);

  } catch (error) {
    console.log('\n❌ ERRO NO TESTE:', error.message);
  }

  console.log('\n🎯 DIAGNÓSTICO:');
  console.log('================');
  console.log('Se os testes falharam com 401/403, o problema é autenticação');
  console.log('Se os testes falharam com 404, as tabelas não estão expostas via REST API');
  console.log('Se os testes funcionaram, o problema é no frontend');
  console.log('');
  console.log('🔧 PRÓXIMOS PASSOS:');
  console.log('- Verificar se RLS está desabilitado');
  console.log('- Verificar se as tabelas estão no schema public');
  console.log('- Verificar autenticação do frontend');
}

// Executar teste
testarModuloCaixa();
