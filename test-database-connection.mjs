import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

const supabase = createClient(supabaseUrl, supabaseKey)

async function testDatabaseConnection() {
  console.log('🔌 Testando conexão completa com Supabase...')
  console.log(`📍 URL: ${supabaseUrl}`)
  
  try {
    // Teste 1: Verificar tabelas existentes
    console.log('\n📊 Testando acesso às tabelas...')
    
    const tables = ['categorias', 'produtos', 'clientes', 'vendas', 'caixa', 'ordens_servico']
    
    for (const table of tables) {
      try {
        const { data, error } = await supabase
          .from(table)
          .select('*', { count: 'exact', head: true })
        
        if (error) {
          console.log(`❌ ${table}: ${error.message}`)
        } else {
          console.log(`✅ ${table}: OK (${data?.length || 0} registros)`)
        }
      } catch (err) {
        console.log(`❌ ${table}: Erro de conexão`)
      }
    }
    
    // Teste 2: Verificar autenticação
    console.log('\n🔐 Testando autenticação...')
    const { data: { session }, error: authError } = await supabase.auth.getSession()
    
    if (authError) {
      console.log('❌ Erro de autenticação:', authError.message)
    } else {
      console.log('✅ Sistema de autenticação funcionando')
      console.log('👤 Usuário logado:', session?.user?.email || 'Nenhum')
    }
    
    // Teste 3: Verificar configurações
    console.log('\n⚙️ Verificando configurações...')
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    
    if (userError) {
      console.log('ℹ️ Nenhum usuário logado (normal para testes)')
    } else {
      console.log('✅ Usuário ativo:', user?.email)
    }
    
    console.log('\n✅ Teste de conexão concluído!')
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message)
  }
}

// Executar teste
testDatabaseConnection()
