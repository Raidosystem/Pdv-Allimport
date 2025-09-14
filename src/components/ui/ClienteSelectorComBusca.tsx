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
  MapPin
} from 'lucide-react'
import { Button } from '../ui/Button'
import { Input } from '../ui/Input'
import { Card } from '../ui/Card'
import { CpfSearchInput } from '../ui/CpfSearchInput'
import { ClienteService } from '../../services/clienteService'
import { formatarTelefone, validarCpfCnpj } from '../../utils/formatacao'
import type { Cliente } from '../../types/cliente'

// Schema para novo cliente
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

interface ClienteSelectorComBuscaProps {
  onClienteSelect: (cliente: Cliente | null) => void
  clienteSelecionado?: Cliente | null
  titulo?: string
  showCard?: boolean
}

export function ClienteSelectorComBusca({ 
  onClienteSelect, 
  clienteSelecionado, 
  titulo = "Dados do Cliente",
  showCard = true 
}: ClienteSelectorComBuscaProps) {
  const [searchTerm, setSearchTerm] = useState('')
  const [clientesEncontrados, setClientesEncontrados] = useState<Cliente[]>([])
  const [showSearchResults, setShowSearchResults] = useState(false)
  const [showNewClientForm, setShowNewClientForm] = useState(false)
  const [loading, setLoading] = useState(false)
  const [telefoneValue, setTelefoneValue] = useState('')
  const [cpfCnpjValue, setCpfCnpjValue] = useState('')

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

  // Buscar clientes em tempo real
  useEffect(() => {
    const buscarClientes = async () => {
      if (searchTerm.length < 3) {
        setClientesEncontrados([])
        setShowSearchResults(false)
        return
      }

      setLoading(true)
      try {
        const clientes = await ClienteService.buscarClientes({ search: searchTerm })
        setClientesEncontrados(clientes.slice(0, 10)) // Limitar a 10 resultados
        setShowSearchResults(clientes.length > 0)
      } catch (error) {
        console.error('Erro ao buscar clientes:', error)
        toast.error('Erro ao buscar clientes')
      } finally {
        setLoading(false)
      }
    }

    const timer = setTimeout(buscarClientes, 300)
    return () => clearTimeout(timer)
  }, [searchTerm])

  const handleTelefoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const formatted = formatarTelefone(e.target.value)
    setTelefoneValue(formatted)
    setValue('telefone', formatted.replace(/\D/g, ''))
  }

  const handleSelectCliente = (cliente: Cliente) => {
    onClienteSelect(cliente)
    setShowSearchResults(false)
    setSearchTerm('')
  }

  const handleClienteEncontradoPorCpf = (cliente: Cliente) => {
    // Auto-selecionar cliente encontrado por CPF
    handleSelectCliente(cliente)
    toast.success(`Cliente ${cliente.nome} selecionado automaticamente!`)
  }

  const handleEditarClienteCpf = (cliente: Cliente) => {
    // Preencher formulário para edição
    setValue('nome', cliente.nome)
    setValue('telefone', cliente.telefone || '')
    setTelefoneValue(cliente.telefone || '')
    setValue('email', cliente.email || '')
    setValue('endereco', cliente.endereco || '')
    setValue('tipo', cliente.tipo || 'Física')
    setValue('observacoes', cliente.observacoes || '')
    
    setShowNewClientForm(true)
    toast('Dados do cliente carregados para edição', { icon: 'ℹ️' })
  }

  const onSubmitNewClient = async (data: NovoClienteData) => {
    try {
      setLoading(true)
      
      const novoCliente = await ClienteService.criarCliente({
        ...data,
        ativo: true
      })

      toast.success('Cliente cadastrado com sucesso!')
      onClienteSelect(novoCliente)
      
      // Limpar formulário
      reset()
      setTelefoneValue('')
      setCpfCnpjValue('')
      setShowNewClientForm(false)
      
    } catch (error) {
      console.error('Erro ao cadastrar cliente:', error)
      toast.error('Erro ao cadastrar cliente')
    } finally {
      setLoading(false)
    }
  }

  const content = (
    <div className="space-y-4">
      {/* Cliente Selecionado */}
      {clienteSelecionado && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-4">
          <div className="flex items-start justify-between">
            <div className="flex items-start space-x-3">
              <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                <User className="w-5 h-5 text-green-600" />
              </div>
              <div className="flex-1">
                <h3 className="font-medium text-green-900">{clienteSelecionado.nome}</h3>
                <div className="text-sm text-green-700 space-y-1">
                  {clienteSelecionado.telefone && (
                    <div className="flex items-center gap-1">
                      <Phone className="w-3 h-3" />
                      <span>{clienteSelecionado.telefone}</span>
                    </div>
                  )}
                  {clienteSelecionado.email && (
                    <div className="flex items-center gap-1">
                      <Mail className="w-3 h-3" />
                      <span>{clienteSelecionado.email}</span>
                    </div>
                  )}
                  {clienteSelecionado.endereco && (
                    <div className="flex items-center gap-1">
                      <MapPin className="w-3 h-3" />
                      <span>{clienteSelecionado.endereco}</span>
                    </div>
                  )}
                </div>
              </div>
            </div>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => onClienteSelect(null)}
              className="text-green-700 border-green-300 hover:bg-green-100"
            >
              <X className="w-4 h-4" />
            </Button>
          </div>
        </div>
      )}

      {/* Busca de Cliente */}
      {!clienteSelecionado && (
        <div className="space-y-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <Input
              placeholder="Buscar cliente por nome, telefone ou endereço..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>

          {/* Resultados da Busca */}
          {showSearchResults && (
            <div className="border border-gray-200 rounded-lg bg-white max-h-64 overflow-y-auto">
              {clientesEncontrados.map((cliente) => (
                <div
                  key={cliente.id}
                  className="p-3 hover:bg-gray-50 cursor-pointer border-b border-gray-100 last:border-b-0"
                  onClick={() => handleSelectCliente(cliente)}
                >
                  <div className="flex items-center space-x-3">
                    <div className="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center">
                      <User className="w-4 h-4 text-orange-600" />
                    </div>
                    <div className="flex-1">
                      <div className="font-medium text-gray-900">{cliente.nome}</div>
                      <div className="text-sm text-gray-600">
                        {cliente.telefone && <span>{cliente.telefone}</span>}
                        {cliente.telefone && cliente.email && ' • '}
                        {cliente.email && <span>{cliente.email}</span>}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Botão para Novo Cliente */}
          <Button
            type="button"
            variant="outline"
            onClick={() => setShowNewClientForm(true)}
            className="w-full border-dashed border-2 border-orange-300 text-orange-700 hover:bg-orange-50"
          >
            <Plus className="w-4 h-4 mr-2" />
            Cadastrar novo cliente
          </Button>
        </div>
      )}

      {/* Formulário de Novo Cliente */}
      {showNewClientForm && (
        <Card className="p-6 bg-gray-50 border-gray-200">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Novo Cliente</h3>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => {
                setShowNewClientForm(false)
                reset()
                setTelefoneValue('')
                setCpfCnpjValue('')
              }}
            >
              <X className="w-4 h-4" />
            </Button>
          </div>

          <form onSubmit={handleSubmit(onSubmitNewClient)} className="space-y-4">
            {/* Nome */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nome *
              </label>
              <Input
                {...register('nome')}
                placeholder="Nome completo"
                error={errors.nome?.message}
              />
            </div>

            {/* Telefone */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Telefone *
              </label>
              <Input
                value={telefoneValue}
                onChange={handleTelefoneChange}
                placeholder="(11) 99999-9999"
                error={errors.telefone?.message}
              />
            </div>

            {/* CPF/CNPJ com Busca Inteligente */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                CPF/CNPJ
              </label>
              <CpfSearchInput
                value={cpfCnpjValue}
                onChange={(value) => {
                  setCpfCnpjValue(value)
                  setValue('cpf_cnpj', value)
                }}
                onClienteEncontrado={handleClienteEncontradoPorCpf}
                onEditarCliente={handleEditarClienteCpf}
                placeholder={tipoSelecionado === 'Física' ? '000.000.000-00' : '00.000.000/0000-00'}
                error={errors.cpf_cnpj?.message}
              />
            </div>

            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                E-mail
              </label>
              <Input
                {...register('email')}
                type="email"
                placeholder="email@exemplo.com"
                error={errors.email?.message}
              />
            </div>

            {/* Endereço */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Endereço
              </label>
              <Input
                {...register('endereco')}
                placeholder="Rua, número, bairro, cidade"
                error={errors.endereco?.message}
              />
            </div>

            {/* Tipo */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo
              </label>
              <div className="flex space-x-4">
                <label className="flex items-center">
                  <input
                    {...register('tipo')}
                    type="radio"
                    value="Física"
                    className="mr-2"
                  />
                  Pessoa Física
                </label>
                <label className="flex items-center">
                  <input
                    {...register('tipo')}
                    type="radio"
                    value="Jurídica"
                    className="mr-2"
                  />
                  Pessoa Jurídica
                </label>
              </div>
            </div>

            {/* Observações */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Observações
              </label>
              <textarea
                {...register('observacoes')}
                rows={2}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                placeholder="Observações adicionais..."
              />
            </div>

            {/* Botões */}
            <div className="flex space-x-3 pt-4">
              <Button
                type="submit"
                disabled={loading}
                className="flex-1 bg-orange-500 hover:bg-orange-600"
              >
                <Check className="w-4 h-4 mr-2" />
                {loading ? 'Salvando...' : 'Salvar Cliente'}
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  setShowNewClientForm(false)
                  reset()
                  setTelefoneValue('')
                  setCpfCnpjValue('')
                }}
              >
                Cancelar
              </Button>
            </div>
          </form>
        </Card>
      )}
    </div>
  )

  if (!showCard) {
    return content
  }

  return (
    <Card className="p-6 bg-white border border-gray-200">
      <div className="flex items-center gap-2 mb-4">
        <User className="w-5 h-5 text-orange-600" />
        <h2 className="text-lg font-semibold text-gray-900">{titulo}</h2>
      </div>
      {content}
    </Card>
  )
}