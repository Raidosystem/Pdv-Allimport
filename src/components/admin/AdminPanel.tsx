import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Users, Shield, Mail, Eye, EyeOff, CheckCircle, XCircle, UserPlus, Database, Crown } from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { Input } from '../ui/Input'
import { supabase } from '../../lib/supabase'
import { useAuth } from '../../modules/auth'
import { ensureAdminUserExists } from '../../utils/createAdminUser'
import { SubscriptionService } from '../../services/subscriptionService'
import toast from 'react-hot-toast'

interface AdminUser {
  id: string
  email: string
  email_confirmed_at: string | null
  created_at: string
  last_sign_in_at: string | null
  user_metadata: any
  app_metadata: any
  banned_until: string | null
  // Novos campos para aprovação
  approval_status?: 'pending' | 'approved' | 'rejected'
  full_name?: string
  company_name?: string
  approved_by?: string
  approved_at?: string
  // Campos hierárquicos
  user_role?: 'owner' | 'employee'
  parent_user_id?: string
  created_by?: string
  // Dados REAIS da assinatura
  subscription?: {
    id: string
    status: string // 'pending', 'trial', 'active', 'expired', 'cancelled'
    trial_start_date?: string
    trial_end_date?: string
    subscription_start_date?: string
    subscription_end_date?: string
    days_remaining?: number
    is_paused?: boolean
    plan_type?: string
  }
}

