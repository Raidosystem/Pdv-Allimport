import { createClient } from '@supabase/supabase-js'

// CONFIGURAÇÕES FORÇADAS - IGNORAR .env.production
const SUPABASE_URL = 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg'

// Verificação de segurança
if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('❌ Configurações do Supabase não encontradas!');
  throw new Error('Configurações do Supabase inválidas');
}

console.log('🔧 Supabase Config FORÇADO (correto):', {
  url: SUPABASE_URL,
  hasKey: !!SUPABASE_ANON_KEY,
  keyLength: SUPABASE_ANON_KEY.length,
  envUrl: import.meta.env.VITE_SUPABASE_URL,
  envKey: import.meta.env.VITE_SUPABASE_ANON_KEY ? 'Present' : 'Missing'
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
