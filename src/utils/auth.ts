import { supabase } from '../lib/supabase'
import type { User } from '@supabase/supabase-js'

/**
 * 🔒 VALIDAÇÃO DE SEGURANÇA CRÍTICA
 * Função para garantir user_id consistente para assistenciaallimport10@gmail.com
 */
const USER_ID_ASSISTENCIA = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'

async function validarUsuarioAssistencia(user: User): Promise<User> {
  // Para o email específico da assistência, sempre usar o mesmo user_id
  if (user.email === 'assistenciaallimport10@gmail.com') {
    if (user.id !== USER_ID_ASSISTENCIA) {
      console.warn('⚠️ User ID inconsistente detectado para assistenciaallimport10@gmail.com')
      console.warn('🔧 Corrigindo automaticamente...')
      
      // Retornar user com ID corrigido
      return {
        ...user,
        id: USER_ID_ASSISTENCIA
      }
    }
  }
  
  return user
}

/**
 * Função utilitária para obter o usuário autenticado
 * Funciona tanto com sessões reais do Supabase quanto com sessões de teste simuladas
 */
export async function getAuthenticatedUser(): Promise<User | null> {
  try {
    // Primeiro tentar obter do Supabase
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      // 🔒 APLICAR VALIDAÇÃO DE SEGURANÇA
      return await validarUsuarioAssistencia(user)
    }

    // Se não houver usuário no Supabase, verificar se há uma sessão de teste
    const testUser = localStorage.getItem('test-user')
    const testSession = localStorage.getItem('test-session')
    
    if (testUser && testSession) {
      try {
        const user = JSON.parse(testUser)
        const session = JSON.parse(testSession)
        
        // Verificar se o ID do usuário é válido (deve ser um UUID)
        const isValidUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(user.id)
        
        if (!isValidUUID) {
          // ID inválido, limpar localStorage
          console.log('Sessão com ID inválido detectada, limpando...')
          localStorage.removeItem('test-user')
          localStorage.removeItem('test-session')
          return null
        }
        
        // 🔒 APLICAR VALIDAÇÃO DE SEGURANÇA TAMBÉM PARA SESSÕES DE TESTE
        const validatedUser = await validarUsuarioAssistencia(user)
        
        // Verificar se a sessão ainda é válida (não expirou)
        if (session.expires_at && session.expires_at > Math.floor(Date.now() / 1000)) {
          return validatedUser
        } else {
          // Sessão expirada, limpar localStorage
          localStorage.removeItem('test-user')
          localStorage.removeItem('test-session')
        }
      } catch {
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
 * 🔒 FUNÇÃO REQUIREAUTH COM VALIDAÇÃO DE SEGURANÇA CRÍTICA
 * Garante que o usuário está autenticado e com user_id consistente
 */
export async function requireAuth(): Promise<User> {
  const user = await getAuthenticatedUser()
  
  if (!user) {
    throw new Error('Usuário não autenticado')
  }

  // 🔒 LOG DE SEGURANÇA: Registrar acesso para auditoria
  console.log(`🔐 Acesso autorizado para: ${user.email} (${user.id})`)
  
  return user
}

/**
 * Função utilitária para obter o ID do usuário autenticado
 */
export async function getAuthenticatedUserId(): Promise<string> {
  const user = await requireAuth()
  return user.id
}
