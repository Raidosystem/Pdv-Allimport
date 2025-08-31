import { supabase } from '../lib/supabase'

// Script para verificar dados na base
export async function debugDatabase() {
  console.log('=== DEBUG DATABASE ===')
  
  // Verificar usuário atual
  const { data: { user }, error: userError } = await supabase.auth.getUser()
  console.log('👤 Current user:', user?.id, userError)
  
  if (!user) {
    console.log('❌ Usuário não está logado!')
    return
  }

  // Verificar tabelas
  const tables = ['sales', 'clientes', 'produtos', 'categories', 'service_orders']
  
  for (const table of tables) {
    console.log(`🔍 Verificando tabela: ${table}`)
    
    try {
      const { error, count } = await supabase
        .from(table)
        .select('*', { count: 'exact', head: true })
        .eq('user_id', user.id)
      
      console.log(`📊 ${table}: ${count} registros`, error ? `❌ ${error.message}` : '✅')
    } catch (err) {
      console.log(`❌ Erro ao consultar ${table}:`, err)
    }
  }

  // Verificar dados específicos de vendas
  console.log('🔍 Verificando vendas específicas...')
  const { data: salesData, error: salesError } = await supabase
    .from('sales')
    .select('id, total, data_venda, cliente_id, vendedor')
    .eq('user_id', user.id)
    .limit(5)
  
  console.log('💰 Primeiras 5 vendas:', salesData, salesError)

  // Verificar clientes
  console.log('🔍 Verificando clientes...')
  const { data: clientesData, error: clientesError } = await supabase
    .from('clientes')
    .select('id, nome, email')
    .eq('user_id', user.id)
    .limit(5)
  
  console.log('👥 Primeiros 5 clientes:', clientesData, clientesError)
  
  console.log('=== FIM DEBUG ===')
}
