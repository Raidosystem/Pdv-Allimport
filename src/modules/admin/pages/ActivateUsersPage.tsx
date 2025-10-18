import { useState, useEffect } from 'react'
import { UserPlus, Eye, EyeOff, Trash2, Pause, Play, Users, AlertTriangle } from 'lucide-react'
import { Card } from '../../../components/ui/Card'
import { Button } from '../../../components/ui/Button'
import { Input } from '../../../components/ui/Input'
import { supabase } from '../../../lib/supabase'
import toast from 'react-hot-toast'
import { useAuth } from '../../auth/AuthContext'

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
  senha: string
}

interface DeleteConfirmation {
  isOpen: boolean
  funcionarioId: string | null
  funcionarioNome: string
}

export function ActivateUsersPage() {
  const { user } = useAuth()
  const [funcionarios, setFuncionarios] = useState<Funcionario[]>([])
  const [loading, setLoading] = useState(true)
  const [novoUsuario, setNovoUsuario] = useState<NovoUsuario>({
    nome: '',
    senha: ''
  })
  const [mostrarSenha, setMostrarSenha] = useState(false)
  const [deleteConfirm, setDeleteConfirm] = useState<DeleteConfirmation>({
    isOpen: false,
    funcionarioId: null,
    funcionarioNome: ''
  })

  // Buscar funcionários
  const carregarFuncionarios = async () => {
    try {
      setLoading(true)

      // Buscar empresa_id do contexto (AuthContext já fornece isso)
      const empresaId = user?.id // No sistema, user.id É o empresa_id

      if (!empresaId) {
        throw new Error('Empresa não identificada')
      }

      // Buscar todos os funcionários da empresa (exceto admin)
      const { data: funcionariosData, error: funcionariosError } = await supabase
        .from('funcionarios')
        .select(`
          id,
          nome,
          status,
          ultimo_acesso,
          tipo_admin,
          login_funcionarios (
            usuario
          )
        `)
        .eq('empresa_id', empresaId)
        .neq('tipo_admin', 'admin_empresa')
        .order('nome')

      if (funcionariosError) throw funcionariosError

      const funcionariosFormatados = (funcionariosData || []).map((f: any) => ({
        id: f.id,
        nome: f.nome,
        usuario: f.login_funcionarios?.[0]?.usuario || 'Sem usuário',
        status: f.status || 'ativo',
        ultimo_acesso: f.ultimo_acesso,
        tipo_admin: f.tipo_admin
      }))

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
  }, [user])

  // Criar novo funcionário (SEM EMAIL)
  const handleCriarFuncionario = async () => {
    try {
      if (!novoUsuario.nome.trim()) {
        toast.error('Preencha o nome do funcionário')
        return
      }

      if (!novoUsuario.senha || novoUsuario.senha.length < 6) {
        toast.error('A senha deve ter pelo menos 6 caracteres')
        return
      }

      // Empresa ID do contexto
      const empresaId = user?.id // No sistema, user.id É o empresa_id

      if (!empresaId) {
        toast.error('Empresa não identificada')
        return
      }

      // Gerar usuário único a partir do nome
      const usuarioBase = novoUsuario.nome
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9]/g, '')
        .substring(0, 20)

      // Verificar se usuário já existe
      let usuario = usuarioBase
      let contador = 1
      let usuarioExiste = true

      while (usuarioExiste) {
        const { data, error } = await supabase
          .from('login_funcionarios')
          .select('id')
          .eq('usuario', usuario)
          .maybeSingle() // Usa maybeSingle ao invés de single

        if (!data || error) {
          usuarioExiste = false
        } else {
          usuario = `${usuarioBase}${contador}`
          contador++
        }
      }

      // Hash da senha (simplificado - em produção use bcrypt)
      const senhaHash = btoa(novoUsuario.senha)

      // Criar funcionário
      const { data: novoFuncionario, error: funcionarioError } = await supabase
        .from('funcionarios')
        .insert({
          empresa_id: empresaId,
          nome: novoUsuario.nome,
          email: null, // SEM EMAIL
          status: 'ativo',
          tipo_admin: 'funcionario'
        })
        .select()
        .single()

      if (funcionarioError) throw funcionarioError

      // Criar login do funcionário
      const { error: loginError } = await supabase
        .from('login_funcionarios')
        .insert({
          funcionario_id: novoFuncionario.id,
          usuario: usuario,
          senha: senhaHash,  // Pode ser 'senha' ou 'senha_hash'
          ativo: true
        })

      if (loginError) throw loginError

      toast.success(`Funcionário criado! Usuário: ${usuario}`)
      setNovoUsuario({ nome: '', senha: '' })
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

  // Excluir funcionário PERMANENTEMENTE
  const handleExcluirFuncionario = async () => {
    try {
      if (!deleteConfirm.funcionarioId) return

      // Excluir login primeiro (FK)
      const { error: loginError } = await supabase
        .from('login_funcionarios')
        .delete()
        .eq('funcionario_id', deleteConfirm.funcionarioId)

      if (loginError) throw loginError

      // Excluir funcionário
      const { error: funcionarioError } = await supabase
        .from('funcionarios')
        .delete()
        .eq('id', deleteConfirm.funcionarioId)

      if (funcionarioError) throw funcionarioError

      toast.success(`${deleteConfirm.funcionarioNome} foi excluído permanentemente do sistema.`)
      setDeleteConfirm({ isOpen: false, funcionarioId: null, funcionarioNome: '' })
      carregarFuncionarios()
    } catch (error: any) {
      console.error('Erro ao excluir funcionário:', error)
      toast.error('Erro ao excluir funcionário: ' + error.message)
    }
  }

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

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
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

          <div className="mt-4 flex items-center justify-between">
            <p className="text-sm text-secondary-500">
              O nome de usuário será gerado automaticamente
            </p>
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
              {funcionarios.map((funcionario) => (
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
              ))}
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
