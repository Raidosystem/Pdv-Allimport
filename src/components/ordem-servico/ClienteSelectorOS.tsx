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
  FileText
} from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { ClienteService } from '../../services/clienteService'
import { formatarTelefone, formatarCpfCnpj, validarCpfCnpj } from '../../utils/formatacao'
import type { Cliente, ClienteInput } from '../../types/cliente'

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
  rua: z.string().optional(),
  numero: z.string().optional(),
  bairro: z.string().optional(),
  cidade: z.string().optional(),
  cep: z.string().optional(),
  tipo: z.enum(['Física', 'Jurídica']),
  observacoes: z.string().optional()
})

type NovoClienteData = z.infer<typeof novoClienteSchema>

interface ClienteSelectorOSProps {
  onClienteSelect: (cliente: Cliente) => void
  clienteSelecionado?: Cliente | null
}

export function ClienteSelectorOS({ onClienteSelect, clienteSelecionado }: ClienteSelectorOSProps) {
  const [busca, setBusca] = useState('')
  const [clientesEncontrados, setClientesEncontrados] = useState<Cliente[]>([])
  const [mostrarSugestoes, setMostrarSugestoes] = useState(false)
  const [mostrarFormCadastro, setMostrarFormCadastro] = useState(false)
  const [loadingBusca, setLoadingBusca] = useState(false)
  const [loadingCadastro, setLoadingCadastro] = useState(false)
  const [telefoneValue, setTelefoneValue] = useState('')
  const [cpfCnpjValue, setCpfCnpjValue] = useState('')
  const [cepValue, setCepValue] = useState('')

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
  const rua = watch('rua')
  const numero = watch('numero')
  const bairro = watch('bairro')
  const cidade = watch('cidade')
  const cepWatch = watch('cep')

  // Atualizar endereço completo automaticamente
  useEffect(() => {
    const enderecoParts = []
    if (rua) enderecoParts.push(rua)
    if (numero) enderecoParts.push(numero)
    if (bairro) enderecoParts.push(bairro)
    if (cidade) enderecoParts.push(cidade)
    if (cepWatch) enderecoParts.push(cepWatch)
    
    const enderecoCompleto = enderecoParts.join(', ')
    setValue('endereco', enderecoCompleto)
  }, [rua, numero, bairro, cidade, cepWatch, setValue])

  // Buscar clientes conforme digita
  useEffect(() => {
    const buscarClientes = async () => {
      if (busca && busca.length >= 2) {
        setLoadingBusca(true)
        try {
          const clientes = await ClienteService.buscarClientes({ search: busca, ativo: true })
          setClientesEncontrados(clientes)
          setMostrarSugestoes(true)
        } catch (error) {
          console.error('Erro ao buscar clientes:', error)
          toast.error('Erro ao buscar clientes')
        } finally {
          setLoadingBusca(false)
        }
      } else {
        setMostrarSugestoes(false)
        setClientesEncontrados([])
      }
    }

    const timeoutId = setTimeout(buscarClientes, 300)
    return () => clearTimeout(timeoutId)
  }, [busca])

  const selecionarCliente = (cliente: Cliente) => {
    onClienteSelect(cliente)
    setBusca(cliente.nome)
    setMostrarSugestoes(false)
  }

  const limparSelecao = () => {
    onClienteSelect(null as any)
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
    setCepValue('')
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

  const handleCepChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/\D/g, '')
    const formatted = value.replace(/(\d{5})(\d{3})/, '$1-$2')
    setCepValue(formatted)
    setValue('cep', formatted)
  }

  const onSubmitNovoCliente = async (data: NovoClienteData) => {
    setLoadingCadastro(true)
    try {
      const novoCliente: ClienteInput = {
        ...data,
        ativo: true
      }
      
      const clienteCriado = await ClienteService.criarCliente(novoCliente)
      
      toast.success('Cliente cadastrado com sucesso!')
      onClienteSelect(clienteCriado)
      setBusca(clienteCriado.nome)
      fecharFormCadastro()
    } catch (error: any) {
      console.error('Erro ao criar cliente:', error)
      toast.error(error.message || 'Erro ao cadastrar cliente')
    } finally {
      setLoadingCadastro(false)
    }
  }

  return (
    <Card className="p-6">
      <div className="flex items-center gap-2 mb-4">
        <User className="w-5 h-5 text-blue-600" />
        <h2 className="text-lg font-semibold text-gray-900">Dados do Cliente</h2>
      </div>

      {/* Campo de busca */}
      <div className="relative mb-4">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Buscar Cliente ou Cadastrar Novo
        </label>
        
        <div className="flex gap-2">
          <div className="relative flex-1">
            <input
              type="text"
              value={busca}
              onChange={(e) => setBusca(e.target.value)}
              className="w-full px-3 py-2 pr-10 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Digite o nome, telefone ou CPF/CNPJ do cliente..."
            />
            <Search className="w-4 h-4 text-gray-400 absolute right-3 top-3" />
            
            {clienteSelecionado && (
              <button
                type="button"
                onClick={limparSelecao}
                className="absolute right-8 top-3 text-red-500 hover:text-red-700"
              >
                <X className="w-4 h-4" />
              </button>
            )}
          </div>
          
          <Button
            type="button"
            onClick={abrirFormCadastro}
            className="gap-2 px-4"
            variant="outline"
          >
            <Plus className="w-4 h-4" />
            Novo Cliente
          </Button>
        </div>

        {/* Loading de busca */}
        {loadingBusca && (
          <div className="absolute z-10 w-full mt-1 p-3 bg-white border border-gray-200 rounded-md shadow-lg">
            <div className="flex items-center gap-2 text-gray-600">
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
              Buscando clientes...
            </div>
          </div>
        )}

        {/* Sugestões de clientes */}
        {mostrarSugestoes && clientesEncontrados.length > 0 && !loadingBusca && (
          <div className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg max-h-64 overflow-y-auto">
            {clientesEncontrados.map((cliente) => (
              <button
                key={cliente.id}
                type="button"
                onClick={() => selecionarCliente(cliente)}
                className="w-full px-3 py-3 text-left hover:bg-gray-50 border-b border-gray-100 last:border-b-0"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-medium text-gray-900">{cliente.nome}</div>
                    <div className="text-sm text-gray-500">{cliente.telefone}</div>
                    {cliente.email && (
                      <div className="text-sm text-gray-500">{cliente.email}</div>
                    )}
                  </div>
                  <div className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                    {cliente.tipo}
                  </div>
                </div>
              </button>
            ))}
          </div>
        )}

        {/* Nenhum resultado */}
        {mostrarSugestoes && clientesEncontrados.length === 0 && !loadingBusca && busca.length >= 2 && (
          <div className="absolute z-10 w-full mt-1 p-3 bg-white border border-gray-200 rounded-md shadow-lg">
            <div className="text-center text-gray-500">
              <div className="text-sm">Nenhum cliente encontrado</div>
              <button
                type="button"
                onClick={abrirFormCadastro}
                className="text-blue-600 hover:text-blue-800 text-sm mt-1"
              >
                Clique aqui para cadastrar novo cliente
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Cliente selecionado */}
      {clienteSelecionado && (
        <div className="mb-4 p-3 bg-green-50 border border-green-200 rounded-md">
          <div className="flex items-center gap-2 text-green-800">
            <Check className="w-4 h-4" />
            <span className="font-medium">Cliente selecionado:</span>
          </div>
          <div className="mt-2 text-sm text-green-700">
            <div className="font-medium">{clienteSelecionado.nome}</div>
            <div>{clienteSelecionado.telefone}</div>
            {clienteSelecionado.email && <div>{clienteSelecionado.email}</div>}
          </div>
        </div>
      )}

      {/* Formulário de cadastro de novo cliente */}
      {mostrarFormCadastro && (
        <div className="border-t pt-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-md font-semibold text-gray-900">Cadastrar Novo Cliente</h3>
            <button
              type="button"
              onClick={fecharFormCadastro}
              className="text-gray-500 hover:text-gray-700"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          <form onSubmit={handleSubmit(onSubmitNovoCliente)} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nome Completo *
                </label>
                <input
                  {...register('nome')}
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Nome completo do cliente"
                />
                {errors.nome && (
                  <span className="text-red-500 text-sm">{errors.nome.message}</span>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Telefone *
                </label>
                <div className="relative">
                  <Phone className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                  <input
                    value={telefoneValue}
                    onChange={handleTelefoneChange}
                    type="tel"
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
                  Tipo de Cliente *
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
                  {tipoSelecionado === 'Física' ? 'CPF' : 'CNPJ'} (opcional)
                </label>
                <div className="relative">
                  <FileText className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                  <input
                    value={cpfCnpjValue}
                    onChange={handleCpfCnpjChange}
                    type="text"
                    className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder={tipoSelecionado === 'Física' ? '000.000.000-00' : '00.000.000/0000-00'}
                  />
                </div>
                {errors.cpf_cnpj && (
                  <span className="text-red-500 text-sm">{errors.cpf_cnpj.message}</span>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  E-mail (opcional)
                </label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                  <input
                    {...register('email')}
                    type="email"
                    className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="cliente@email.com"
                  />
                </div>
                {errors.email && (
                  <span className="text-red-500 text-sm">{errors.email.message}</span>
                )}
              </div>
            </div>

            {/* Seção de Endereço Detalhado */}
            <div>
              <h4 className="text-md font-medium text-gray-900 mb-3">Endereço (opcional)</h4>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Rua/Avenida
                  </label>
                  <input
                    {...register('rua')}
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Rua das Flores"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Número
                  </label>
                  <input
                    {...register('numero')}
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="123"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    CEP
                  </label>
                  <input
                    value={cepValue}
                    onChange={handleCepChange}
                    type="text"
                    maxLength={9}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="00000-000"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Bairro
                  </label>
                  <input
                    {...register('bairro')}
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Centro"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cidade
                  </label>
                  <input
                    {...register('cidade')}
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="São Paulo"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Endereço Completo (auto)
                  </label>
                  <input
                    {...register('endereco')}
                    type="text"
                    readOnly
                    className="w-full px-3 py-2 border border-gray-200 rounded-md bg-gray-50 text-gray-600"
                    placeholder="Endereço será preenchido automaticamente"
                  />
                </div>
              </div>
            </div>            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Observações (opcional)
              </label>
              <textarea
                {...register('observacoes')}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Observações sobre o cliente..."
              />
            </div>

            <div className="flex gap-3 pt-2">
              <Button
                type="submit"
                disabled={loadingCadastro}
                className="gap-2"
              >
                {loadingCadastro ? (
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                ) : (
                  <Check className="w-4 h-4" />
                )}
                Cadastrar Cliente
              </Button>
              
              <Button
                type="button"
                variant="outline"
                onClick={fecharFormCadastro}
                disabled={loadingCadastro}
              >
                Cancelar
              </Button>
            </div>
          </form>
        </div>
      )}
    </Card>
  )
}
