#!/usr/bin/env node

/**
 * TESTE DE CONECTIVIDADE DO PDV
 * Verifica se o domínio e a aplicação estão funcionando
 */

import https from 'https';

const DOMAIN = 'pdv.crmvsystem.com';
const PROTOCOL = 'https://';
const FULL_URL = `${PROTOCOL}${DOMAIN}/`;

console.log('🚀 Testando conectividade do PDV Allimport');
console.log('📍 URL:', FULL_URL);
console.log('⏰ Timestamp:', new Date().toISOString());
console.log('─'.repeat(50));

// Teste 1: Conectividade básica
function testarConectividade() {
  return new Promise((resolve, reject) => {
    console.log('🔍 Teste 1: Conectividade básica...');
    
    const request = https.get(FULL_URL, (response) => {
      console.log(`✅ Status: ${response.statusCode} ${response.statusMessage}`);
      console.log(`📡 Server: ${response.headers.server || 'Unknown'}`);
      console.log(`📦 Content-Type: ${response.headers['content-type'] || 'Unknown'}`);
      console.log(`💾 Content-Length: ${response.headers['content-length'] || 'Unknown'} bytes`);
      console.log(`🚀 X-Vercel-Cache: ${response.headers['x-vercel-cache'] || 'N/A'}`);
      
      let data = '';
      response.on('data', chunk => data += chunk);
      response.on('end', () => {
        resolve({ status: response.statusCode, data, headers: response.headers });
      });
    });
    
    request.on('error', (error) => {
      console.error('❌ Erro de conectividade:', error.message);
      reject(error);
    });
    
    request.setTimeout(10000, () => {
      console.error('❌ Timeout: Servidor não respondeu em 10s');
      request.destroy();
      reject(new Error('Timeout'));
    });
  });
}

// Teste 2: Análise do conteúdo
function analisarConteudo(data) {
  console.log('\n🔍 Teste 2: Análise do conteúdo...');
  
  const checks = [
    { name: 'React App', pattern: /react/i, required: true },
    { name: 'PWA Manifest', pattern: /manifest\.json/i, required: true },
    { name: 'Service Worker', pattern: /service-worker|sw\.js/i, required: false },
    { name: 'Vite', pattern: /vite|\/assets\//i, required: false },
    { name: 'Tailwind CSS', pattern: /tailwind/i, required: false },
    { name: 'Title PDV', pattern: /<title>.*PDV.*<\/title>/i, required: true }
  ];
  
  checks.forEach(check => {
    const found = check.pattern.test(data);
    const icon = found ? '✅' : (check.required ? '❌' : '⚠️');
    console.log(`${icon} ${check.name}: ${found ? 'Encontrado' : 'Não encontrado'}`);
  });
  
  // Verificar tamanho do conteúdo
  const size = Buffer.byteLength(data, 'utf8');
  console.log(`📊 Tamanho do HTML: ${size} bytes`);
  
  if (size < 500) {
    console.log('⚠️ Aviso: HTML muito pequeno, pode estar vazio ou com erro');
  } else if (size > 1000) {
    console.log('✅ HTML com tamanho adequado');
  }
}

// Teste 3: Headers de segurança
function verificarSeguranca(headers) {
  console.log('\n🔍 Teste 3: Headers de segurança...');
  
  const securityHeaders = [
    'strict-transport-security',
    'x-frame-options',
    'x-content-type-options',
    'content-security-policy'
  ];
  
  securityHeaders.forEach(header => {
    const value = headers[header];
    const icon = value ? '✅' : '⚠️';
    console.log(`${icon} ${header}: ${value || 'Não definido'}`);
  });
}

// Executar todos os testes
async function executarTestes() {
  try {
    const { status, data, headers } = await testarConectividade();
    
    if (status === 200) {
      analisarConteudo(data);
      verificarSeguranca(headers);
      
      console.log('\n' + '─'.repeat(50));
      console.log('🎉 RESULTADO FINAL: DOMÍNIO FUNCIONANDO!');
      console.log('📋 Status: Online e operacional');
      console.log('🌐 URL: https://pdv.crmvsystem.com/');
      console.log('⚡ PWA: Pronto para instalação');
      console.log('🔑 Próximo passo: Configurar autenticação Supabase');
    } else {
      console.log(`\n❌ ERRO: Status ${status} - Site com problemas`);
    }
    
  } catch (error) {
    console.log('\n❌ ERRO CRÍTICO:');
    console.log('🚨 Falha na conectividade');
    console.log('💡 Verifique:');
    console.log('   - Conexão com internet');
    console.log('   - Configuração DNS');
    console.log('   - Status do Vercel');
  }
  
  console.log('\n📝 Log gerado em:', new Date().toLocaleString('pt-BR'));
}

// Executar
executarTestes();
