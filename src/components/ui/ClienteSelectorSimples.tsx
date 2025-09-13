import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { 
  Search, 
  User, 
  Phone, 
  Mail, 
  Plus,
  Check,
  X,
  CreditCard,
  MapPin
} from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { ClienteService } from '../../services/clienteService'
import { formatarTelefone, formatarCpfCnpj, validarCpfCnpj } from '../../utils/formatacao'
import type { Cliente, ClienteInput } from '../../types/cliente'

// Schema simples para ClienteSelector (usado em OS e Vendas)
const novoClienteSchema = z.object({
  nome: z.string().min(3, 'Nome deve ter pelo menos 3 caracteres'),
  telefone: z.string().min(10, 'Telefone deve ter pelo menos 10 dígitos'),
  cpf_cnpj: z.string().optional().refine((val) => {
    if (!val || val.trim() === '') return true
    return validarCpfCnpj(val)
  }, 'CPF/CNPJ inválido'),
  email: z.string().email('E-mail inválido').optional().or(z.literal('')),
  endereco: z.string().optional(),
  tipo: z.enum(['Física', 'Jurídica']),
  observacoes: z.string().optional()
})

type NovoClienteData = z.infer<typeof novoClienteSchema>

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
  const [clientesEncontrados, setClientesEncontrados] = useState<Cliente[]>([])
  const [mostrarSugestoes, setMostrarSugestoes] = useState(false)
  const [mostrarFormCadastro, setMostrarFormCadastro] = useState(false)
  const [loadingBusca, setLoadingBusca] = useState(false)
  const [loadingCadastro, setLoadingCadastro] = useState(false)
  const [telefoneValue, setTelefoneValue] = useState('')
  const [cpfCnpjValue, setCpfCnpjValue] = useState('')
  const [clienteDuplicado, setClienteDuplicado] = useState<Cliente | null>(null)
  const [verificandoDuplicata, setVerificandoDuplicata] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch,
    reset
  } = useForm<NovoClienteData>({
    resolver: zodResolver(novoClienteSchema),
    defaultValues: {
      nome: '',
      telefone: '',
      cpf_cnpj: '',
      email: '',
      endereco: '',
      tipo: 'Física',
      observacoes: ''
    }
  })

  const tipoSelecionado = watch('tipo')

  // Buscar clientes conforme digita
  useEffect(() => {
    const buscarClientes = async () => {
      if (busca.length < 2) {
        setClientesEncontrados([])
        setMostrarSugestoes(false)
        return
      }

      setLoadingBusca(true)
      try {
        console.log('🔍 Buscando clientes com termo:', busca)
        const clientes = await ClienteService.buscarClientes({
          search: busca,
          ativo: true
        })
        console.log('📋 Clientes encontrados:', clientes.length)
        setClientesEncontrados(clientes.slice(0, 5)) // Limitar a 5 resultados
        setMostrarSugestoes(true)
      } catch (error) {
        console.error('Erro ao buscar clientes:', error)
        setClientesEncontrados([])
        // Mostrar toast de erro para o usuário
        toast.error('Erro ao buscar clientes. Tente novamente.')
      } finally {
        setLoadingBusca(false)
      }
    }

    const timeoutId = setTimeout(buscarClientes, 300)
    return () => clearTimeout(timeoutId)
  }, [busca])

  // Verificar duplicata de CPF/CNPJ em tempo real
  useEffect(() => {
    const verificarDuplicata = async () => {
      const cleanValue = cpfCnpjValue.replace(/\D/g, '')
      
      // Verificar apenas se tiver pelo menos 8 dígitos (começa a ser útil)
      if (cleanValue.length >= 8) {
        console.log('🔍 Verificando duplicata em tempo real para:', cpfCnpjValue, '| Dígitos:', cleanValue.length)
        setVerificandoDuplicata(true)
        try {
          const clientes = await ClienteService.buscarClientes({
            search: cpfCnpjValue,
            ativo: true
          })
          
          console.log('📋 Clientes encontrados na busca:', clientes.length)
          
          // Procurar por CPF/CNPJ que contenha os dígitos digitados
          const clienteExistente = clientes.find(cliente => {
            if (!cliente.cpf_cnpj) return false
            const clienteCpfCnpj = cliente.cpf_cnpj.replace(/\D/g, '')
            
            // Se já temos 11 ou 14 dígitos, fazer busca exata
            if (cleanValue.length === 11 || cleanValue.length === 14) {
              const match = clienteCpfCnpj === cleanValue
              if (match) console.log('✅ Match exato encontrado:', cliente.nome)
              return match
            }
            
            // Senão, verificar se o CPF/CNPJ do cliente começa com os dígitos digitados
            const partialMatch = clienteCpfCnpj.startsWith(cleanValue)
            if (partialMatch) console.log('🎯 Match parcial encontrado:', cliente.nome, '|', clienteCpfCnpj)
            return partialMatch
          })
          
          if (clienteExistente) {
            console.log('⚠️ Cliente duplicado detectado:', clienteExistente.nome)
          } else {
            console.log('✅ Nenhuma duplicata encontrada')
          }
          
          setClienteDuplicado(clienteExistente || null)
        } catch (error) {
          console.error('Erro ao verificar duplicata:', error)
        } finally {
          setVerificandoDuplicata(false)
        }
      } else {
        setClienteDuplicado(null)
        setVerificandoDuplicata(false)
      }
    }

    // Debounce de 500ms para não fazer muitas requisições
    const timeoutId = setTimeout(verificarDuplicata, 500)
    return () => clearTimeout(timeoutId)
  }, [cpfCnpjValue])

  // Fechar sugestões quando clicar fora
  useEffect(() => {
    const handleClickOutside = () => {
      setMostrarSugestoes(false)
    }

    if (mostrarSugestoes) {
      document.addEventListener('click', handleClickOutside)
      return () => document.removeEventListener('click', handleClickOutside)
    }
  }, [mostrarSugestoes])

  const selecionarCliente = (cliente: Cliente) => {
    console.log('👤 Cliente selecionado no selector:', cliente)
    console.log('📋 Dados do cliente selecionado:')
    console.log('  - Nome:', cliente.nome)
    console.log('  - CPF/CNPJ:', cliente.cpf_cnpj)
    console.log('  - Telefone:', cliente.telefone)
    console.log('  - Endereço:', cliente.endereco)
    console.log('  - Email:', cliente.email)
    onClienteSelect(cliente)
    setBusca(cliente.nome)
    setMostrarSugestoes(false)
  }

  const removerCliente = () => {
    onClienteSelect(null)
    setBusca('')
    setMostrarSugestoes(false)
  }

  const abrirFormCadastro = () => {
    setMostrarFormCadastro(true)
    setMostrarSugestoes(false)
    // Pré-preencher nome se houver busca
    if (busca) {
      setValue('nome', busca)
    }
  }

  const fecharFormCadastro = () => {
    setMostrarFormCadastro(false)
    reset()
    setTelefoneValue('')
    setCpfCnpjValue('')
  }

  const handleTelefoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const formatted = formatarTelefone(e.target.value)
    setTelefoneValue(formatted)
    setValue('telefone', formatted.replace(/\D/g, ''))
  }

  const handleCpfCnpjChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const formatted = formatarCpfCnpj(e.target.value)
    setCpfCnpjValue(formatted)
    setValue('cpf_cnpj', formatted)
  }

  // Função para editar cliente existente
  const editarClienteExistente = () => {
    if (clienteDuplicado) {
      // Preencher formulário com dados do cliente existente
      setValue('nome', clienteDuplicado.nome)
      setValue('telefone', clienteDuplicado.telefone || '')
      setValue('cpf_cnpj', clienteDuplicado.cpf_cnpj || '')
      setValue('email', clienteDuplicado.email || '')
      setValue('endereco', clienteDuplicado.endereco || '')
      setValue('tipo', clienteDuplicado.tipo || 'Física')
      setValue('observacoes', clienteDuplicado.observacoes || '')
      
      setTelefoneValue(formatarTelefone(clienteDuplicado.telefone || ''))
      setCpfCnpjValue(formatarCpfCnpj(clienteDuplicado.cpf_cnpj || ''))
      
      // Limpar a duplicata para permitir edição
      setClienteDuplicado(null)
    }
  }

  const onSubmitNovoCliente = async (data: NovoClienteData) => {
    setLoadingCadastro(true)
    try {
      const dadosCliente: ClienteInput = {
        ...data,
        ativo: true
      }
      
      let clienteResultado: Cliente
      
      // Verificar se estamos editando um cliente existente (baseado no CPF/CNPJ)
      if (data.cpf_cnpj) {
        const clientesExistentes = await ClienteService.buscarClientes({
          search: data.cpf_cnpj,
          ativo: true
        })
        
        const clienteExistente = clientesExistentes.find(cliente => 
          cliente.cpf_cnpj?.replace(/\D/g, '') === data.cpf_cnpj?.replace(/\D/g, '')
        )
        
        if (clienteExistente) {
          // Atualizar cliente existente
          clienteResultado = await ClienteService.atualizarCliente(clienteExistente.id, dadosCliente)
          toast.success('Cliente atualizado com sucesso!')
        } else {
          // Criar novo cliente
          clienteResultado = await ClienteService.criarCliente(dadosCliente)
          toast.success('Cliente cadastrado com sucesso!')
        }
      } else {
        // Criar novo cliente sem CPF/CNPJ
        clienteResultado = await ClienteService.criarCliente(dadosCliente)
        toast.success('Cliente cadastrado com sucesso!')
      }
      
      onClienteSelect(clienteResultado)
      setBusca(clienteResultado.nome)
      fecharFormCadastro()
      setClienteDuplicado(null)
    } catch (error: unknown) {
      console.error('Erro ao salvar cliente:', error)
      toast.error((error as Error).message || 'Erro ao salvar cliente')
    } finally {
      setLoadingCadastro(false)
    }
  }

  const content = (
    <>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-md font-semibold text-gray-900">{titulo}</h3>
        {clienteSelecionado && (
          <Button 
            variant="secondary" 
            size="sm" 
            onClick={removerCliente}
            className="flex items-center gap-2"
          >
            <X className="w-4 h-4" />
            Remover
          </Button>
        )}
      </div>

      {/* Cliente Selecionado */}
      {clienteSelecionado && (
        <div className="p-4 bg-green-50 border border-green-200 rounded-lg mb-4">
          <div className="flex items-center gap-2 mb-2">
            <Check className="w-5 h-5 text-green-600" />
            <span className="font-medium text-green-800">{clienteSelecionado.nome}</span>
          </div>
          <div className="text-sm text-green-700 space-y-1">
            <div className="flex items-center gap-2">
              <Phone className="w-4 h-4" />
              <span>{formatarTelefone(clienteSelecionado.telefone)}</span>
            </div>
            {clienteSelecionado.cpf_cnpj && (
              <div className="flex items-center gap-2">
                <CreditCard className="w-4 h-4" />
                <span>{clienteSelecionado.cpf_cnpj}</span>
              </div>
            )}
            {clienteSelecionado.email && (
              <div className="flex items-center gap-2">
                <Mail className="w-4 h-4" />
                <span>{clienteSelecionado.email}</span>
              </div>
            )}
            {clienteSelecionado.endereco && (
              <div className="flex items-start gap-2">
                <MapPin className="w-4 h-4 mt-0.5" />
                <span>{clienteSelecionado.endereco}</span>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Busca e Cadastro */}
      {!clienteSelecionado && !mostrarFormCadastro && (
        <div className="space-y-4">
          {/* Campo de busca */}
          <div className="relative">
            <div className="relative">
              <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
              <input
                type="text"
                value={busca}
                onChange={(e) => setBusca(e.target.value)}
                onClick={(e) => e.stopPropagation()}
                className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Buscar cliente por nome, telefone, CPF, CNPJ ou endereço..."
              />
              {loadingBusca && (
                <div className="absolute right-3 top-3">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600"></div>
                </div>
              )}
            </div>

            {/* Sugestões */}
            {mostrarSugestoes && clientesEncontrados.length > 0 && (
              <div className="absolute z-50 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-y-auto">
                {clientesEncontrados.map((cliente) => (
                  <button
                    key={cliente.id}
                    onClick={(e) => {
                      e.stopPropagation()
                      selecionarCliente(cliente)
                    }}
                    className="w-full px-4 py-3 text-left hover:bg-gray-50 border-b border-gray-100 last:border-b-0"
                  >
                    <div className="flex items-center gap-3">
                      <User className="w-4 h-4 text-gray-400" />
                      <div className="flex-1">
                        <div className="font-medium text-gray-900">{cliente.nome}</div>
                        <div className="text-sm text-gray-500">
                          {formatarTelefone(cliente.telefone)}
                          {cliente.cpf_cnpj && ` • ${cliente.cpf_cnpj}`}
                        </div>
                        {cliente.endereco && (
                          <div className="text-xs text-gray-400 mt-1 truncate">
                            📍 {cliente.endereco}
                          </div>
                        )}
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Botão para cadastrar novo cliente */}
          <Button 
            onClick={abrirFormCadastro}
            variant="secondary"
            className="w-full flex items-center gap-2"
          >
            <Plus className="w-4 h-4" />
            Cadastrar Novo Cliente
          </Button>
        </div>
      )}

      {/* Formulário de Cadastro */}
      {mostrarFormCadastro && (
        <div className="border-t pt-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-md font-semibold text-gray-900">Cadastrar Novo Cliente</h3>
            <Button 
              variant="secondary" 
              size="sm" 
              onClick={fecharFormCadastro}
              className="flex items-center gap-2"
            >
              <X className="w-4 h-4" />
              Cancelar
            </Button>
          </div>

          <form onSubmit={handleSubmit(onSubmitNovoCliente)} className="space-y-4">
            {/* Informações Básicas */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nome Completo *
                </label>
                <div className="relative">
                  <User className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
                  <input
                    {...register('nome')}
                    type="text"
                    className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Nome do cliente"
                  />
                </div>
                {errors.nome && (
                  <span className="text-red-500 text-sm">{errors.nome.message}</span>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Tipo de Pessoa *
                </label>
                <select
                  {...register('tipo')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="Física">Pessoa Física</option>
                  <option value="Jurídica">Pessoa Jurídica</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Telefone *
                </label>
                <div className="relative">
                  <Phone className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
                  <input
                    value={telefoneValue}
                    onChange={handleTelefoneChange}
                    type="text"
                    className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="(11) 99999-9999"
                  />
                </div>
                {errors.telefone && (
                  <span className="text-red-500 text-sm">{errors.telefone.message}</span>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  {tipoSelecionado === 'Física' ? 'CPF' : 'CNPJ'}
                  {verificandoDuplicata && (
                    <span className="ml-2 text-xs text-blue-600 flex items-center gap-1">
                      <div className="animate-spin rounded-full h-3 w-3 border-b border-blue-600"></div>
                      Verificando...
                    </span>
                  )}
                </label>
                <div className="relative">
                  <input
                    value={cpfCnpjValue}
                    onChange={handleCpfCnpjChange}
                    type="text"
                    maxLength={tipoSelecionado === 'Física' ? 14 : 18}
                    className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 ${
                      clienteDuplicado 
                        ? 'border-orange-300 focus:ring-orange-500 bg-orange-50' 
                        : verificandoDuplicata
                        ? 'border-blue-300 focus:ring-blue-500 bg-blue-50'
                        : 'border-gray-300 focus:ring-blue-500'
                    }`}
                    placeholder={tipoSelecionado === 'Física' ? '000.000.000-00' : '00.000.000/0000-00'}
                  />
                  {verificandoDuplicata && (
                    <div className="absolute right-3 top-3">
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600"></div>
                    </div>
                  )}
                </div>
                {errors.cpf_cnpj && (
                  <span className="text-red-500 text-sm">{errors.cpf_cnpj.message}</span>
                )}
                
                {/* Aviso de cliente duplicado - Detecção em tempo real */}
                {clienteDuplicado && (
                  <div className="mt-2 p-3 bg-orange-50 border border-orange-200 rounded-lg">
                    <div className="flex items-start gap-3">
                      <div className="flex-shrink-0">
                        <User className="w-5 h-5 text-orange-600" />
                      </div>
                      <div className="flex-1">
                        <h4 className="text-sm font-medium text-orange-800">
                          ⚡ Cliente encontrado automaticamente
                        </h4>
                        <p className="text-sm text-orange-700 mt-1">
                          Detectamos um cliente com este {tipoSelecionado === 'Física' ? 'CPF' : 'CNPJ'}:
                        </p>
                        <div className="mt-2 p-2 bg-white rounded border">
                          <p className="text-sm font-medium text-gray-900">{clienteDuplicado.nome}</p>
                          <p className="text-xs text-gray-600">
                            {clienteDuplicado.telefone && formatarTelefone(clienteDuplicado.telefone)}
                            {clienteDuplicado.email && ` • ${clienteDuplicado.email}`}
                          </p>
                        </div>
                        <div className="flex gap-2 mt-3">
                          <button
                            type="button"
                            onClick={() => {
                              onClienteSelect(clienteDuplicado)
                              setBusca(clienteDuplicado.nome)
                              fecharFormCadastro()
                            }}
                            className="text-xs bg-orange-600 text-white px-3 py-1 rounded hover:bg-orange-700"
                          >
                            Usar Este Cliente
                          </button>
                          <button
                            type="button"
                            onClick={editarClienteExistente}
                            className="text-xs bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700"
                          >
                            Editar Dados
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  E-mail
                </label>
                <div className="relative">
                  <Mail className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
                  <input
                    {...register('email')}
                    type="email"
                    className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="joao@email.com"
                  />
                </div>
                {errors.email && (
                  <span className="text-red-500 text-sm">{errors.email.message}</span>
                )}
              </div>
            </div>

            {/* Endereço Simples */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Endereço (opcional)
              </label>
              <input
                {...register('endereco')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Endereço completo"
              />
            </div>

            {/* Observações */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Observações
              </label>
              <textarea
                {...register('observacoes')}
                rows={2}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Observações sobre o cliente..."
              />
            </div>

            {/* Botões */}
            <div className="flex gap-3">
              <Button 
                type="submit" 
                disabled={loadingCadastro}
                className="flex items-center gap-2"
              >
                <Plus className="w-4 h-4" />
                {loadingCadastro ? 'Cadastrando...' : 'Cadastrar Cliente'}
              </Button>
              
              <Button 
                type="button" 
                variant="secondary" 
                onClick={fecharFormCadastro}
                disabled={loadingCadastro}
              >
                Cancelar
              </Button>
            </div>
          </form>
        </div>
      )}
    </>
  )

  if (showCard) {
    return (
      <Card className="p-6">
        {content}
      </Card>
    )
  }

  return <div>{content}</div>
}
