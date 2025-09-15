// Exemplo de integração do CpfInput no ClienteFormulario existente
// Este arquivo mostra como modificar o formulário para usar validação de CPF em tempo real

import { useState, useRef } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { X, Save } from 'lucide-react'
import { CpfInput, type CpfInputRef } from '../CpfInput'
import { onlyDigits } from '../../lib/cpf'
// import { ClienteService } from '../../services/clienteService'
// import type { Cliente, ClienteInput } from '../../types/cliente'

// Tipos para exemplo (ajuste conforme seus tipos reais)
interface Cliente {
  id: string
  nome: string
  telefone: string
  cpf_digits?: string // Adicione esta propriedade ao tipo Cliente
  email?: string
  endereco?: string
  tipo: 'Física' | 'Jurídica'
  observacoes?: string
}

interface ClienteInput {
  nome: string
  telefone: string
  cpf_digits: string // Adicione esta propriedade ao tipo ClienteInput
  email?: string
  endereco?: string
  tipo: 'Física' | 'Jurídica'
  observacoes?: string
  ativo: boolean
  empresa_id?: string
}

// Schema atualizado - removemos validação de CPF do Zod pois será feita pelo CpfInput
const clienteFormSchema = z.object({
  nome: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  telefone: z.string().min(10, 'Telefone deve ter pelo menos 10 dígitos'),
  email: z.string().email('E-mail inválido').optional().or(z.literal('')),
  endereco: z.string().optional(),
  tipo: z.enum(['Física', 'Jurídica']),
  observacoes: z.string().optional()
})

type ClienteFormData = z.infer<typeof clienteFormSchema>

interface ClienteFormularioComCpfProps {
  cliente?: Cliente
  empresaId?: string
  onSuccess?: (cliente: Cliente) => void
  onCancel?: () => void
}