export function AdminPanel() {
  const { user } = useAuth()
  const navigate = useNavigate()
  const [users, setUsers] = useState<AdminUser[]>([])
  const [loading, setLoading] = useState(true)
  const [newUserEmail, setNewUserEmail] = useState('')
  const [newUserPassword, setNewUserPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [creating, setCreating] = useState(false)

  // Estados para login administrativo
  const [loginEmail, setLoginEmail] = useState('')
  const [loginPassword, setLoginPassword] = useState('')
  const [loggingIn, setLoggingIn] = useState(false)
  const [showLoginPassword, setShowLoginPassword] = useState(false)

  // Estados para modal de assinatura
  const [showSubscriptionModal, setShowSubscriptionModal] = useState(false)
  const [selectedUser, setSelectedUser] = useState<AdminUser | null>(null)
  const [daysToAdd, setDaysToAdd] = useState(30)

  // Verificar se o usuário atual é admin ou se não está logado (para configuração inicial)
  const isAdmin = !user || // Permitir acesso quando não logado para configuração inicial
                  user?.email === 'admin@pdvallimport.com' || 
                  user?.email === 'novaradiosystem@outlook.com' || 
                  user?.app_metadata?.role === 'admin'

  useEffect(() => {
    if (isAdmin) {
      loadUsers()
    }
  }, [isAdmin])

  const loadUsers = async () => {
    try {
      setLoading(true)
      
      // Verificar se a tabela user_approvals existe
      const { data: tableExists } = await supabase
        .from('user_approvals')
        .select('count')
        .limit(1)
        .maybeSingle()
      
      if (!tableExists && tableExists !== null) {
        toast.error('Sistema de aprovação não configurado. Execute o script SQL primeiro.')
        return
      }
      
      // Carregar usuários da tabela user_approvals com hierarquia
      const { data: approvals, error } = await supabase
        .from('user_approvals')
        .select(`
          user_id,
          email,
          full_name,
          company_name,
          status,
          approved_by,
          approved_at,
          created_at,
          user_role,
          parent_user_id,
          created_by
        `)
        .order('created_at', { ascending: false })
      
      if (error) {
        console.error('Erro ao carregar aprovações:', error)
        if (error.code === 'PGRST116') {
          toast.error('Tabela user_approvals não existe. Execute o script SQL de configuração.')
        } else {
          toast.error(`Erro ao carregar lista de usuários: ${error.message}`)
        }
        return
      }
      
      // Buscar assinaturas REAIS de todos os usuários
      const userIds = approvals?.map(a => a.user_id) || []
      const { data: subscriptions, error: subError } = await supabase
        .from('subscriptions')
        .select('*')
        .in('user_id', userIds)
      
      if (subError) {
        console.warn('Aviso ao carregar assinaturas:', subError.message)
      }
      
      // Criar mapa de assinaturas por user_id
      const subscriptionMap = new Map()
      subscriptions?.forEach(sub => {
        // Calcular dias restantes em tempo real
        let daysRemaining = 0
        const now = new Date()
        
        if (sub.status === 'trial' && sub.trial_end_date) {
          const endDate = new Date(sub.trial_end_date)
          const diffTime = endDate.getTime() - now.getTime()
          daysRemaining = Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)))
        } else if (sub.status === 'active' && sub.subscription_end_date) {
          const endDate = new Date(sub.subscription_end_date)
          const diffTime = endDate.getTime() - now.getTime()
          daysRemaining = Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)))
        }
        
        subscriptionMap.set(sub.user_id, {
          id: sub.id,
          status: sub.status,
          trial_start_date: sub.trial_start_date,
          trial_end_date: sub.trial_end_date,
          subscription_start_date: sub.subscription_start_date,
          subscription_end_date: sub.subscription_end_date,
          days_remaining: daysRemaining,
          is_paused: sub.payment_status === 'paused' || false,
          plan_type: sub.status
        })
      })
      
      // Converter para formato AdminUser com dados REAIS de assinatura
      const adminUsers: AdminUser[] = approvals?.map(approval => ({
        id: approval.user_id,
        email: approval.email,
        email_confirmed_at: approval.status === 'approved' ? approval.approved_at : null,
        created_at: approval.created_at,
        last_sign_in_at: null,
        user_metadata: { 
          full_name: approval.full_name,
          company_name: approval.company_name 
        },
        app_metadata: {},
        banned_until: null,
        approval_status: approval.status as 'pending' | 'approved' | 'rejected',
        full_name: approval.full_name,
        company_name: approval.company_name,
        approved_by: approval.approved_by,
        approved_at: approval.approved_at,
        user_role: approval.user_role,
        parent_user_id: approval.parent_user_id,
        created_by: approval.created_by,
        subscription: subscriptionMap.get(approval.user_id) // Dados REAIS da assinatura
      })) || []
      
      setUsers(adminUsers)
      console.log(`✅ Carregados ${adminUsers.length} usuários com assinaturas reais`)
      
    } catch (error) {
      console.error('Erro:', error)
      toast.error('Erro ao conectar com o sistema de usuários')
    } finally {
      setLoading(false)
    }
  }

  const approveUser = async (userId: string, email: string) => {
    try {
      // 1. Atualizar status de aprovação
      const { error: approvalError } = await supabase
        .from('user_approvals')
        .update({
          status: 'approved',
          approved_by: user?.id,
          approved_at: new Date().toISOString()
        })
        .eq('user_id', userId)
      
      if (approvalError) {
        console.error('Erro ao aprovar usuário:', approvalError)
        toast.error('Erro ao aprovar usuário')
        return
      }

      // 2. Ativar período de teste de 30 dias
      try {
        const trialResult = await SubscriptionService.activateTrial(email)
        if (trialResult.success) {
          toast.success(`✅ ${email} aprovado com período de teste de 30 dias!`)
        } else {
          toast.error(`⚠️ ${email} aprovado, mas houve erro ao ativar período de teste`)
        }
      } catch (trialError) {
        console.error('Erro ao ativar período de teste:', trialError)
        toast.error(`⚠️ ${email} aprovado, mas houve erro ao ativar período de teste`)
      }
      
      loadUsers() // Recarregar lista
    } catch (err) {
      console.error('Erro ao aprovar usuário:', err)
      toast.error('Erro ao aprovar usuário')
    }
  }

  const rejectUser = async (userId: string, email: string) => {
    try {
      const { error } = await supabase
        .from('user_approvals')
        .update({
          status: 'rejected',
          approved_by: user?.id,
          approved_at: new Date().toISOString()
        })
        .eq('user_id', userId)
      
      if (error) {
        console.error('Erro ao rejeitar usuário:', error)
        toast.error('Erro ao rejeitar usuário')
        return
      }
      
      toast.success(`Usuário ${email} rejeitado`)
      loadUsers()
    } catch (err) {
      console.error('Erro ao rejeitar usuário:', err)
      toast.error('Erro ao rejeitar usuário')
    }
  }

  const openSubscriptionModal = (user: AdminUser) => {
    setSelectedUser(user)
    setShowSubscriptionModal(true)
    setDaysToAdd(30)
  }

  const closeSubscriptionModal = () => {
    setShowSubscriptionModal(false)
    setSelectedUser(null)
    setDaysToAdd(30)
  }

  const addSubscriptionDays = async () => {
    if (!selectedUser || daysToAdd <= 0) {
      toast.error('Selecione um número válido de dias')
      return
    }

    const loadingToast = toast.loading('Adicionando dias de assinatura...')

    try {
      if (!selectedUser.subscription) {
        toast.dismiss(loadingToast)
        toast.error('Usuário não possui assinatura')
        return
      }

      // Calcular nova data de expiração
      const currentEndDate = selectedUser.subscription.status === 'trial' 
        ? new Date(selectedUser.subscription.trial_end_date || Date.now())
        : new Date(selectedUser.subscription.subscription_end_date || Date.now())
      
      const newEndDate = new Date(currentEndDate.getTime() + (daysToAdd * 24 * 60 * 60 * 1000))

      // Atualizar assinatura no banco de dados
      const updateData: any = {
        updated_at: new Date().toISOString()
      }

      if (selectedUser.subscription.status === 'trial') {
        updateData.trial_end_date = newEndDate.toISOString()
      } else {
        updateData.subscription_end_date = newEndDate.toISOString()
      }

      const { error } = await supabase
        .from('subscriptions')
        .update(updateData)
        .eq('user_id', selectedUser.id)

      if (error) {
        throw error
      }

      toast.dismiss(loadingToast)
      toast.success(`✅ ${daysToAdd} dias adicionados para ${selectedUser.full_name || selectedUser.email}!`)
      
      closeSubscriptionModal()
      await loadUsers() // Recarregar dados atualizados
    } catch (error) {
      console.error('Erro ao adicionar dias:', error)
      toast.dismiss(loadingToast)
      toast.error('Erro ao adicionar dias de assinatura')
    }
  }

  const toggleUserStatus = async (_userId: string, _email: string, _currentlyBanned: boolean) => {
    toast.error('Função não disponível sem permissões admin do Supabase')
  }

  const deleteUser = async (_userId: string, _email: string) => {
    toast.error('Função não disponível sem permissões admin do Supabase')
  }

  const createUser = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!newUserEmail || !newUserPassword) {
      toast.error('Preencha email e senha')
      return
    }

    try {
      setCreating(true)
      
      // Usar signup normal em vez de admin.createUser
      const { data, error } = await supabase.auth.signUp({
        email: newUserEmail,
        password: newUserPassword,
        options: {
          data: {
            full_name: 'Funcionário Criado pelo Admin',
            created_by_admin: true, // Marcar que foi criado pelo admin
            role: 'employee'
          }
        }
      })

      if (error) {
        toast.error(`Erro ao criar usuário: ${error.message}`)
        return
      }

      // Se o usuário foi criado com sucesso, aprová-lo automaticamente
      if (data.user) {
        try {
          // Aguardar um pouco para o trigger criar o registro
          await new Promise(resolve => setTimeout(resolve, 1000))
          
          // Aprovar automaticamente usuários criados pelo admin
          const { error: approvalError } = await supabase
            .from('user_approvals')
            .update({
              status: 'approved',
              approved_by: user?.id,
              approved_at: new Date().toISOString()
            })
            .eq('user_id', data.user.id)
          
          if (approvalError) {
            console.error('Erro ao aprovar automaticamente:', approvalError)
            toast.success(`Usuário ${newUserEmail} criado! Precisa ser aprovado manualmente.`)
          } else {
            toast.success(`✅ Funcionário ${newUserEmail} criado e aprovado automaticamente!`)
          }
        } catch (approvalErr) {
          console.error('Erro no processo de aprovação automática:', approvalErr)
          toast.success(`Usuário ${newUserEmail} criado! Precisa ser aprovado manualmente.`)
        }
      }

      setNewUserEmail('')
      setNewUserPassword('')
      loadUsers() // Recarregar lista
    } catch (error) {
      console.error('Erro ao criar usuário:', error)
      toast.error('Erro inesperado ao criar usuário')
    } finally {
      setCreating(false)
    }
  }

  const createMainAdmin = async () => {
    try {
      setCreating(true)
      const result = await ensureAdminUserExists()
      
      if (result.success) {
        if (result.exists) {
          toast.success('Usuário administrador principal já existe!')
        } else {
          toast.success('Usuário administrador principal criado com sucesso!')
        }
        loadUsers()
      } else {
        toast.error(`Erro: ${result.error}`)
      }
    } catch (error) {
      console.error('Erro ao criar admin principal:', error)
      toast.error('Erro inesperado')
    } finally {
      setCreating(false)
    }
  }

  // Função para login administrativo
  const handleAdminLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!loginEmail || !loginPassword) {
      toast.error('Preencha email e senha')
      return
    }

    try {
      setLoggingIn(true)
      
      const { error } = await supabase.auth.signInWithPassword({
        email: loginEmail,
        password: loginPassword
      })

      if (error) {
        toast.error(`Erro no login: ${error.message}`)
        return
      }

      toast.success('Login realizado com sucesso!')
      // O componente será re-renderizado automaticamente devido ao useAuth
    } catch (error) {
      console.error('Erro no login:', error)
      toast.error('Erro inesperado no login')
    } finally {
      setLoggingIn(false)
    }
  }

  // Mostrar acesso negado apenas se há um usuário logado que não é admin
  const shouldShowAccessDenied = user && !isAdmin

  if (shouldShowAccessDenied) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <Card className="p-8 text-center max-w-lg">
          <Shield className="w-16 h-16 mx-auto mb-4 text-red-500" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Acesso Negado</h1>
          <div className="text-gray-600 mb-6 space-y-3">
            <p>O usuário <strong>{user.email}</strong> não tem permissões de administrador.</p>
            <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
              <h3 className="font-semibold text-blue-800 mb-2">📝 Acesso Restrito</h3>
              <div className="text-sm text-blue-700 space-y-2">
                <div className="bg-white p-3 rounded border">
                  <p className="font-medium">Para acessar o painel administrativo:</p>
                  <p>• Faça logout desta conta</p>
                  <p>• Entre com uma conta de administrador</p>
                  <p>• Contate o administrador do sistema se necessário</p>
                </div>
              </div>
            </div>
          </div>
          <div className="space-y-3">
            <Button onClick={() => supabase.auth.signOut()} className="w-full">
              Fazer Logout
            </Button>
            <Link to="/login">
              <Button variant="outline" className="w-full">
                Ir para Login
              </Button>
            </Link>
            <Link to="/dashboard">
              <Button variant="ghost" className="w-full">
                Voltar ao PDV
              </Button>
            </Link>
          </div>
        </Card>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Se não há usuário logado, mostrar login rápido */}
      {!user && (
        <div className="min-h-screen bg-gradient-to-br from-indigo-900 via-indigo-800 to-black flex items-center justify-center p-4">
          <div className="p-8 text-center max-w-md bg-white/95 backdrop-blur-sm border-0 shadow-2xl rounded-xl">
            <Shield className="w-16 h-16 mx-auto mb-4 text-indigo-600" />
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Painel Administrativo</h1>
            <p className="text-gray-600 mb-6">Faça login para acessar o painel administrativo</p>
            
            {/* Formulário de Login Direto */}
            <form onSubmit={handleAdminLogin} className="space-y-4 mb-6">
              <div className="text-left">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Email Admin
                </label>
                <Input
                  type="email"
                  value={loginEmail}
                  onChange={(e) => setLoginEmail(e.target.value)}
                  placeholder="admin@exemplo.com"
                  required
                />
              </div>
              
              <div className="text-left">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Senha
                </label>
                <div className="relative">
                  <Input
                    type={showLoginPassword ? 'text' : 'password'}
                    value={loginPassword}
                    onChange={(e) => setLoginPassword(e.target.value)}
                    placeholder="Sua senha admin"
                    required
                  />
                  <button
                    type="button"
                    onClick={(e) => {
                      e.preventDefault()
                      e.stopPropagation()
                      setShowLoginPassword(!showLoginPassword)
                    }}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  >
                    {showLoginPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>
              
              <button
                type="submit"
                disabled={loggingIn}
                className="w-full bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg font-medium disabled:opacity-50"
                onClick={(e) => {
                  e.stopPropagation()
                }}
              >
                {loggingIn ? 'Entrando...' : 'Fazer Login Admin'}
              </button>
            </form>

            {/* Login Admin */}
            <div className="space-y-4 mb-6">
              <div className="bg-indigo-50 p-4 rounded-lg border border-indigo-200">
                <h3 className="font-semibold text-indigo-800 mb-2">� Acesso Administrativo</h3>
                <div className="text-sm text-indigo-700 mb-3">
                  <p>Entre com suas credenciais de administrador para acessar o painel.</p>
                </div>
              </div>
            </div>
            
            <div className="space-y-3">
              <button 
                onClick={(e) => {
                  e.preventDefault()
                  e.stopPropagation()
                  navigate('/signup')
                }}
                className="w-full px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
              >
                Criar Conta Admin Principal
              </button>
              <button 
                onClick={(e) => {
                  e.preventDefault()
                  e.stopPropagation()
                  navigate('/dashboard')
                }}
                className="w-full px-4 py-2 text-sm font-medium text-gray-600 bg-transparent hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
              >
                Voltar ao PDV
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Conteúdo normal do admin quando logado */}
      {user && (
        <>
          {/* Header */}
          <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              <Link to="/dashboard">
                <Button variant="ghost" size="sm" className="text-gray-600 hover:text-gray-800">
                  ← Voltar ao PDV
                </Button>
              </Link>
              <div className="flex items-center space-x-3">
                <Shield className="w-8 h-8 text-indigo-600" />
                <div>
                  <h1 className="text-xl font-bold text-gray-900">Painel Administrativo</h1>
                  <p className="text-sm text-gray-600">Gerenciamento de usuários PDV</p>
                </div>
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              <span className="text-sm text-gray-600">Admin:</span>
              <span className="font-medium text-indigo-600">{user?.email}</span>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8 space-y-8">
        
        {/* Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-6 gap-6">
          <Card className="p-6">
            <div className="flex items-center">
              <Users className="w-8 h-8 text-blue-500" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Total de Usuários</p>
                <p className="text-2xl font-bold text-gray-900">{users.length}</p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <Crown className="w-8 h-8 text-purple-500" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Proprietários</p>
                <p className="text-2xl font-bold text-gray-900">
                  {users.filter(u => u.user_role === 'owner' || !u.user_role).length}
                </p>
              </div>
            </div>
          </Card>

          <Card className="p-6">
            <div className="flex items-center">
              <Users className="w-8 h-8 text-blue-500" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Funcionários</p>
                <p className="text-2xl font-bold text-gray-900">
                  {users.filter(u => u.user_role === 'employee').length}
                </p>
              </div>
            </div>
          </Card>
          
          <Card className="p-6">
            <div className="flex items-center">
              <CheckCircle className="w-8 h-8 text-green-500" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Usuários Aprovados</p>
                <p className="text-2xl font-bold text-gray-900">
                  {users.filter(u => u.approval_status === 'approved').length}
                </p>
              </div>
            </div>
          </Card>
          
          <Card className="p-6">
            <div className="flex items-center">
              <Mail className="w-8 h-8 text-orange-500" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Aguardando Aprovação</p>
                <p className="text-2xl font-bold text-gray-900">
                  {users.filter(u => u.approval_status === 'pending').length}
                </p>
              </div>
            </div>
          </Card>
          
          <Card className="p-6">
            <div className="flex items-center">
              <XCircle className="w-8 h-8 text-red-500" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Usuários Desativados</p>
                <p className="text-2xl font-bold text-gray-900">
                  {users.filter(u => u.banned_until).length}
                </p>
              </div>
            </div>
          </Card>
        </div>

        {/* Criar Admin Principal */}
        <Card className="p-6 bg-gradient-to-r from-indigo-50 to-purple-50 border-indigo-200">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Crown className="w-8 h-8 text-indigo-600" />
              <div>
                <h2 className="text-xl font-semibold text-indigo-900">Usuário Administrador Principal</h2>
                <p className="text-sm text-indigo-600">Criar ou verificar o usuário admin principal do sistema</p>
              </div>
            </div>
            
            <Button
              onClick={createMainAdmin}
              disabled={creating}
              variant="primary"
              className="bg-indigo-600 hover:bg-indigo-700"
            >
              {creating ? 'Criando...' : 'Criar/Verificar Admin'}
            </Button>
          </div>
        </Card>

        {/* Criar Novo Proprietário */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl shadow-xl p-8 text-white">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-3xl font-bold mb-2 flex items-center">
                <UserPlus className="w-8 h-8 mr-3" />
                Criar Novo Proprietário
              </h2>
              <p className="text-blue-100 text-lg">
                Adicione manualmente um novo proprietário do sistema PDV
              </p>
            </div>
          </div>
          
          <form onSubmit={createUser} className="grid grid-cols-1 md:grid-cols-4 gap-4 mt-6">
            <div>
              <label className="block text-sm font-semibold text-blue-100 mb-2">
                Email *
              </label>
              <Input
                type="email"
                value={newUserEmail}
                onChange={(e) => setNewUserEmail(e.target.value)}
                placeholder="proprietario@empresa.com"
                className="bg-white/95"
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-semibold text-blue-100 mb-2">
                Senha *
              </label>
              <div className="relative">
                <Input
                  type={showPassword ? 'text' : 'password'}
                  value={newUserPassword}
                  onChange={(e) => setNewUserPassword(e.target.value)}
                  placeholder="Digite uma senha segura"
                  className="bg-white/95 pr-10"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-semibold text-blue-100 mb-2">
                Nome da Empresa
              </label>
              <Input
                type="text"
                placeholder="Nome da Empresa"
                className="bg-white/95"
              />
            </div>
            
            <div className="flex items-end">
              <Button
                type="submit"
                disabled={creating}
                className="w-full bg-white text-blue-600 hover:bg-blue-50 font-semibold shadow-lg hover:shadow-xl transition-all"
              >
                {creating ? 'Criando...' : '✅ Criar Proprietário'}
              </Button>
            </div>
          </form>
        </div>

        {/* Lista de Proprietários em Cards */}
        <div>
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl font-bold text-gray-900 flex items-center gap-3">
              <Database className="w-7 h-7 text-blue-600" />
              Proprietários do Sistema PDV
            </h2>
            
            <Button
              onClick={loadUsers}
              disabled={loading}
              variant="secondary"
              size="sm"
              className="shadow-md"
            >
              {loading ? '🔄 Atualizando...' : '🔄 Atualizar Lista'}
            </Button>
          </div>

          {loading ? (
            <div className="flex items-center justify-center py-16">
              <div className="text-center">
                <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-blue-600 mx-auto mb-4"></div>
                <p className="text-gray-600 font-medium">Carregando proprietários...</p>
              </div>
            </div>
          ) : users.filter(u => u.user_role !== 'employee').length === 0 ? (
            <Card className="p-12 text-center">
              <Users className="w-16 h-16 mx-auto mb-4 text-gray-400" />
              <h3 className="text-xl font-bold text-gray-900 mb-2">Nenhum proprietário encontrado</h3>
              <p className="text-gray-600">Use o formulário acima para adicionar o primeiro proprietário do sistema</p>
            </Card>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {users.filter(u => u.user_role !== 'employee').map((user) => (
                <div key={user.id} className="bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all p-6 border-2 border-gray-100 hover:border-blue-200">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-center flex-1">
                      <div className="w-14 h-14 bg-gradient-to-br from-purple-500 to-purple-600 rounded-full flex items-center justify-center text-white text-xl font-bold shadow-md mr-4">
                        {user.full_name?.charAt(0).toUpperCase() || user.email.charAt(0).toUpperCase()}
                      </div>
                      <div className="flex-1">
                        <h3 className="font-bold text-lg text-gray-900 mb-1">
                          {user.full_name || user.email.split('@')[0]}
                        </h3>
                        <div className="flex gap-2 flex-wrap">
                          <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold ${
                            user.approval_status === 'approved'
                              ? 'bg-green-100 text-green-800 border border-green-300' 
                              : user.approval_status === 'rejected'
                              ? 'bg-red-100 text-red-800 border border-red-300'
                              : 'bg-yellow-100 text-yellow-800 border border-yellow-300'
                          }`}>
                            {user.approval_status === 'approved' ? '✅ Ativo' : 
                             user.approval_status === 'rejected' ? '❌ Rejeitado' : 
                             '⏳ Aguardando'}
                          </span>
                          {user.banned_until && (
                            <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-bold bg-red-100 text-red-800 border border-red-300">
                              🚫 Pausado
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Informações de Assinatura REAIS */}
                  {user.approval_status === 'approved' && user.subscription && (
                    <div className="mb-4 p-3 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl border-2 border-blue-200">
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-xs font-bold text-blue-900">📋 PLANO</span>
                        <span className={`px-2 py-1 text-white text-xs font-bold rounded-full ${
                          user.subscription.status === 'trial' 
                            ? 'bg-blue-600' 
                            : user.subscription.status === 'active'
                            ? 'bg-green-600'
                            : user.subscription.status === 'expired'
                            ? 'bg-red-600'
                            : 'bg-gray-600'
                        }`}>
                          {user.subscription.status === 'trial' 
                            ? '🎁 TESTE' 
                            : user.subscription.status === 'active'
                            ? '⭐ PREMIUM'
                            : user.subscription.status === 'expired'
                            ? '❌ EXPIRADO'
                            : '⏳ PENDENTE'}
                        </span>
                      </div>
                      <div className="text-xs text-blue-800 font-semibold space-y-1">
                        <div>⏰ Dias restantes: <span className={`text-blue-900 font-bold ${
                          (user.subscription.days_remaining || 0) <= 5 ? 'text-red-600' : 
                          (user.subscription.days_remaining || 0) <= 10 ? 'text-yellow-600' : ''
                        }`}>{user.subscription.days_remaining || 0} dias</span></div>
                        
                        {user.subscription.status === 'trial' && user.subscription.trial_end_date && (
                          <div>📅 Expira em: {new Date(user.subscription.trial_end_date).toLocaleDateString('pt-BR')}</div>
                        )}
                        
                        {user.subscription.status === 'active' && user.subscription.subscription_end_date && (
                          <div>📅 Renova em: {new Date(user.subscription.subscription_end_date).toLocaleDateString('pt-BR')}</div>
                        )}
                        
                        {user.subscription.is_paused && (
                          <div className="mt-1 px-2 py-1 bg-yellow-100 text-yellow-800 rounded text-xs font-bold">
                            ⏸️ PAUSADO
                          </div>
                        )}
                      </div>
                    </div>
                  )}
                  
                  {/* Sem assinatura mas aprovado */}
                  {user.approval_status === 'approved' && !user.subscription && (
                    <div className="mb-4 p-3 bg-yellow-50 rounded-xl border-2 border-yellow-200">
                      <div className="text-xs text-yellow-800 font-semibold">
                        ⚠️ Sem assinatura ativa - Crie manualmente
                      </div>
                    </div>
                  )}

                  <div className="space-y-2 mb-4">
                    <div className="flex items-center text-sm text-gray-700 bg-gray-50 p-2 rounded-lg">
                      <Mail className="w-4 h-4 mr-2 text-blue-600 flex-shrink-0" />
                      <span className="truncate">{user.email}</span>
                    </div>
                    {user.company_name && (
                      <div className="flex items-center text-sm text-gray-700 bg-gray-50 p-2 rounded-lg">
                        <Crown className="w-4 h-4 mr-2 text-purple-600 flex-shrink-0" />
                        <span className="truncate">{user.company_name}</span>
                      </div>
                    )}
                    <div className="flex items-center text-sm text-gray-600 bg-gray-50 p-2 rounded-lg">
                      <span className="mr-2">📅</span>
                      Cadastrado em {new Date(user.created_at).toLocaleDateString('pt-BR')}
                    </div>
                    {user.last_sign_in_at && (
                      <div className="flex items-center text-sm text-gray-600 bg-gray-50 p-2 rounded-lg">
                        <span className="mr-2">🕐</span>
                        Último acesso: {new Date(user.last_sign_in_at).toLocaleDateString('pt-BR')}
                      </div>
                    )}
                  </div>

                  <div className="flex gap-2 pt-4 border-t-2 border-gray-100">
                    {user.approval_status === 'pending' && (
                      <>
                        <Button
                          onClick={() => approveUser(user.id, user.email)}
                          size="sm"
                          className="flex-1 bg-green-600 hover:bg-green-700 text-white font-semibold"
                          title="Aprovar proprietário e ativar teste de 30 dias"
                        >
                          <CheckCircle className="w-4 h-4 mr-1" />
                          Aprovar
                        </Button>
                        <Button
                          onClick={() => rejectUser(user.id, user.email)}
                          size="sm"
                          variant="outline"
                          className="flex-1 border-2 border-red-300 text-red-600 hover:bg-red-50 font-semibold"
                          title="Rejeitar proprietário"
                        >
                          <XCircle className="w-4 h-4 mr-1" />
                          Rejeitar
                        </Button>
                      </>
                    )}
                    
                    {user.approval_status === 'rejected' && (
                      <Button
                        onClick={() => approveUser(user.id, user.email)}
                        size="sm"
                        className="flex-1 bg-green-600 hover:bg-green-700 text-white font-semibold"
                        title="Aprovar proprietário e ativar teste de 30 dias"
                      >
                        <CheckCircle className="w-4 h-4 mr-1" />
                        Aprovar
                      </Button>
                    )}

                    {user.approval_status === 'approved' && (
                      <>
                        <Button
                          onClick={() => openSubscriptionModal(user)}
                          size="sm"
                          className="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-semibold"
                          title="Gerenciar assinatura e adicionar dias"
                        >
                          💳 Assinatura
                        </Button>
                        
                        <Button
                          onClick={() => toggleUserStatus(user.id, user.email, !!user.banned_until)}
                          size="sm"
                          className={`flex-1 ${user.banned_until ? 'bg-green-600 hover:bg-green-700 text-white' : 'bg-orange-600 hover:bg-orange-700 text-white'} font-semibold`}
                          title={user.banned_until ? "Reativar acesso do proprietário" : "Pausar acesso do proprietário"}
                        >
                          {user.banned_until ? (
                            <>
                              <Eye className="w-4 h-4 mr-1" />
                              Reativar
                            </>
                          ) : (
                            <>
                              <EyeOff className="w-4 h-4 mr-1" />
                              Pausar
                            </>
                          )}
                        </Button>
                      </>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Modal de Gerenciar Assinatura */}
        {showSubscriptionModal && selectedUser && (
          <div className="fixed inset-0 z-50 overflow-y-auto">
            <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20">
              <div className="fixed inset-0 bg-black bg-opacity-50 transition-opacity backdrop-blur-sm" onClick={closeSubscriptionModal}></div>
              
              <div className="relative bg-white rounded-2xl shadow-2xl max-w-2xl w-full">
                {/* Header do Modal */}
                <div className="bg-gradient-to-r from-blue-600 to-indigo-700 text-white px-8 py-6 rounded-t-2xl">
                  <div className="flex items-center justify-between">
                    <div>
                      <h2 className="text-2xl font-bold flex items-center">
                        💳 Gerenciar Assinatura
                      </h2>
                      <p className="text-blue-100 mt-1">
                        {selectedUser.full_name || selectedUser.email}
                      </p>
                    </div>
                    <button onClick={closeSubscriptionModal} className="w-10 h-10 flex items-center justify-center rounded-full bg-white/20 hover:bg-white/30 transition-colors">
                      <XCircle className="w-6 h-6" />
                    </button>
                  </div>
                </div>

                <div className="p-8">
                  {/* Informações Atuais REAIS */}
                  <div className="mb-6 p-4 bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl border-2 border-blue-200">
                    <h3 className="font-bold text-blue-900 mb-3 flex items-center">
                      <Database className="w-5 h-5 mr-2" />
                      Status Atual da Assinatura
                    </h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="bg-white p-3 rounded-lg">
                        <p className="text-xs text-gray-600 mb-1">Plano</p>
                        <p className={`font-bold ${
                          selectedUser.subscription?.status === 'trial' ? 'text-blue-900' :
                          selectedUser.subscription?.status === 'active' ? 'text-green-900' :
                          'text-gray-900'
                        }`}>
                          {selectedUser.subscription?.status === 'trial' ? '🎁 TESTE' :
                           selectedUser.subscription?.status === 'active' ? '⭐ PREMIUM' :
                           selectedUser.subscription?.status === 'expired' ? '❌ EXPIRADO' :
                           '⏳ PENDENTE'}
                        </p>
                      </div>
                      <div className="bg-white p-3 rounded-lg">
                        <p className="text-xs text-gray-600 mb-1">Dias Restantes</p>
                        <p className={`font-bold ${
                          (selectedUser.subscription?.days_remaining || 0) <= 5 ? 'text-red-600' :
                          (selectedUser.subscription?.days_remaining || 0) <= 10 ? 'text-yellow-600' :
                          'text-green-600'
                        }`}>
                          {selectedUser.subscription?.days_remaining || 0} dias
                        </p>
                      </div>
                      <div className="bg-white p-3 rounded-lg">
                        <p className="text-xs text-gray-600 mb-1">Data de Início</p>
                        <p className="font-bold text-gray-900">
                          {selectedUser.subscription?.trial_start_date 
                            ? new Date(selectedUser.subscription.trial_start_date).toLocaleDateString('pt-BR')
                            : selectedUser.subscription?.subscription_start_date
                            ? new Date(selectedUser.subscription.subscription_start_date).toLocaleDateString('pt-BR')
                            : new Date(selectedUser.created_at).toLocaleDateString('pt-BR')}
                        </p>
                      </div>
                      <div className="bg-white p-3 rounded-lg">
                        <p className="text-xs text-gray-600 mb-1">Vencimento</p>
                        <p className="font-bold text-orange-600">
                          {selectedUser.subscription?.trial_end_date 
                            ? new Date(selectedUser.subscription.trial_end_date).toLocaleDateString('pt-BR')
                            : selectedUser.subscription?.subscription_end_date
                            ? new Date(selectedUser.subscription.subscription_end_date).toLocaleDateString('pt-BR')
                            : 'Não definido'}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Adicionar Dias */}
                  <div className="mb-6">
                    <h3 className="font-bold text-gray-900 mb-4 flex items-center text-lg">
                      <CheckCircle className="w-5 h-5 mr-2 text-green-600" />
                      Adicionar Dias de Assinatura
                    </h3>
                    
                    <div className="space-y-4">
                      {/* Input de Dias */}
                      <div>
                        <label className="block text-sm font-semibold text-gray-700 mb-2">
                          Quantidade de Dias
                        </label>
                        <input
                          type="number"
                          value={daysToAdd}
                          onChange={(e) => setDaysToAdd(parseInt(e.target.value) || 0)}
                          min="1"
                          max="3650"
                          className="w-full px-4 py-3 text-lg font-bold border-2 border-gray-300 rounded-xl focus:outline-none focus:border-blue-500 transition-colors text-center"
                          placeholder="30"
                        />
                      </div>

                      {/* Botões Rápidos */}
                      <div>
                        <p className="text-sm font-semibold text-gray-700 mb-2">Atalhos Rápidos:</p>
                        <div className="grid grid-cols-4 gap-2">
                          <button
                            onClick={() => setDaysToAdd(7)}
                            className="px-4 py-3 bg-gray-100 hover:bg-blue-100 hover:text-blue-700 font-bold rounded-xl transition-colors border-2 border-gray-200 hover:border-blue-300"
                          >
                            7 dias
                          </button>
                          <button
                            onClick={() => setDaysToAdd(30)}
                            className="px-4 py-3 bg-blue-100 text-blue-700 hover:bg-blue-200 font-bold rounded-xl transition-colors border-2 border-blue-300"
                          >
                            30 dias
                          </button>
                          <button
                            onClick={() => setDaysToAdd(90)}
                            className="px-4 py-3 bg-gray-100 hover:bg-green-100 hover:text-green-700 font-bold rounded-xl transition-colors border-2 border-gray-200 hover:border-green-300"
                          >
                            90 dias
                          </button>
                          <button
                            onClick={() => setDaysToAdd(365)}
                            className="px-4 py-3 bg-gray-100 hover:bg-purple-100 hover:text-purple-700 font-bold rounded-xl transition-colors border-2 border-gray-200 hover:border-purple-300"
                          >
                            1 ano
                          </button>
                        </div>
                      </div>

                      {/* Preview com dados REAIS */}
                      {daysToAdd > 0 && selectedUser.subscription && (
                        <div className="p-4 bg-green-50 border-2 border-green-300 rounded-xl">
                          <p className="text-sm text-green-800 mb-1 font-semibold">✨ Nova Data de Vencimento:</p>
                          <p className="text-2xl font-bold text-green-900">
                            {(() => {
                              const currentEndDate = selectedUser.subscription.status === 'trial'
                                ? new Date(selectedUser.subscription.trial_end_date || Date.now())
                                : new Date(selectedUser.subscription.subscription_end_date || Date.now())
                              const newEndDate = new Date(currentEndDate.getTime() + (daysToAdd * 24 * 60 * 60 * 1000))
                              return newEndDate.toLocaleDateString('pt-BR')
                            })()}
                          </p>
                          <p className="text-xs text-green-700 mt-1">
                            Total: {(selectedUser.subscription.days_remaining || 0) + daysToAdd} dias de acesso
                          </p>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Botões de Ação */}
                  <div className="flex gap-4 pt-6 border-t-2 border-gray-200">
                    <button
                      onClick={closeSubscriptionModal}
                      className="flex-1 px-6 py-4 text-sm font-semibold text-gray-700 bg-gray-100 border-2 border-gray-300 rounded-xl hover:bg-gray-200 transition-all"
                    >
                      Cancelar
                    </button>
                    <button
                      onClick={addSubscriptionDays}
                      disabled={daysToAdd <= 0}
                      className="flex-1 px-6 py-4 text-sm font-semibold text-white bg-gradient-to-r from-green-600 to-green-700 rounded-xl hover:from-green-700 hover:to-green-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
                    >
                      ✅ Adicionar {daysToAdd} Dias
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
      </>
      )}
    </div>
  )
}
