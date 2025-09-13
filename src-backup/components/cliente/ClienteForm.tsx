import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { useState, useEffect } from 'react'
import { User, Phone, Mail, MapPin, FileText, Save, X } from 'lucide-react'
import { Button } from '../../components/ui/Button'
import { Input } from '../../components/ui/Input'
import { Card } from '../../components/ui/Card'
import { formatarTelefone, formatarCpfCnpj, validarCpfCnpj } from '../../utils/formatacao'
import type { Cliente, ClienteInput } from '../../types/cliente'

// Schema de validação
const clienteSchema = z.object({
  nome: z.string().min(3, 'Nome deve ter pelo menos 3 caracteres'),
  telefone: z.string().min(10, 'Telefone deve ter pelo menos 10 dígitos'),
  cpf_cnpj: z.string().optional().refine((val) => {
    if (!val || val.trim() === '') return true
    return validarCpfCnpj(val)
  }, 'CPF/CNPJ inválido'),
  email: z.string().email('E-mail inválido').optional().or(z.literal('')),
  endereco: z.string().optional(),
  tipo: z.enum(['Física', 'Jurídica']),
  observacoes: z.string().optional(),
  ativo: z.boolean()
})

type ClienteFormData = z.infer<typeof clienteSchema>

interface ClienteFormProps {
  cliente?: Cliente
  onSubmit: (data: ClienteInput) => Promise<void>
  onCancel: () => void
  loading?: boolean
}

export function ClienteForm({ cliente, onSubmit, onCancel, loading }: ClienteFormProps) {
  const [telefoneValue, setTelefoneValue] = useState('')
  const [cpfCnpjValue, setCpfCnpjValue] = useState('')

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    watch,
    reset
  } = useForm<ClienteFormData>({
    resolver: zodResolver(clienteSchema),
    defaultValues: {
      nome: '',
      telefone: '',
      cpf_cnpj: '',
      email: '',
      endereco: '',
      tipo: 'Física',
      observacoes: '',
      ativo: true
    }
  })

  const tipoSelecionado = watch('tipo')

  // Preencher formulário quando cliente for passado
  useEffect(() => {
    if (cliente) {
      reset({
        nome: cliente.nome,
        telefone: cliente.telefone,
        cpf_cnpj: cliente.cpf_cnpj || '',
        email: cliente.email || '',
        endereco: cliente.endereco || '',
        tipo: cliente.tipo,
        observacoes: cliente.observacoes || '',
        ativo: cliente.ativo
      })
      setTelefoneValue(cliente.telefone)
      setCpfCnpjValue(cliente.cpf_cnpj || '')
    }
  }, [cliente, reset])

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

  const onFormSubmit = async (data: ClienteFormData) => {
    try {
      await onSubmit(data)
      if (!cliente) {
        reset()
        setTelefoneValue('')
        setCpfCnpjValue('')
      }
    } catch {
      // Erro já tratado no hook useClientes
    }
  }

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-orange-600 rounded-lg flex items-center justify-center">
            <User className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-xl font-bold text-gray-900">
              {cliente ? 'Editar Cliente' : 'Novo Cliente'}
            </h2>
            <p className="text-sm text-gray-600">
              {cliente ? 'Atualize as informações do cliente' : 'Preencha os dados do novo cliente'}
            </p>
          </div>
        </div>
        <Button
          type="button"
          variant="outline"
          onClick={onCancel}
          className="text-gray-600 hover:text-gray-800"
        >
          <X className="w-4 h-4 mr-2" />
          Cancelar
        </Button>
      </div>

      <form onSubmit={handleSubmit(onFormSubmit)} className="space-y-6">
        {/* Informações Básicas */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Nome Completo *
            </label>
            <Input
              {...register('nome')}
              placeholder="Digite o nome completo"
              error={errors.nome?.message}
              icon={<User className="w-4 h-4 text-gray-400" />}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Telefone *
            </label>
            <Input
              value={telefoneValue}
              onChange={handleTelefoneChange}
              placeholder="(11) 99999-9999"
              error={errors.telefone?.message}
              icon={<Phone className="w-4 h-4 text-gray-400" />}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              CPF/CNPJ
            </label>
            <Input
              value={cpfCnpjValue}
              onChange={handleCpfCnpjChange}
              placeholder={tipoSelecionado === 'Física' ? '000.000.000-00' : '00.000.000/0000-00'}
              error={errors.cpf_cnpj?.message}
              icon={<FileText className="w-4 h-4 text-gray-400" />}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              E-mail
            </label>
            <Input
              {...register('email')}
              type="email"
              placeholder="cliente@email.com"
              error={errors.email?.message}
              icon={<Mail className="w-4 h-4 text-gray-400" />}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Tipo de Pessoa
            </label>
            <div className="flex space-x-4">
              <label className="flex items-center">
                <input
                  {...register('tipo')}
                  type="radio"
                  value="Física"
                  className="w-4 h-4 text-orange-600 border-gray-300 focus:ring-orange-500"
                />
                <span className="ml-2 text-sm text-gray-700">Pessoa Física</span>
              </label>
              <label className="flex items-center">
                <input
                  {...register('tipo')}
                  type="radio"
                  value="Jurídica"
                  className="w-4 h-4 text-orange-600 border-gray-300 focus:ring-orange-500"
                />
                <span className="ml-2 text-sm text-gray-700">Pessoa Jurídica</span>
              </label>
            </div>
          </div>
        </div>

        {/* Endereço */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Endereço Completo
          </label>
          <Input
            {...register('endereco')}
            placeholder="Rua, número, bairro, cidade, CEP"
            error={errors.endereco?.message}
            icon={<MapPin className="w-4 h-4 text-gray-400" />}
          />
        </div>

        {/* Observações */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Observações
          </label>
          <textarea
            {...register('observacoes')}
            rows={3}
            placeholder="Informações adicionais sobre o cliente..."
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500 focus:border-transparent resize-none"
          />
        </div>

        {/* Status */}
        <div className="flex items-center space-x-3">
          <input
            {...register('ativo')}
            type="checkbox"
            className="w-4 h-4 text-orange-600 border-gray-300 rounded focus:ring-orange-500"
          />
          <label className="text-sm font-medium text-gray-700">
            Cliente Ativo
          </label>
        </div>

        {/* Botões */}
        <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200">
          <Button
            type="button"
            variant="outline"
            onClick={onCancel}
            disabled={loading}
          >
            Cancelar
          </Button>
          <Button
            type="submit"
            disabled={loading}
            className="bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700"
          >
            <Save className="w-4 h-4 mr-2" />
            {loading ? 'Salvando...' : 'Salvar Cliente'}
          </Button>
        </div>
      </form>
    </Card>
  )
}
