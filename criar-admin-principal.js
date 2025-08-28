// Criar usuário administrador principal no Supabase
console.log('🔧 Criando usuário administrador principal...')

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

// Credenciais do administrador principal
const adminEmail = 'novaradiosystem@outlook.com'
const adminPassword = 'admin123'

async function criarAdministrador() {
  try {
    console.log('👤 Criando usuário:', adminEmail)
    
    // Tentar criar o usuário
    const signupResponse = await fetch(`${SUPABASE_URL}/auth/v1/signup`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: adminEmail,
        password: adminPassword,
        data: {
          full_name: 'Administrador Principal',
          role: 'admin'
        }
      })
    })
    
    const signupData = await signupResponse.json()
    console.log('📝 Resultado do cadastro:', {
      status: signupResponse.status,
      data: signupData
    })
    
    if (signupResponse.status === 200 || signupResponse.status === 422) {
      console.log('✅ Usuário criado ou já existe!')
      
      // Tentar fazer login
      console.log('🔐 Testando login...')
      const loginResponse = await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email: adminEmail,
          password: adminPassword
        })
      })
      
      const loginData = await loginResponse.json()
      console.log('🔓 Resultado do login:', {
        status: loginResponse.status,
        success: loginResponse.ok,
        user: loginData.user?.email,
        token: loginData.access_token ? 'Present' : 'Missing'
      })
      
      if (loginResponse.ok) {
        console.log('🎉 LOGIN FUNCIONANDO! Use essas credenciais:')
        console.log('📧 Email:', adminEmail)
        console.log('🔒 Senha:', adminPassword)
      } else {
        console.log('❌ Erro no login:', loginData)
      }
      
    } else {
      console.log('❌ Erro no cadastro:', signupData)
    }
    
  } catch (error) {
    console.log('💥 Erro geral:', error)
  }
}

// Executar
criarAdministrador()
