import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import type { User, Session, AuthError } from '@supabase/supabase-js'
import { supabase } from '../../lib/supabase'
import { SubscriptionService } from '../../services/subscriptionService'

const ADMIN_EMAILS = (import.meta.env.VITE_ADMIN_EMAILS || '')
  .split(',')
  .map((e: string) => e.trim().toLowerCase())
  .filter(Boolean)

interface AuthContextType {
  user: User | null
  session: Session | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<{ data: unknown; error: AuthError | null }>
  signUp: (email: string, password: string, metadata?: Record<string, unknown>) => Promise<{ data: unknown; error: AuthError | null }>
  signUpEmployee: (email: string, password: string, metadata: Record<string, unknown>) => Promise<{ data: unknown; error: AuthError | null }>
  signOut: () => Promise<{ error: AuthError | null }>
  resendConfirmation: (email: string) => Promise<{ data: unknown; error: AuthError | null }>
  resetPassword: (email: string) => Promise<{ data: unknown; error: AuthError | null }>
  checkAccess: () => Promise<boolean>
  isAdmin: () => boolean
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
    // Usar autenticação normal do Supabase
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    // Se login bem-sucedido, verificar se usuário está aprovado
    if (data.user && !error) {
      // Verificar se é admin (sempre aprovado)
      const isAdmin = ADMIN_EMAILS.includes(email.toLowerCase())

      if (!isAdmin) {
        // Verificar status de aprovação para usuários normais
        const { data: approvalData, error: approvalError } = await supabase
          .from('user_approvals')
          .select('status')
          .eq('user_id', data.user.id)
          .single()
        
        if (approvalError || !approvalData) {
          // Se não encontrou registro de aprovação, criar um pendente
          await supabase.from('user_approvals').insert({
            user_id: data.user.id,
            email: data.user.email,
            status: 'pending'
          })
          
          // Fazer logout e retornar erro
          await supabase.auth.signOut()
          return { 
            data: null, 
            error: { 
              message: 'Sua conta está pendente de aprovação pelo administrador. Aguarde a aprovação para acessar o sistema.',
              name: 'PENDING_APPROVAL'
            } as any 
          }
        }
        
        if (approvalData.status !== 'approved') {
          // Usuário não aprovado, fazer logout
          await supabase.auth.signOut()
          return { 
            data: null, 
            error: { 
              message: approvalData.status === 'rejected' 
                ? 'Sua conta foi rejeitada pelo administrador. Entre em contato para mais informações.'
                : 'Sua conta está pendente de aprovação pelo administrador. Aguarde a aprovação para acessar o sistema.',
              name: 'PENDING_APPROVAL'
            } as any 
          }
        }
      }
    }

