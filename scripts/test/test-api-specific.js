#!/usr/bin/env node

// Teste específico de endpoints que requerem dados
import https from 'https';

const API_BASE = 'https://pdv.crmvsystem.com/api';

function makeRequest(url, options = {}) {
  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          headers: res.headers,
          data: data
        });
      });
    });
    
    req.on('error', reject);
    if (options.body) {
      req.write(options.body);
    }
    req.end();
  });
}

async function testSpecificEndpoints() {
  console.log('🧪 Testando endpoints específicos...\n');

  // 1. Testar PIX com dados válidos
  console.log('🔍 Testando PIX (POST com dados)...');
  try {
    const pixData = {
      title: "Teste PIX",
      description: "Pagamento de teste via PIX",
      price: 50.00,
      quantity: 1,
      payer_email: "test@example.com"
    };

    const pixResult = await makeRequest(`${API_BASE}/pix`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'API-Test/1.0'
      },
      body: JSON.stringify(pixData)
    });

    console.log(`   Status: ${pixResult.status}`);
    if (pixResult.status === 200) {
      console.log('   ✅ PIX endpoint funcionando');
    } else {
      console.log('   ❌ PIX endpoint com problema');
      console.log(`   📄 Resposta: ${pixResult.data.substring(0, 200)}`);
    }
  } catch (error) {
    console.log(`   💥 Erro: ${error.message}`);
  }

  // 2. Testar Payment Status com ID
  console.log('\n🔍 Testando Payment Status com ID...');
  try {
    const paymentResult = await makeRequest(`${API_BASE}/payment-status?paymentId=12345`, {
      method: 'GET',
      headers: {
        'User-Agent': 'API-Test/1.0'
      }
    });

    console.log(`   Status: ${paymentResult.status}`);
    if (paymentResult.status === 200 || paymentResult.status === 404) {
      console.log('   ✅ Payment Status endpoint funcionando');
    } else {
      console.log('   ❌ Payment Status com problema');
      console.log(`   📄 Resposta: ${paymentResult.data.substring(0, 200)}`);
    }
  } catch (error) {
    console.log(`   💥 Erro: ${error.message}`);
  }

  // 3. Testar Preference Basic com dados
  console.log('\n🔍 Testando Preference Basic (POST)...');
  try {
    const preferenceData = {
      title: "Produto Teste",
      unit_price: 100.00,
      quantity: 1
    };

    const prefResult = await makeRequest(`${API_BASE}/preference-basic`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'API-Test/1.0'
      },
      body: JSON.stringify(preferenceData)
    });

    console.log(`   Status: ${prefResult.status}`);
    if (prefResult.status === 200) {
      console.log('   ✅ Preference Basic funcionando');
    } else {
      console.log('   ❌ Preference Basic com problema');
      console.log(`   📄 Resposta: ${prefResult.data.substring(0, 200)}`);
    }
  } catch (error) {
    console.log(`   💥 Erro: ${error.message}`);
  }

  // 4. Verificar se MP Diagnostic precisa de autenticação
  console.log('\n🔍 Verificando se MP Diagnostic precisa de auth...');
  try {
    const diagResult = await makeRequest(`${API_BASE}/mp-diagnostic`, {
      method: 'GET',
      headers: {
        'User-Agent': 'API-Test/1.0',
        'Authorization': 'Bearer test-token'
      }
    });

    console.log(`   Status: ${diagResult.status}`);
    console.log(`   📄 Resposta: ${diagResult.data.substring(0, 200)}`);
  } catch (error) {
    console.log(`   💥 Erro: ${error.message}`);
  }

  console.log('\n✅ Testes específicos concluídos!');
}

testSpecificEndpoints().catch(console.error);