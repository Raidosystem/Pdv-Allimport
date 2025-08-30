// ===================================================
// 🧪 TESTE RÁPIDO DE LOGIN - DIAGNÓSTICO
// ===================================================
// Execute com: node teste-login-debug.js

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

async function testarLogin() {
  console.log('🧪 TESTE DE LOGIN - PDV ALLIMPORT');
  console.log('═'.repeat(50));
  
  try {
    // 1. Testar conexão básica
    console.log('📡 1. Testando conexão básica...');
    const testResponse = await fetch(`${supabaseUrl}/rest/v1/`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });

    if (!testResponse.ok) {
      throw new Error(`Falha na conexão: ${testResponse.status}`);
    }
    console.log('✅ Conexão OK!');

    // 2. Testar endpoint de autenticação
    console.log('\n🔐 2. Testando endpoint de auth...');
    const authResponse = await fetch(`${supabaseUrl}/auth/v1/`, {
      headers: {
        'apikey': supabaseKey
      }
    });
    
    console.log(`Auth endpoint: ${authResponse.status} ${authResponse.statusText}`);

    // 3. Simular tentativa de login (sem credenciais reais)
    console.log('\n🧪 3. Testando formato de login...');
    const loginTest = await fetch(`${supabaseUrl}/auth/v1/token?grant_type=password`, {
      method: 'POST',
      headers: {
        'apikey': supabaseKey,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'teste@exemplo.com',
        password: 'senha123'
      })
    });

    const loginResult = await loginTest.text();
    console.log(`Login test status: ${loginTest.status}`);
    
    if (loginTest.status === 400) {
      console.log('✅ Endpoint de login está funcionando (erro 400 é esperado para credenciais falsas)');
    } else if (loginTest.status === 422) {
      console.log('✅ Endpoint de login funcional (validação de email)');
    } else {
      console.log('⚠️ Resposta inesperada:', loginResult.substring(0, 200));
    }

  } catch (error) {
    console.error('❌ Erro:', error.message);
  }

  console.log('\n🔧 SOLUÇÕES PARA PROBLEMAS DE LOGIN:');
  console.log('═'.repeat(50));
  console.log('1. Execute o script SQL: sql/fix/RESOLVER_LOGIN_USUARIOS_EXISTENTES.sql');
  console.log('2. Limpe o cache do navegador (Ctrl+Shift+Delete)');
  console.log('3. Teste em aba privada/incógnito');
  console.log('4. Confirme se a chave Supabase no frontend está atualizada');
  console.log('5. Verifique configurações de URL no dashboard Supabase');
}

testarLogin();
