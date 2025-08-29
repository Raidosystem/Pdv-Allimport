#!/usr/bin/env node

/**
 * TESTE ESPECÍFICO DO DOMÍNIO EM PRODUÇÃO
 * Verificar se o deploy tem as configurações corretas
 */

import https from 'https';

const DOMAIN = 'pdv.crmvsystem.com';
const SUPABASE_URL = 'https://YOUR_SUPABASE_PROJECT.supabase.co';
const ANON_KEY = 'YOUR_SUPABASE_ANON_KEY'

console.log('🔍 TESTE DO DOMÍNIO EM PRODUÇÃO');
console.log(`🌐 URL: https://${DOMAIN}/`);
console.log('═'.repeat(50));

// Verificar se o HTML contém as configurações corretas
function verificarHTML() {
  return new Promise((resolve, reject) => {
    https.get(`https://${DOMAIN}/`, (response) => {
      let data = '';
      response.on('data', chunk => data += chunk);
      response.on('end', () => {
        console.log('📄 Analisando HTML da produção...');
        
        // Verificar se contém referências ao Supabase
        const patterns = [
          { name: 'Supabase URL', regex: /your-project-ref/gi },
          { name: 'Variáveis ENV', regex: /VITE_SUPABASE/gi },
          { name: 'React App', regex: /react/gi },
          { name: 'Scripts JS', regex: /\.js/gi }
        ];
        
        patterns.forEach(pattern => {
          const matches = data.match(pattern.regex) || [];
          console.log(`   ${matches.length > 0 ? '✅' : '❌'} ${pattern.name}: ${matches.length} ocorrências`);
        });
        
        resolve(data);
      });
    }).on('error', reject);
  });
}

// Testar API do Supabase diretamente
async function testarSupabaseDirecto() {
  console.log('\n🔧 Testando Supabase diretamente...');
  
  try {
    // Testar endpoint de health
    const response = await fetch(`${SUPABASE_URL}/rest/v1/`, {
      headers: {
        'apikey': ANON_KEY,
        'Authorization': `Bearer ${ANON_KEY}`
      }
    });
    
    console.log(`✅ Supabase API: ${response.status} ${response.statusText}`);
    
    if (response.status === 200) {
      // Testar login direto
      console.log('🧪 Testando login direto...');
      
      const loginResponse = await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
        method: 'POST',
        headers: {
          'apikey': ANON_KEY,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email: 'novaradiosystem@outlook.com',
          password: '@qw12aszx##'
        })
      });
      
      if (loginResponse.ok) {
        const loginData = await loginResponse.json();
        console.log('✅ Login direto: FUNCIONANDO');
        console.log(`👤 Token: ${loginData.access_token?.substring(0, 20)}...`);
      } else {
        console.log('❌ Login direto: FALHOU');
        const errorData = await loginResponse.text();
        console.log('📋 Erro:', errorData);
      }
    }
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  }
}

// Verificar cache e headers
function verificarHeaders() {
  return new Promise((resolve) => {
    https.get(`https://${DOMAIN}/`, (response) => {
      console.log('\n📡 Headers da resposta:');
      console.log(`   Cache-Control: ${response.headers['cache-control'] || 'Não definido'}`);
      console.log(`   ETag: ${response.headers['etag'] || 'Não definido'}`);
      console.log(`   Last-Modified: ${response.headers['last-modified'] || 'Não definido'}`);
      console.log(`   X-Vercel-Cache: ${response.headers['x-vercel-cache'] || 'Não definido'}`);
      console.log(`   X-Vercel-Id: ${response.headers['x-vercel-id'] || 'Não definido'}`);
      
      if (response.headers['x-vercel-cache'] === 'HIT') {
        console.log('⚠️ CACHE HIT - Pode estar servindo versão antiga');
      } else {
        console.log('✅ Cache OK - Servindo versão atual');
      }
      
      resolve();
    });
  });
}

// Executar todos os testes
async function executar() {
  try {
    await verificarHTML();
    await testarSupabaseDirecto();
    await verificarHeaders();
    
    console.log('\n═'.repeat(50));
    console.log('🎯 DIAGNÓSTICO:');
    console.log('1. Se Supabase direto funciona = Problema é no frontend');
    console.log('2. Se cache é HIT = Deploy não atualizou ainda');
    console.log('3. Se não tem configurações = Build não incluiu .env');
    
    console.log('\n💡 POSSÍVEIS SOLUÇÕES:');
    console.log('1. Aguardar propagação do cache (5-10 min)');
    console.log('2. Limpar cache do navegador');
    console.log('3. Forçar novo deploy');
    console.log('4. Verificar se .env está no .gitignore');
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message);
  }
}

executar();
