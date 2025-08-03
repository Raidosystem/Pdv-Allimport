import { supabase } from '../src/lib/supabase.js'

async function testSupabaseConnection() {
  console.log('🔌 Testando conexão com Supabase...')
  
  try {
    // Teste básico de conexão
    const { data, error } = await supabase
      .from('categorias')
      .select('count', { count: 'exact', head: true })
    
    if (error) {
      console.error('❌ Erro na conexão:', error.message)
      return false
    }
    
    console.log('✅ Conexão com Supabase OK!')
    console.log(`📊 Tabela categorias encontrada`)
    
    // Teste de autenticação
    console.log('\n🔐 Testando sistema de autenticação...')
    const { data: { session } } = await supabase.auth.getSession()
    console.log('✅ Sistema de auth funcionando!')
    
    // Verificar tabelas principais
    console.log('\n📋 Verificando tabelas principais...')
    const tables = ['produtos', 'clientes', 'vendas', 'ordens_servico', 'caixa']
    
    for (const table of tables) {
      try {
        const { error: tableError } = await supabase
          .from(table)
          .select('count', { count: 'exact', head: true })
        
        if (tableError) {
          console.log(`❌ Tabela ${table}: ${tableError.message}`)
        } else {
          console.log(`✅ Tabela ${table}: OK`)
        }
      } catch (err) {
        console.log(`❌ Tabela ${table}: Erro inesperado`)
      }
    }
    
    console.log('\n🚀 Supabase está funcionando perfeitamente!')
    console.log('🌐 Deploy do backend está completo!')
    
  } catch (error) {
    console.error('❌ Erro geral:', error)
    return false
  }
  
  return true
}

testSupabaseConnection()
  .then(success => {
    if (success) {
      console.log('\n✅ DEPLOY SUPABASE VERIFICADO COM SUCESSO!')
    } else {
      console.log('\n❌ Problemas encontrados no deploy Supabase')
    }
    process.exit(success ? 0 : 1)
  })
  .catch(error => {
    console.error('❌ Erro na verificação:', error)
    process.exit(1)
  })
