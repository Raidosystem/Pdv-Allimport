import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { X, Save, User, Phone, Mail, MapPin, Smartphone, Wrench, Calendar, DollarSign, Shield } from 'lucide-react'
import { toast } from 'react-hot-toast'
import type { OrdemServico } from '../../types/ordemServico'
import { ordemServicoService } from '../../services/ordemServicoService'

// Schema de validação para edição
const editOrdemSchema = z.object({
  // Dados do Cliente
  cliente_nome: z.string().min(2, 'Nome do cliente é obrigatório'),
  cliente_telefone: z.string().optional(),
  cliente_email: z.string().email('Email inválido').optional().or(z.literal('')),
  cliente_endereco: z.string().optional(),
  cliente_cidade: z.string().optional(),
  
  // Equipamento
  marca: z.string().min(1, 'Marca é obrigatória'),
  modelo: z.string().min(1, 'Modelo é obrigatório'),
  equipamento: z.string().optional(),
  numero_os: z.string().optional(),
  
  // Problema e Observações
  defeito_relatado: z.string().min(5, 'Defeito deve ter pelo menos 5 caracteres'),
  descricao_problema: z.string().optional(),
  observacoes: z.string().optional(),
  
  // Datas
  data_entrada: z.string(),
  data_previsao: z.string().optional(),
  data_finalizacao: z.string().optional(),
  data_entrega: z.string().optional(),
  
  // Status e Valores
  status: z.enum(['Em análise', 'Aguardando aprovação', 'Aguardando peças', 'Em conserto', 'Pronto', 'Entregue', 'Cancelado']),
  valor: z.number().min(0, 'Valor deve ser positivo').optional(),
  valor_orcamento: z.number().min(0, 'Valor deve ser positivo').optional(),
  mao_de_obra: z.number().min(0, 'Valor deve ser positivo').optional(),
  forma_pagamento: z.string().optional(),
  
  // Garantia
  garantia_meses: z.number().min(0, 'Garantia deve ser positiva').optional(),
})

type FormData = z.infer<typeof editOrdemSchema>

interface EditarOrdemModalProps {
  ordem: OrdemServico | null
  isOpen: boolean
  onClose: () => void
  onSuccess: () => void
}

