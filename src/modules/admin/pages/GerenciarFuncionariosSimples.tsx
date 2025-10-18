import { useState, useEffect } from 'react'
import { UserPlus, Eye, EyeOff, Trash2, Users } from 'lucide-react'
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
  ativo: boolean
  ultimo_acesso: string | null
}

interface NovoFuncionario {
  nome: string
  senha: string
  funcao_id: string
}

interface Funcao {
  id: string
  nome: string
  descricao: string
}

export function GerenciarFuncionariosSimples() {
  const { user } = useAuth()
  const [funcionarios, setFuncionarios] = useState<Funcionario[]>([])
  const [funcoes, setFuncoes] = useState<Funcao[]>([])
  const [loading, setLoading] = useState(true)
  const [showNovo, setShowNovo] = useState(false)
  const [salvando, setSalvando] = useState(false)
  const [showSenha, setShowSenha] = useState(false)
  
  const [novoFuncionario, setNovoFuncionario] = useState<NovoFuncionario>({
    nome: '',
    senha: '',
    funcao_id: ''
  })

  useEffect(() => {
    carregarDados()
  }, [])

  const carregarDados = async () => {
    try {
      setLoading(true)

      const empresaId = user?.id
      if (!empresaId) {
        toast.error('Erro: usuário não identificado')
        return
      }

      // Buscar funcionários com seus logins
      const { data: funcionariosData, error: funcError } = await supabase
        .from('funcionarios')
        .select(`
          id,
          nome,
          status,
          login_funcionarios (
            usuario,
            ativo,
            ultimo_acesso
          )
        `)
        .eq('empresa_id', empresaId)
        .eq('status', 'ativo')
        .order('nome')

      if (funcError) {
        console.error('Erro ao buscar funcionários:', funcError)
        toast.error('Erro ao carregar funcionários')
      } else {
        // Mapear dados
        const funcionariosMapeados = (funcionariosData || [])
          .filter(f => f.login_funcionarios && f.login_funcionarios.length > 0)
          .map(f => ({
            id: f.id,
            nome: f.nome,
            usuario: f.login_funcionarios[0].usuario,
            ativo: f.login_funcionarios[0].ativo,
            ultimo_acesso: f.login_funcionarios[0].ultimo_acesso
          }))
        
        setFuncionarios(funcionariosMapeados)
      }

      // Buscar funções disponíveis
      const { data: funcoesData, error: funcoesError } = await supabase
        .from('funcoes')
        .select('id, nome, descricao')
        .eq('empresa_id', empresaId)
        .order('nome')

      if (funcoesError) {
        console.error('Erro ao buscar funções:', funcoesError)
      } else {
        setFuncoes(funcoesData || [])
      }

    } catch (error) {
      console.error('Erro ao carregar dados:', error)
      toast.error('Erro ao carregar dados')
    } finally {
      setLoading(false)
    }
  }

  const handleCadastrar = async () => {
    if (!novoFuncionario.nome.trim()) {
      toast.error('Digite o nome do funcionário')
      return
    }

    if (!novoFuncionario.senha) {
      toast.error('Digite a senha')
      return
    }

    if (novoFuncionario.senha.length < 6) {
      toast.error('Senha deve ter no mínimo 6 caracteres')
      return
    }

    try {
      setSalvando(true)

      const empresaId = user?.id
      if (!empresaId) {
        toast.error('Erro: usuário não identificado')
        return
      }

      // Chamar função SQL para cadastrar funcionário
      const { data, error } = await supabase.rpc('cadastrar_funcionario_simples', {
        p_empresa_id: empresaId,
        p_nome: novoFuncionario.nome,
        p_senha: novoFuncionario.senha,
        p_funcao_id: novoFuncionario.funcao_id || null
      })

      if (error) {
        console.error('Erro ao cadastrar funcionário:', error)
        toast.error('Erro ao cadastrar funcionário')
        return
      }

      if (data && data.success) {
        toast.success(`✅ ${data.nome} cadastrado! Usuário: ${data.usuario}`)
        
        // Resetar formulário
        setNovoFuncionario({
          nome: '',
          senha: '',
          funcao_id: ''
        })
        setShowNovo(false)
        
        // Recarregar lista
        carregarDados()
      } else {
        toast.error(data?.error || 'Erro ao cadastrar funcionário')
      }

    } catch (error) {
      console.error('Erro ao cadastrar funcionário:', error)
      toast.error('Erro ao cadastrar funcionário')
    } finally {
      setSalvando(false)
    }
  }

  const handleExcluir = async (id: string, nome: string) => {
    if (!confirm(`Deseja realmente excluir o funcionário ${nome}?`)) {
      return
    }

    try {
      // Inativar funcionário
      const { error } = await supabase
        .from('funcionarios')
        .update({ status: 'inativo' })
        .eq('id', id)

      if (error) {
        console.error('Erro ao excluir funcionário:', error)
        toast.error('Erro ao excluir funcionário')
        return
      }

      toast.success(`${nome} excluído com sucesso`)
      carregarDados()

    } catch (error) {
      console.error('Erro ao excluir funcionário:', error)
      toast.error('Erro ao excluir funcionário')
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Carregando...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-7xl mx-auto p-6">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
          <Users className="w-8 h-8 text-primary-600" />
          Gerenciar Funcionários
        </h1>
        <p className="text-gray-600 mt-2">
          Cadastre e gerencie funcionários do sistema
        </p>
      </div>

      {/* Botão Novo Funcionário */}
      {!showNovo && (
        <div className="mb-6">
          <Button
            onClick={() => setShowNovo(true)}
            className="flex items-center gap-2"
          >
            <UserPlus className="w-5 h-5" />
            Novo Funcionário
          </Button>
        </div>
      )}

      {/* Formulário Novo Funcionário */}
      {showNovo && (
        <Card className="mb-6 p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">
            Cadastrar Novo Funcionário
          </h2>

          <div className="space-y-4">
            {/* Nome */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nome Completo *
              </label>
              <Input
                value={novoFuncionario.nome}
                onChange={(e) => setNovoFuncionario({ ...novoFuncionario, nome: e.target.value })}
                placeholder="Ex: Maria Silva"
              />
            </div>

            {/* Senha */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Senha * (mínimo 6 caracteres)
              </label>
              <div className="relative">
                <Input
                  type={showSenha ? 'text' : 'password'}
                  value={novoFuncionario.senha}
                  onChange={(e) => setNovoFuncionario({ ...novoFuncionario, senha: e.target.value })}
                  placeholder="Digite a senha"
                />
                <button
                  type="button"
                  onClick={() => setShowSenha(!showSenha)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showSenha ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
            </div>

            {/* Função (opcional) */}
            {funcoes.length > 0 && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Função (opcional)
                </label>
                <select
                  value={novoFuncionario.funcao_id}
                  onChange={(e) => setNovoFuncionario({ ...novoFuncionario, funcao_id: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                >
                  <option value="">Selecione uma função</option>
                  {funcoes.map(funcao => (
                    <option key={funcao.id} value={funcao.id}>
                      {funcao.nome}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Botões */}
            <div className="flex gap-3 pt-4">
              <Button
                onClick={handleCadastrar}
                disabled={salvando}
                className="flex-1"
              >
                {salvando ? 'Cadastrando...' : 'Cadastrar Funcionário'}
              </Button>
              <Button
                variant="secondary"
                onClick={() => {
                  setShowNovo(false)
                  setNovoFuncionario({ nome: '', senha: '', funcao_id: '' })
                }}
              >
                Cancelar
              </Button>
            </div>
          </div>
        </Card>
      )}

      {/* Lista de Funcionários */}
      <Card>
        <div className="p-6">
          <h2 className="text-xl font-bold text-gray-900 mb-4">
            Funcionários Cadastrados ({funcionarios.length})
          </h2>

          {funcionarios.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              <Users className="w-16 h-16 mx-auto mb-4 opacity-30" />
              <p>Nenhum funcionário cadastrado</p>
              <p className="text-sm mt-2">Clique em "Novo Funcionário" para começar</p>
            </div>
          ) : (
            <div className="space-y-3">
              {funcionarios.map(func => (
                <div
                  key={func.id}
                  className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
                >
                  <div className="flex-1">
                    <h3 className="font-semibold text-gray-900">{func.nome}</h3>
                    <div className="flex items-center gap-4 mt-1 text-sm text-gray-600">
                      <span>Usuário: <strong>{func.usuario}</strong></span>
                      {func.ultimo_acesso && (
                        <span>
                          Último acesso: {new Date(func.ultimo_acesso).toLocaleString('pt-BR')}
                        </span>
                      )}
                    </div>
                  </div>
                  
                  <button
                    onClick={() => handleExcluir(func.id, func.nome)}
                    className="flex items-center gap-2 px-3 py-2 text-sm bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                    Excluir
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </Card>

      {/* Instruções */}
      <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <h3 className="font-semibold text-blue-900 mb-2">ℹ️ Como funciona:</h3>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• Digite apenas o <strong>nome</strong> e a <strong>senha</strong> do funcionário</li>
          <li>• Não precisa de email! O sistema gera automaticamente um nome de usuário</li>
          <li>• O funcionário faz login usando o <strong>usuário gerado</strong> + senha</li>
          <li>• Apenas o admin pode criar ou excluir funcionários</li>
        </ul>
      </div>
    </div>
  )
}
