import { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { Users, Shield, Mail, Eye, EyeOff, CheckCircle, XCircle, UserPlus, Database, Crown } from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { Input } from '../ui/Input'
import { supabase } from '../../lib/supabase'
import { useAuth } from '../../modules/auth'
import { ensureAdminUserExists } from '../../utils/createAdminUser'
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

  // Verificar se o usuário atual é admin ou se não está logado (para configuração inicial)
  const isAdmin = !user || // Permitir acesso quando não logado para configuração inicial
                  user?.email === 'admin@pdvallimport.com' || 
                  user?.email === 'novaradiosystem@outlook.com' || 
                  user?.email === 'teste@teste.com' || // Permitir teste@teste.com como admin temporário
                  user?.app_metadata?.role === 'admin'

  useEffect(() => {
    if (isAdmin) {
      loadUsers()
    }
  }, [isAdmin])

  const loadUsers = async () => {
    try {
      setLoading(true)
      
      // Como não temos acesso à API admin, vamos mostrar apenas informações básicas
      // Em um ambiente de produção, isso seria feito via uma tabela customizada
      console.log('Função de listar usuários não disponível sem permissões admin')
      
      // Simular alguns usuários para demonstração
      const mockUsers: AdminUser[] = [
        {
          id: '1',
          email: 'teste@teste.com',
          email_confirmed_at: new Date().toISOString(),
          created_at: new Date().toISOString(),
          last_sign_in_at: new Date().toISOString(),
          user_metadata: { name: 'Usuário Teste' },
          app_metadata: {},
          banned_until: null
        }
      ]
      
      setUsers(mockUsers)
    } catch (error) {
      console.error('Erro:', error)
      toast.error('Erro ao conectar com o sistema de usuários')
    } finally {
      setLoading(false)
    }
  }

  const confirmUserEmail = async (_userId: string, _email: string) => {
    toast.error('Função não disponível sem permissões admin do Supabase')
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
      const { error } = await supabase.auth.signUp({
        email: newUserEmail,
        password: newUserPassword,
        options: {
          data: {
            full_name: 'Usuário Criado pelo Admin'
          }
        }
      })

      if (error) {
        toast.error(`Erro ao criar usuário: ${error.message}`)
        return
      }

      toast.success(`Usuário ${newUserEmail} criado com sucesso! Eles precisarão confirmar o email.`)
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

  // Função para pré-preencher credenciais de teste
  const fillTestCredentials = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setLoginEmail('teste@teste.com')
    setLoginPassword('teste@@')
    toast.success('Credenciais preenchidas!')
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
              <h3 className="font-semibold text-blue-800 mb-2">📝 Faça logout e entre com uma conta admin:</h3>
              <div className="text-sm text-blue-700 space-y-2">
                <div className="bg-white p-3 rounded border">
                  <p className="font-medium">Admin Temporário:</p>
                  <p>Email: <strong>teste@teste.com</strong></p>
                  <p>Senha: <strong>teste@@</strong></p>
                </div>
                <div className="bg-white p-3 rounded border">
                  <p className="font-medium">Admin Principal:</p>
                  <p>Email: <strong>novaradiosystem@outlook.com</strong></p>
                  <p>Senha: <strong>@qw12aszx##</strong></p>
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

            {/* Credenciais de Teste */}
            <div className="space-y-4 mb-6">
              <div className="bg-indigo-50 p-4 rounded-lg border border-indigo-200">
                <h3 className="font-semibold text-indigo-800 mb-2">🚀 Login Rápido - Admin Temporário</h3>
                <div className="text-sm text-indigo-700 mb-3">
                  <p><strong>Email:</strong> teste@teste.com</p>
                  <p><strong>Senha:</strong> teste@@</p>
                </div>
                <button 
                  onClick={fillTestCredentials}
                  type="button"
                  className="w-full px-4 py-2 text-sm font-medium text-indigo-700 bg-white border border-indigo-300 rounded-md hover:bg-indigo-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                >
                  Preencher Credenciais de Teste
                </button>
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
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
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
              <CheckCircle className="w-8 h-8 text-green-500" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Emails Confirmados</p>
                <p className="text-2xl font-bold text-gray-900">
                  {users.filter(u => u.email_confirmed_at).length}
                </p>
              </div>
            </div>
          </Card>
          
          <Card className="p-6">
            <div className="flex items-center">
              <Mail className="w-8 h-8 text-orange-500" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Aguardando Confirmação</p>
                <p className="text-2xl font-bold text-gray-900">
                  {users.filter(u => !u.email_confirmed_at).length}
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
                <p className="text-indigo-700">Email: novaradiosystem@outlook.com</p>
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
                        <div className="text-xs text-gray-500">ID: {user.id.slice(0, 8)}...</div>
                      </td>
                      
                      <td className="py-3 px-4">
                        <div className="flex flex-col gap-1">
                          <span className={`inline-flex items-center px-2 py-1 text-xs font-medium rounded-full ${
                            user.email_confirmed_at 
                              ? 'bg-green-100 text-green-800' 
                              : 'bg-yellow-100 text-yellow-800'
                          }`}>
                            {user.email_confirmed_at ? '✅ Confirmado' : '⏳ Pendente'}
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
                          {!user.email_confirmed_at && (
                            <Button
                              onClick={() => confirmUserEmail(user.id, user.email)}
                              size="sm"
                              variant="primary"
                              title="Confirmar email"
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
