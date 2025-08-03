import { supabase } from '../lib/supabase'
import type { User } from '@supabase/supabase-js'

/**
 * Função utilitária para obter o usuário autenticado
 * Funciona tanto com sessões reais do Supabase quanto com sessões de teste simuladas
 */
export async function getAuthenticatedUser(): Promise<User | null> {
  try {
    // Primeiro tentar obter do Supabase
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      return user
    }

    // Se não houver usuário no Supabase, verificar se há uma sessão de teste
    const testUser = localStorage.getItem('test-user')
    const testSession = localStorage.getItem('test-session')
    
    if (testUser && testSession) {
      try {
        const user = JSON.parse(testUser)
        const session = JSON.parse(testSession)
        
        // Verificar se a sessão ainda é válida (não expirou)
        if (session.expires_at && session.expires_at > Math.floor(Date.now() / 1000)) {
          return user
        } else {
          // Sessão expirada, limpar localStorage
          localStorage.removeItem('test-user')
          localStorage.removeItem('test-session')
        }
      } catch (error) {
        // Erro ao fazer parse, limpar localStorage
        localStorage.removeItem('test-user')
        localStorage.removeItem('test-session')
      }
    }

    return null
  } catch (error) {
    console.error('Erro ao verificar autenticação:', error)
    return null
  }
}

/**
 * Função utilitária para verificar se o usuário está autenticado
 * Lança um erro se não estiver autenticado
 */
export async function requireAuth(): Promise<User> {
  const user = await getAuthenticatedUser()
  
  if (!user) {
    throw new Error('Usuário não autenticado')
  }
  
  return user
}

/**
 * Função utilitária para obter o ID do usuário autenticado
 */
export async function getAuthenticatedUserId(): Promise<string> {
  const user = await requireAuth()
  return user.id
}
