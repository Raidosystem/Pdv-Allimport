import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

async function testarAuth() {
  try {
    const supabase = createClient(supabaseUrl, supabaseAnonKey)
    
    console.log('🔍 Testando autenticação Supabase...')
    
    // 1. Testar login do admin
    console.log('\n1️⃣ Testando login admin@pdv.com...')
    const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
      email: 'admin@pdv.com',
      password: 'admin123'
    })
    
    if (loginError) {
      console.log('❌ Erro no login:', loginError.message)
      console.log('📄 Código do erro:', loginError.status)
    } else {
      console.log('✅ Login admin bem-sucedido!')
      console.log('👤 Email:', loginData.user?.email)
      console.log('🆔 ID:', loginData.user?.id)
    }
    
    // 2. Testar criação de nova conta
    console.log('\n2️⃣ Testando criação de nova conta...')
    const testEmail = `teste${Date.now()}@exemplo.com`
    const { data: signupData, error: signupError } = await supabase.auth.signUp({
      email: testEmail,
      password: '123456789'
    })
    
    if (signupError) {
      console.log('❌ Erro na criação:', signupError.message)
      console.log('📄 Código do erro:', signupError.status)
    } else {
      console.log('✅ Criação de conta bem-sucedida!')
      console.log('👤 Email:', signupData.user?.email)
    }
    
    // 3. Testar sessão atual
    console.log('\n3️⃣ Verificando sessão atual...')
    const { data: sessionData } = await supabase.auth.getSession()
    console.log('🔐 Sessão ativa:', !!sessionData.session)
    
  } catch (error) {
    console.log('💥 Erro geral:', error.message)
  }
}

testarAuth()