export function ClienteFormularioComCpf({
  cliente,
  empresaId,
  onSuccess,
  onCancel
}: ClienteFormularioComCpfProps) {
  const [loading, setLoading] = useState(false)
  const [cpf, setCpf] = useState(cliente?.cpf_digits ? formatCpfFromDigits(cliente.cpf_digits) : '')
  const cpfInputRef = useRef<CpfInputRef>(null)

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors }
  } = useForm<ClienteFormData>({
    resolver: zodResolver(clienteFormSchema),
    defaultValues: {
      nome: cliente?.nome || '',
      telefone: cliente?.telefone || '',
      email: cliente?.email || '',
      endereco: cliente?.endereco || '',
      tipo: cliente?.tipo || 'Física',
      observacoes: cliente?.observacoes || ''
    }
  })

  // Função para formatar CPF a partir dos dígitos (para edição)
  function formatCpfFromDigits(digits: string): string {
    if (digits.length !== 11) return digits
    return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9, 11)}`
  }

  // Verificar se o formulário pode ser submetido
  const canSubmit = () => {
    const formData = watch()
    return (
      formData.nome?.trim().length > 0 &&
      formData.telefone?.trim().length >= 10 &&
      cpfInputRef.current?.isCpfOk === true &&
      !loading
    )
  }

  const onSubmit = async (data: ClienteFormData) => {
    if (!cpfInputRef.current?.isCpfOk) {
      toast.error('Por favor, verifique o CPF antes de salvar.')
      return
    }

    setLoading(true)

    try {
      const cpfDigits = onlyDigits(cpf)
      
      const clienteData: ClienteInput = {
        nome: data.nome.trim(),
        telefone: data.telefone.trim(),
        cpf_digits: cpfDigits, // Armazenar apenas dígitos
        email: data.email?.trim() || undefined,
        endereco: data.endereco?.trim() || undefined,
        tipo: data.tipo,
        observacoes: data.observacoes?.trim() || undefined,
        ativo: true,
        ...(empresaId && { empresa_id: empresaId })
      }

      let resultado: Cliente

      if (cliente?.id) {
        // Editando cliente existente
        // resultado = await ClienteService.atualizarCliente(cliente.id, clienteData)
        console.log('Atualizando cliente:', clienteData)
        resultado = { ...clienteData, id: cliente.id } as Cliente
        toast.success('Cliente atualizado com sucesso!')
      } else {
        // Criando novo cliente
        // resultado = await ClienteService.criarCliente(clienteData)
        console.log('Criando cliente:', clienteData)
        resultado = { ...clienteData, id: 'novo-id' } as Cliente
        toast.success('Cliente criado com sucesso!')
      }

      if (onSuccess) {
        onSuccess(resultado)
      }

    } catch (error: any) {
      console.error('Erro ao salvar cliente:', error)
      
      // Tratar erros específicos
      if (error.code === '23505') {
        toast.error('Este CPF já está cadastrado.')
      } else if (error.message?.includes('cpf')) {
        toast.error('Erro de validação do CPF.')
      } else {
        toast.error('Erro ao salvar cliente. Tente novamente.')
      }
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-2xl mx-auto">
      <div className="bg-white rounded-lg shadow-md">
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-semibold text-gray-900">
              {cliente ? 'Editar Cliente' : 'Novo Cliente'}
            </h2>
            {onCancel && (
              <button
                type="button"
                onClick={onCancel}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            )}
          </div>
        </div>

        {/* Formulário */}
        <form onSubmit={handleSubmit(onSubmit)} className="p-6 space-y-6">
          
          {/* Nome */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Nome Completo *
            </label>
            <input
              {...register('nome')}
              type="text"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Digite o nome completo"
            />
            {errors.nome && (
              <p className="mt-1 text-sm text-red-600">{errors.nome.message}</p>
            )}
          </div>

          {/* CPF com validação em tempo real */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              CPF *
            </label>
            <CpfInput
              ref={cpfInputRef}
              value={cpf}
              onChange={setCpf}
              empresaId={empresaId}
              placeholder="000.000.000-00"
            />
          </div>

          {/* Telefone */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Telefone *
            </label>
            <input
              {...register('telefone')}
              type="tel"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="(11) 99999-9999"
            />
            {errors.telefone && (
              <p className="mt-1 text-sm text-red-600">{errors.telefone.message}</p>
            )}
          </div>

          {/* Email */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Email
            </label>
            <input
              {...register('email')}
              type="email"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="email@exemplo.com"
            />
            {errors.email && (
              <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>
            )}
          </div>

          {/* Tipo */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Tipo *
            </label>
            <select
              {...register('tipo')}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="Física">Pessoa Física</option>
              <option value="Jurídica">Pessoa Jurídica</option>
            </select>
          </div>

          {/* Endereço */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Endereço
            </label>
            <textarea
              {...register('endereco')}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
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
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Observações adicionais"
            />
          </div>

          {/* Footer com botões */}
          <div className="flex items-center justify-between pt-6 border-t border-gray-200">
            <div className="text-sm text-gray-600">
              {cpfInputRef.current?.isCpfOk ? (
                <span className="text-green-600">✓ Todos os campos válidos</span>
              ) : (
                <span className="text-gray-500">* Campos obrigatórios</span>
              )}
            </div>

            <div className="flex gap-3">
              {onCancel && (
                <button
                  type="button"
                  onClick={onCancel}
                  className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Cancelar
                </button>
              )}

              <button
                type="submit"
                disabled={!canSubmit()}
                className={`px-6 py-2 rounded-lg font-medium transition-colors ${
                  canSubmit()
                    ? 'bg-blue-600 hover:bg-blue-700 text-white'
                    : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                }`}
              >
                {loading ? (
                  <span className="flex items-center gap-2">
                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                    Salvando...
                  </span>
                ) : (
                  <>
                    <Save className="w-4 h-4 inline mr-2" />
                    Salvar
                  </>
                )}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  )
}

// Importar ClienteService se não estiver disponível
// import { ClienteService } from '../../services/clienteService'