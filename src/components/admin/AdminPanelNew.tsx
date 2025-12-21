import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { 
  Users, Shield, Eye, EyeOff, CheckCircle, XCircle, UserPlus, Database, Crown,
  ShoppingCart, Package, UsersIcon, Wallet, Wrench, BarChart3, Settings,
  Trash2, Check, X, Sparkles, Briefcase, DollarSign, Mail
} from 'lucide-react'
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
  approval_status?: 'pending' | 'approved' | 'rejected'
  full_name?: string
  company_name?: string
  approved_by?: string
  approved_at?: string
  user_role?: 'owner' | 'employee'
  parent_user_id?: string
  created_by?: string
  permissions?: EmployeePermissions
}

interface EmployeePermissions {
  vendas: boolean
  produtos: boolean
  clientes: boolean
  caixa: boolean
  ordens_servico: boolean
  relatorios: boolean
  configuracoes: boolean
  backup: boolean
}

const defaultPermissions: EmployeePermissions = {
  vendas: true,
  produtos: true,
  clientes: true,
  caixa: false,
  ordens_servico: true,
  relatorios: false,
  configuracoes: false,
  backup: false
}

// Templates de permissões
const permissionTemplates = {
  vendedor: {
    name: 'Vendedor',
    icon: ShoppingCart,
    color: 'blue',
    description: 'Acesso a vendas e cadastro de clientes',
    permissions: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: false,
      ordens_servico: false,
      relatorios: false,
      configuracoes: false,
      backup: false
    }
  },
  caixa: {
    name: 'Operador de Caixa',
    icon: DollarSign,
    color: 'green',
    description: 'Vendas e gestão de caixa',
    permissions: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: true,
      ordens_servico: false,
      relatorios: false,
      configuracoes: false,
      backup: false
    }
  },
  tecnico: {
    name: 'Técnico',
    icon: Wrench,
    color: 'purple',
    description: 'Ordens de serviço e clientes',
    permissions: {
      vendas: false,
      produtos: true,
      clientes: true,
      caixa: false,
      ordens_servico: true,
      relatorios: false,
      configuracoes: false,
      backup: false
    }
  },
  gerente: {
    name: 'Gerente',
    icon: Briefcase,
    color: 'orange',
    description: 'Acesso completo exceto configurações',
    permissions: {
      vendas: true,
      produtos: true,
      clientes: true,
      caixa: true,
      ordens_servico: true,
      relatorios: true,
      configuracoes: false,
      backup: false
    }
  }
}

