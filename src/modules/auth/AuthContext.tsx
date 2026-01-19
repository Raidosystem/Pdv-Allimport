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
  sendWhatsAppCode: (userId: string, phone: string) => Promise<boolean>
  verifyWhatsAppCode: (userId: string, code: string) => Promise<boolean>
  resendWhatsAppCode: (userId: string, phone: string) => Promise<boolean>
  signInLocal?: (userData: any) => Promise<void>
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
    // Definir loading como false imediatamente para não bloquear UI
    setLoading(false)
    
    // Obter sessão de forma assíncrona sem bloquear
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setUser(session?.user ?? null)
    }).catch(err => {
      console.error('Erro ao obter sessão:', err)
    })

    // Escutar mudanças de autenticação do Supabase
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session)
      setUser(session?.user ?? null)
    })

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    // Usar autenticação normal do Supabase
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    // Retornar resultado direto do Supabase (sem verificação de aprovação)
    // Todos os usuários com contas válidas podem fazer login
    return { data, error }
  }

  const signUp = async (email: string, password: string, metadata?: Record<string, unknown>) => {
    console.log('=== SIGNUP AuthContext ===')
    console.log('📧 Email:', email)
    console.log('📋 Metadata:', metadata)
    
    try {
      // APENAS criar conta no Supabase Auth
      // O resto do fluxo (aprovação, trial) é feito pelo SignupPageNew após verificar email
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: metadata,
          // Sem emailRedirectTo - verificação é feita via código OTP
        }
      })

      console.log('📊 Supabase signUp result:', { 
        userId: data?.user?.id, 
        hasError: !!error 
      })
      
      if (error) {
        console.error('❌ Signup error:', error)
        throw error
      }

      // Retornar dados para o SignupPageNew continuar o fluxo
      return { data, error: null }
      
    } catch (err: any) {
      console.error('❌ SignUp error:', err)
      return {
        data: null,
        error: err
      }
    }
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
    // ✅ Não usamos mais localStorage para funcionario_id - tudo em Supabase Auth
    
    // Limpar estado local
    setUser(null)
    setSession(null)
    
    // Fazer logout do Supabase também (caso tenha uma sessão real)
    const { error } = await supabase.auth.signOut()
    return { error }
  }

  const resendConfirmation = async (email: string) => {
    // URL base para produção e desenvolvimento
    const baseUrl = import.meta.env.VITE_APP_URL || 'https://pdv.gruporaval.com.br'
    
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
    const baseUrl = import.meta.env.VITE_APP_URL || 'https://pdv.gruporaval.com.br'
    
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

  /**
   * Enviar código de verificação via WhatsApp
   */
  const sendWhatsAppCode = async (userId: string, phone: string): Promise<boolean> => {
    try {
      // Chamar função do Supabase que gera e envia o código
      const { data, error } = await supabase.rpc('generate_verification_code', {
        p_user_id: userId,
        p_phone: phone
      })

      if (error) {
        console.error('Erro ao gerar código:', error)
        throw error
      }

      // Enviar código via WhatsApp (em produção)
      // Por enquanto, apenas loga no console
      console.log('📱 Código gerado:', data)
      console.log('📱 Telefone:', phone)
      
      // TODO: Integrar com serviço de WhatsApp real
      // const { whatsappService } = await import('../../services/whatsappService')
      // await whatsappService.sendVerificationCode(phone, data[0].code)

      return true
    } catch (error) {
      console.error('Erro ao enviar código:', error)
      return false
    }
  }

  /**
   * Verificar código de WhatsApp
   */
  const verifyWhatsAppCode = async (userId: string, code: string): Promise<boolean> => {
    try {
      const { data, error } = await supabase.rpc('verify_whatsapp_code', {
        p_user_id: userId,
        p_code: code
      })

      if (error) {
        console.error('Erro ao verificar código:', error)
        throw error
      }

      return data === true
    } catch (error) {
      console.error('Erro ao verificar código:', error)
      throw error
    }
  }

  /**
   * Reenviar código de verificação
   */
  const resendWhatsAppCode = async (userId: string, phone: string): Promise<boolean> => {
    return sendWhatsAppCode(userId, phone)
  }

  /**
   * Login local (MANTÉM sessão Supabase Auth original)
   */
  const signInLocal = async (userData: any) => {
    console.log('🔐 Login local iniciado:', userData)
    
    // ✅ MANTER SESSÃO ORIGINAL DO SUPABASE AUTH
    // Apenas adicionar metadados do funcionário ao contexto
    console.log('✅ Mantendo sessão Supabase Auth original')
    
    try {
      // Obter sessão atual (do admin/dono da empresa)
      const { data: { session: currentSession } } = await supabase.auth.getSession()
      
      if (!currentSession?.user) {
        console.error('❌ Nenhuma sessão ativa encontrada')
        throw new Error('Sessão expirada. Faça login novamente.')
      }
      
      // Salvar dados do funcionário no localStorage para manter contexto
      const funcionarioContext = {
        funcionario_id: userData.id,
        user_id: userData.user_id,
        nome: userData.nome,
        email: userData.email,
        tipo_admin: userData.tipo_admin,
        empresa_id: userData.empresa_id,
        funcao_id: userData.funcao_id,
        funcao_nome: userData.funcao_nome,
        permissions: userData.permissions || []
      }
      
      localStorage.setItem('pdv_funcionario_context', JSON.stringify(funcionarioContext))
      console.log('✅ Contexto do funcionário salvo:', funcionarioContext)
      
      // Atualizar user metadata para incluir dados do funcionário
      const updatedUser = {
        ...currentSession.user,
        user_metadata: {
          ...currentSession.user.user_metadata,
          funcionario_context: funcionarioContext
        }
      } as User
      
      setUser(updatedUser)
      
      // Disparar evento para recarregar permissões
      window.dispatchEvent(new CustomEvent('pdv_permissions_reload', {
        detail: funcionarioContext
      }))
      
      console.log('✅ Login local completo (sessão Supabase mantida)')
      console.log('🔑 Funcionário ID:', userData.id)
      console.log('👤 User ID (auth):', currentSession.user.id)
      console.log('🏢 Empresa ID:', userData.empresa_id)
      console.log('🔔 Evento pdv_permissions_reload disparado')
      
    } catch (error) {
      console.error('❌ Erro no login local:', error)
      throw error
    }
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
    sendWhatsAppCode,
    verifyWhatsAppCode,
    resendWhatsAppCode,
    signInLocal,
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
