import { createClient } from '@supabase/supabase-js'
import fs from 'fs'

// Configuração do Supabase
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

const supabase = createClient(supabaseUrl, supabaseKey)

async function testarConexao() {
  console.log('🔗 Testando conexão com Supabase...')
  
  try {
    // Testar conexão simples usando uma query direta
    const { data, error } = await supabase
      .rpc('exec_sql', { 
        query: 'SELECT table_name FROM information_schema.tables WHERE table_schema = \'public\' LIMIT 5' 
      })
    
    if (error) {
      console.error('❌ Erro na conexão:', error.message)
      // Tentar método alternativo
      const { data: tables, error: err2 } = await supabase
        .from('pg_tables')
        .select('tablename')
        .eq('schemaname', 'public')
        .limit(5)
      
      if (err2) {
        console.error('❌ Erro alternativo:', err2.message)
        return false
      }
      
      console.log('✅ Conexão estabelecida (método alternativo)!')
      console.log('📊 Tabelas encontradas:', tables.map(t => t.tablename))
      return true
    }
    
    console.log('✅ Conexão estabelecida!')
    console.log('📊 Resultado:', data)
    return true
    
  } catch (err) {
    console.error('❌ Erro de conexão:', err.message)
    return false
  }
}

async function executarComandoSimples() {
  console.log('🎯 Executando comando de teste...')
  
  try {
    // Comando simples para testar
    const { data, error } = await supabase.rpc('exec', {
      query: 'SELECT NOW() as current_time'
    })
    
    if (error) {
      console.error('❌ Erro:', error.message)
    } else {
      console.log('✅ Resultado:', data)
    }
    
  } catch (err) {
    console.error('❌ Erro na execução:', err.message)
  }
}

// Executar testes
async function main() {
  const conectado = await testarConexao()
  if (conectado) {
    await executarComandoSimples()
  }
}

main()
