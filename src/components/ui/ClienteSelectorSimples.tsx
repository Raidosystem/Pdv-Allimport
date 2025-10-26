import { useState, useEffect } from 'react'
import { toast } from 'react-hot-toast'
import { 
  Search, 
  User, 
  Phone, 
  Mail, 
  Plus,
  Check,
  X,
  CreditCard
} from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { ClienteService } from '../../services/clienteService'
import { formatarTelefone, formatarCpfCnpj } from '../../utils/formatacao'
import { ClienteFormUnificado } from '../cliente/ClienteFormUnificado'
import type { Cliente } from '../../types/cliente'

type SearchType = 'geral' | 'telefone'

interface ClienteSelectorProps {
  onClienteSelect: (cliente: Cliente | null) => void
  clienteSelecionado?: Cliente | null
  titulo?: string
  showCard?: boolean
}

export function ClienteSelector({ 
  onClienteSelect, 
  clienteSelecionado, 
  titulo = "Dados do Cliente",
  showCard = true
}: ClienteSelectorProps) {
  const [busca, setBusca] = useState('')
  const [searchType, setSearchType] = useState<SearchType>('geral')
  const [clientesEncontrados, setClientesEncontrados] = useState<Cliente[]>([])
  const [mostrarSugestoes, setMostrarSugestoes] = useState(false)
  const [mostrarFormCadastro, setMostrarFormCadastro] = useState(false)
  const [mostrarFormEdicao, setMostrarFormEdicao] = useState(false)
  const [clienteParaEditar, setClienteParaEditar] = useState<Cliente | null>(null)
  const [loadingBusca, setLoadingBusca] = useState(false)

  // Debug: monitorar mudanças no estado de edição
  useEffect(() => {
    console.log('🔍 [DEBUG] Estado de edição mudou:', {
      mostrarFormEdicao,
      clienteParaEditar: clienteParaEditar?.nome || null
    })
  }, [mostrarFormEdicao, clienteParaEditar])

  // Buscar clientes conforme digita
  useEffect(() => {
    const buscarClientes = async () => {
      if (busca.length < 2) {
        setClientesEncontrados([])
        setMostrarSugestoes(false)
        return
      }

      console.log('🔍 [CLIENTE SELECTOR] Buscando clientes para:', busca)
      console.log('🔍 [CLIENTE SELECTOR] Contexto:', window.location.pathname)

      setLoadingBusca(true)
      try {
        const clientes = await ClienteService.buscarClientes({
          search: busca,
          ativo: true
        })
        
        setClientesEncontrados(clientes)
        setMostrarSugestoes(clientes.length > 0)
      } catch (error) {
        console.error('Erro ao buscar clientes:', error)
        toast.error('Erro ao buscar clientes')
      } finally {
        setLoadingBusca(false)
      }
    }

    const timeoutId = setTimeout(buscarClientes, 300)
    return () => clearTimeout(timeoutId)
  }, [busca])

  // Aplicar formatação automática para CPF/CNPJ
  const handleBuscaChange = (value: string) => {
    setBusca(value)
    
    // Aplicar formatação automática apenas se for busca geral (que inclui CPF/CNPJ)
    if (searchType === 'geral') {
      let formattedValue = value
      
      // Se tem apenas dígitos ou formatação de CPF/CNPJ, aplicar formatação automática
      if (/^[\d.\-/]*$/.test(value)) {
        formattedValue = formatarCpfCnpj(value)
      }
      
      if (formattedValue !== value) {
        setBusca(formattedValue)
      }
    }
  }

  const handleClienteSelect = (cliente: Cliente) => {
    console.log('✅ Cliente selecionado:', cliente.nome)
    onClienteSelect(cliente)
    setBusca('')
    setMostrarSugestoes(false)
    setMostrarFormCadastro(false) // Garantir que o form de cadastro não abra
  }

  const handleClienteRemove = () => {
    onClienteSelect(null)
  }

  const abrirFormCadastro = () => {
    setMostrarFormCadastro(true)
    setMostrarSugestoes(false)
  }

  const fecharFormCadastro = () => {
    console.log('🟡 ClienteSelectorSimples - fecharFormCadastro chamado')
    setMostrarFormCadastro(false)
  }

  const fecharFormEdicao = () => {
    setMostrarFormEdicao(false)
    setClienteParaEditar(null)
  }

  const handleNovoClienteSuccess = (cliente: Cliente) => {
    onClienteSelect(cliente)
    setMostrarFormCadastro(false)
    
    // Verificar se é um cliente recém criado ou um cliente existente selecionado
    // Se o cliente tem criado_em muito recente (últimos 5 segundos), é novo
    if (cliente.criado_em) {
      const agora = new Date()
      const criadoEm = new Date(cliente.criado_em)
      const diferencaSegundos = (agora.getTime() - criadoEm.getTime()) / 1000
      
      if (diferencaSegundos <= 5) {
        toast.success('Cliente cadastrado e selecionado com sucesso!')
      } else {
        toast.success(`Cliente "${cliente.nome}" selecionado!`)
      }
    } else {
      // Se não tem data de criação, assumir que é novo
      toast.success('Cliente cadastrado e selecionado com sucesso!')
    }
  }

  const handleClienteEditadoSuccess = (cliente: Cliente) => {
    console.log('✅ [DEBUG] Cliente editado com sucesso:', cliente.nome, cliente)
    onClienteSelect(cliente)
    setMostrarFormEdicao(false)
    setClienteParaEditar(null)
    toast.success(`Cliente "${cliente.nome}" atualizado com sucesso!`)
    console.log('✅ [DEBUG] Formulário de edição fechado')
  }

  return (
    <>
      <div className={showCard ? "bg-white p-4 rounded-lg shadow-sm border" : ""}>
        <h3 className="text-lg font-semibold text-gray-900 mb-4">{titulo}</h3>

        {/* Cliente Selecionado */}
        {clienteSelecionado ? (
          <div className="p-4 bg-green-50 rounded-lg border border-green-200 shadow-sm">
            <div className="flex items-start justify-between">
              <div className="flex items-start space-x-3 flex-1">
                <div className="flex-shrink-0">
                  <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                    <User className="w-6 h-6 text-green-600" />
                  </div>
                </div>
                <div className="flex-1 min-w-0 space-y-2">
                  <h4 className="text-lg font-semibold text-green-900">{clienteSelecionado.nome}</h4>
                  <div className="space-y-1">
                    {clienteSelecionado.telefone && (
                      <div className="flex items-center gap-2">
                        <Phone className="w-4 h-4 text-green-600" />
                        <span className="text-sm font-medium text-green-700">
                          <strong>Telefone:</strong> {formatarTelefone(clienteSelecionado.telefone)}
                        </span>
                      </div>
                    )}
                    {clienteSelecionado.email && (
                      <div className="flex items-center gap-2">
                        <Mail className="w-4 h-4 text-green-600" />
                        <span className="text-sm font-medium text-green-700">
                          <strong>Email:</strong> {clienteSelecionado.email}
                        </span>
                      </div>
                    )}
                    {clienteSelecionado.cpf_cnpj && (
                      <div className="flex items-center gap-2">
                        <CreditCard className="w-4 h-4 text-green-600" />
                        <span className="text-sm font-medium text-green-700">
                          <strong>CPF:</strong> {formatarCpfCnpj(clienteSelecionado.cpf_cnpj)}
                        </span>
                      </div>
                    )}
                    {clienteSelecionado.criado_em && (
                      <div className="flex items-center gap-2">
                        <User className="w-4 h-4 text-green-600" />
                        <span className="text-sm font-medium text-green-700">
                          <strong>Cadastrado em:</strong> {new Date(clienteSelecionado.criado_em).toLocaleDateString('pt-BR')}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
              <div className="flex-shrink-0 ml-3">
                <Button 
                  variant="secondary" 
                  size="sm" 
                  onClick={handleClienteRemove}
                  className="flex items-center gap-2 bg-red-50 hover:bg-red-100 text-red-600 border-red-200"
                >
                  <X className="w-4 h-4" />
                  Remover
                </Button>
              </div>
            </div>
          </div>
        ) : (
          <>
            {/* Busca de Cliente */}
            <div className="space-y-4">
              <div className="flex gap-2">
                <div className="flex-1 relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Search className="h-4 w-4 text-gray-400" />
                  </div>
                  <Input
                    type="text"
                    value={busca}
                    onChange={(e) => handleBuscaChange(e.target.value)}
                    placeholder={searchType === 'telefone' ? "Buscar por telefone..." : "Buscar por nome, CPF/CNPJ ou telefone..."}
                    className="pl-10"
                  />
                  {loadingBusca && (
                    <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600"></div>
                    </div>
                  )}
                </div>
                <Button 
                  onClick={abrirFormCadastro}
                  className="flex items-center gap-2 whitespace-nowrap"
                >
                  <Plus className="w-4 h-4" />
                  Novo Cliente
                </Button>
              </div>

              {/* Toggle de tipo de busca */}
              <div className="flex gap-2">
                <button
                  onClick={() => setSearchType('geral')}
                  className={`px-3 py-1 text-xs rounded-full transition-colors ${
                    searchType === 'geral' 
                      ? 'bg-blue-100 text-blue-700 border-blue-200' 
                      : 'bg-gray-100 text-gray-600 border-gray-200'
                  } border`}
                >
                  Busca Geral
                </button>
                <button
                  onClick={() => setSearchType('telefone')}
                  className={`px-3 py-1 text-xs rounded-full transition-colors ${
                    searchType === 'telefone' 
                      ? 'bg-blue-100 text-blue-700 border-blue-200' 
                      : 'bg-gray-100 text-gray-600 border-gray-200'
                  } border`}
                >
                  Apenas Telefone
                </button>
              </div>
            </div>

            {/* Sugestões de Clientes */}
            {mostrarSugestoes && clientesEncontrados.length > 0 && (
              <div className="mt-4 border border-green-200 rounded-lg max-h-64 overflow-y-auto bg-green-50">
                {clientesEncontrados.map((cliente) => (
                  <div
                    key={cliente.id}
                    className="p-4 hover:bg-green-100 cursor-pointer border-b border-green-100 last:border-b-0 transition-colors"
                    onClick={() => handleClienteSelect(cliente)}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex-1 space-y-2">
                        <h4 className="font-semibold text-green-900 text-base">{cliente.nome}</h4>
                        <div className="space-y-1">
                          {cliente.telefone && (
                            <div className="flex items-center gap-2">
                              <Phone className="w-4 h-4 text-green-600" />
                              <span className="text-sm font-medium text-green-700">
                                <strong>Telefone:</strong> {formatarTelefone(cliente.telefone)}
                              </span>
                            </div>
                          )}
                          {cliente.cpf_cnpj && (
                            <div className="flex items-center gap-2">
                              <CreditCard className="w-4 h-4 text-green-600" />
                              <span className="text-sm font-medium text-green-700">
                                <strong>CPF:</strong> {formatarCpfCnpj(cliente.cpf_cnpj)}
                              </span>
                            </div>
                          )}
                          {cliente.criado_em && (
                            <div className="flex items-center gap-2">
                              <User className="w-4 h-4 text-green-600" />
                              <span className="text-sm font-medium text-green-700">
                                <strong>Cadastrado em:</strong> {new Date(cliente.criado_em).toLocaleDateString('pt-BR')}
                              </span>
                            </div>
                          )}
                        </div>
                      </div>
                      <div className="flex-shrink-0 ml-4">
                        <Button size="sm" variant="secondary" className="bg-green-200 hover:bg-green-300 text-green-800 border-green-300">
                          <Check className="w-4 h-4" />
                        </Button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Nenhum resultado */}
            {busca.length >= 2 && !loadingBusca && clientesEncontrados.length === 0 && (
              <div className="mt-4 text-center py-8 text-gray-500">
                <User className="w-12 h-12 mx-auto mb-2 text-gray-300" />
                <p>Nenhum cliente encontrado para "{busca}"</p>
                <Button 
                  onClick={abrirFormCadastro}
                  variant="secondary" 
                  className="mt-3"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Cadastrar novo cliente
                </Button>
              </div>
            )}
          </>
        )}

        {/* Formulário de Cadastro Inline */}
        {mostrarFormCadastro && (
          <div className="border-t pt-4 mt-4">
            <ClienteFormUnificado
              titulo="Cadastrar Novo Cliente"
              onSuccess={handleNovoClienteSuccess}
              onCancel={fecharFormCadastro}
              showHeader={true}
              isModal={false}
              showToastOnSelect={false}
              showUseClientButton={true}
            />
          </div>
        )}

        {/* Formulário de Edição Inline */}
        {mostrarFormEdicao && clienteParaEditar && (
          <div className="border-t pt-4 mt-4">
            <ClienteFormUnificado
              titulo={`Editar ${clienteParaEditar.nome}`}
              cliente={clienteParaEditar}
              onSuccess={handleClienteEditadoSuccess}
              onCancel={fecharFormEdicao}
              showHeader={true}
              isModal={false}
              showToastOnSelect={false}
            />
          </div>
        )}
      </div>
    </>
  )
}

// Manter compatibilidade com nome anterior
export { ClienteSelector as ClienteSelectorSimples }