import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY

// Validação de variáveis de ambiente
if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('❌ Variáveis VITE_SUPABASE_URL ou VITE_SUPABASE_ANON_KEY não configuradas')
  throw new Error('Configurações do Supabase inválidas')
}

console.log('🔧 Supabase Config:', {
  url: SUPABASE_URL,
  hasKey: !!SUPABASE_ANON_KEY,
  keyLength: SUPABASE_ANON_KEY.length
})

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
})

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
