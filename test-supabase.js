// Teste de conectividade com Supabase
// Execute este arquivo para verificar se a conexão está funcionando

import { createClient } from '@supabase/supabase-js'

const testSupabaseConnection = async () => {
  try {
    console.log('🔍 Testando conexão com Supabase...')
    
    const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
    const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'
    
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // Testar acesso às tabelas
    console.log('📦 Testando tabela produtos...')
    try {
      const { data: produtos, error: produtosError } = await supabase
        .from('produtos')
        .select('*')
        .limit(5)
      
      if (produtosError) {
        console.log('❌ Erro na tabela produtos:', produtosError.message)
      } else {
        console.log('✅ Produtos encontrados:', produtos?.length || 0)
      }
    } catch (e) {
      console.log('❌ Erro ao acessar produtos:', e.message)
    }
    
    console.log('👥 Testando tabela clientes...')
    try {
      const { data: clientes, error: clientesError } = await supabase
        .from('clientes')
        .select('*')
        .limit(5)
      
      if (clientesError) {
        console.log('❌ Erro na tabela clientes:', clientesError.message)
      } else {
        console.log('✅ Clientes encontrados:', clientes?.length || 0)
      }
    } catch (e) {
      console.log('❌ Erro ao acessar clientes:', e.message)
    }
    
    console.log('📚 Testando tabela categorias...')
    try {
      const { data: categorias, error: categoriasError } = await supabase
        .from('categorias')
        .select('*')
        .limit(5)
      
      if (categoriasError) {
        console.log('❌ Erro na tabela categorias:', categoriasError.message)
      } else {
        console.log('✅ Categorias encontradas:', categorias?.length || 0)
      }
    } catch (e) {
      console.log('❌ Erro ao acessar categorias:', e.message)
    }
    
    console.log('\n🎯 Próximos passos para conectar:')
    console.log('1. Acesse: https://app.supabase.com/project/kmcaaqetxtwkdcczdomw/editor')
    console.log('2. Vá no SQL Editor')
    console.log('3. Execute: ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;')
    console.log('4. Execute: ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;')
    console.log('5. Execute: ALTER TABLE categorias DISABLE ROW LEVEL SECURITY;')
    
  } catch (error) {
    console.log('💥 Erro geral:', error.message)
  }
}

// Executar teste
testSupabaseConnection()
