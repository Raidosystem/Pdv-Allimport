// Teste de login com Supabase - Diagnóstico
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

async function diagnosticLogin() {
  console.log('🔍 DIAGNÓSTICO DE LOGIN - SUPABASE');
  console.log('================================');
  
  try {
    // 1. Testar conexão básica
    console.log('1. Testando conexão básica...');
    const connResponse = await fetch(`${supabaseUrl}/rest/v1/`, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    console.log('   Status conexão:', connResponse.status, connResponse.statusText);
    
    if (!connResponse.ok) {
      const error = await connResponse.text();
      console.log('   ❌ Erro de conexão:', error);
      return;
    }
    console.log('   ✅ Conexão OK');

    // 2. Listar usuários existentes
    console.log('\n2. Verificando usuários no auth...');
    try {
      const usersResponse = await fetch(`${supabaseUrl}/auth/v1/admin/users`, {
        headers: {
          'apikey': supabaseKey,
          'Authorization': `Bearer ${supabaseKey}`,
          'Content-Type': 'application/json'
        }
      });
      console.log('   Status usuários:', usersResponse.status);
      
      if (usersResponse.ok) {
        const users = await usersResponse.json();
        console.log('   Total usuários:', users.users?.length || 0);
        users.users?.forEach((user, i) => {
          console.log(`   User ${i+1}: ${user.email} - ${user.email_confirmed_at ? 'Confirmado' : 'Não confirmado'}`);
        });
      } else {
        console.log('   ⚠️ Não foi possível listar usuários (normal com chave anon)');
      }
    } catch (e) {
      console.log('   ⚠️ Erro ao listar usuários:', e.message);
    }

    // 3. Testar login com credenciais específicas
    console.log('\n3. Testando login...');
    console.log('   Digite as credenciais de teste:');
    
    // Para teste, usando credenciais comuns que podem existir
    const testCredentials = [
      { email: 'admin@example.com', password: 'password123' },
      { email: 'test@test.com', password: '123456' },
      { email: 'usuario@teste.com', password: 'senha123' }
    ];

    for (const cred of testCredentials) {
      console.log(`\n   Testando: ${cred.email}...`);
      try {
        const loginResponse = await fetch(`${supabaseUrl}/auth/v1/token?grant_type=password`, {
          method: 'POST',
          headers: {
            'apikey': supabaseKey,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            email: cred.email,
            password: cred.password
          })
        });

        console.log(`   Status login: ${loginResponse.status}`);
        
        if (loginResponse.ok) {
          const loginData = await loginResponse.json();
          console.log('   ✅ LOGIN SUCESSO!');
          console.log('   Token existe:', !!loginData.access_token);
          console.log('   User ID:', loginData.user?.id);
          return; // Parar no primeiro sucesso
        } else {
          const errorData = await loginResponse.text();
          console.log('   ❌ Falha no login:', errorData);
        }
      } catch (e) {
        console.log('   ❌ Erro no login:', e.message);
      }
    }

    console.log('\n4. Verificando configuração de auth...');
    const settingsResponse = await fetch(`${supabaseUrl}/auth/v1/settings`, {
      headers: {
        'apikey': supabaseKey
      }
    });
    
    if (settingsResponse.ok) {
      const settings = await settingsResponse.json();
      console.log('   Confirmação de email necessária:', settings.external_email_enabled);
      console.log('   Providers habilitados:', Object.keys(settings.external || {}));
    }

  } catch (error) {
    console.log('❌ Erro geral:', error.message);
  }
}

// Executar diagnóstico
diagnosticLogin();
