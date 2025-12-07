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

    // Retornar resultado direto do Supabase (sem verificação de aprovação)
    // Todos os usuários com contas válidas podem fazer login
    return { data, error }
  }

  const signUp = async (email: string, password: string, metadata?: Record<string, unknown>) => {
    console.log('=== SIGNUP DEBUG ===')
    console.log('Email:', email)
    console.log('Is Admin:', ADMIN_EMAILS.includes(email.toLowerCase()))
    
    try {
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
      
      // Tratamento específico para erro de webhook 404
      if (error) {
        const errorMessage = error.message || ''
        console.error('❌ Signup error details:', {
          message: errorMessage,
          status: (error as any).status,
          code: (error as any).code
        })
        
        // Se for erro de webhook/hook 404
        if (errorMessage.includes('404') || errorMessage.includes('hook') || errorMessage.includes('webhook')) {
          throw new Error('ERRO DE CONFIGURAÇÃO: O sistema de autenticação está com um webhook configurado incorretamente no Supabase. Por favor, acesse o Dashboard do Supabase → Authentication → Hooks e desative/delete todos os webhooks configurados.')
        }
        
        // Outros erros
        throw error
      }

      // Se a conta foi criada com sucesso
      if (data.user) {
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
          console.log('Non-admin user - auto-approving and logging in')
          
          // Para usuários normais, auto-aprovar e inserir na tabela user_approvals
          try {
            // Inserir o usuário na tabela de aprovações como aprovado
            const { error: insertError } = await supabase
              .from('user_approvals')
              .insert({
                user_id: data.user.id,
                email: email,
                full_name: metadata?.full_name || 'Usuário',
                company_name: metadata?.company_name || 'Não informado',
                cpf_cnpj: metadata?.cpf_cnpj,
                whatsapp: metadata?.whatsapp,
                document_type: metadata?.document_type,
                phone_verified: false, // Será verificado depois
                status: 'pending', // Pendente até verificar WhatsApp
                user_role: 'owner',
                created_at: new Date().toISOString()
              })
            
            if (insertError) {
              console.error('Warning: Could not insert into user_approvals:', insertError)
            }
            
            // Enviar código de verificação via WhatsApp
            if (metadata?.whatsapp) {
              await sendWhatsAppCode(data.user.id, metadata.whatsapp as string)
            }
            
            // Retornar sucesso para ir para tela de verificação
            return { data: { user: data.user, session: null }, error: null }
          } catch (err) {
            console.log('Error in auto-approval process:', err)
            throw err
          }
        }
      }

      return { data, error: null }
    } catch (err: any) {
      console.error('SignUp error:', err)
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
   * Login local (sem Supabase Auth)
   */
  const signInLocal = async (userData: any) => {
    console.log('🔐 Login local iniciado:', userData)
    
    // 🚨 CRITICAL: Fazer logout da sessão admin ANTES de criar sessão do funcionário
    console.log('🚪 Fazendo logout da sessão admin antes de criar sessão do funcionário...')
    await supabase.auth.signOut()
    
    // Buscar email da empresa (que já está logada)
    let empresaEmail = user?.email || 'local@user.com'
    
    try {
      // Se temos empresa_id, buscar o email dela
      if (userData.empresa_id && empresaEmail === 'local@user.com') {
        const { data: empresaData } = await supabase
          .from('empresas')
          .select('email')
          .eq('id', userData.empresa_id)
          .single()
        
        if (empresaData?.email) {
          empresaEmail = empresaData.email
          console.log('📧 Email da empresa encontrado:', empresaEmail)
        }
      }
      
      // Tentar fazer login real no Supabase usando o email do funcionário
      // Isso criará uma sessão válida que o RLS reconhece
      if (userData.email && userData.token) {
        console.log('🔑 Tentando autenticação real com email:', userData.email)
        
        // Verificar se existe uma sessão válida do Supabase
        const { data: sessionData, error: sessionError } = await supabase.auth.getSession()
        
        if (sessionError) {
          console.warn('⚠️ Erro ao verificar sessão:', sessionError)
        }
        
        // Se não há sessão válida, criar uma sessão "fake" mas funcional
        // usando setSession com os dados do funcionário
        const localUser = {
          id: userData.user_id || userData.id, // ✅ USAR user_id DO FUNCIONÁRIO
          email: userData.email || empresaEmail, // ✅ EMAIL DO FUNCIONÁRIO
          user_metadata: {
            nome: userData.nome,
            tipo_admin: userData.tipo_admin,
            empresa_id: userData.empresa_id,
            funcionario_id: userData.funcionario_id
          },
          app_metadata: {
            provider: 'local',
            empresa_id: userData.empresa_id
          },
          aud: 'authenticated',
          created_at: new Date().toISOString(),
          role: 'authenticated'
        } as User

        const localSession = {
          access_token: userData.token || 'local-session-token',
          refresh_token: userData.token || 'local-refresh-token',
          token_type: 'bearer',
          user: localUser,
          expires_at: Math.floor(Date.now() / 1000) + 28800,
          expires_in: 28800
        } as Session

        // Tentar definir a sessão no Supabase
        const { error: setSessionError } = await supabase.auth.setSession({
          access_token: localSession.access_token,
          refresh_token: localSession.refresh_token
        })

        if (setSessionError) {
          console.warn('⚠️ Não foi possível definir sessão no Supabase:', setSessionError)
          console.log('💡 Usando sessão local sem integração Supabase auth')
        } else {
          console.log('✅ Sessão definida no Supabase com sucesso')
        }

        setUser(localUser)
        setSession(localSession)
        
        // ✅ NÃO usamos mais localStorage - cada funcionário tem conta própria no Supabase Auth
        console.log('✅ Login local completo:', localUser)
        console.log('🔑 User ID (user_id do funcionário):', userData.user_id || userData.id)
        console.log('🏢 Empresa ID:', userData.empresa_id)
        
        return
      }
    } catch (error) {
      console.error('❌ Erro no login local:', error)
    }
    
    // Fallback: criar user/session básico
    const localUser = {
      id: userData.user_id || userData.id, // ✅ USAR user_id DO FUNCIONÁRIO, NÃO empresa_id
      email: userData.email || empresaEmail, // ✅ EMAIL DO FUNCIONÁRIO se disponível
      user_metadata: {
        nome: userData.nome,
        tipo_admin: userData.tipo_admin,
        empresa_id: userData.empresa_id,
        funcionario_id: userData.funcionario_id
      },
      app_metadata: {},
      aud: 'authenticated',
      created_at: new Date().toISOString()
    } as User

    const localSession = {
      access_token: userData.token,
      token_type: 'bearer',
      user: localUser,
      expires_at: Math.floor(Date.now() / 1000) + 28800,
      expires_in: 28800
    } as Session

    setUser(localUser)
    setSession(localSession)
    
    // ✅ NÃO usamos mais localStorage - cada funcionário tem conta própria no Supabase Auth
    console.log('✅ Login local completo (modo fallback):', localUser)
    console.log('🔑 User ID (user_id do funcionário):', userData.user_id || userData.id)
    console.log('🏢 Empresa ID:', userData.empresa_id)
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
