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
}

export function AdminPanel() {
  const { user } = useAuth()
  const navigate = useNavigate()
  const [users, setUsers] = useState<AdminUser[]>([])
  const [adminLogs, setAdminLogs] = useState<any[]>([])
  const [showLogs, setShowLogs] = useState(false)
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

  // Verificar se o usuário atual é admin ou se não está logado (para configuração inicial)
  const isAdmin = !user || // Permitir acesso quando não logado para configuração inicial
                  user?.email === 'admin@pdvallimport.com' || 
                  user?.email === 'novaradiosystem@outlook.com' || 
                  user?.app_metadata?.role === 'admin'

  useEffect(() => {
    if (isAdmin) {
      loadUsers()
      if (showLogs) {
        loadAdminLogs()
      }
    }
  }, [isAdmin, showLogs])

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
        console.error('Código do erro:', error.code)
        console.error('Mensagem do erro:', error.message)
        console.error('Detalhes do erro:', error.details)
        
        if (error.code === 'PGRST116') {
          toast.error('Tabela user_approvals não existe. Execute o script SQL de configuração.')
        } else {
          toast.error(`Erro ao carregar lista de usuários: ${error.message}`)
        }
        return
      }
      
      // Converter para formato AdminUser
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
        created_by: approval.created_by
      })) || []
      
      setUsers(adminUsers)
      console.log(`Carregados ${adminUsers.length} usuários`)
      
    } catch (error) {
      console.error('Erro:', error)
      toast.error('Erro ao conectar com o sistema de usuários')
    } finally {
      setLoading(false)
    }
  }

  const loadAdminLogs = async () => {
    try {
      console.log('📋 Carregando logs administrativos...')
      
      const { data, error } = await supabase
        .from('admin_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(50) // Últimos 50 logs

      if (error) {
        console.error('Erro ao carregar logs:', error.message)
        // Não mostrar erro se a tabela não existir
        return
      }

      console.log('✅ Logs carregados:', data?.length || 0)
      setAdminLogs(data || [])
      
    } catch (err) {
      console.error('Erro ao carregar logs:', err)
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
      loadUsers() // Recarregar lista
    } catch (err) {
      console.error('Erro ao rejeitar usuário:', err)
      toast.error('Erro ao rejeitar usuário')
    }
  }

  const toggleUserStatus = async (_userId: string, _email: string, _currentlyBanned: boolean) => {
    toast.error('Função não disponível sem permissões admin do Supabase')
  }

  const deleteUser = async (userId: string, email: string) => {
    // Confirmar exclusão
    const confirmDelete = window.confirm(
      `⚠️ ATENÇÃO: Deseja realmente excluir o usuário?\n\n` +
      `Email: ${email}\n` +
      `ID: ${userId}\n\n` +
      `Esta ação não pode ser desfeita e removerá:\n` +
      `• Registro de aprovação\n` +
      `• Dados associados ao usuário\n` +
      `• Histórico de atividades\n\n` +
      `Digite "CONFIRMAR" para continuar...`
    )
    
    if (!confirmDelete) return
    
    const finalConfirm = window.prompt(
      `Para confirmar a exclusão do usuário ${email}, digite: CONFIRMAR`
    )
    
    if (finalConfirm !== 'CONFIRMAR') {
      toast.error('Exclusão cancelada - confirmação incorreta')
      return
    }

    try {
      setLoading(true)
      
      // 1. Remover da tabela user_approvals
      console.log('🗑️ Removendo usuário da tabela user_approvals...')
      const { error: approvalError } = await supabase
        .from('user_approvals')
        .delete()
        .eq('user_id', userId)

      if (approvalError) {
        console.error('Erro ao remover de user_approvals:', approvalError)
        toast.error('Erro ao remover aprovação do usuário')
        return
      }

      // 2. Remover registros relacionados em outras tabelas
      console.log('🗑️ Removendo dados relacionados...')
      
      // Remover de clientes se existir
      await supabase
        .from('clientes')
        .delete()
        .eq('user_id', userId)

      // Remover de vendas se existir
      await supabase
        .from('vendas')
        .delete()
        .eq('user_id', userId)

      // Remover de produtos se existir
      await supabase
        .from('produtos')
        .delete()
        .eq('user_id', userId)

      // 3. Tentar invalidar sessões do usuário (se possível)
      console.log('🔐 Invalidando sessões do usuário...')
      
      // 4. Registrar log de exclusão
      try {
        await supabase
          .from('admin_logs')
          .insert({
            action: 'delete_user',
            user_id: userId,
            user_email: email,
            admin_id: user?.id,
            admin_email: user?.email,
            details: `Usuário ${email} excluído pelo admin`,
            created_at: new Date().toISOString()
          })
      } catch (logError) {
        console.log('ℹ️ Log não registrado (tabela admin_logs pode não existir)')
      }

      console.log('✅ Usuário excluído com sucesso!')
      toast.success(`✅ Usuário ${email} excluído com sucesso`)
      
      // Recarregar lista de usuários
      loadUsers()
      
    } catch (error) {
      console.error('❌ Erro ao excluir usuário:', error)
      const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido'
      toast.error(`❌ Erro ao excluir usuário: ${errorMessage}`)
    } finally {
      setLoading(false)
    }
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

        {/* Criar Novo Usuário */}
        <Card className="p-6">
          <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
            <UserPlus className="w-5 h-5 text-green-600" />
            Criar Novo Usuário
          </h2>
          
          <form onSubmit={createUser} className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Email
              </label>
              <Input
                type="email"
                value={newUserEmail}
                onChange={(e) => setNewUserEmail(e.target.value)}
                placeholder="usuario@exemplo.com"
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Senha
              </label>
              <div className="relative">
                <Input
                  type={showPassword ? 'text' : 'password'}
                  value={newUserPassword}
                  onChange={(e) => setNewUserPassword(e.target.value)}
                  placeholder="Digite uma senha segura"
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
            
            <div className="flex items-end">
              <Button
                type="submit"
                disabled={creating}
                className="w-full"
                variant="primary"
              >
                {creating ? 'Criando...' : 'Criar Usuário'}
              </Button>
            </div>
          </form>
        </Card>

        {/* Logs Administrativos */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold flex items-center gap-2">
              <Database className="w-5 h-5 text-orange-600" />
              Logs Administrativos
            </h2>
            
            <div className="flex gap-2">
              <Button
                onClick={loadAdminLogs}
                size="sm"
                variant="outline"
                disabled={loading}
              >
                Atualizar Logs
              </Button>
              <Button
                onClick={() => setShowLogs(!showLogs)}
                size="sm"
                variant="outline"
              >
                {showLogs ? 'Ocultar' : 'Mostrar'} Logs
              </Button>
            </div>
          </div>

          {showLogs && (
            <div className="mt-4">
              {adminLogs.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <Database className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                  <p>Nenhum log administrativo encontrado</p>
                  <p className="text-sm">Execute o script CRIAR_ADMIN_LOGS.sql primeiro</p>
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full border-collapse">
                    <thead>
                      <tr className="bg-gray-50">
                        <th className="text-left py-3 px-4 font-medium">Data/Hora</th>
                        <th className="text-left py-3 px-4 font-medium">Ação</th>
                        <th className="text-left py-3 px-4 font-medium">Usuário</th>
                        <th className="text-left py-3 px-4 font-medium">Admin</th>
                        <th className="text-left py-3 px-4 font-medium">Detalhes</th>
                      </tr>
                    </thead>
                    <tbody>
                      {adminLogs.map((log, index) => (
                        <tr key={index} className="border-b border-gray-200 hover:bg-gray-50">
                          <td className="py-3 px-4 text-sm">
                            {new Date(log.created_at).toLocaleString('pt-BR')}
                          </td>
                          <td className="py-3 px-4">
                            <span className={`inline-flex items-center px-2 py-1 text-xs font-medium rounded-full ${
                              log.action === 'delete_user' ? 'bg-red-100 text-red-800' :
                              log.action === 'approve_user' ? 'bg-green-100 text-green-800' :
                              log.action === 'reject_user' ? 'bg-yellow-100 text-yellow-800' :
                              'bg-blue-100 text-blue-800'
                            }`}>
                              {log.action}
                            </span>
                          </td>
                          <td className="py-3 px-4 text-sm">
                            {log.user_email || 'N/A'}
                          </td>
                          <td className="py-3 px-4 text-sm">
                            {log.admin_email || 'Sistema'}
                          </td>
                          <td className="py-3 px-4 text-sm text-gray-600">
                            {log.details}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}
        </Card>

        {/* Lista de Usuários */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold flex items-center gap-2">
              <Database className="w-5 h-5 text-blue-600" />
              Gerenciar Usuários
            </h2>
            
            <Button
              onClick={loadUsers}
              disabled={loading}
              variant="secondary"
              size="sm"
            >
              {loading ? 'Carregando...' : 'Atualizar'}
            </Button>
          </div>

          {loading ? (
            <div className="text-center py-8">
              <div className="text-gray-600">Carregando usuários...</div>
            </div>
          ) : users.length === 0 ? (
            <div className="text-center py-8">
              <Users className="w-12 h-12 mx-auto mb-4 text-gray-400" />
              <div className="text-gray-600">Nenhum usuário encontrado</div>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Email</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Tipo</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Criado em</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Último login</th>
                    <th className="text-center py-3 px-4 font-medium text-gray-700">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {users.map((user) => (
                    <tr key={user.id} className="border-b border-gray-100 hover:bg-gray-50">
                      <td className="py-3 px-4">
                        <div className="font-medium text-gray-900">{user.email}</div>
                        <div className="text-xs text-gray-500">
                          ID: {user.id.slice(0, 8)}...
                          {user.full_name && <span className="ml-2">• {user.full_name}</span>}
                        </div>
                      </td>

                      <td className="py-3 px-4">
                        <div className="flex flex-col gap-1">
                          <span className={`inline-flex items-center px-2 py-1 text-xs font-medium rounded-full ${
                            user.user_role === 'employee'
                              ? 'bg-blue-100 text-blue-800'
                              : 'bg-purple-100 text-purple-800'
                          }`}>
                            {user.user_role === 'employee' ? '👤 Funcionário' : '🏢 Proprietário'}
                          </span>
                          {user.parent_user_id && (
                            <div className="text-xs text-gray-500">
                              Vinculado ao proprietário
                            </div>
                          )}
                        </div>
                      </td>
                      
                      <td className="py-3 px-4">
                        <div className="flex flex-col gap-1">
                          <span className={`inline-flex items-center px-2 py-1 text-xs font-medium rounded-full ${
                            user.approval_status === 'approved'
                              ? 'bg-green-100 text-green-800' 
                              : user.approval_status === 'rejected'
                              ? 'bg-red-100 text-red-800'
                              : 'bg-yellow-100 text-yellow-800'
                          }`}>
                            {user.approval_status === 'approved' ? '✅ Aprovado' : 
                             user.approval_status === 'rejected' ? '❌ Rejeitado' : 
                             '⏳ Pendente'}
                          </span>
                          
                          {user.banned_until && (
                            <span className="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full bg-red-100 text-red-800">
                              🚫 Desativado
                            </span>
                          )}
                        </div>
                      </td>
                      
                      <td className="py-3 px-4 text-sm text-gray-600">
                        {new Date(user.created_at).toLocaleDateString('pt-BR')}
                      </td>
                      
                      <td className="py-3 px-4 text-sm text-gray-600">
                        {user.last_sign_in_at 
                          ? new Date(user.last_sign_in_at).toLocaleDateString('pt-BR')
                          : 'Nunca'
                        }
                      </td>
                      
                      <td className="py-3 px-4">
                        <div className="flex items-center justify-center gap-2">
                          {user.approval_status === 'pending' && (
                            <>
                              <Button
                                onClick={() => approveUser(user.id, user.email)}
                                size="sm"
                                variant="primary"
                                title="Aprovar usuário"
                              >
                                <CheckCircle className="w-4 h-4" />
                              </Button>
                              <Button
                                onClick={() => rejectUser(user.id, user.email)}
                                size="sm"
                                variant="outline"
                                title="Rejeitar usuário"
                                className="border-red-300 text-red-600 hover:bg-red-50"
                              >
                                <XCircle className="w-4 h-4" />
                              </Button>
                            </>
                          )}
                          
                          {user.approval_status === 'rejected' && (
                            <Button
                              onClick={() => approveUser(user.id, user.email)}
                              size="sm"
                              variant="primary"
                              title="Aprovar usuário"
                            >
                              <CheckCircle className="w-4 h-4" />
                            </Button>
                          )}
                          
                          <Button
                            onClick={() => toggleUserStatus(user.id, user.email, !!user.banned_until)}
                            size="sm"
                            variant={user.banned_until ? "primary" : "secondary"}
                            title={user.banned_until ? "Ativar usuário" : "Desativar usuário"}
                          >
                            {user.banned_until ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
                          </Button>
                          
                          <Button
                            onClick={() => deleteUser(user.id, user.email)}
                            size="sm"
                            variant="outline"
                            title="Excluir usuário"
                          >
                            <XCircle className="w-4 h-4" />
                          </Button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Card>
      </div>
      </>
      )}
    </div>
  )
}
