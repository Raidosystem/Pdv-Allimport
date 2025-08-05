// Teste completo de login e caixa
// Execute com: node test-login-caixa.cjs

const https = require('https');

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

function makeRequest(path, method = 'GET', data = null, authToken = null) {
  return new Promise((resolve, reject) => {
    const headers = {
      'apikey': supabaseAnonKey,
      'Content-Type': 'application/json'
    };
    
    if (authToken) {
      headers['Authorization'] = `Bearer ${authToken}`;
    } else {
      headers['Authorization'] = `Bearer ${supabaseAnonKey}`;
    }

    const options = {
      hostname: 'kmcaaqetxtwkdcczdomw.supabase.co',
      port: 443,
      path: path,
      method: method,
      headers: headers
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

    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function testarLoginCompleto() {
  console.log('🔐 TESTE COMPLETO: LOGIN + CAIXA');
  console.log('=================================');
  console.log('');

  try {
    // 1. Tentar fazer login com email/senha
    console.log('1️⃣ Tentando fazer login...');
    const loginTest = await makeRequest('/auth/v1/token?grant_type=password', 'POST', {
      email: 'teste123@teste.com',
      password: 'teste123'
    });
    
    console.log(`   Status: ${loginTest.status}`);
    console.log(`   Sucesso: ${loginTest.success}`);
    
    if (loginTest.success && loginTest.data.access_token) {
      console.log(`   ✅ Login realizado com sucesso!`);
      console.log(`   🎫 Token obtido: ${loginTest.data.access_token.substring(0, 50)}...`);
      
      const accessToken = loginTest.data.access_token;
      const userId = loginTest.data.user?.id;
      
      console.log(`   👤 User ID: ${userId}`);
      
      // 2. Verificar usuário atual com token
      console.log('\n2️⃣ Verificando usuário atual com token...');
      const userCheck = await makeRequest('/auth/v1/user', 'GET', null, accessToken);
      
      console.log(`   Status: ${userCheck.status}`);
      console.log(`   Sucesso: ${userCheck.success}`);
      
      if (userCheck.success) {
        console.log(`   ✅ Usuário verificado: ${userCheck.data.email}`);
        
        // 3. Tentar abrir caixa com usuário autenticado
        console.log('\n3️⃣ Tentando abrir caixa com usuário autenticado...');
        const caixaTest = await makeRequest('/rest/v1/caixa', 'POST', {
          usuario_id: userId,
          valor_inicial: 100.00,
          observacoes: 'Teste com login completo',
          status: 'aberto'
        }, accessToken);
        
        console.log(`   Status: ${caixaTest.status}`);
        console.log(`   Sucesso: ${caixaTest.success}`);
        
        if (caixaTest.success) {
          console.log(`   ✅ Caixa aberto com sucesso!`);
          console.log(`   📋 Dados: ${JSON.stringify(caixaTest.data, null, 2)}`);
        } else {
          console.log(`   ❌ Erro ao abrir caixa: ${caixaTest.body}`);
        }
        
      } else {
        console.log(`   ❌ Erro na verificação: ${userCheck.body}`);
      }
      
    } else {
      console.log(`   ❌ Falha no login: ${loginTest.body}`);
    }

  } catch (error) {
    console.log('\n❌ ERRO NO TESTE:', error.message);
  }

  console.log('\n🎯 CONCLUSÕES:');
  console.log('===============');
  console.log('• Se o login funcionou: Sistema de auth está OK');
  console.log('• Se o caixa abriu: Sistema completo está funcionando');
  console.log('• Se falhou: Verificar se o usuário do frontend está logado');
  console.log('');
  console.log('💡 PRÓXIMOS PASSOS:');
  console.log('• Verificar se o usuário está logado no frontend');
  console.log('• Verificar se a sessão não expirou');
  console.log('• Testar login/logout no sistema web');
}

// Executar teste
testarLoginCompleto();
