#!/usr/bin/env node

// Script de teste completo da API
import https from 'https';
import fs from 'fs';

const API_BASE = 'https://pdv.crmvsystem.com/api';
const results = [];

console.log('🧪 Iniciando testes completos da API...\n');

// Função para fazer requisições
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

// Testes para executar
const tests = [
  {
    name: '🏥 Health Check',
    url: `${API_BASE}/health`,
    method: 'GET',
    expected: 200
  },
  {
    name: '📊 Test Endpoint',
    url: `${API_BASE}/test`,
    method: 'GET',
    expected: 200
  },
  {
    name: '💳 MP Diagnostic',
    url: `${API_BASE}/mp-diagnostic`,
    method: 'GET',
    expected: 200
  },
  {
    name: '🔗 PIX Endpoint',
    url: `${API_BASE}/pix`,
    method: 'GET',
    expected: 200
  },
  {
    name: '⚙️ Preference Basic',
    url: `${API_BASE}/preference-basic`,
    method: 'GET',
    expected: 200
  },
  {
    name: '📈 Payment Status',
    url: `${API_BASE}/payment-status`,
    method: 'GET',
    expected: 200
  },
  {
    name: '🔍 Recent Payments',
    url: `${API_BASE}/recent-payments`,
    method: 'GET',
    expected: 200
  },
  {
    name: '📋 Subscription Status',
    url: `${API_BASE}/subscription-status`,
    method: 'GET',
    expected: 200
  },
  {
    name: '🧹 Clear Cache',
    url: `${API_BASE}/clear-cache`,
    method: 'POST',
    expected: [200, 201]
  }
];

// Executar testes
async function runTests() {
  for (const test of tests) {
    try {
      console.log(`\n🔍 Testando: ${test.name}`);
      console.log(`   URL: ${test.url}`);
      
      const options = {
        method: test.method,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'API-Test-Script/1.0'
        }
      };

      if (test.body) {
        options.body = JSON.stringify(test.body);
      }

      const result = await makeRequest(test.url, options);
      
      const isSuccess = Array.isArray(test.expected) 
        ? test.expected.includes(result.status)
        : result.status === test.expected;

      if (isSuccess) {
        console.log(`   ✅ SUCESSO - Status: ${result.status}`);
        
        // Tentar parsear resposta
        try {
          const jsonData = JSON.parse(result.data);
          if (jsonData.status) console.log(`   📄 Status: ${jsonData.status}`);
          if (jsonData.version) console.log(`   🏷️  Versão: ${jsonData.version}`);
          if (jsonData.timestamp) console.log(`   🕐 Timestamp: ${jsonData.timestamp}`);
        } catch {
          // Não é JSON válido, mostrar primeiros caracteres
          const preview = result.data.substring(0, 100);
          console.log(`   📄 Resposta: ${preview}${result.data.length > 100 ? '...' : ''}`);
        }
      } else {
        console.log(`   ❌ ERRO - Status: ${result.status} (esperado: ${test.expected})`);
        console.log(`   📄 Resposta: ${result.data.substring(0, 200)}`);
      }

      results.push({
        test: test.name,
        url: test.url,
        status: result.status,
        success: isSuccess,
        data: result.data.substring(0, 500)
      });

      // Pausa entre requests
      await new Promise(resolve => setTimeout(resolve, 500));

    } catch (error) {
      console.log(`   💥 FALHA - ${error.message}`);
      results.push({
        test: test.name,
        url: test.url,
        error: error.message,
        success: false
      });
    }
  }

  // Resumo final
  console.log('\n' + '='.repeat(50));
  console.log('📊 RESUMO DOS TESTES');
  console.log('='.repeat(50));

  const sucessos = results.filter(r => r.success).length;
  const falhas = results.filter(r => !r.success).length;

  console.log(`✅ Sucessos: ${sucessos}`);
  console.log(`❌ Falhas: ${falhas}`);
  console.log(`📊 Total: ${results.length}`);
  console.log(`📈 Taxa de sucesso: ${(sucessos/results.length*100).toFixed(1)}%`);

  if (falhas > 0) {
    console.log('\n❌ ENDPOINTS COM FALHA:');
    results.filter(r => !r.success).forEach(r => {
      console.log(`   - ${r.test}: ${r.error || `Status ${r.status}`}`);
    });
  }

  // Salvar relatório
  const report = {
    timestamp: new Date().toISOString(),
    summary: { sucessos, falhas, total: results.length },
    results: results
  };

  fs.writeFileSync('api-test-report.json', JSON.stringify(report, null, 2));
  console.log('\n📄 Relatório salvo em: api-test-report.json');
}

runTests().catch(console.error);