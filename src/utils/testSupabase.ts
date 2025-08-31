// Teste básico de conexão com Supabase
import { supabase } from '../lib/supabase'

export async function testSupabaseConnection() {
  console.log('🔍 Testando conexão com Supabase...')
  
  try {
    // Teste 1: Verificar se o Supabase está configurado
    console.log('📡 Supabase configurado')
    
    // Teste 2: Verificar usuário atual
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    console.log('👤 Usuário atual:', user?.id, user?.email, userError)
    
    if (!user) {
      console.log('❌ Usuário não está logado')
      return { error: 'Usuário não está logado', user: null }
    }
    
    // Teste 3: Fazer uma query simples
    console.log('🔍 Testando query simples...')
    const { data, error } = await supabase
      .from('sales')
      .select('id')
      .limit(1)
    
    console.log('📊 Query resultado:', data, error)
    
    return { user, data, error }
    
  } catch (error) {
    console.error('❌ Erro no teste:', error)
    return { error: error, user: null }
  }
}
