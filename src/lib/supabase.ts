import { createClient } from '@supabase/supabase-js'

// Credenciais atualizadas - 30/08/2025
const SUPABASE_URL = (import.meta as any)?.env?.VITE_SUPABASE_URL || 'https://kmcaaqetxtwkdcczdomw.supabase.co'
const SUPABASE_ANON_KEY = (import.meta as any)?.env?.VITE_SUPABASE_ANON_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('Supabase config missing. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.')
  throw new Error('Invalid Supabase configuration')
}

// Log de debug para verificar configurações
console.log('[supabase] url:', SUPABASE_URL)
console.log('[supabase] key length:', SUPABASE_ANON_KEY.length)
console.log('[supabase] using env vars:', !!(import.meta as any)?.env?.VITE_SUPABASE_URL, !!(import.meta as any)?.env?.VITE_SUPABASE_ANON_KEY)

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
  realtime: {
    params: { eventsPerSecond: 10 },
  },
})

// Types placeholder; expand as needed
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
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}