// Card de permissão individual
const PermissionCard = ({ 
  icon: Icon, 
  title, 
  description, 
  enabled, 
  onChange, 
  color 
}: any) => {
  const colorClasses = {
    blue: { border: 'border-blue-500', bg: 'bg-blue-50', iconBg: 'bg-blue-100', icon: 'text-blue-600', text: 'text-blue-900', desc: 'text-blue-700', checkBg: 'bg-blue-500', checkBorder: 'border-blue-500' },
    green: { border: 'border-green-500', bg: 'bg-green-50', iconBg: 'bg-green-100', icon: 'text-green-600', text: 'text-green-900', desc: 'text-green-700', checkBg: 'bg-green-500', checkBorder: 'border-green-500' },
    purple: { border: 'border-purple-500', bg: 'bg-purple-50', iconBg: 'bg-purple-100', icon: 'text-purple-600', text: 'text-purple-900', desc: 'text-purple-700', checkBg: 'bg-purple-500', checkBorder: 'border-purple-500' },
    yellow: { border: 'border-yellow-500', bg: 'bg-yellow-50', iconBg: 'bg-yellow-100', icon: 'text-yellow-600', text: 'text-yellow-900', desc: 'text-yellow-700', checkBg: 'bg-yellow-500', checkBorder: 'border-yellow-500' },
    orange: { border: 'border-orange-500', bg: 'bg-orange-50', iconBg: 'bg-orange-100', icon: 'text-orange-600', text: 'text-orange-900', desc: 'text-orange-700', checkBg: 'bg-orange-500', checkBorder: 'border-orange-500' },
    indigo: { border: 'border-indigo-500', bg: 'bg-indigo-50', iconBg: 'bg-indigo-100', icon: 'text-indigo-600', text: 'text-indigo-900', desc: 'text-indigo-700', checkBg: 'bg-indigo-500', checkBorder: 'border-indigo-500' },
    red: { border: 'border-red-500', bg: 'bg-red-50', iconBg: 'bg-red-100', icon: 'text-red-600', text: 'text-red-900', desc: 'text-red-700', checkBg: 'bg-red-500', checkBorder: 'border-red-500' },
    pink: { border: 'border-pink-500', bg: 'bg-pink-50', iconBg: 'bg-pink-100', icon: 'text-pink-600', text: 'text-pink-900', desc: 'text-pink-700', checkBg: 'bg-pink-500', checkBorder: 'border-pink-500' }
  }

  const colors = colorClasses[color as keyof typeof colorClasses] || colorClasses.blue

  return (
    <div 
      className={`relative p-4 border-2 rounded-xl transition-all cursor-pointer group hover:shadow-lg ${
        enabled ? `${colors.border} ${colors.bg}` : 'border-gray-200 bg-white hover:border-gray-300'
      }`}
      onClick={onChange}
    >
      <div className="flex items-start justify-between mb-2">
        <div className={`p-2 rounded-lg ${enabled ? colors.iconBg : 'bg-gray-100'}`}>
          <Icon className={`w-5 h-5 ${enabled ? colors.icon : 'text-gray-400'}`} />
        </div>
        <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center transition-all ${
          enabled ? `${colors.checkBg} ${colors.checkBorder}` : 'border-gray-300 bg-white'
        }`}>
          {enabled && <Check className="w-4 h-4 text-white" />}
        </div>
      </div>
      <h3 className={`font-semibold text-sm mb-1 ${enabled ? colors.text : 'text-gray-700'}`}>
        {title}
      </h3>
      <p className={`text-xs ${enabled ? colors.desc : 'text-gray-500'}`}>
        {description}
      </p>
    </div>
  )
}

export function AdminPanel() {
  const { user } = useAuth()
  const navigate = useNavigate()
  const [users, setUsers] = useState<AdminUser[]>([])
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [selectedTemplate, setSelectedTemplate] = useState<string | null>(null)
  const [permissions, setPermissions] = useState<EmployeePermissions>(defaultPermissions)
  
  const [newUserEmail, setNewUserEmail] = useState('')
  const [newUserPassword, setNewUserPassword] = useState('')
  const [newUserName, setNewUserName] = useState('')
  const [newUserPosition, setNewUserPosition] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [creating, setCreating] = useState(false)

  // Estados para login administrativo
  const [loginEmail, setLoginEmail] = useState('')
  const [loginPassword, setLoginPassword] = useState('')
  const [loggingIn, setLoggingIn] = useState(false)
  const [showLoginPassword, setShowLoginPassword] = useState(false)

  const permissionsConfig = [
    { key: 'vendas', icon: ShoppingCart, title: 'Vendas', description: 'Registrar e gerenciar vendas', color: 'blue' },
    { key: 'produtos', icon: Package, title: 'Produtos', description: 'Cadastrar e editar produtos', color: 'green' },
    { key: 'clientes', icon: UsersIcon, title: 'Clientes', description: 'Gerenciar cadastro de clientes', color: 'purple' },
    { key: 'caixa', icon: Wallet, title: 'Caixa', description: 'Abrir/fechar caixa e movimentações', color: 'yellow' },
    { key: 'ordens_servico', icon: Wrench, title: 'Ordens de Serviço', description: 'Criar e acompanhar OS', color: 'orange' },
    { key: 'relatorios', icon: BarChart3, title: 'Relatórios', description: 'Visualizar relatórios e analytics', color: 'indigo' },
    { key: 'configuracoes', icon: Settings, title: 'Configurações', description: 'Alterar configurações do sistema', color: 'red' },
    { key: 'backup', icon: Database, title: 'Backup', description: 'Fazer backup e restaurar dados', color: 'pink' }
  ]

  const isAdmin = !user || user?.email === 'admin@pdvallimport.com' || user?.email === 'novaradiosystem@outlook.com' || user?.app_metadata?.role === 'admin'

  useEffect(() => {
    if (isAdmin) {
      loadUsers()
      
      // Auto-refresh a cada 30 segundos
      const interval = setInterval(() => {
        console.log('🔄 Auto-atualizando lista de usuários...')
        loadUsers()
      }, 30000)
      
      // Supabase Realtime - Atualizar instantaneamente quando houver novos cadastros
      const channel = supabase
        .channel('user_approvals_changes')
        .on('postgres_changes', 
          { event: '*', schema: 'public', table: 'user_approvals' },
          (payload) => {
            console.log('🔔 Novo cadastro detectado:', payload)
            toast.success('Nova solicitação de cadastro recebida!')
            loadUsers()
          }
        )
        .subscribe()
      
      return () => {
        clearInterval(interval)
        supabase.removeChannel(channel)
      }
    }
  }, [isAdmin])

  // Aplicar template
  const applyTemplate = (templateKey: string) => {
    const template = permissionTemplates[templateKey as keyof typeof permissionTemplates]
    if (template) {
      setPermissions(template.permissions)
      setSelectedTemplate(templateKey)
      toast.success(`Template "${template.name}" aplicado!`)
    }
  }

  // Toggle permissão individual
  const togglePermission = (key: keyof EmployeePermissions) => {
    setPermissions(prev => ({ ...prev, [key]: !prev[key] }))
    setSelectedTemplate(null)
  }

  const activePermissionsCount = Object.values(permissions).filter(Boolean).length

  const loadUsers = async () => {
    try {
      setLoading(true)
      
      const { data: tableExists } = await supabase
        .from('user_approvals')
        .select('count')
        .limit(1)
        .maybeSingle()
      
      if (!tableExists && tableExists !== null) {
        toast.error('Sistema de aprovação não configurado. Execute o script SQL primeiro.')
        return
      }
      
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
          created_by,
          permissions
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
      
      const adminUsers: AdminUser[] = approvals?.map(approval => ({
        id: approval.user_id,
        email: approval.email,
        email_confirmed_at: approval.status === 'approved' ? approval.approved_at : null,
        created_at: approval.created_at,
        last_sign_in_at: null,
        user_metadata: { full_name: approval.full_name, company_name: approval.company_name },
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
        permissions: approval.permissions
      })) || []
      
      setUsers(adminUsers)
      
    } catch (error) {
      console.error('Erro:', error)
      toast.error('Erro ao conectar com o sistema de usuários')
    } finally {
      setLoading(false)
    }
  }

  const approveUser = async (userId: string, email: string) => {
    try {
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

      try {
        const trialResult = await SubscriptionService.activateTrial(email)
        if (trialResult.success) {
          toast.success(`✅ ${email} aprovado com período de teste de 15 dias!`)
        } else {
          toast.error(`⚠️ ${email} aprovado, mas houve erro ao ativar período de teste`)
        }
      } catch (trialError) {
        console.error('Erro ao ativar período de teste:', trialError)
        toast.error(`⚠️ ${email} aprovado, mas houve erro ao ativar período de teste`)
      }
      
      loadUsers()
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

  const deleteEmployee = async (employeeId: string, email: string, employeeName: string) => {
    if (!confirm(`⚠️ Deseja excluir o funcionário "${employeeName}"?\n\nEsta ação não pode ser desfeita.`)) {
      return
    }

    const loadingToast = toast.loading('Excluindo funcionário...')

    try {
      const { error } = await supabase
        .from('user_approvals')
        .update({ status: 'rejected', approved_at: null, approved_by: null })
        .eq('user_id', employeeId)

      if (error) {
        toast.error('Erro ao excluir funcionário')
        return
      }

      toast.success(`✅ ${employeeName} foi excluído com sucesso`)
      await loadUsers()
    } catch (error) {
      console.error('Erro ao excluir funcionário:', error)
      toast.error('Erro inesperado ao excluir funcionário')
    } finally {
      toast.dismiss(loadingToast)
    }
  }

  const createUser = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!newUserName.trim()) {
      toast.error('Nome é obrigatório')
      return
    }
    if (!newUserEmail || !newUserPassword) {
      toast.error('Preencha email e senha')
      return
    }
    if (newUserPassword.length < 6) {
      toast.error('Senha deve ter pelo menos 6 caracteres')
      return
    }

    try {
      setCreating(true)
      
      const { data, error } = await supabase.auth.signUp({
        email: newUserEmail,
        password: newUserPassword,
        options: {
          data: {
            full_name: newUserName,
            position: newUserPosition,
            created_by_admin: true,
            role: 'employee',
            permissions: permissions
          }
        }
      })

      if (error) {
        toast.error(`Erro ao criar usuário: ${error.message}`)
        return
      }

      if (data.user) {
        try {
          await new Promise(resolve => setTimeout(resolve, 1000))
          
          const { error: approvalError } = await supabase
            .from('user_approvals')
            .update({
              status: 'approved',
              approved_by: user?.id,
              approved_at: new Date().toISOString(),
              permissions: permissions
            })
            .eq('user_id', data.user.id)
          
          if (approvalError) {
            console.error('Erro ao aprovar automaticamente:', approvalError)
            toast.success(`Funcionário ${newUserName} criado! Precisa ser aprovado manualmente.`)
          } else {
            toast.success(`✅ Funcionário ${newUserName} criado e aprovado automaticamente!`)
          }
        } catch (approvalErr) {
          console.error('Erro no processo de aprovação automática:', approvalErr)
          toast.success(`Funcionário ${newUserName} criado! Precisa ser aprovado manualmente.`)
        }
      }

      closeModal()
      loadUsers()
    } catch (error) {
      console.error('Erro ao criar usuário:', error)
      toast.error('Erro inesperado ao criar usuário')
    } finally {
      setCreating(false)
    }
  }

  const closeModal = () => {
    setShowModal(false)
    setNewUserEmail('')
    setNewUserPassword('')
    setNewUserName('')
    setNewUserPosition('')
    setPermissions(defaultPermissions)
    setSelectedTemplate(null)
    setShowPassword(false)
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
    } catch (error) {
      console.error('Erro no login:', error)
      toast.error('Erro inesperado no login')
    } finally {
      setLoggingIn(false)
    }
  }

  // Verificar se é admin (super_admin OU admin_empresa)
  // Funcionários normais NÃO têm isAdmin = true
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
            <Button onClick={() => supabase.auth.signOut()} className="w-full">Fazer Logout</Button>
            <Link to="/login"><Button variant="outline" className="w-full">Ir para Login</Button></Link>
            <Link to="/dashboard"><Button variant="ghost" className="w-full">Voltar ao PDV</Button></Link>
          </div>
        </Card>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      {/* Login Screen */}
      {!user && (
        <div className="min-h-screen bg-gradient-to-br from-indigo-900 via-indigo-800 to-black flex items-center justify-center p-4">
          <div className="p-8 text-center max-w-md bg-white/95 backdrop-blur-sm border-0 shadow-2xl rounded-xl">
            <Shield className="w-16 h-16 mx-auto mb-4 text-indigo-600" />
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Painel Administrativo</h1>
            <p className="text-gray-600 mb-6">Faça login para acessar o painel administrativo</p>
            
            <form onSubmit={handleAdminLogin} className="space-y-4 mb-6">
              <div className="text-left">
                <label className="block text-sm font-medium text-gray-700 mb-2">Email Admin</label>
                <Input type="email" value={loginEmail} onChange={(e) => setLoginEmail(e.target.value)} placeholder="admin@exemplo.com" required />
              </div>
              
              <div className="text-left">
                <label className="block text-sm font-medium text-gray-700 mb-2">Senha</label>
                <div className="relative">
                  <Input type={showLoginPassword ? 'text' : 'password'} value={loginPassword} onChange={(e) => setLoginPassword(e.target.value)} placeholder="Sua senha admin" required />
                  <button type="button" onClick={() => setShowLoginPassword(!showLoginPassword)} className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600">
                    {showLoginPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>
              
              <button type="submit" disabled={loggingIn} className="w-full bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg font-medium disabled:opacity-50">
                {loggingIn ? 'Entrando...' : 'Fazer Login Admin'}
              </button>
            </form>

            <div className="space-y-3">
              <button onClick={() => navigate('/signup')} className="w-full px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
                Criar Conta Admin Principal
              </button>
              <button onClick={() => navigate('/dashboard')} className="w-full px-4 py-2 text-sm font-medium text-gray-600 bg-transparent hover:bg-gray-50">
                Voltar ao PDV
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Main Admin Panel */}
      {user && (
        <>
          {/* Header */}
          <div className="bg-white shadow-sm border-b sticky top-0 z-10">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
              <div className="flex items-center justify-between h-16">
                <div className="flex items-center space-x-4">
                  <Link to="/dashboard">
                    <Button variant="ghost" size="sm" className="text-gray-600 hover:text-gray-800">← Voltar ao PDV</Button>
                  </Link>
                  <div className="flex items-center space-x-3">
                    <Shield className="w-8 h-8 text-indigo-600" />
                    <div>
                      <h1 className="text-xl font-bold text-gray-900">Administração do Sistema</h1>
                      <p className="text-sm text-gray-600">Como administrador da empresa, gerencie funcionários, permissões e configurações</p>
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
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
              <Card className="p-6 hover:shadow-lg transition-shadow">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-blue-100"><Users className="w-6 h-6 text-blue-600" /></div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total de Usuários</p>
                    <p className="text-2xl font-bold text-gray-900">{users.length}</p>
                  </div>
                </div>
              </Card>

              <Card className="p-6 hover:shadow-lg transition-shadow">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-purple-100"><Crown className="w-6 h-6 text-purple-600" /></div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Proprietários</p>
                    <p className="text-2xl font-bold text-gray-900">{users.filter(u => u.user_role === 'owner' || !u.user_role).length}</p>
                  </div>
                </div>
              </Card>

              <Card className="p-6 hover:shadow-lg transition-shadow">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-blue-100"><Users className="w-6 h-6 text-blue-600" /></div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Funcionários</p>
                    <p className="text-2xl font-bold text-gray-900">{users.filter(u => u.user_role === 'employee').length}</p>
                  </div>
                </div>
              </Card>
              
              <Card className="p-6 hover:shadow-lg transition-shadow">
                <div className="flex items-center">
                  <div className="p-3 rounded-full bg-green-100"><CheckCircle className="w-6 h-6 text-green-600" /></div>
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Aprovados</p>
                    <p className="text-2xl font-bold text-gray-900">{users.filter(u => u.approval_status === 'approved').length}</p>
                  </div>
                </div>
              </Card>
            </div>

            {/* Criar Admin Principal */}
            <Card className="p-6 bg-gradient-to-r from-indigo-50 to-purple-50 border-indigo-200 hover:shadow-lg transition-shadow">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                  <Crown className="w-8 h-8 text-indigo-600" />
                  <div>
                    <h2 className="text-xl font-semibold text-indigo-900">Usuário Administrador Principal</h2>
                    <p className="text-sm text-indigo-600">Criar ou verificar o usuário admin principal do sistema</p>
                  </div>
                </div>
                
                <Button onClick={createMainAdmin} disabled={creating} variant="primary" className="bg-indigo-600 hover:bg-indigo-700">
                  {creating ? 'Criando...' : 'Criar/Verificar Admin'}
                </Button>
              </div>
            </Card>

            {/* Header de Gerenciamento */}
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-2xl shadow-xl p-8 text-white">
              <div className="flex justify-between items-center">
                <div>
                  <h2 className="text-3xl font-bold mb-2 flex items-center">
                    <Users className="w-8 h-8 mr-3" />
                    Gerenciar Funcionários
                  </h2>
                  <p className="text-blue-100 text-lg">
                    {users.filter(u => u.user_role === 'employee').length} funcionário{users.filter(u => u.user_role === 'employee').length !== 1 ? 's' : ''} cadastrado{users.filter(u => u.user_role === 'employee').length !== 1 ? 's' : ''}
                  </p>
                </div>
                
                <button
                  onClick={() => setShowModal(true)}
                  className="flex items-center px-6 py-3 bg-white text-blue-600 rounded-xl hover:bg-blue-50 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 font-semibold"
                >
                  <UserPlus className="w-5 h-5 mr-2" />
                  Novo Funcionário
                </button>
              </div>
            </div>

            {/* Lista de Funcionários em Cards */}
            {loading ? (
              <div className="flex items-center justify-center py-12">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              </div>
            ) : users.filter(u => u.user_role === 'employee').length === 0 ? (
              <div className="bg-white rounded-2xl shadow-lg p-12 text-center">
                <div className="max-w-md mx-auto">
                  <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-6">
                    <Users className="w-10 h-10 text-blue-600" />
                  </div>
                  <h3 className="text-2xl font-bold text-gray-900 mb-3">Nenhum funcionário cadastrado</h3>
                  <p className="text-gray-600 mb-8 text-lg">Adicione funcionários para que possam acessar o sistema com permissões personalizadas</p>
                  <button
                    onClick={() => setShowModal(true)}
                    className="inline-flex items-center px-8 py-4 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl hover:from-blue-700 hover:to-blue-800 shadow-lg hover:shadow-xl transition-all transform hover:-translate-y-0.5 font-semibold text-lg"
                  >
                    <UserPlus className="w-6 h-6 mr-3" />
                    Adicionar Primeiro Funcionário
                  </button>
                </div>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {users.filter(u => u.user_role === 'employee').map((employee) => (
                  <div key={employee.id} className="bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all p-6 border border-gray-100">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex items-center">
                        <div className="w-14 h-14 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center text-white text-xl font-bold shadow-md">
                          {employee.full_name?.charAt(0).toUpperCase() || employee.email.charAt(0).toUpperCase()}
                        </div>
                        <div className="ml-4">
                          <h3 className="font-bold text-lg text-gray-900">{employee.full_name || employee.email}</h3>
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            employee.approval_status === 'approved' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                          }`}>
                            <span className={`w-2 h-2 rounded-full mr-1.5 ${
                              employee.approval_status === 'approved' ? 'bg-green-500 animate-pulse' : 'bg-yellow-500'
                            }`}></span>
                            {employee.approval_status === 'approved' ? 'Ativo' : 'Pendente'}
                          </span>
                        </div>
                      </div>
                    </div>

                    <div className="space-y-2 mb-4">
                      <div className="flex items-center text-sm text-gray-600">
                        <Mail className="w-4 h-4 mr-2" />
                        {employee.email}
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <span className="font-medium mr-2">📅</span>
                        Desde {new Date(employee.created_at).toLocaleDateString('pt-BR')}
                      </div>
                    </div>

                    <div className="flex gap-2 pt-4 border-t border-gray-100">
                      {employee.approval_status === 'pending' && (
                        <>
                          <button
                            onClick={() => approveUser(employee.id, employee.email)}
                            className="flex-1 flex items-center justify-center px-4 py-2.5 text-sm font-medium text-green-600 bg-green-50 border border-green-200 rounded-lg hover:bg-green-100 transition-colors"
                          >
                            <CheckCircle className="w-4 h-4 mr-2" />
                            Aprovar
                          </button>
                          <button
                            onClick={() => rejectUser(employee.id, employee.email)}
                            className="flex-1 flex items-center justify-center px-4 py-2.5 text-sm font-medium text-red-600 bg-red-50 border border-red-200 rounded-lg hover:bg-red-100 transition-colors"
                          >
                            <XCircle className="w-4 h-4 mr-2" />
                            Rejeitar
                          </button>
                        </>
                      )}
                      {employee.approval_status === 'approved' && (
                        <button
                          onClick={() => deleteEmployee(employee.id, employee.email, employee.full_name || employee.email)}
                          className="flex-1 flex items-center justify-center px-4 py-2.5 text-sm font-medium text-red-600 bg-red-50 border border-red-200 rounded-lg hover:bg-red-100 transition-colors"
                        >
                          <Trash2 className="w-4 h-4 mr-2" />
                          Excluir
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Modal Criar Funcionário */}
            {showModal && (
              <div className="fixed inset-0 z-50 overflow-y-auto">
                <div className="flex items-center justify-center min-h-screen pt-4 px-4 pb-20">
                  <div className="fixed inset-0 bg-black bg-opacity-50 transition-opacity backdrop-blur-sm" onClick={closeModal}></div>
                  
                  <div className="relative bg-white rounded-2xl shadow-2xl max-w-5xl w-full max-h-[90vh] overflow-y-auto">
                    {/* Header do Modal */}
                    <div className="sticky top-0 bg-gradient-to-r from-blue-600 to-blue-700 text-white px-8 py-6 rounded-t-2xl">
                      <div className="flex items-center justify-between">
                        <div>
                          <h2 className="text-2xl font-bold">Novo Funcionário</h2>
                          <p className="text-blue-100 mt-1">Preencha os dados e configure as permissões de acesso</p>
                        </div>
                        <button onClick={closeModal} className="w-10 h-10 flex items-center justify-center rounded-full bg-white/20 hover:bg-white/30 transition-colors">
                          <X className="w-6 h-6" />
                        </button>
                      </div>
                    </div>

                    <div className="p-8">
                      {/* Dados Básicos */}
                      <div className="mb-8">
                        <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center">
                          <Users className="w-5 h-5 mr-2 text-blue-600" />
                          Dados do Funcionário
                        </h3>
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Nome Completo *</label>
                            <input type="text" value={newUserName} onChange={(e) => setNewUserName(e.target.value)} className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors" placeholder="João Silva" />
                          </div>
                          <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Email *</label>
                            <input type="email" value={newUserEmail} onChange={(e) => setNewUserEmail(e.target.value)} className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors" placeholder="joao@email.com" />
                          </div>
                          <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Cargo</label>
                            <input type="text" value={newUserPosition} onChange={(e) => setNewUserPosition(e.target.value)} className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors" placeholder="Vendedor, Gerente, etc." />
                          </div>
                          <div className="relative">
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Senha *</label>
                            <input type={showPassword ? 'text' : 'password'} value={newUserPassword} onChange={(e) => setNewUserPassword(e.target.value)} className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-blue-500 transition-colors pr-12" placeholder="••••••••" />
                            <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3 top-11 text-gray-400 hover:text-gray-600">
                              {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                            </button>
                          </div>
                        </div>
                      </div>

                      {/* Templates de Permissões */}
                      <div className="mb-8">
                        <h3 className="text-lg font-bold text-gray-900 mb-4 flex items-center">
                          <Sparkles className="w-5 h-5 mr-2 text-blue-600" />
                          Templates Rápidos
                        </h3>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                          {Object.entries(permissionTemplates).map(([key, template]) => {
                            const Icon = template.icon
                            const isSelected = selectedTemplate === key
                            const templateColors: Record<string, any> = {
                              blue: { border: 'border-blue-500', bg: 'bg-blue-50', icon: 'text-blue-600', text: 'text-blue-900', desc: 'text-blue-700' },
                              green: { border: 'border-green-500', bg: 'bg-green-50', icon: 'text-green-600', text: 'text-green-900', desc: 'text-green-700' },
                              purple: { border: 'border-purple-500', bg: 'bg-purple-50', icon: 'text-purple-600', text: 'text-purple-900', desc: 'text-purple-700' },
                              orange: { border: 'border-orange-500', bg: 'bg-orange-50', icon: 'text-orange-600', text: 'text-orange-900', desc: 'text-orange-700' }
                            }
                            const colors = templateColors[template.color] || templateColors.blue
                            
                            return (
                              <button key={key} onClick={() => applyTemplate(key)} className={`p-4 border-2 rounded-xl transition-all text-left ${isSelected ? `${colors.border} ${colors.bg}` : 'border-gray-200 hover:border-gray-300 bg-white'}`}>
                                <Icon className={`w-8 h-8 mb-2 ${isSelected ? colors.icon : 'text-gray-400'}`} />
                                <div className={`font-semibold text-sm mb-1 ${isSelected ? colors.text : 'text-gray-700'}`}>{template.name}</div>
                                <div className={`text-xs ${isSelected ? colors.desc : 'text-gray-500'}`}>{template.description}</div>
                              </button>
                            )
                          })}
                        </div>
                      </div>

                      {/* Permissões Personalizadas */}
                      <div className="mb-8">
                        <div className="flex items-center justify-between mb-4">
                          <h3 className="text-lg font-bold text-gray-900 flex items-center">
                            <Shield className="w-5 h-5 mr-2 text-blue-600" />
                            Permissões Personalizadas
                          </h3>
                          <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm font-semibold">{activePermissionsCount} ativas</span>
                        </div>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                          {permissionsConfig.map((config) => (
                            <PermissionCard
                              key={config.key}
                              icon={config.icon}
                              title={config.title}
                              description={config.description}
                              enabled={permissions[config.key as keyof EmployeePermissions]}
                              onChange={() => togglePermission(config.key as keyof EmployeePermissions)}
                              color={config.color}
                            />
                          ))}
                        </div>
                      </div>

                      {/* Botões de Ação */}
                      <div className="flex gap-4 pt-6 border-t border-gray-200">
                        <button onClick={closeModal} className="flex-1 px-6 py-4 text-sm font-semibold text-gray-700 bg-gray-100 border-2 border-gray-200 rounded-xl hover:bg-gray-200 transition-all">
                          Cancelar
                        </button>
                        <button
                          onClick={createUser}
                          disabled={creating}
                          className="flex-1 px-6 py-4 text-sm font-semibold text-white bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl hover:from-blue-700 hover:to-blue-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
                        >
                          {creating ? (
                            <span className="flex items-center justify-center">
                              <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                              Criando...
                            </span>
                          ) : (
                            'Criar Funcionário'
                          )}
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
