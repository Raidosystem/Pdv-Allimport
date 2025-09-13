import { supabase } from '../lib/supabase'

export async function testSupabase() {
  try {
    console.log('🔗 Testando conexão com Supabase...')
    
    // Testar autenticação
    const { data: authData, error: authError } = await supabase.auth.getUser()
    console.log('👤 Usuário autenticado:', authData.user?.email || 'Não autenticado')
    
    if (authError) {
      console.warn('⚠️ Erro de autenticação:', authError.message)
    }
    
    // Testar conexão com banco
    const { error: testError } = await supabase
      .from('clientes')
      .select('id')
      .limit(1)
    
    if (testError) {
      console.error('❌ Erro na conexão:', testError.message)
      return {
        success: false,
        error: testError,
        message: 'Erro na conexão com Supabase'
      }
    }
    
    console.log('✅ Conexão com Supabase funcionando')
    
    // Testar outras tabelas
    const tables = ['produtos', 'vendas', 'ordens_servico']
    const results: Record<string, { count?: number; error?: string }> = {}
    
    for (const table of tables) {
      try {
        const { count, error } = await supabase
          .from(table)
          .select('*', { count: 'exact', head: true })
        
        if (error) {
          console.warn(`⚠️ Tabela ${table}:`, error.message)
          results[table] = { error: error.message }
        } else {
          console.log(`📊 Tabela ${table}: ${count} registros`)
          results[table] = { count: count || 0 }
        }
      } catch (err) {
        console.warn(`⚠️ Erro ao testar tabela ${table}:`, err)
        const errorMessage = err instanceof Error ? err.message : 'Erro desconhecido'
        results[table] = { error: errorMessage }
      }
    }
    
    return {
      success: true,
      auth: {
        authenticated: !!authData.user,
        user: authData.user?.email
      },
      tables: results,
      message: 'Teste do Supabase concluído'
    }
  } catch (error) {
    console.error('❌ Erro no teste do Supabase:', error)
    return {
      success: false,
      error: error,
      message: 'Erro durante o teste do Supabase'
    }
  }
}