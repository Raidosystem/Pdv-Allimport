import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

console.log('🔍 Testando conexão com Supabase...')

async function testarSupabase() {
  try {
    const supabase = createClient(supabaseUrl, supabaseAnonKey)
    
    console.log('✅ Cliente Supabase criado')
    
    // Teste simples de conexão
    const { data, error } = await supabase
      .from('users')
      .select('count(*)')
      .limit(1)
    
    if (error) {
      console.log('❌ Erro na consulta:', error.message)
      console.log('📄 Detalhes do erro:', JSON.stringify(error, null, 2))
    } else {
      console.log('✅ Conexão com Supabase funcionando!')
      console.log('📊 Dados retornados:', data)
    }
    
    // Testar se o usuário admin existe
    const { data: adminUser, error: adminError } = await supabase.auth.signInWithPassword({
      email: 'admin@pdv.com',
      password: 'admin123'
    })
    
    if (adminError) {
      console.log('❌ Erro no login admin:', adminError.message)
    } else {
      console.log('✅ Login admin funcionando!')
      console.log('👤 Usuário:', adminUser.user?.email)
    }
    
  } catch (error) {
    console.log('💥 Erro geral:', error.message)
  }
}

testarSupabase()
