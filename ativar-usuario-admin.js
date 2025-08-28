// Script para ativar usuário administrativamente no Supabase
console.log('🔧 Ativando usuário administrativamente...')

const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.nJN4QXLXR5uRH4LKZhfANJ8gW8Jjnt0FUqKQx-jgC3w'

// Ativar usuário diretamente via API de admin
async function ativarUsuario() {
  try {
    console.log('🔓 Ativando usuário novaradiosystem@outlook.com...')
    
    // Atualizar usuário para confirmar email
    const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users/3a310812-4d07-4fbb-8c93-61f53198722a`, {
      method: 'PUT',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email_confirm: true,
        ban_duration: 'none'
      })
    })
    
    const data = await response.json()
    console.log('✅ Resultado da ativação:', {
      status: response.status,
      data: data
    })
    
    if (response.ok) {
      console.log('🎉 USUÁRIO ATIVADO COM SUCESSO!')
      
      // Testar login novamente
      console.log('🔐 Testando login após ativação...')
      const loginResponse = await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
        method: 'POST',
        headers: {
          'apikey': SUPABASE_SERVICE_KEY,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email: 'novaradiosystem@outlook.com',
          password: 'admin123'
        })
      })
      
      const loginData = await loginResponse.json()
      console.log('🔓 Teste de login:', {
        status: loginResponse.status,
        success: loginResponse.ok
      })
      
      if (loginResponse.ok) {
        console.log('🚀 LOGIN FUNCIONANDO PERFEITAMENTE!')
        console.log('📧 Use: novaradiosystem@outlook.com')
        console.log('🔒 Senha: admin123')
      }
    }
    
  } catch (error) {
    console.log('💥 Erro:', error)
  }
}

ativarUsuario()
