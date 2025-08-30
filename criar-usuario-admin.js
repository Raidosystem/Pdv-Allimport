// Script para criar um usuário admin e resolver problemas de login
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4';

async function criarUsuarioAdmin() {
  console.log('🔧 CRIANDO USUÁRIO ADMIN PARA TESTE');
  console.log('==================================');
  
  const adminEmail = 'admin@teste.com';
  const adminPassword = '123456789';
  
  try {
    // 1. Criar usuário
    console.log('1. Criando usuário...');
    const signupResponse = await fetch(`${supabaseUrl}/auth/v1/signup`, {
      method: 'POST',
      headers: {
        'apikey': supabaseKey,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: adminEmail,
        password: adminPassword,
        data: {
          nome: 'Administrador',
          role: 'admin'
        }
      })
    });

    console.log('Status signup:', signupResponse.status);
    
    if (signupResponse.ok) {
      const signupData = await signupResponse.json();
      console.log('✅ Usuário criado com sucesso!');
      console.log('User ID:', signupData.user?.id);
      console.log('Email:', signupData.user?.email);
      console.log('Confirmado:', signupData.user?.email_confirmed_at ? 'Sim' : 'Não');
      
      // 2. Tentar login imediatamente
      console.log('\n2. Testando login...');
      const loginResponse = await fetch(`${supabaseUrl}/auth/v1/token?grant_type=password`, {
        method: 'POST',
        headers: {
          'apikey': supabaseKey,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email: adminEmail,
          password: adminPassword
        })
      });

      console.log('Status login:', loginResponse.status);
      
      if (loginResponse.ok) {
        const loginData = await loginResponse.json();
        console.log('✅ LOGIN FUNCIONOU!');
        console.log('Access Token:', loginData.access_token ? 'Recebido' : 'Não recebido');
        
        console.log('\n🎯 CREDENCIAIS PARA USAR NO SISTEMA:');
        console.log('===================================');
        console.log('Email:', adminEmail);
        console.log('Senha:', adminPassword);
        
      } else {
        const loginError = await loginResponse.text();
        console.log('❌ Erro no login:', loginError);
        
        // Possível que precise confirmar email
        if (loginError.includes('email_not_confirmed')) {
          console.log('\n⚠️ EMAIL PRECISA SER CONFIRMADO');
          console.log('Vá ao Supabase Dashboard > Authentication > Users');
          console.log('E confirme o email manualmente.');
        }
      }
      
    } else {
      const signupError = await signupResponse.text();
      console.log('❌ Erro ao criar usuário:', signupError);
      
      // Se usuário já existe, tentar login
      if (signupError.includes('already_exists')) {
        console.log('\n⚠️ Usuário já existe, tentando login...');
        
        const loginResponse = await fetch(`${supabaseUrl}/auth/v1/token?grant_type=password`, {
          method: 'POST',
          headers: {
            'apikey': supabaseKey,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            email: adminEmail,
            password: adminPassword
          })
        });

        if (loginResponse.ok) {
          console.log('✅ Login com usuário existente funcionou!');
          
          console.log('\n🎯 CREDENCIAIS PARA USAR NO SISTEMA:');
          console.log('===================================');
          console.log('Email:', adminEmail);
          console.log('Senha:', adminPassword);
        } else {
          const loginError = await loginResponse.text();
          console.log('❌ Erro no login com usuário existente:', loginError);
        }
      }
    }

  } catch (error) {
    console.log('❌ Erro geral:', error.message);
  }
}

// Executar
criarUsuarioAdmin();
