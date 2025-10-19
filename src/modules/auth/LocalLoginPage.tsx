import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { ShoppingCart, Lock, ArrowLeft, User } from 'lucide-react'
import { useAuth } from './AuthContext'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'
import { supabase } from '../../lib/supabase'
import toast from 'react-hot-toast'

interface LocalUser {
  id: string
  nome: string
  email: string
  foto_perfil: string | null
  tipo_admin: string
  senha_definida: boolean
  primeiro_acesso: boolean
}

export function LocalLoginPage() {
  const { user, signInLocal } = useAuth()
  const navigate = useNavigate()
  const [usuarios, setUsuarios] = useState<LocalUser[]>([])
  const [usuarioSelecionado, setUsuarioSelecionado] = useState<LocalUser | null>(null)
  const [senha, setSenha] = useState('')
  const [loading, setLoading] = useState(true)
  const [loginLoading, setLoginLoading] = useState(false)

  // Redirecionar apenas se já fez login local completo (funcionário)
  // Se só fez login email/senha (empresa), permitir selecionar funcionário
  useEffect(() => {
    if (user && user.user_metadata?.funcionario_id) {
      // Já fez login local (tem funcionario_id)
      console.log('✅ Login local já completo, redirecionando para dashboard...')
      navigate('/dashboard', { replace: true })
    }
  }, [user, navigate])

  // Carregar usuários ativos ao montar
  useEffect(() => {
    carregarUsuarios()
  }, [])

  const carregarUsuarios = async () => {
    try {
      setLoading(true)
      
      // Buscar empresa padrão (primeira empresa do sistema)
      const { data: empresas, error: empresaError } = await supabase
        .from('empresas')
        .select('id')
        .limit(1)

      if (empresaError) {
        console.error('Erro ao buscar empresa:', empresaError)
        toast.error('Erro ao carregar usuários. Verifique as permissões.')
        return
      }

      // Se não há empresa cadastrada, criar empresa padrão
      if (!empresas || empresas.length === 0) {
        console.log('⚠️ Nenhuma empresa cadastrada. Criando empresa padrão...')
        
        const { data: novaEmpresa, error: criarError } = await supabase
          .from('empresas')
          .insert({
            nome: 'Allimport',
            cnpj: '00000000000000',
            telefone: '(00) 00000-0000',
            email: 'contato@allimport.com'
          })
          .select('id')
          .single()

        if (criarError || !novaEmpresa) {
          console.error('Erro ao criar empresa padrão:', criarError)
          toast.error('Erro ao configurar sistema. Entre em contato com o suporte.')
          return
        }

        // Usar a empresa recém-criada
        const { data, error } = await supabase
          .rpc('listar_usuarios_ativos', { p_empresa_id: novaEmpresa.id })

        if (error) {
          console.error('Erro ao listar usuários:', error)
          toast.error('Erro ao carregar usuários')
          return
        }

        setUsuarios(data || [])
        
        if (data && data.length === 1) {
          setUsuarioSelecionado(data[0])
        }
        
        return
      }

      const empresa = empresas[0]
      console.log('🏢 Empresa encontrada:', empresa)

      // Listar usuários ativos usando RPC
      const { data, error } = await supabase
        .rpc('listar_usuarios_ativos', { p_empresa_id: empresa.id })

      if (error) {
        console.error('❌ Erro ao listar usuários:', error)
        toast.error('Erro ao carregar usuários')
        return
      }

      console.log('👥 Usuários encontrados:', data?.length || 0, data)
      setUsuarios(data || [])
      
      // Se houver apenas 1 usuário, selecionar automaticamente
      if (data && data.length === 1) {
        console.log('✅ Auto-selecionando único usuário:', data[0].nome)
        setUsuarioSelecionado(data[0])
      } else if (!data || data.length === 0) {
        console.warn('⚠️ Nenhum usuário ativo encontrado para a empresa')
        toast.error('Nenhum usuário ativo encontrado. Verifique as configurações.')
      }
    } catch (error) {
      console.error('❌ Erro ao carregar usuários:', error)
      toast.error('Erro ao carregar usuários')
    } finally {
      setLoading(false)
    }
  }

  const handleSelecionarUsuario = (usuario: LocalUser) => {
    setUsuarioSelecionado(usuario)
    setSenha('')
  }

  const handleVoltar = () => {
    setUsuarioSelecionado(null)
    setSenha('')
  }

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!usuarioSelecionado) return
    
    setLoginLoading(true)

    try {
      // Validar senha usando RPC
      const { data, error } = await supabase
        .rpc('validar_senha_local', {
          p_funcionario_id: usuarioSelecionado.id,
          p_senha: senha
        })

      if (error) {
        console.error('Erro ao validar senha:', error)
        toast.error('Erro ao fazer login')
        setLoginLoading(false)
        return
      }

      // Verificar resposta
      if (!data || data.length === 0 || !data[0].sucesso) {
        toast.error('Senha incorreta')
        setSenha('')
        setLoginLoading(false)
        return
      }

      // Login bem-sucedido
      const userData = data[0]
      
      // Salvar sessão local
      localStorage.setItem('pdv_local_session', JSON.stringify({
        token: userData.token,
        funcionario_id: userData.funcionario_id,
        nome: userData.nome,
        tipo_admin: userData.tipo_admin,
        empresa_id: userData.empresa_id
      }))

      // Atualizar contexto de autenticação
      if (signInLocal) {
        await signInLocal(userData)
      }

      toast.success(`Bem-vindo, ${userData.nome}!`)
      
      // Redirecionar para dashboard
      navigate('/dashboard', { replace: true })
    } catch (error) {
      console.error('Erro no login:', error)
      toast.error('Erro ao fazer login')
    } finally {
      setLoginLoading(false)
    }
  }

  const getIniciais = (nome: string) => {
    const partes = nome.split(' ')
    if (partes.length >= 2) {
      return `${partes[0][0]}${partes[1][0]}`.toUpperCase()
    }
    return nome.substring(0, 2).toUpperCase()
  }

  const getTipoBadge = (tipoAdmin: string) => {
    if (tipoAdmin === 'admin_empresa') {
      return { label: 'Administrador', color: 'bg-primary-500' }
    }
    return { label: 'Funcionário', color: 'bg-secondary-500' }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-secondary-900 via-secondary-800 to-black flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-primary-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-white text-lg">Carregando usuários...</p>
        </div>
      </div>
    )
  }

  // TELA DE SELEÇÃO DE USUÁRIOS
  if (!usuarioSelecionado) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-secondary-900 via-secondary-800 to-black flex items-center justify-center p-4">
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute inset-0 bg-gradient-to-r from-primary-500/20 to-transparent"></div>
          <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl"></div>
          <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-primary-400/10 rounded-full blur-3xl"></div>
        </div>

        <div className="relative w-full max-w-5xl">
          {/* Logo Card */}
          <Card className="mb-8 bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
            <div className="text-center py-6">
              <div className="inline-flex items-center space-x-3">
                <div className="w-16 h-16 bg-gradient-to-br from-primary-500 to-primary-600 rounded-2xl flex items-center justify-center shadow-lg">
                  <ShoppingCart className="w-8 h-8 text-white" />
                </div>
                <div>
                  <h1 className="text-3xl font-bold text-secondary-900">PDV Import</h1>
                  <p className="text-primary-600 font-medium">Sistema de Vendas</p>
                </div>
              </div>
            </div>
          </Card>

          {/* Seleção de Usuário */}
          <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
            <div className="p-8">
              <div className="text-center mb-8">
                <h2 className="text-3xl font-bold text-secondary-900 mb-2">
                  Selecione seu usuário
                </h2>
                <p className="text-secondary-600 text-lg">
                  Clique no seu card para fazer login
                </p>
              </div>

              {usuarios.length === 0 ? (
                <div className="text-center py-12">
                  <div className="w-16 h-16 bg-secondary-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <User className="w-8 h-8 text-secondary-400" />
                  </div>
                  <p className="text-secondary-600 mb-4">
                    Nenhum usuário ativo encontrado
                  </p>
                  <p className="text-secondary-500 text-sm">
                    Entre em contato com o administrador do sistema
                  </p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {usuarios.map((usuario) => {
                    const badge = getTipoBadge(usuario.tipo_admin)
                    
                    return (
                      <button
                        key={usuario.id}
                        onClick={() => handleSelecionarUsuario(usuario)}
                        className="group relative bg-white border-2 border-secondary-200 rounded-2xl p-6 hover:border-primary-500 hover:shadow-xl transition-all duration-200 text-left"
                      >
                        {/* Badge de tipo */}
                        <div className={`absolute top-4 right-4 ${badge.color} text-white text-xs font-medium px-3 py-1 rounded-full`}>
                          {badge.label}
                        </div>

                        {/* Avatar */}
                        <div className="flex flex-col items-center mb-4">
                          {usuario.foto_perfil ? (
                            <img
                              src={usuario.foto_perfil}
                              alt={usuario.nome}
                              className="w-24 h-24 rounded-full object-cover border-4 border-secondary-100 group-hover:border-primary-500 transition-colors"
                            />
                          ) : (
                            <div className="w-24 h-24 bg-gradient-to-br from-primary-500 to-primary-600 rounded-full flex items-center justify-center text-white text-3xl font-bold border-4 border-secondary-100 group-hover:border-primary-500 transition-colors">
                              {getIniciais(usuario.nome)}
                            </div>
                          )}
                        </div>

                        {/* Info */}
                        <div className="text-center">
                          <h3 className="text-xl font-bold text-secondary-900 mb-1 group-hover:text-primary-600 transition-colors">
                            {usuario.nome}
                          </h3>
                          <p className="text-secondary-500 text-sm">
                            {usuario.email}
                          </p>
                        </div>

                        {/* Primeiro acesso indicator */}
                        {usuario.primeiro_acesso && (
                          <div className="mt-3 text-center">
                            <span className="inline-flex items-center text-xs text-primary-600 font-medium">
                              <span className="w-2 h-2 bg-primary-500 rounded-full mr-2 animate-pulse"></span>
                              Primeiro acesso
                            </span>
                          </div>
                        )}
                      </button>
                    )
                  })}
                </div>
              )}
            </div>
          </Card>
        </div>
      </div>
    )
  }

  // TELA DE SENHA
  return (
    <div className="min-h-screen bg-gradient-to-br from-secondary-900 via-secondary-800 to-black flex items-center justify-center p-4">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0 bg-gradient-to-r from-primary-500/20 to-transparent"></div>
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary-500/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-primary-400/10 rounded-full blur-3xl"></div>
      </div>

      <div className="relative w-full max-w-md">
        {/* Botão Voltar */}
        <button
          onClick={handleVoltar}
          className="mb-4 flex items-center text-white hover:text-primary-400 transition-colors"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Voltar para seleção de usuários
        </button>

        {/* Login Card */}
        <Card className="bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8">
            {/* Avatar do usuário selecionado */}
            <div className="text-center mb-6">
              {usuarioSelecionado.foto_perfil ? (
                <img
                  src={usuarioSelecionado.foto_perfil}
                  alt={usuarioSelecionado.nome}
                  className="w-24 h-24 rounded-full object-cover border-4 border-primary-500 mx-auto mb-4"
                />
              ) : (
                <div className="w-24 h-24 bg-gradient-to-br from-primary-500 to-primary-600 rounded-full flex items-center justify-center text-white text-3xl font-bold mx-auto mb-4">
                  {getIniciais(usuarioSelecionado.nome)}
                </div>
              )}
              
              <h2 className="text-2xl font-bold text-secondary-900 mb-1">
                Bem-vindo, {usuarioSelecionado.nome}!
              </h2>
              <p className="text-secondary-600">
                Digite sua senha para continuar
              </p>
              
              {usuarioSelecionado.primeiro_acesso && (
                <div className="mt-3 inline-flex items-center px-3 py-1 bg-primary-50 border border-primary-200 rounded-full text-primary-700 text-sm font-medium">
                  <span className="w-2 h-2 bg-primary-500 rounded-full mr-2 animate-pulse"></span>
                  Primeiro acesso
                </div>
              )}
            </div>

            {/* Formulário de senha */}
            <form onSubmit={handleLogin} className="space-y-6">
              <div className="relative">
                <Input
                  label="Senha"
                  type="password"
                  value={senha}
                  onChange={(e) => setSenha(e.target.value)}
                  placeholder="Digite sua senha"
                  required
                  autoFocus
                  disabled={loginLoading}
                />
                <Lock className="absolute left-3 top-9 w-5 h-5 text-secondary-400 pointer-events-none" />
              </div>

              <Button
                type="submit"
                variant="primary"
                size="lg"
                className="w-full"
                loading={loginLoading}
                disabled={!senha || loginLoading}
              >
                {loginLoading ? 'Entrando...' : 'Entrar no Sistema'}
              </Button>
            </form>

            {usuarioSelecionado.primeiro_acesso && (
              <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                <p className="text-blue-800 text-sm">
                  <strong>💡 Primeiro acesso:</strong> Use a senha que foi definida pelo administrador. 
                  Você poderá alterá-la nas configurações do sistema.
                </p>
              </div>
            )}
          </div>
        </Card>
      </div>
    </div>
  )
}