    return { data, error }
  }

  const signUp = async (email: string, password: string, metadata?: Record<string, unknown>) => {
    console.log('=== SIGNUP DEBUG ===')
    console.log('Email:', email)
    console.log('Is Admin:', ADMIN_EMAILS.includes(email.toLowerCase()))
    
    // Criar conta sem obrigar confirmação de email
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: metadata,
        // Removido emailRedirectTo para evitar fluxo de confirmação obrigatório
      }
    })

    console.log('Supabase signUp result:', { data, error })

    // Se a conta foi criada com sucesso
    if (data.user && !error) {
      // Verificar se é admin (admins são auto-aprovados)
      const isAdmin = ADMIN_EMAILS.includes(email.toLowerCase())
      
      console.log('User created, isAdmin:', isAdmin)
      
      if (isAdmin) {
        // Para admins, fazer login automático
        const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
          email,
          password
        })
        
        if (loginData.user && !loginError) {
          console.log('Admin auto-login success')
          return { data: loginData, error: null }
        }
      } else {
        console.log('Non-admin user - checking approval system')
        // Para usuários normais, verificar se a tabela de aprovação existe
        try {
          const { error: approvalError } = await supabase
            .from('user_approvals')
            .select('user_id')
            .eq('user_id', data.user.id)
            .limit(1)
          
          console.log('Approval table check error:', approvalError)
          
          if (approvalError && approvalError.code === '42P01') {
            // Tabela não existe - forçar logout e informar
            await supabase.auth.signOut()
            console.log('Approval system not configured')
            return { 
              data: { 
                user: data.user, 
                session: null 
              }, 
              error: {
                message: 'APPROVAL_SYSTEM_NOT_CONFIGURED',
                name: 'SETUP_REQUIRED'
              } as any
            }
          }
          
          // Tabela existe - fazer logout normal e aguardar aprovação
          await supabase.auth.signOut()
          console.log('User created, logging out for approval')
          return { 
            data: { 
              user: data.user, 
              session: null 
            }, 
            error: {
              message: 'PENDING_APPROVAL',
              name: 'PENDING_APPROVAL'
            } as any
          }
        } catch (err) {
          // Em caso de erro, forçar logout de segurança
          await supabase.auth.signOut()
          return { 
            data: { 
              user: data.user, 
              session: null 
            }, 
            error: {
              message: 'PENDING_APPROVAL',
              name: 'PENDING_APPROVAL'
            } as any
          }
        }
      }
    }

    return { data, error }
  }

  const signUpEmployee = async (email: string, password: string, metadata: Record<string, unknown>) => {
    console.log('=== EMPLOYEE SIGNUP DEBUG ===')
    console.log('Email:', email)
    console.log('Parent user:', user?.id)
    
    // Verificar se o usuário atual é um owner
    if (!user) {
      return { 
        data: null, 
        error: { 
          message: 'Você precisa estar logado para criar funcionários',
          name: 'NOT_LOGGED_IN'
        } as any
      }
    }

    // Criar conta do funcionário com metadata especial
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          ...metadata,
          role: 'employee',
          parent_user_id: user.id // ID do usuário principal (owner)
        }
      }
    })

    console.log('Employee signup result:', { data, error })

    if (data.user && !error) {
      console.log('Employee created successfully, inserting into user_approvals...')
      
      // Inserir manualmente na user_approvals (workaround para trigger problem)
      try {
        const { error: insertError } = await supabase
          .from('user_approvals')
          .insert({
            user_id: data.user.id,
            email: email,
            full_name: metadata.full_name as string || 'Funcionário',
            company_name: 'Assistencia All-import',
            status: 'approved',
            user_role: 'employee',
            parent_user_id: user.id,
            created_by: user.id,
            approved_at: new Date().toISOString(),
            approved_by: user.id
          })
        
        if (insertError) {
          console.error('❌ Erro ao inserir na user_approvals:', insertError)
          // Mesmo com erro na inserção, o usuário foi criado no auth
          return { 
            data: {
              user: data.user,
              session: null
            }, 
            error: { 
              message: 'Usuário criado mas houve erro ao configurar permissões',
              name: 'PARTIAL_SUCCESS'
            } as any
          }
        } else {
          console.log('✅ Funcionário inserido na user_approvals com sucesso')
        }
      } catch (insertErr) {
        console.error('❌ Erro na inserção manual:', insertErr)
      }
      
      return { 
        data: {
          user: data.user,
          session: null // Funcionários não fazem login automático
        }, 
        error: null 
      }
    }

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

  const checkAccess = async (): Promise<boolean> => {
    if (!user?.email) return false
    
    // Admins sempre têm acesso
    if (isAdmin()) return true
    
    try {
      return await SubscriptionService.hasAccess(user.email)
    } catch (error) {
      console.error('Erro ao verificar acesso:', error)
      return false
    }
  }

  const isAdmin = (): boolean => {
    return ADMIN_EMAILS.includes(user?.email?.toLowerCase() || '') ||
           user?.app_metadata?.role === 'admin'
  }

  const value: AuthContextType = {
    user,
    session,
    loading,
    signIn,
    signUp,
    signUpEmployee,
    signOut,
    resendConfirmation,
    resetPassword,
    checkAccess,
    isAdmin,
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
