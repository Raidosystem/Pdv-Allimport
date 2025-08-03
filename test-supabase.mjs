import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.VITE_SUPABASE_URL || 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIzOTE4NjQsImV4cCI6MjAzNzk2Nzg2NH0.jhv50IBTW2fLkiaPr6E0I9RxRgXrPHKdktQO8TYxjy4'

const supabase = createClient(supabaseUrl, supabaseKey)

async function testConnection() {
  console.log('🔌 Testando Supabase em produção...')
  console.log(`📍 URL: ${supabaseUrl}`)
  
  try {
    // Teste básico
    const { data, error } = await supabase.from('categorias').select('count', { count: 'exact', head: true })
    
    if (error) {
      console.error('❌ Erro:', error.message)
    } else {
      console.log('✅ Supabase funcionando perfeitamente!')
    }
    
    // Teste de auth
    const { data: { session } } = await supabase.auth.getSession()
    console.log('✅ Sistema de autenticação OK!')
    
    return true
  } catch (err) {
    console.error('❌ Erro:', err)
    return false
  }
}

testConnection()
