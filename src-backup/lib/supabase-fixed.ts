import { createClient } from '@supabase/supabase-js'

// Configurações hardcoded para garantir funcionamento
const supabaseUrl = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

// Fallback para variáveis de ambiente
const finalUrl = import.meta.env.VITE_SUPABASE_URL || supabaseUrl
const finalKey = import.meta.env.VITE_SUPABASE_ANON_KEY || supabaseAnonKey

console.log('🔧 Supabase Config Loaded:', {
  url: finalUrl,
  hasKey: !!finalKey,
  keyLength: finalKey.length
})

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
