// Teste de autenticação Supabase
// Execute com: node test-auth.cjs

const https = require('https');

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg';

function makeAuthRequest(path, method = 'GET', data = null, authToken = null) {
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

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function testarAuth() {
  console.log('🔐 TESTANDO AUTENTICAÇÃO SUPABASE');
  console.log('=================================');
  console.log('');

  try {
    // 1. Testar endpoint de usuário atual (sem auth)
    console.log('1️⃣ Testando endpoint /auth/v1/user (sem token)...');
    const userTest = await makeAuthRequest('/auth/v1/user');
    
    console.log(`   Status: ${userTest.status}`);
    console.log(`   Sucesso: ${userTest.success}`);
    console.log(`   Resposta: ${userTest.body.substring(0, 200)}`);

    // 2. Listar usuários do sistema
    console.log('\n2️⃣ Listando usuários existentes...');
    const usersTest = await makeAuthRequest('/rest/v1/auth.users?select=id,email&limit=5');
    
    console.log(`   Status: ${usersTest.status}`);
    console.log(`   Sucesso: ${usersTest.success}`);
    
    if (usersTest.success && Array.isArray(usersTest.data)) {
      console.log(`   ✅ Usuários encontrados: ${usersTest.data.length}`);
      usersTest.data.forEach((user, index) => {
        console.log(`   👤 Usuário ${index + 1}: ${user.email || 'sem email'} (ID: ${user.id})`);
      });
    } else {
      console.log(`   ❌ Erro ou sem acesso: ${usersTest.body.substring(0, 200)}`);
    }

    // 3. Testar inserção com usuário existente
    console.log('\n3️⃣ Testando inserção de caixa com usuário existente...');
    
    // Usar o primeiro usuário encontrado ou um ID fixo
    const userId = '5716d14d-4d2d-44e1-96e5-92c07503c263'; // Do teste anterior
    
    const insertTest = await makeAuthRequest('/rest/v1/caixa', 'POST', {
      usuario_id: userId,
      valor_inicial: 75.00,
      observacoes: 'Teste de autenticação',
      status: 'aberto'
    });
    
    console.log(`   Status: ${insertTest.status}`);
    console.log(`   Sucesso: ${insertTest.success}`);
    
    if (insertTest.success) {
      console.log(`   ✅ Caixa criado com sucesso!`);
      console.log(`   📋 Dados: ${JSON.stringify(insertTest.data)}`);
    } else {
      console.log(`   ❌ Erro: ${insertTest.body.substring(0, 300)}`);
    }

  } catch (error) {
    console.log('\n❌ ERRO NO TESTE:', error.message);
  }

  console.log('\n🎯 DIAGNÓSTICO:');
  console.log('================');
  console.log('✅ Se conseguiu listar usuários: Auth está funcionando');
  console.log('✅ Se conseguiu inserir caixa: Problema resolvido');
  console.log('❌ Se falhou: Verificar RLS ou estrutura das tabelas');
  console.log('');
  console.log('💡 DICA: O erro no frontend pode ser que o usuário não está logado');
  console.log('   ou o token de sessão expirou.');
}

// Executar teste
testarAuth();
