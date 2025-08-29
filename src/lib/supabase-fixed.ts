import { createClient } from '@supabase/supabase-js'

// Load configuration from environment variables
const finalUrl = import.meta.env.VITE_SUPABASE_URL || ''
const finalKey = import.meta.env.VITE_SUPABASE_ANON_KEY || ''

if (!finalUrl || !finalKey) {
  console.warn('⚠️ Missing Supabase environment variables')
}

export const supabase = createClient(finalUrl, finalKey, {
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
          created_at: string
        }
        Insert: {
          id?: string
          email: string
          created_at?: string
        }
        Update: {
          id?: string
          email?: string
          created_at?: string
        }
      }
    }
  }
}

// Export para uso direto das configurações
export const supabaseConfig = {
  url: finalUrl,
  anonKey: finalKey
}
