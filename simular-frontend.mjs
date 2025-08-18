// Simular o comportamento exato do frontend
import { createClient } from '@supabase/supabase-js'

// Usar exatamente as mesmas configurações do frontend
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
})

async function testarComExatamenteOMesmoFluxo() {
  console.log('🧪 Simulando fluxo EXATO do frontend...\n')
  
  try {
    // 1. Simular tentativa de criar conta
    console.log('1️⃣ Simulando criação de nova conta...')
    const novoEmail = `novousuario${Date.now()}@teste.com`
    const { data: signupData, error: signupError } = await supabase.auth.signUp({
      email: novoEmail,
      password: '123456789'
    })
    
    if (signupError) {
      console.log('❌ Erro na criação de conta:', signupError.message)
      console.log('   Código:', signupError.status)
      console.log('   Nome:', signupError.name)
    } else {
      console.log('✅ Conta criada com sucesso!')
      console.log('   Email:', signupData.user?.email)
      console.log('   Confirmado:', signupData.user?.email_confirmed_at ? 'Sim' : 'Não')
    }
    
    // 2. Simular login do admin (mesmo fluxo do AuthContext)
    console.log('\n2️⃣ Simulando login admin (fluxo AuthContext)...')
    const email = 'admin@pdv.com'
    const password = 'admin123'
    
    const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    
    if (loginError) {
      console.log('❌ Erro no login:', loginError.message)
      console.log('   Código:', loginError.status)
      console.log('   Nome:', loginError.name)
      return
    }
    
    console.log('✅ Login bem-sucedido!')
    console.log('   Email:', loginData.user?.email)
    console.log('   ID:', loginData.user?.id)
    
    // 3. Verificar se é admin (mesmo check do frontend)
    const isAdmin = email === 'admin@pdvallimport.com' || 
                   email === 'novaradiosystem@outlook.com' ||
                   email === 'admin@pdv.com'
    
    console.log('   É Admin:', isAdmin)
    
    if (!isAdmin) {
      console.log('👀 Verificando aprovação do usuário...')
      const { data: approvalData, error: approvalError } = await supabase
        .from('user_approvals')
        .select('status')
        .eq('user_id', loginData.user.id)
        .single()
      
      if (approvalError) {
        console.log('⚠️ Erro ao verificar aprovação:', approvalError.message)
      } else {
        console.log('✅ Status de aprovação:', approvalData.status)
      }
    } else {
      console.log('🔑 Usuário admin - acesso liberado automaticamente')
    }
    
    // 4. Testar sessão
    const { data: sessionData } = await supabase.auth.getSession()
    console.log('\n4️⃣ Sessão atual:')
    console.log('   Ativa:', !!sessionData.session)
    console.log('   User ID:', sessionData.session?.user?.id)
    
  } catch (error) {
    console.log('💥 Erro geral no teste:', error.message)
    console.log('   Stack:', error.stack)
  }
}

testarComExatamenteOMesmoFluxo()
