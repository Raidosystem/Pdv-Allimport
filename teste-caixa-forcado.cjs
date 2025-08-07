// Teste de abertura de caixa forçando a tabela correta
// Execute com: node teste-caixa-forcado.cjs

const https = require('https');

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

function makeRequest(path, method = 'GET', data = null) {
  return new Promise((resolve, reject) => {
    const postData = data ? JSON.stringify(data) : null;
    
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

    if (postData) {
      options.headers['Content-Length'] = Buffer.byteLength(postData);
    }

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
    
    if (postData) {
      req.write(postData);
    }
    
    req.end();
  });
}

async function testarCaixaForcado() {
  console.log('🧪 TESTE DE CAIXA FORÇADO (TABELA CORRETA)');
  console.log('==========================================');
  console.log('');

  // Simular dados de usuário (pegar um ID real dos logs anteriores)
  const userId = '5716d14d-4d2d-44e1-96e5-92c07503c263'; // ID do teste anterior

  try {
    // 1. Verificar caixa atual diretamente na tabela 'caixa'
    console.log('1️⃣ Verificando caixa atual na tabela "caixa"...');
    const caixaAtualTest = await makeRequest(`/rest/v1/caixa?usuario_id=eq.${userId}&status=eq.aberto&select=*`);
    
    console.log(`   Status: ${caixaAtualTest.status}`);
    console.log(`   Sucesso: ${caixaAtualTest.success}`);
    
    if (caixaAtualTest.success) {
      console.log(`   📋 Caixas abertos: ${caixaAtualTest.data.length}`);
      if (caixaAtualTest.data.length > 0) {
        console.log(`   💰 Caixa ativo: ${caixaAtualTest.data[0].id} (R$ ${caixaAtualTest.data[0].valor_inicial})`);
        return;
      }
    }

    // 2. Tentar abrir novo caixa diretamente na tabela 'caixa'
    console.log('\n2️⃣ Tentando abrir novo caixa na tabela "caixa"...');
    
    const novoCaixa = {
      usuario_id: userId,
      valor_inicial: 150.00,
      observacoes: 'Teste forçado - ignorando cash_registers',
      status: 'aberto'
    };
    
    const abrirTest = await makeRequest('/rest/v1/caixa', 'POST', novoCaixa);
    
    console.log(`   Status: ${abrirTest.status}`);
    console.log(`   Sucesso: ${abrirTest.success}`);
    
    if (abrirTest.success) {
      console.log(`   ✅ Caixa aberto com sucesso!`);
      console.log(`   📋 Dados: ${JSON.stringify(abrirTest.data, null, 2)}`);
      
      // 3. Testar consulta com relacionamento
      console.log('\n3️⃣ Testando consulta com relacionamento...');
      const relacionamentoTest = await makeRequest(`/rest/v1/caixa?select=*,movimentacoes_caixa(*)&id=eq.${abrirTest.data[0].id}`);
      
      if (relacionamentoTest.success) {
        console.log(`   ✅ Relacionamento funcionando: ${JSON.stringify(relacionamentoTest.data, null, 2)}`);
      } else {
        console.log(`   ❌ Erro no relacionamento: ${relacionamentoTest.body}`);
      }
      
    } else {
      console.log(`   ❌ Erro ao abrir caixa: ${abrirTest.body}`);
    }

  } catch (error) {
    console.log('\n❌ ERRO NO TESTE:', error.message);
  }

  console.log('\n🎯 CONCLUSÃO:');
  console.log('• Se funcionou: Problema é no frontend, não no banco');
  console.log('• Se falhou: Problema está na estrutura do banco');
  console.log('• Frontend deve usar apenas tabela "caixa"');
}

// Executar teste
testarCaixaForcado();
