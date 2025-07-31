import { supabase } from '../lib/supabase'

/**
 * Teste de conexão com o Supabase
 */
export async function testSupabaseConnection() {
  try {
    const { error } = await supabase
      .from('_test')
      .select('*')
      .limit(1)
    
    if (error && error.code !== 'PGRST116') {
      console.error('Erro na conexão com Supabase:', error)
      return false
    }
    
    console.log('✅ Conexão com Supabase estabelecida com sucesso!')
    return true
  } catch (error) {
    console.error('❌ Falha na conexão com Supabase:', error)
    return false
  }
}

/**
 * Verificar autenticação
 */
export async function checkAuth() {
  try {
    const { data: { user }, error } = await supabase.auth.getUser()
    
    if (error) {
      console.log('Usuário não autenticado')
      return null
    }
    
    console.log('✅ Usuário autenticado:', user?.email)
    return user
  } catch (error) {
    console.error('❌ Erro ao verificar autenticação:', error)
    return null
  }
}

/**
 * Função para fazer login (para teste)
 */
export async function signInWithEmail(email: string, password: string) {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      console.error('❌ Erro no login:', error.message)
      return { user: null, error }
    }

    console.log('✅ Login realizado com sucesso!')
    return { user: data.user, error: null }
  } catch (error) {
    console.error('❌ Erro inesperado no login:', error)
    return { user: null, error }
  }
}

/**
 * Função para fazer logout
 */
export async function signOut() {
  try {
    const { error } = await supabase.auth.signOut()
    
    if (error) {
      console.error('❌ Erro no logout:', error.message)
      return false
    }
    
    console.log('✅ Logout realizado com sucesso!')
    return true
  } catch (error) {
    console.error('❌ Erro inesperado no logout:', error)
    return false
  }
}
