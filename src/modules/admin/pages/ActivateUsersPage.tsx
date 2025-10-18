import { useState, useEffect } from 'react'
import { UserPlus, Eye, EyeOff, Save, Check, X } from 'lucide-react'
import { Card } from '../../../components/ui/Card'
import { Button } from '../../../components/ui/Button'
import { Input } from '../../../components/ui/Input'
import { supabase } from '../../../lib/supabase'
import toast from 'react-hot-toast'
import { useAuth } from '../../auth/AuthContext'

interface Funcionario {
  id: string
  nome: string
  email: string
  usuario_ativo: boolean
  senha_definida: boolean
  tipo_admin: string
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

export function ActivateUsersPage() {
  const { user } = useAuth()
  const [funcionarios, setFuncionarios] = useState<Funcionario[]>([])
  const [funcoes, setFuncoes] = useState<Funcao[]>([])
  const [loading, setLoading] = useState(true)
  const [showNovoUsuario, setShowNovoUsuario] = useState(false)
  const [novoUsuario, setNovoUsuario] = useState<NovoUsuario>({
    nome: '',
    email: '',
    senha: '',
    funcao_id: ''
  })
  const [showSenha, setShowSenha] = useState(false)
  const [adminNeedPassword, setAdminNeedPassword] = useState(false)
  const [adminPassword, setAdminPassword] = useState('')
  const [savingAdmin, setSavingAdmin] = useState(false)

  useEffect(() => {
    carregarDados()
  }, [])

  const carregarDados = async () => {
    try {
      setLoading(true)

      // Buscar empresa do usuário
      // Usar user.id como empresa_id (cada usuário é sua própria empresa)
      const empresa = { id: user?.id };

      if (!empresa.id) {
        console.error('❌ [carregarDados] user_id não disponível')
        toast.error('Erro ao carregar dados')
        return
      }

      console.log('✅ [carregarDados] Usando empresa_id:', empresa.id);

      // Buscar funcionários
      const { data: funcionariosData, error: funcError } = await supabase
        .from('funcionarios')
        .select('id, nome, email, usuario_ativo, senha_definida, tipo_admin')
        .eq('empresa_id', empresa.id)
        .order('nome')

      if (funcError) {
        console.error('Erro ao buscar funcionários:', funcError)
        toast.error('Erro ao carregar funcionários')
      } else {
        setFuncionarios(funcionariosData || [])
        
        // Verificar se admin precisa definir senha
        const admin = funcionariosData?.find(f => f.tipo_admin === 'admin_empresa')
        if (admin && !admin.senha_definida) {
          setAdminNeedPassword(true)
        }
      }

      // Buscar funções disponíveis
      const { data: funcoesData, error: funcoesError } = await supabase
        .from('funcoes')
        .select('id, nome, descricao')
        .eq('empresa_id', empresa.id)
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

  const handleDefinirSenhaAdmin = async () => {
    if (!adminPassword || adminPassword.length < 6) {
      toast.error('A senha deve ter no mínimo 6 caracteres')
      return
    }

    try {
      setSavingAdmin(true)

      // Buscar admin
      const admin = funcionarios.find(f => f.tipo_admin === 'admin_empresa')
      if (!admin) {
        toast.error('Administrador não encontrado')
        return
      }

      // Definir senha usando RPC
      const { data, error } = await supabase
        .rpc('definir_senha_local', {
          p_funcionario_id: admin.id,
          p_senha: adminPassword
        })

      if (error) {
        console.error('Erro ao definir senha:', error)
        toast.error('Erro ao definir senha do administrador')
        return
      }

      if (data) {
        toast.success('Senha do administrador definida com sucesso!')
        setAdminNeedPassword(false)
        setAdminPassword('')
        await carregarDados()
      } else {
        toast.error('Erro ao definir senha do administrador')
      }
    } catch (error) {
      console.error('Erro ao definir senha admin:', error)
      toast.error('Erro ao definir senha do administrador')
    } finally {
      setSavingAdmin(false)
    }
  }

  const handleCriarUsuario = async () => {
    // Validações
    if (!novoUsuario.nome.trim()) {
      toast.error('Digite o nome do funcionário')
      return
    }

    if (!novoUsuario.email.trim()) {
      toast.error('Digite o email do funcionário')
      return
    }

    if (!novoUsuario.senha || novoUsuario.senha.length < 6) {
      toast.error('A senha deve ter no mínimo 6 caracteres')
      return
    }

    if (!novoUsuario.funcao_id) {
      toast.error('Selecione uma função para o funcionário')
      return
    }

    try {
      setLoading(true)

      // Usar user.id como empresa_id (cada usuário é sua própria empresa)
      const empresaId = user?.id;

      if (!empresaId) {
        console.error('❌ [handleActivateUser] user_id não disponível');
        toast.error('Erro: Usuário não identificado');
        return;
      }

      console.log('✅ [handleActivateUser] Usando empresa_id:', empresaId);

      // Criar funcionário
      const { data: funcionarioDataArray, error: funcError } = await supabase
        .from('funcionarios')
        .insert({
          empresa_id: empresaId,
          nome: novoUsuario.nome,
          email: novoUsuario.email,
          status: 'ativo',
          tipo_admin: 'funcionario',
          usuario_ativo: false, // Será ativado quando definir senha
          senha_definida: false
        })
        .select()

      const funcionario = funcionarioDataArray && funcionarioDataArray.length > 0 ? funcionarioDataArray[0] : null;

      if (funcError) {
        console.error('Erro ao criar funcionário:', funcError)
        toast.error('Erro ao criar funcionário')
        return
      }

      // Associar função
      const { error: funcaoError } = await supabase
        .from('funcionario_funcoes')
        .insert({
          funcionario_id: funcionario.id,
          funcao_id: novoUsuario.funcao_id,
          empresa_id: empresaId
        })

      if (funcaoError) {
        console.error('Erro ao associar função:', funcaoError)
        toast.error('Erro ao associar função ao funcionário')
        return
      }

      // Definir senha usando RPC
      const { data: senhaDefinida, error: senhaError } = await supabase
        .rpc('definir_senha_local', {
          p_funcionario_id: funcionario.id,
          p_senha: novoUsuario.senha
        })

      if (senhaError || !senhaDefinida) {
        console.error('Erro ao definir senha:', senhaError)
        toast.error('Funcionário criado, mas erro ao definir senha')
        return
      }

      toast.success(`Usuário ${novoUsuario.nome} criado e ativado com sucesso!`)
      
      // Limpar formulário
      setNovoUsuario({
        nome: '',
        email: '',
        senha: '',
        funcao_id: ''
      })
      setShowNovoUsuario(false)
      
      // Recarregar lista
      await carregarDados()
    } catch (error) {
      console.error('Erro ao criar usuário:', error)
      toast.error('Erro ao criar usuário')
    } finally {
      setLoading(false)
    }
  }

  const handleToggleAtivo = async (funcionario: Funcionario) => {
    try {
      const novoStatus = !funcionario.usuario_ativo

      const { error } = await supabase
        .from('funcionarios')
        .update({ usuario_ativo: novoStatus })
        .eq('id', funcionario.id)

      if (error) {
        console.error('Erro ao atualizar status:', error)
        toast.error('Erro ao atualizar status do usuário')
        return
      }

      toast.success(
        novoStatus 
          ? `${funcionario.nome} foi ativado` 
          : `${funcionario.nome} foi desativado`
      )
      
      await carregarDados()
    } catch (error) {
      console.error('Erro ao toggle ativo:', error)
      toast.error('Erro ao atualizar status')
    }
  }

  // Modal de definir senha do admin
  if (adminNeedPassword) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-secondary-900 via-secondary-800 to-black flex items-center justify-center p-4">
        <Card className="w-full max-w-md bg-white/95 backdrop-blur-sm border-0 shadow-2xl">
          <div className="p-8">
            <div className="text-center mb-6">
              <div className="w-16 h-16 bg-gradient-to-br from-primary-500 to-primary-600 rounded-full flex items-center justify-center mx-auto mb-4">
                <UserPlus className="w-8 h-8 text-white" />
              </div>
              <h2 className="text-2xl font-bold text-secondary-900 mb-2">
                Bem-vindo, Administrador!
              </h2>
              <p className="text-secondary-600">
                Defina sua senha pessoal para começar a usar o sistema
              </p>
            </div>

            <div className="space-y-4">
              <Input
                label="Sua Senha de Administrador"
                type={showSenha ? 'text' : 'password'}
                value={adminPassword}
                onChange={(e) => setAdminPassword(e.target.value)}
                placeholder="Mínimo 6 caracteres"
                required
                autoFocus
              />

              <button
                type="button"
                onClick={() => setShowSenha(!showSenha)}
                className="text-sm text-primary-600 hover:text-primary-700 flex items-center"
              >
                {showSenha ? (
                  <>
                    <EyeOff className="w-4 h-4 mr-2" />
                    Ocultar senha
                  </>
                ) : (
                  <>
                    <Eye className="w-4 h-4 mr-2" />
                    Mostrar senha
                  </>
                )}
              </button>

              <Button
                onClick={handleDefinirSenhaAdmin}
                variant="primary"
                size="lg"
                className="w-full"
                loading={savingAdmin}
                disabled={!adminPassword || adminPassword.length < 6}
              >
                {savingAdmin ? 'Salvando...' : 'Definir Senha e Continuar'}
              </Button>
            </div>

            <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
              <p className="text-blue-800 text-sm">
                <strong>💡 Dica:</strong> Escolha uma senha forte e memorável. 
                Você precisará dela para acessar o sistema.
              </p>
            </div>
          </div>
        </Card>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-primary-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-secondary-600">Carregando usuários...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-secondary-900">Ativar Novos Usuários</h1>
          <p className="text-secondary-600 mt-1">
            Crie e ative funcionários para acessar o sistema
          </p>
        </div>
        
        <Button
          onClick={() => setShowNovoUsuario(!showNovoUsuario)}
          variant="primary"
        >
          <UserPlus className="w-5 h-5 mr-2" />
          Novo Usuário
        </Button>
      </div>

      {/* Formulário de Novo Usuário */}
      {showNovoUsuario && (
        <Card>
          <div className="p-6">
            <h3 className="text-lg font-semibold text-secondary-900 mb-4">
              Criar Novo Funcionário
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
              <Input
                label="Nome Completo"
                value={novoUsuario.nome}
                onChange={(e) => setNovoUsuario({ ...novoUsuario, nome: e.target.value })}
                placeholder="João Silva"
                required
              />

              <Input
                label="Email"
                type="email"
                value={novoUsuario.email}
                onChange={(e) => setNovoUsuario({ ...novoUsuario, email: e.target.value })}
                placeholder="joao@email.com"
                required
              />

              <div className="relative">
                <Input
                  label="Senha"
                  type={showSenha ? 'text' : 'password'}
                  value={novoUsuario.senha}
                  onChange={(e) => setNovoUsuario({ ...novoUsuario, senha: e.target.value })}
                  placeholder="Mínimo 6 caracteres"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowSenha(!showSenha)}
                  className="absolute right-3 top-9 text-secondary-400 hover:text-secondary-600"
                >
                  {showSenha ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>

              <div>
                <label className="block text-sm font-medium text-secondary-700 mb-1">
                  Função
                </label>
                <select
                  value={novoUsuario.funcao_id}
                  onChange={(e) => setNovoUsuario({ ...novoUsuario, funcao_id: e.target.value })}
                  className="w-full px-4 py-2 border border-secondary-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                  required
                >
                  <option value="">Selecione uma função</option>
                  {funcoes.map((funcao) => (
                    <option key={funcao.id} value={funcao.id}>
                      {funcao.nome}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="flex gap-3">
              <Button
                onClick={handleCriarUsuario}
                variant="primary"
                loading={loading}
              >
                <Save className="w-5 h-5 mr-2" />
                Criar e Ativar Usuário
              </Button>
              
              <Button
                onClick={() => {
                  setShowNovoUsuario(false)
                  setNovoUsuario({ nome: '', email: '', senha: '', funcao_id: '' })
                }}
                variant="outline"
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
          <h3 className="text-lg font-semibold text-secondary-900 mb-4">
            Usuários Cadastrados
          </h3>

          {funcionarios.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-secondary-600">Nenhum funcionário cadastrado ainda</p>
            </div>
          ) : (
            <div className="space-y-3">
              {funcionarios.map((funcionario) => (
                <div
                  key={funcionario.id}
                  className="flex items-center justify-between p-4 bg-secondary-50 rounded-lg hover:bg-secondary-100 transition-colors"
                >
                  <div className="flex-1">
                    <div className="flex items-center gap-3">
                      <h4 className="font-semibold text-secondary-900">
                        {funcionario.nome}
                      </h4>
                      {funcionario.tipo_admin === 'admin_empresa' && (
                        <span className="px-2 py-1 bg-primary-100 text-primary-700 text-xs font-medium rounded-full">
                          Administrador
                        </span>
                      )}
                      {funcionario.senha_definida && (
                        <span className="px-2 py-1 bg-green-100 text-green-700 text-xs font-medium rounded-full flex items-center">
                          <Check className="w-3 h-3 mr-1" />
                          Senha OK
                        </span>
                      )}
                    </div>
                    <p className="text-sm text-secondary-600 mt-1">{funcionario.email}</p>
                  </div>

                  <div className="flex items-center gap-3">
                    <span className={`text-sm font-medium ${
                      funcionario.usuario_ativo ? 'text-green-600' : 'text-secondary-400'
                    }`}>
                      {funcionario.usuario_ativo ? 'Ativo' : 'Inativo'}
                    </span>

                    {funcionario.tipo_admin !== 'admin_empresa' && (
                      <button
                        onClick={() => handleToggleAtivo(funcionario)}
                        className={`p-2 rounded-lg transition-colors ${
                          funcionario.usuario_ativo
                            ? 'bg-red-100 text-red-600 hover:bg-red-200'
                            : 'bg-green-100 text-green-600 hover:bg-green-200'
                        }`}
                        title={funcionario.usuario_ativo ? 'Desativar' : 'Ativar'}
                      >
                        {funcionario.usuario_ativo ? (
                          <X className="w-5 h-5" />
                        ) : (
                          <Check className="w-5 h-5" />
                        )}
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </Card>
    </div>
  )
}
