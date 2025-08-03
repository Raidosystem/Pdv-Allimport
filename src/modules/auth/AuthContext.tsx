import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import type { User, Session, AuthError } from '@supabase/supabase-js'
import { supabase } from '../../lib/supabase'

interface AuthContextType {
  user: User | null
  session: Session | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<{ data: unknown; error: AuthError | null }>
  signUp: (email: string, password: string, metadata?: Record<string, unknown>) => Promise<{ data: unknown; error: AuthError | null }>
  signOut: () => Promise<{ error: AuthError | null }>
  resendConfirmation: (email: string) => Promise<{ data: unknown; error: AuthError | null }>
  resetPassword: (email: string) => Promise<{ data: unknown; error: AuthError | null }>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

interface AuthProviderProps {
  children: ReactNode
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Verificar se há uma sessão de teste salva
    const testUser = localStorage.getItem('test-user')
    const testSession = localStorage.getItem('test-session')
    
    if (testUser && testSession) {
      try {
        const user = JSON.parse(testUser)
        const session = JSON.parse(testSession)
        
        // Verificar se a sessão ainda é válida (não expirou)
        if (session.expires_at && session.expires_at > Math.floor(Date.now() / 1000)) {
          setUser(user)
          setSession(session)
          setLoading(false)
          return
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

    // Obter sessão atual do Supabase
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setUser(session?.user ?? null)
      setLoading(false)
    })

    // Escutar mudanças de autenticação do Supabase
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session)
      setUser(session?.user ?? null)
      setLoading(false)
    })

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    // Verificação para credenciais de teste
    if (email === 'teste@teste.com' && password === 'teste@@') {
      // Criar uma sessão simulada para o usuário de teste
      const mockUser = {
        id: 'test-user-id',
        email: 'teste@teste.com',
        user_metadata: {
          name: 'Usuário Teste'
        },
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        aud: 'authenticated',
        role: 'authenticated',
        app_metadata: {},
        email_confirmed_at: new Date().toISOString(),
        phone: '',
        confirmation_sent_at: undefined,
        confirmed_at: new Date().toISOString(),
        recovery_sent_at: undefined,
        email_change_sent_at: undefined,
        new_email: undefined,
        invited_at: undefined,
        action_link: undefined,
        email_change: undefined,
        phone_change: undefined,
        factors: undefined,
        identities: []
      } as unknown as User

      const mockSession = {
        access_token: 'mock-access-token',
        refresh_token: 'mock-refresh-token',
        expires_in: 3600,
        expires_at: Math.floor(Date.now() / 1000) + 3600,
        token_type: 'bearer',
        user: mockUser
      } as Session

      setUser(mockUser)
      setSession(mockSession)
      
      // Salvar no localStorage para persistir entre reloads
      localStorage.setItem('test-user', JSON.stringify(mockUser))
      localStorage.setItem('test-session', JSON.stringify(mockSession))
      
      return { data: { user: mockUser, session: mockSession }, error: null }
    }

    // Caso contrário, usar autenticação normal do Supabase
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    return { data, error }
  }

  const signUp = async (email: string, password: string, metadata?: Record<string, unknown>) => {
    // URL base para produção e desenvolvimento
    const baseUrl = import.meta.env.VITE_APP_URL || 'https://pdv-allimport.vercel.app'
    
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: metadata,
        emailRedirectTo: `${baseUrl}/confirm-email`,
      }
    })
    return { data, error }
  }

  const signOut = async () => {
    // Limpar dados de teste do localStorage
    localStorage.removeItem('test-user')
    localStorage.removeItem('test-session')
    
    // Limpar estado local
    setUser(null)
    setSession(null)
    
    // Fazer logout do Supabase também (caso tenha uma sessão real)
    const { error } = await supabase.auth.signOut()
    return { error }
  }

  const resendConfirmation = async (email: string) => {
    // URL base para produção e desenvolvimento
    const baseUrl = import.meta.env.VITE_APP_URL || 'https://pdv-allimport.vercel.app'
    
    const { data, error } = await supabase.auth.resend({
      type: 'signup',
      email,
      options: {
        emailRedirectTo: `${baseUrl}/confirm-email`
      }
    })
    return { data, error }
  }

  const resetPassword = async (email: string) => {
    // URL base para produção e desenvolvimento
    const baseUrl = import.meta.env.VITE_APP_URL || 'https://pdv-allimport.vercel.app'
    
    const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${baseUrl}/reset-password`
    })
    return { data, error }
  }

  const value: AuthContextType = {
    user,
    session,
    loading,
    signIn,
    signUp,
    signOut,
    resendConfirmation,
    resetPassword,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

export default AuthContext
