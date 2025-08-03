import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { 
  User, 
  Phone, 
  Mail, 
  Save,
  X
} from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { ClienteService } from '../../services/clienteService'
import { formatarTelefone, formatarCpfCnpj, validarCpfCnpj } from '../../utils/formatacao'
import type { Cliente, ClienteInput } from '../../types/cliente'

// Schema de validação para o formulário de cliente completo
const clienteFormSchema = z.object({
  nome: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  telefone: z.string().min(10, 'Telefone deve ter pelo menos 10 dígitos'),
  cpf_cnpj: z.string().optional().refine((val) => {
    if (!val || val.trim() === '') return true
    return validarCpfCnpj(val)
  }, 'CPF/CNPJ inválido'),
  email: z.string().email('E-mail inválido').optional().or(z.literal('')),
  endereco: z.string().optional(),
  // Campos específicos de endereço
  tipo_logradouro: z.string().optional(),
  logradouro: z.string().optional(),
  numero: z.string().optional(),
  complemento: z.string().optional(),
  bairro: z.string().optional(),
  cidade: z.string().optional(),
  estado: z.string().optional(),
  cep: z.string().optional(),
  ponto_referencia: z.string().optional(),
  tipo: z.enum(['Física', 'Jurídica']),
  observacoes: z.string().optional()
})

type ClienteFormData = z.infer<typeof clienteFormSchema>

interface ClienteFormularioProps {
  cliente?: Cliente
  onSuccess?: (cliente: Cliente) => void
  onCancel?: () => void
}

