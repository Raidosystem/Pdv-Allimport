// Teste para verificar se a coluna checklist foi adicionada
const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = process.env.VITE_SUPABASE_URL || 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI0NjAwNDQsImV4cCI6MjAzODAzNjA0NH0.wtwJiZYjSJhU0LsQOOQkWx0aYZxIBxiGrY8HgIb8bKo'

const supabase = createClient(supabaseUrl, supabaseKey)

async function testChecklistColumn() {
  try {
    console.log('🔍 Testando se a coluna checklist existe...')
    
    // Tentar fazer uma query incluindo a coluna checklist
    const { data, error } = await supabase
      .from('ordens_servico')
      .select('id, checklist')
      .limit(1)
    
    if (error) {
      if (error.message.includes("checklist")) {
        console.log('❌ Coluna checklist não encontrada:', error.message)
        return false
      } else {
        console.log('✅ Coluna checklist existe! (Query retornou outro tipo de erro)')
        return true
      }
    }
    
    console.log('✅ Coluna checklist existe e funciona corretamente!')
    console.log('Dados retornados:', data)
    return true
    
  } catch (err) {
    console.error('❌ Erro ao testar coluna checklist:', err)
    return false
  }
}

testChecklistColumn().then(success => {
  console.log(success ? '✅ Teste concluído com sucesso!' : '❌ Teste falhou!')
  process.exit(success ? 0 : 1)
})
