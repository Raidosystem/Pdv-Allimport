import { createClient } from '@supabase/supabase-js'

// Supabase configuration loaded from environment variables
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || ''
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || ''

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.warn('⚠️ Supabase environment variables are not set.')
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    flowType: 'pkce',
    storage: window.localStorage,
    storageKey: 'supabase.auth.token',
    debug: import.meta.env.DEV
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
  // ❌ NÃO definir Content-Type globalmente pois quebra uploads de arquivo
  // O Supabase SDK define automaticamente o Content-Type correto para cada tipo de requisição
})

// Log de inicialização
console.log('🔧 Supabase inicializado:', {
  url: SUPABASE_URL.substring(0, 30) + '...',
  hasKey: !!SUPABASE_ANON_KEY,
  persistSession: true,
  storageKey: 'supabase.auth.token'
})

// Função para limpar sessão corrompida
export const clearCorruptedSession = async () => {
  try {
    await supabase.auth.signOut()
    localStorage.removeItem('supabase.auth.token')
    sessionStorage.clear()
    console.log('🧹 Sessão corrompida limpa')
  } catch (error) {
    console.error('Erro ao limpar sessão:', error)
  }
}

// Função para verificar e corrigir sessão
export const validateSession = async () => {
  try {
    const { data: { session }, error } = await supabase.auth.getSession()
    
    if (error) {
      console.error('❌ Erro na sessão:', error.message)
      
      // Se for erro de refresh token, limpar sessão
      if (error.message.includes('Invalid Refresh Token') || 
          error.message.includes('Refresh Token Not Found')) {
        console.log('🔄 Limpando refresh token inválido...')
        await clearCorruptedSession()
        return null
      }
    }
    
    return session
  } catch (error) {
    console.error('❌ Erro ao validar sessão:', error)
    await clearCorruptedSession()
    return null
  }
}

// Inicializar verificação de sessão (apenas em desenvolvimento)
if (import.meta.env.DEV) {
  validateSession().then((session) => {
    if (session) {
      console.log('✅ Sessão válida encontrada')
    } else {
      console.log('ℹ️ Nenhuma sessão válida encontrada')
    }
  })
}

// Tipos para o banco de dados (será expandido conforme necessário)
export type Database = {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          email: string
          name: string
          role: 'admin' | 'operator' | 'manager'
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          email: string
          name: string
          role?: 'admin' | 'operator' | 'manager'
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          email?: string
          name?: string
          role?: 'admin' | 'operator' | 'manager'
          created_at?: string
          updated_at?: string
        }
      }
      // Outras tabelas serão adicionadas conforme necessário
    }
  }
}