export function ClienteFormulario({ cliente, onSuccess, onCancel }: ClienteFormularioProps) {
  const [loading, setLoading] = useState(false)
  const [telefoneValue, setTelefoneValue] = useState('')
  const [cpfCnpjValue, setCpfCnpjValue] = useState('')
  const [cepValue, setCepValue] = useState('')
  const [loadingCep, setLoadingCep] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch
  } = useForm<ClienteFormData>({
    resolver: zodResolver(clienteFormSchema),
    defaultValues: {
      tipo: 'Física',
      tipo_logradouro: '',
      logradouro: '',
      numero: '',
      complemento: '',
      bairro: '',
      cidade: '',
      estado: '',
      cep: '',
      ponto_referencia: ''
    }
  })

  const tipoSelecionado = watch('tipo')
  const tipoLogradouro = watch('tipo_logradouro')
  const logradouro = watch('logradouro')
  const numero = watch('numero')
  const complemento = watch('complemento')
  const bairro = watch('bairro')
  const cidade = watch('cidade')
  const estado = watch('estado')
  const cepWatch = watch('cep')

  // Preencher valores formatados se editando cliente existente
  useEffect(() => {
    if (cliente) {
      setTelefoneValue(formatarTelefone(cliente.telefone || ''))
      setCpfCnpjValue(cliente.cpf_cnpj || '')
      setCepValue(cliente.cep || '')
    }
  }, [cliente])

  // Atualizar endereço completo automaticamente
  useEffect(() => {
    const enderecoParts = []
    
    // Tipo de logradouro + logradouro
    if (tipoLogradouro && logradouro) {
      enderecoParts.push(`${tipoLogradouro} ${logradouro}`)
    } else if (logradouro) {
      enderecoParts.push(logradouro)
    }
    
    // Número
    if (numero) enderecoParts.push(numero)
    
    // Complemento
    if (complemento) enderecoParts.push(complemento)
    
    // Bairro
    if (bairro) enderecoParts.push(bairro)
    
    // Cidade + Estado
    if (cidade && estado) {
      enderecoParts.push(`${cidade} - ${estado}`)
    } else if (cidade) {
      enderecoParts.push(cidade)
    }
    
    // CEP
    if (cepWatch) enderecoParts.push(`CEP: ${cepWatch}`)
    
    const enderecoCompleto = enderecoParts.join(', ')
    setValue('endereco', enderecoCompleto)
  }, [tipoLogradouro, logradouro, numero, complemento, bairro, cidade, estado, cepWatch, setValue])

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

  const handleCepChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/\D/g, '')
    const formatted = value.replace(/(\d{5})(\d{3})/, '$1-$2')
    setCepValue(formatted)
    setValue('cep', formatted)

    // Buscar dados do CEP quando tiver 8 dígitos
    if (value.length === 8) {
      setLoadingCep(true)
      try {
        const response = await fetch(`https://viacep.com.br/ws/${value}/json/`)
        const data = await response.json()
        
        if (!data.erro) {
          // Preencher campos automaticamente
          setValue('logradouro', data.logradouro || '')
          setValue('bairro', data.bairro || '')
          setValue('cidade', data.localidade || '')
          setValue('estado', data.uf || '')
          
          // Determinar tipo de logradouro baseado no nome da rua
          if (data.logradouro) {
            const logradouro = data.logradouro.toLowerCase()
            if (logradouro.startsWith('rua ')) {
              setValue('tipo_logradouro', 'Rua')
              setValue('logradouro', data.logradouro.replace(/^rua /i, ''))
            } else if (logradouro.startsWith('avenida ')) {
              setValue('tipo_logradouro', 'Avenida')
              setValue('logradouro', data.logradouro.replace(/^avenida /i, ''))
            } else if (logradouro.startsWith('travessa ')) {
              setValue('tipo_logradouro', 'Travessa')
              setValue('logradouro', data.logradouro.replace(/^travessa /i, ''))
            } else if (logradouro.startsWith('alameda ')) {
              setValue('tipo_logradouro', 'Alameda')
              setValue('logradouro', data.logradouro.replace(/^alameda /i, ''))
            } else if (logradouro.startsWith('praça ')) {
              setValue('tipo_logradouro', 'Praça')
              setValue('logradouro', data.logradouro.replace(/^praça /i, ''))
            } else if (logradouro.startsWith('estrada ')) {
              setValue('tipo_logradouro', 'Estrada')
              setValue('logradouro', data.logradouro.replace(/^estrada /i, ''))
            } else {
              setValue('logradouro', data.logradouro)
            }
          }
          
          toast.success('Endereço preenchido automaticamente!')
        } else {
          toast.error('CEP não encontrado')
        }
      } catch (error) {
        console.error('Erro ao buscar CEP:', error)
        toast.error('Erro ao buscar CEP')
      } finally {
        setLoadingCep(false)
      }
    }
  }

  const onSubmit = async (data: ClienteFormData) => {
    setLoading(true)
    try {
      const clienteData: ClienteInput = {
        ...data,
        ativo: true
      }
      
      let clienteResult: Cliente
      
      if (cliente) {
        clienteResult = await ClienteService.atualizarCliente(cliente.id, clienteData)
        toast.success('Cliente atualizado com sucesso!')
      } else {
        clienteResult = await ClienteService.criarCliente(clienteData)
        toast.success('Cliente cadastrado com sucesso!')
      }
      
      onSuccess?.(clienteResult)
    } catch (error: unknown) {
      console.error('Erro ao salvar cliente:', error)
      const errorMessage = error instanceof Error ? error.message : 'Erro ao salvar cliente'
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-lg font-semibold text-gray-900">
          {cliente ? 'Editar Cliente' : 'Cadastrar Novo Cliente'}
        </h2>
        {onCancel && (
          <Button 
            variant="secondary" 
            size="sm" 
            onClick={onCancel}
            className="flex items-center gap-2"
          >
            <X className="w-4 h-4" />
            Cancelar
          </Button>
        )}
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Informações Básicas */}
        <div>
          <h3 className="text-md font-medium text-gray-900 mb-4">Informações Básicas</h3>
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
                  placeholder="João Silva"
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
              </label>
              <input
                value={cpfCnpjValue}
                onChange={handleCpfCnpjChange}
                type="text"
                maxLength={tipoSelecionado === 'Física' ? 14 : 18}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder={tipoSelecionado === 'Física' ? '000.000.000-00' : '00.000.000/0000-00'}
              />
              {errors.cpf_cnpj && (
                <span className="text-red-500 text-sm">{errors.cpf_cnpj.message}</span>
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
        </div>

        {/* Seção de Endereço */}
        <div>
          <h3 className="text-md font-medium text-gray-900 mb-4">Endereço (opcional)</h3>
          
          {/* CEP - Campo principal para busca automática */}
          <div className="mb-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  CEP <span className="text-blue-600">(preenche automaticamente)</span>
                </label>
                <input
                  value={cepValue}
                  onChange={handleCepChange}
                  type="text"
                  maxLength={9}
                  className={`w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${loadingCep ? 'bg-gray-100' : ''}`}
                  placeholder="00000-000"
                  disabled={loadingCep}
                />
                {loadingCep && (
                  <span className="text-sm text-blue-600 mt-1">Buscando endereço...</span>
                )}
              </div>
            </div>
          </div>

          {/* Rua/Avenida */}
          <div className="mb-4">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Tipo
                </label>
                <select
                  {...register('tipo_logradouro')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">Tipo...</option>
                  <option value="Rua">Rua</option>
                  <option value="Avenida">Avenida</option>
                  <option value="Travessa">Travessa</option>
                  <option value="Alameda">Alameda</option>
                  <option value="Praça">Praça</option>
                  <option value="Estrada">Estrada</option>
                  <option value="Rodovia">Rodovia</option>
                </select>
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Nome da Rua/Avenida
                </label>
                <input
                  {...register('logradouro')}
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="das Flores, Paulista, etc."
                />
              </div>
            </div>
          </div>

          {/* Número - Campo separado */}
          <div className="mb-4">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
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
                  Complemento
                </label>
                <input
                  {...register('complemento')}
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Apto 101, Bloco A"
                />
              </div>
            </div>
          </div>

          {/* Localização */}
          <div className="mb-4">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
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
                  Estado (UF)
                </label>
                <select
                  {...register('estado')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">UF...</option>
                  <option value="AC">AC</option>
                  <option value="AL">AL</option>
                  <option value="AP">AP</option>
                  <option value="AM">AM</option>
                  <option value="BA">BA</option>
                  <option value="CE">CE</option>
                  <option value="DF">DF</option>
                  <option value="ES">ES</option>
                  <option value="GO">GO</option>
                  <option value="MA">MA</option>
                  <option value="MT">MT</option>
                  <option value="MS">MS</option>
                  <option value="MG">MG</option>
                  <option value="PA">PA</option>
                  <option value="PB">PB</option>
                  <option value="PR">PR</option>
                  <option value="PE">PE</option>
                  <option value="PI">PI</option>
                  <option value="RJ">RJ</option>
                  <option value="RN">RN</option>
                  <option value="RS">RS</option>
                  <option value="RO">RO</option>
                  <option value="RR">RR</option>
                  <option value="SC">SC</option>
                  <option value="SP">SP</option>
                  <option value="SE">SE</option>
                  <option value="TO">TO</option>
                </select>
              </div>
            </div>
          </div>

          {/* Ponto de Referência */}
          <div className="mb-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Ponto de Referência (opcional)
              </label>
              <input
                {...register('ponto_referencia')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Próximo ao shopping, em frente à farmácia"
              />
            </div>
          </div>

          {/* Endereço Completo (Auto) */}
          <div>
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
        </div>

        {/* Observações */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Observações
          </label>
          <textarea
            {...register('observacoes')}
            rows={3}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Observações sobre o cliente..."
          />
        </div>

        {/* Botões */}
        <div className="flex gap-3 pt-4">
          <Button 
            type="submit" 
            disabled={loading}
            className="flex items-center gap-2"
          >
            <Save className="w-4 h-4" />
            {loading ? 'Salvando...' : (cliente ? 'Atualizar Cliente' : 'Cadastrar Cliente')}
          </Button>
          
          {onCancel && (
            <Button 
              type="button" 
              variant="secondary" 
              onClick={onCancel}
              disabled={loading}
            >
              Cancelar
            </Button>
          )}
        </div>
      </form>
    </Card>
  )
}
