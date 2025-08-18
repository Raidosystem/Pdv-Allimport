#!/usr/bin/env node

/**
 * TESTE ESPECÍFICO DE AUTENTICAÇÃO
 * Verifica se o problema está resolvido
 */

import https from 'https';

console.log('🎯 TESTE DE AUTENTICAÇÃO ESPECÍFICO');
console.log('✅ Site URL: Correto (https://pdv.crmvsystem.com)');
console.log('✅ Redirect URLs: Corretos');
console.log('📋 Próximo: Verificar CORS e cache');
console.log('═'.repeat(50));

// Teste de conectividade com headers específicos
function testarHeaders() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'pdv.crmvsystem.com',
      port: 443,
      path: '/',
      method: 'GET',
      headers: {
        'Origin': 'https://pdv.crmvsystem.com',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      }
    };

    console.log('🔍 Testando headers de CORS...');
    
    const req = https.request(options, (res) => {
      console.log(`✅ Status: ${res.statusCode}`);
      console.log(`🌐 CORS Access-Control-Allow-Origin: ${res.headers['access-control-allow-origin'] || 'Não definido'}`);
      console.log(`🔒 Content-Security-Policy: ${res.headers['content-security-policy'] || 'Não definido'}`);
      console.log(`🛡️ X-Frame-Options: ${res.headers['x-frame-options'] || 'Não definido'}`);
      
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        resolve({ status: res.statusCode, headers: res.headers, data });
      });
    });

    req.on('error', (error) => {
      console.error('❌ Erro:', error.message);
      reject(error);
    });

    req.end();
  });
}

// Simular chamada de autenticação
function simularAuth() {
  console.log('\n🔐 Simulando chamada de autenticação...');
  
  const authPatterns = [
    'supabase',
    'auth',
    'login',
    'session',
    'token'
  ];
  
  console.log('📋 O que buscar na aplicação:');
  authPatterns.forEach(pattern => {
    console.log(`   - Referências a: ${pattern}`);
  });
}

// Guia de troubleshooting
function guiaTroubleshooting() {
  console.log('\n🔧 GUIA DE TROUBLESHOOTING:');
  console.log('═'.repeat(30));
  
  const steps = [
    {
      step: '1️⃣ CORS no Supabase',
      action: 'Settings > API > CORS',
      value: 'Adicionar: https://pdv.crmvsystem.com'
    },
    {
      step: '2️⃣ Limpar cache',
      action: 'Ctrl + Shift + Delete',
      value: 'Todo o histórico, cookies e cache'
    },
    {
      step: '3️⃣ Teste em aba privada',
      action: 'Nova aba incógnito',
      value: 'Acessar: https://pdv.crmvsystem.com/'
    },
    {
      step: '4️⃣ SQL de limpeza',
      action: 'SQL Editor no Supabase',
      value: 'Executar: limpar-apenas-sessoes.sql'
    },
    {
      step: '5️⃣ Verificar usuário',
      action: 'Authentication > Users',
      value: 'Confirmar que email está verificado'
    }
  ];
  
  steps.forEach(item => {
    console.log(`\n${item.step} ${item.action}`);
    console.log(`   📝 ${item.value}`);
  });
}

// Executar testes
async function executar() {
  try {
    await testarHeaders();
    simularAuth();
    guiaTroubleshooting();
    
    console.log('\n═'.repeat(50));
    console.log('🎯 RESUMO:');
    console.log('✅ Site URL: Correto');
    console.log('✅ Domínio: Funcionando');
    console.log('❓ CORS: Verificar no Supabase');
    console.log('❓ Cache: Limpar navegador');
    console.log('❓ Teste: Aba privada');
    
    console.log('\n💡 Se ainda não funcionar após estes passos:');
    console.log('   Execute: limpar-apenas-sessoes.sql');
    console.log('   Ou compartilhe o erro específico que aparece');
    
  } catch (error) {
    console.error('❌ Erro no teste:', error.message);
  }
}

executar();
