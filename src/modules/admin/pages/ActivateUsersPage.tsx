import { useState, useEffect } from 'react'
import { UserPlus, Eye, EyeOff, Trash2, Pause, Play, Users, AlertTriangle, Lock, Shield } from 'lucide-react'
import { Card } from '../../../components/ui/Card'
import { Button } from '../../../components/ui/Button'
import { Input } from '../../../components/ui/Input'
import { supabase } from '../../../lib/supabase'
import toast from 'react-hot-toast'
import { useAuth } from '../../auth/AuthContext'
import { useEmployeesStatus } from '../../../hooks/useEmployeesStatus'
import { AdminCreationModal } from '../../../components/AdminCreationModal'

interface Funcionario {
  id: string
  nome: string
  usuario: string
  status: 'ativo' | 'pausado' | 'inativo'
  ultimo_acesso: string | null
  tipo_admin: string | null
}

interface NovoUsuario {
  nome: string
  email: string
  senha: string
  funcao_id: string
}

interface Funcao {
  id: string
  nome: string
  descricao: string
}

interface DeleteConfirmation {
  isOpen: boolean
  funcionarioId: string | null
  funcionarioNome: string
}

export function ActivateUsersPage() {
  const { user } = useAuth()
  const { hasEmployees, isLoading: checkingEmployees, refetch: refetchEmployeesStatus } = useEmployeesStatus()
  const [funcionarios, setFuncionarios] = useState<Funcionario[]>([])
  const [funcoes, setFuncoes] = useState<Funcao[]>([])
  const [loading, setLoading] = useState(true)
  const [showAdminModal, setShowAdminModal] = useState(false)
  const [novoUsuario, setNovoUsuario] = useState<NovoUsuario>({
    nome: '',
    email: '',
    senha: '',
    funcao_id: ''
  })
  const [mostrarSenha, setMostrarSenha] = useState(false)
  const [deleteConfirm, setDeleteConfirm] = useState<DeleteConfirmation>({
    isOpen: false,
    funcionarioId: null,
    funcionarioNome: ''
  })

  // Buscar empresa_id real da tabela empresas
  const buscarEmpresaId = async () => {
    if (!user?.email) return null
    
    const { data, error } = await supabase
      .from('empresas')
      .select('id')
      .eq('email', user.email)
      .single()
    
    if (error || !data) {
      console.error('Erro ao buscar empresa:', error)
      return null
    }
    
    return data.id
  }

  // Buscar funções disponíveis
  const carregarFuncoes = async () => {
    try {
      const empresaId = await buscarEmpresaId()

      if (!empresaId) return

      const { data, error } = await supabase
        .from('funcoes')
        .select('*')
        .eq('empresa_id', empresaId)
        .order('nome')

      if (error) throw error

      setFuncoes(data || [])
    } catch (error: any) {
      console.error('Erro ao carregar funções:', error)
    }
  }

  // Buscar funcionários
  const carregarFuncionarios = async () => {
    try {
      setLoading(true)

      // Buscar empresa_id REAL da tabela empresas
      const empresaId = await buscarEmpresaId()

      console.log('🔍 DEBUG ActivateUsers - empresaId:', empresaId)
      console.log('🔍 DEBUG ActivateUsers - user completo:', user)

      if (!empresaId) {
        throw new Error('Empresa não identificada')
      }

      // Buscar todos os funcionários da empresa (incluindo admin para debug)
      const { data: funcionariosData, error: funcionariosError } = await supabase
        .from('funcionarios')
        .select('id, nome, status, ultimo_acesso, tipo_admin')
        .eq('empresa_id', empresaId)
        .order('nome')

      console.log('🔍 DEBUG ActivateUsers - Funcionários retornados:', funcionariosData)
      console.log('🔍 DEBUG ActivateUsers - Erro funcionários:', funcionariosError)

      if (funcionariosError) throw funcionariosError

      // Buscar logins SEPARADAMENTE (evita problema de RLS com nested query)
      const funcionariosIds = (funcionariosData || []).map((f: any) => f.id)
      
      const { data: loginsData, error: loginsError } = await supabase
        .from('login_funcionarios')
        .select('funcionario_id, usuario')
        .in('funcionario_id', funcionariosIds)

      console.log('🔍 DEBUG ActivateUsers - Logins retornados:', loginsData)
      console.log('🔍 DEBUG ActivateUsers - Erro logins:', loginsError)

      // Criar mapa de logins por funcionario_id
      const loginsMap = new Map(
        (loginsData || []).map((l: any) => [l.funcionario_id, l.usuario])
      )

      const funcionariosFormatados = (funcionariosData || []).map((f: any) => ({
        id: f.id,
        nome: f.nome,
        usuario: loginsMap.get(f.id) || 'Sem usuário',
        status: f.status || 'ativo',
        ultimo_acesso: f.ultimo_acesso,
        tipo_admin: f.tipo_admin
      }))

      console.log('🔍 DEBUG ActivateUsers - Funcionários formatados:', funcionariosFormatados)
      console.log('📊 Total de funcionários:', funcionariosFormatados.length)
      
      // Salvar globalmente para debug fácil
      ;(window as any).lastFuncionarios = funcionariosFormatados

      setFuncionarios(funcionariosFormatados)
    } catch (error: any) {
      console.error('Erro ao carregar funcionários:', error)
      toast.error('Erro ao carregar funcionários')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    carregarFuncionarios()
    carregarFuncoes()
  }, [user])

  // Criar novo funcionário (SEM EMAIL)
  const handleCriarFuncionario = async () => {
    try {
      if (!novoUsuario.nome.trim()) {
        toast.error('Preencha o nome do funcionário')
        return
      }

      if (!novoUsuario.email.trim()) {
        toast.error('Preencha o email do funcionário')
        return
      }

      // Validar formato de email
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailRegex.test(novoUsuario.email)) {
        toast.error('Email inválido')
        return
      }

      if (!novoUsuario.senha || novoUsuario.senha.length < 6) {
        toast.error('A senha deve ter pelo menos 6 caracteres')
        return
      }

      if (!novoUsuario.funcao_id) {
        toast.error('Selecione uma função para o funcionário')
        return
      }

      // Empresa ID do contexto
      const empresaId = await buscarEmpresaId()

      if (!empresaId) {
        toast.error('Empresa não identificada')
        return
      }

      // ✅ USAR NOVA RPC cadastrar_funcionario_simples COM EMAIL
      const { data, error } = await supabase
        .rpc('cadastrar_funcionario_simples', {
          p_empresa_id: empresaId,
          p_nome: novoUsuario.nome,
          p_email: novoUsuario.email,
          p_senha: novoUsuario.senha,
          p_funcao_id: novoUsuario.funcao_id
        })

      if (error) {
        console.error('❌ Erro ao criar funcionário:', error)
        throw error
      }

      console.log('✅ Resposta da RPC:', data)

      // Verificar resultado da RPC
      if (data?.success) {
        toast.success(`✅ ${data.message || 'Funcionário criado com sucesso!'}`)
      } else {
        toast.error(data?.error || 'Erro ao criar funcionário')
        return
      }

      setNovoUsuario({ nome: '', email: '', senha: '', funcao_id: '' })
      carregarFuncionarios()
    } catch (error: any) {
      console.error('Erro ao criar funcionário:', error)
      toast.error('Erro ao criar funcionário: ' + error.message)
    }
  }

  // Pausar/Ativar funcionário
  const handleTogglePausarFuncionario = async (funcionario: Funcionario) => {
    try {
      const novoStatus = funcionario.status === 'ativo' ? 'pausado' : 'ativo'

      const { error } = await supabase
        .from('funcionarios')
        .update({ status: novoStatus })
        .eq('id', funcionario.id)

      if (error) throw error

      // Atualizar também o login
      const { error: loginError } = await supabase
        .from('login_funcionarios')
        .update({ ativo: novoStatus === 'ativo' })
        .eq('funcionario_id', funcionario.id)

      if (loginError) throw loginError

      toast.success(
        novoStatus === 'pausado'
          ? `${funcionario.nome} foi pausado. Não poderá fazer login.`
          : `${funcionario.nome} foi ativado novamente.`
      )

      carregarFuncionarios()
    } catch (error: any) {
      console.error('Erro ao pausar/ativar funcionário:', error)
      toast.error('Erro ao atualizar funcionário')
    }
  }

  // Excluir funcionário PERMANENTEMENTE (incluindo auth.users)
  const handleExcluirFuncionario = async () => {
    try {
      if (!deleteConfirm.funcionarioId) return

      // ✅ USAR RPC QUE LIMPA TUDO (login_funcionarios, funcionarios, auth.users)
      const { data, error } = await supabase
        .rpc('excluir_funcionario_completo', {
          p_funcionario_id: deleteConfirm.funcionarioId
        })

      if (error) {
        console.error('❌ Erro ao chamar RPC:', error)
        throw error
      }

      console.log('📋 Resultado da exclusão:', data)

      if (data?.success) {
        toast.success(data.message || `${deleteConfirm.funcionarioNome} foi excluído permanentemente do sistema.`)
        setDeleteConfirm({ isOpen: false, funcionarioId: null, funcionarioNome: '' })
        carregarFuncionarios()
      } else {
        toast.error(data?.error || 'Erro ao excluir funcionário')
      }

    } catch (error: any) {
      console.error('Erro ao excluir funcionário:', error)
      toast.error('Erro ao excluir funcionário: ' + error.message)
    }
  }

  const handleAdminCreated = async () => {
    // Recarregar status de funcionários
    await refetchEmployeesStatus()
    // Recarregar lista de funcionários
    await carregarFuncionarios()
  }

  // TELA BLOQUEADA - Quando não há funcionários
  if (checkingEmployees || (loading && !hasEmployees)) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (!hasEmployees) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 p-6">
        <div className="max-w-2xl mx-auto pt-12">
          <div className="bg-white rounded-xl shadow-lg p-8 text-center border border-gray-200">
            {/* Ícone de Cadeado */}
            <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center mx-auto mb-4 shadow-lg">
              <Lock className="w-8 h-8 text-white" />
            </div>

            {/* Título */}
            <h1 className="text-2xl font-bold text-gray-900 mb-3">
              Sistema de Funcionários Bloqueado
            </h1>

            {/* Descrição */}
            <p className="text-base text-gray-600 mb-6">
              Para ativar esta funcionalidade, crie o{' '}
              <span className="font-semibold text-blue-600">Administrador Principal</span> primeiro.
            </p>

            {/* Informações */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4 text-left">
              <div className="flex items-start">
                <Shield className="w-5 h-5 text-blue-600 mt-0.5 mr-3 flex-shrink-0" />
                <div>
                  <h3 className="font-semibold text-blue-900 mb-2 text-sm">O que acontece ao criar o administrador?</h3>
                  <ul className="space-y-1.5 text-sm text-blue-800">
                    <li className="flex items-start">
                      <span className="text-blue-600 mr-2">•</span>
                      <span>Sistema de funcionários será desbloqueado</span>
                    </li>
                    <li className="flex items-start">
                      <span className="text-blue-600 mr-2">•</span>
                      <span>Poderá adicionar quantos funcionários precisar</span>
                    </li>
                    <li className="flex items-start">
                      <span className="text-blue-600 mr-2">•</span>
                      <span>Administrador terá acesso completo ao sistema</span>
                    </li>
                  </ul>
                </div>
              </div>
            </div>

            {/* Nota sobre empresas pequenas */}
            <div className="bg-amber-50 border border-amber-200 rounded-lg p-3 mb-6">
              <p className="text-xs text-amber-900">
                <strong>💡 Dica:</strong> Empresas pequenas podem continuar usando o sistema sem ativar funcionários.
              </p>
            </div>

            {/* Botão de Ação */}
            <button
              onClick={() => setShowAdminModal(true)}
              className="inline-flex items-center px-6 py-3 text-base font-semibold text-white bg-gradient-to-r from-blue-600 to-blue-700 rounded-lg hover:from-blue-700 hover:to-blue-800 shadow-lg hover:shadow-xl transition-all transform hover:-translate-y-0.5"
            >
              <Shield className="w-5 h-5 mr-2" />
              Criar Administrador Principal
            </button>
          </div>
        </div>

        {/* Modal de Criação de Admin */}
        <AdminCreationModal
          isOpen={showAdminModal}
          onClose={() => setShowAdminModal(false)}
          onSuccess={handleAdminCreated}
        />
      </div>
    )
  }

  // TELA NORMAL - Quando já existem funcionários
  return (
    <div className="p-6 max-w-6xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-secondary-900 mb-2">
          Gerenciar Funcionários
        </h1>
        <p className="text-secondary-600">
          Crie, pause ou exclua funcionários do sistema
        </p>
      </div>

      {/* Card de Novo Funcionário */}
      <Card className="mb-6">
        <div className="p-6">
          <div className="flex items-center mb-4">
            <UserPlus className="w-5 h-5 text-primary-600 mr-2" />
            <h2 className="text-lg font-semibold text-secondary-900">
              Novo Funcionário
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {/* Nome */}
            <div>
              <label className="block text-sm font-medium text-secondary-700 mb-1">
                Nome Completo *
              </label>
              <Input
                type="text"
                placeholder="Nome do funcionário"
                value={novoUsuario.nome}
                onChange={(e) => setNovoUsuario({ ...novoUsuario, nome: e.target.value })}
              />
            </div>

            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-secondary-700 mb-1">
                Email * <span className="text-xs text-secondary-500">(login)</span>
              </label>
              <Input
                type="email"
                placeholder="email@exemplo.com"
                value={novoUsuario.email}
                onChange={(e) => setNovoUsuario({ ...novoUsuario, email: e.target.value })}
              />
            </div>

            {/* Função */}
            <div>
              <label className="block text-sm font-medium text-secondary-700 mb-1">
                Função *
              </label>
              <select
                value={novoUsuario.funcao_id}
                onChange={(e) => setNovoUsuario({ ...novoUsuario, funcao_id: e.target.value })}
                className="w-full px-3 py-2 border border-secondary-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Selecione uma função</option>
                {funcoes.map((funcao) => (
                  <option key={funcao.id} value={funcao.id}>
                    {funcao.nome}
                  </option>
                ))}
              </select>
              {novoUsuario.funcao_id && (
                <p className="text-xs text-secondary-500 mt-1">
                  {funcoes.find(f => f.id === novoUsuario.funcao_id)?.descricao}
                </p>
              )}
            </div>

            {/* Senha */}
            <div>
              <label className="block text-sm font-medium text-secondary-700 mb-1">
                Senha *
              </label>
              <div className="relative">
                <Input
                  type={mostrarSenha ? 'text' : 'password'}
                  placeholder="Mínimo 6 caracteres"
                  value={novoUsuario.senha}
                  onChange={(e) => setNovoUsuario({ ...novoUsuario, senha: e.target.value })}
                />
                <button
                  type="button"
                  onClick={() => setMostrarSenha(!mostrarSenha)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-secondary-400 hover:text-secondary-600"
                >
                  {mostrarSenha ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>
          </div>

          <div className="mt-4 flex items-center justify-end">
            <Button onClick={handleCriarFuncionario}>
              <UserPlus className="w-4 h-4 mr-2" />
              Criar Funcionário
            </Button>
          </div>
        </div>
      </Card>

      {/* Lista de Funcionários */}
      <Card>
        <div className="p-6">
          <div className="flex items-center mb-4">
            <Users className="w-5 h-5 text-primary-600 mr-2" />
            <h2 className="text-lg font-semibold text-secondary-900">
              Funcionários Cadastrados ({funcionarios.length})
            </h2>
          </div>

          {loading ? (
            <div className="text-center py-8 text-secondary-500">
              Carregando funcionários...
            </div>
          ) : funcionarios.length === 0 ? (
            <div className="text-center py-8 text-secondary-500">
              Nenhum funcionário cadastrado
            </div>
          ) : (
            <div className="space-y-3">
              {funcionarios.map((funcionario) => {
                console.log('🎨 Renderizando funcionário:', funcionario)
                return (
                <div
                  key={funcionario.id}
                  className="flex items-center justify-between p-4 bg-secondary-50 rounded-lg border border-secondary-200"
                >
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <h3 className="font-medium text-secondary-900">
                        {funcionario.nome}
                      </h3>
                      <span
                        className={`px-2 py-1 text-xs rounded-full font-medium ${
                          funcionario.status === 'ativo'
                            ? 'bg-green-100 text-green-700'
                            : funcionario.status === 'pausado'
                            ? 'bg-yellow-100 text-yellow-700'
                            : 'bg-red-100 text-red-700'
                        }`}
                      >
                        {funcionario.status === 'ativo'
                          ? 'Ativo'
                          : funcionario.status === 'pausado'
                          ? 'Pausado'
                          : 'Inativo'}
                      </span>
                    </div>
                    <p className="text-sm text-secondary-600 mt-1">
                      Usuário: <span className="font-mono font-medium">{funcionario.usuario}</span>
                    </p>
                    {funcionario.ultimo_acesso && (
                      <p className="text-xs text-secondary-500 mt-1">
                        Último acesso: {new Date(funcionario.ultimo_acesso).toLocaleDateString('pt-BR')}
                      </p>
                    )}
                  </div>

                  <div className="flex items-center gap-2">
                    {/* Botão Pausar/Ativar */}
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleTogglePausarFuncionario(funcionario)}
                      title={funcionario.status === 'ativo' ? 'Pausar funcionário' : 'Ativar funcionário'}
                      className={
                        funcionario.status === 'ativo'
                          ? 'text-yellow-600 hover:text-yellow-700 hover:bg-yellow-50'
                          : 'text-green-600 hover:text-green-700 hover:bg-green-50'
                      }
                    >
                      {funcionario.status === 'ativo' ? (
                        <Pause className="w-4 h-4" />
                      ) : (
                        <Play className="w-4 h-4" />
                      )}
                    </Button>

                    {/* Botão Excluir */}
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() =>
                        setDeleteConfirm({
                          isOpen: true,
                          funcionarioId: funcionario.id,
                          funcionarioNome: funcionario.nome
                        })
                      }
                      title="Excluir funcionário permanentemente"
                      className="text-red-600 hover:text-red-700 hover:bg-red-50"
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              )})}
            </div>
          )}
        </div>
      </Card>

      {/* Modal de Confirmação de Exclusão */}
      {deleteConfirm.isOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <div className="flex items-center mb-4">
              <AlertTriangle className="w-6 h-6 text-red-600 mr-2" />
              <h3 className="text-lg font-semibold text-secondary-900">
                Confirmar Exclusão
              </h3>
            </div>

            <p className="text-secondary-700 mb-4">
              Tem certeza que deseja excluir <strong>{deleteConfirm.funcionarioNome}</strong>?
            </p>

            <div className="bg-red-50 border border-red-200 rounded-lg p-3 mb-4">
              <p className="text-sm text-red-800">
                ⚠️ Esta ação é <strong>permanente</strong> e não pode ser desfeita.
                O funcionário será removido completamente do banco de dados.
              </p>
            </div>

            <div className="flex gap-3 justify-end">
              <Button
                variant="outline"
                onClick={() =>
                  setDeleteConfirm({ isOpen: false, funcionarioId: null, funcionarioNome: '' })
                }
              >
                Cancelar
              </Button>
              <Button 
                variant="primary" 
                onClick={handleExcluirFuncionario}
                className="bg-red-600 hover:bg-red-700 text-white"
              >
                <Trash2 className="w-4 h-4 mr-2" />
                Excluir Permanentemente
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