export function EditarOrdemModal({ ordem, isOpen, onClose, onSuccess }: EditarOrdemModalProps) {
  const [loading, setLoading] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset
  } = useForm<FormData>({
    resolver: zodResolver(editOrdemSchema)
  })

  // Preencher formulário quando ordem mudar
  useEffect(() => {
    if (ordem) {
      reset({
        cliente_nome: ordem.cliente?.nome || '',
        cliente_telefone: ordem.cliente?.telefone || '',
        cliente_email: ordem.cliente?.email || '',
        cliente_endereco: ordem.cliente?.endereco || '',
        cliente_cidade: ordem.cliente?.cidade || '',
        marca: ordem.marca || '',
        modelo: ordem.modelo || '',
        equipamento: ordem.equipamento || `${ordem.marca} ${ordem.modelo}`,
        numero_os: ordem.numero_os || '',
        defeito_relatado: ordem.defeito_relatado || '',
        descricao_problema: ordem.descricao_problema || '',
        observacoes: ordem.observacoes || '',
        data_entrada: ordem.data_entrada?.split('T')[0] || '',
        data_previsao: ordem.data_previsao?.split('T')[0] || '',
        data_finalizacao: ordem.data_finalizacao?.split('T')[0] || '',
        data_entrega: ordem.data_entrega?.split('T')[0] || '',
        status: ordem.status,
        valor: ordem.valor || ordem.valor_orcamento || 0,
        valor_orcamento: ordem.valor_orcamento || 0,
        mao_de_obra: ordem.mao_de_obra || 0,
        forma_pagamento: ordem.forma_pagamento || '',
        garantia_meses: ordem.garantia_meses || 0,
      })
    }
  }, [ordem, reset])

  const onSubmit = async (data: FormData) => {
    if (!ordem) return

    setLoading(true)
    try {
      await ordemServicoService.atualizarOrdem(ordem.id, {
        // Dados básicos
        marca: data.marca,
        modelo: data.modelo,
        defeito_relatado: data.defeito_relatado,
        observacoes: data.observacoes,
        data_previsao: data.data_previsao,
        data_finalizacao: data.data_finalizacao,
        data_entrega: data.data_entrega,
        status: data.status,
        valor_orcamento: data.valor_orcamento,
        garantia_meses: data.garantia_meses,
      })

      toast.success('Ordem de serviço atualizada com sucesso!')
      onSuccess()
      onClose()
    } catch (error) {
      console.error('Erro ao atualizar ordem:', error)
      toast.error('Erro ao atualizar ordem de serviço')
    } finally {
      setLoading(false)
    }
  }

  if (!isOpen || !ordem) return null

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-6xl max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b px-6 py-4 flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">Editar Ordem de Serviço</h2>
            <p className="text-gray-600">{ordem.numero_os || `OS #${ordem.id.slice(0, 8)}`}</p>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <X className="h-6 w-6" />
          </button>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="p-6 space-y-8">
          {/* Seção Cliente */}
          <div className="bg-blue-50 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <User className="h-5 w-5 text-blue-600" />
              Dados do Cliente
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Nome *</label>
                <input
                  {...register('cliente_nome')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  readOnly
                />
                {errors.cliente_nome && (
                  <p className="text-red-500 text-sm mt-1">{errors.cliente_nome.message}</p>
                )}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Phone className="inline h-4 w-4 mr-1" />
                  Telefone
                </label>
                <input
                  {...register('cliente_telefone')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  readOnly
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Mail className="inline h-4 w-4 mr-1" />
                  Email
                </label>
                <input
                  {...register('cliente_email')}
                  type="email"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  readOnly
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <MapPin className="inline h-4 w-4 mr-1" />
                  Cidade
                </label>
                <input
                  {...register('cliente_cidade')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  readOnly
                />
              </div>
            </div>
          </div>

          {/* Seção Equipamento */}
          <div className="bg-green-50 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Smartphone className="h-5 w-5 text-green-600" />
              Equipamento
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Marca *</label>
                <input
                  {...register('marca')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                />
                {errors.marca && (
                  <p className="text-red-500 text-sm mt-1">{errors.marca.message}</p>
                )}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Modelo *</label>
                <input
                  {...register('modelo')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                />
                {errors.modelo && (
                  <p className="text-red-500 text-sm mt-1">{errors.modelo.message}</p>
                )}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Número OS</label>
                <input
                  {...register('numero_os')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500"
                  readOnly
                />
              </div>
            </div>
          </div>

          {/* Seção Problema */}
          <div className="bg-red-50 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Wrench className="h-5 w-5 text-red-600" />
              Problema e Serviço
            </h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Defeito Relatado *</label>
                <textarea
                  {...register('defeito_relatado')}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                />
                {errors.defeito_relatado && (
                  <p className="text-red-500 text-sm mt-1">{errors.defeito_relatado.message}</p>
                )}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Observações Técnicas</label>
                <textarea
                  {...register('observacoes')}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-red-500"
                  placeholder="Observações sobre o serviço, peças utilizadas, etc..."
                />
              </div>
            </div>
          </div>

          {/* Seção Datas e Status */}
          <div className="bg-yellow-50 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Calendar className="h-5 w-5 text-yellow-600" />
              Datas e Status
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Data Entrada</label>
                <input
                  {...register('data_entrada')}
                  type="date"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                  readOnly
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Data Previsão</label>
                <input
                  {...register('data_previsao')}
                  type="date"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Data Finalização</label>
                <input
                  {...register('data_finalizacao')}
                  type="date"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Data Entrega</label>
                <input
                  {...register('data_entrega')}
                  type="date"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
                />
              </div>
            </div>
            <div className="mt-4">
              <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <select
                {...register('status')}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-yellow-500"
              >
                <option value="Em análise">Em análise</option>
                <option value="Aguardando aprovação">Aguardando aprovação</option>
                <option value="Aguardando peças">Aguardando peças</option>
                <option value="Em conserto">Em conserto</option>
                <option value="Pronto">Pronto</option>
                <option value="Entregue">Entregue</option>
                <option value="Cancelado">Cancelado</option>
              </select>
            </div>
          </div>

          {/* Seção Financeiro */}
          <div className="bg-purple-50 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <DollarSign className="h-5 w-5 text-purple-600" />
              Valores e Pagamento
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Valor Orçamento</label>
                <input
                  {...register('valor_orcamento', { valueAsNumber: true })}
                  type="number"
                  step="0.01"
                  min="0"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Mão de Obra</label>
                <input
                  {...register('mao_de_obra', { valueAsNumber: true })}
                  type="number"
                  step="0.01"
                  min="0"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Forma Pagamento</label>
                <select
                  {...register('forma_pagamento')}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                >
                  <option value="">Selecione...</option>
                  <option value="Dinheiro">Dinheiro</option>
                  <option value="PIX">PIX</option>
                  <option value="Cartão de Crédito">Cartão de Crédito</option>
                  <option value="Cartão de Débito">Cartão de Débito</option>
                  <option value="Orçamento">Orçamento</option>
                  <option value="Garantia">Garantia</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  <Shield className="inline h-4 w-4 mr-1" />
                  Garantia (meses)
                </label>
                <input
                  {...register('garantia_meses', { valueAsNumber: true })}
                  type="number"
                  min="0"
                  max="24"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                />
              </div>
            </div>
          </div>

          {/* Botões de Ação */}
          <div className="flex items-center justify-end gap-4 pt-6 border-t">
            <button
              type="button"
              onClick={onClose}
              className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2 transition-colors"
            >
              <Save className="h-4 w-4" />
              {loading ? 'Salvando...' : 'Salvar Alterações'}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
