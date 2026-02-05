import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { 
  X, 
  Calendar, 
  Clock, 
  Shield, 
  CheckCircle,
  Package,
  Printer
} from 'lucide-react'
import { Button } from '../ui/Button'
import { BackButton } from '../ui/BackButton'
import { Card } from '../ui/Card'
import { roundCurrency } from '../../utils/currency'
import type { OrdemServico } from '../../types/ordemServico'

// Schema de validação para entrega
const entregaSchema = z.object({
  garantia_tipo: z.enum(['sem_garantia', 'com_garantia']),
  garantia_meses: z.number().min(1, 'Mínimo 1 mês').max(60, 'Máximo 60 meses').optional(),
  valor_final: z.number().min(0, 'Valor deve ser positivo').optional()
})

type EntregaFormData = z.infer<typeof entregaSchema>

interface ModalEntregaOSProps {
  ordem: OrdemServico
  isOpen: boolean
  onClose: () => void
  onConfirmar: (dados: {
    garantia_meses?: number
    valor_final?: number
    data_entrega: string
    data_fim_garantia?: string
  }) => Promise<void>
}

export function ModalEntregaOS({ ordem, isOpen, onClose, onConfirmar }: ModalEntregaOSProps) {
  const [loading, setLoading] = useState(false)
  const [encerradoComSucesso, setEncerradoComSucesso] = useState(false)

  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
    reset
  } = useForm<EntregaFormData>({
    resolver: zodResolver(entregaSchema),
    defaultValues: {
      garantia_tipo: 'sem_garantia',
      valor_final: roundCurrency(ordem.valor_orcamento),
      garantia_meses: 12
    }
  })

  const garantiaTipo = watch('garantia_tipo')
  const garantiaMeses = watch('garantia_meses')

  // Calcular tempo de reparo
  const calcularTempoReparo = () => {
    const entrada = new Date(ordem.data_entrada)
    const agora = new Date()
    const diffTime = Math.abs(agora.getTime() - entrada.getTime())
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
    return diffDays
  }

  // Formatar data
  const formatarData = (data: string) => {
    return new Date(data).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  // Calcular data de fim da garantia
  const calcularFimGarantia = (meses: number) => {
    const agora = new Date()
    const fimGarantia = new Date(agora.setMonth(agora.getMonth() + meses))
    return fimGarantia.toISOString()
  }

  const onSubmit = async (data: EntregaFormData) => {
    setLoading(true)
    try {
      const agora = new Date().toISOString()
      
      const dadosEntrega = {
        valor_final: roundCurrency(data.valor_final),
        data_entrega: agora,
        garantia_meses: data.garantia_tipo === 'com_garantia' ? data.garantia_meses : undefined,
        data_fim_garantia: data.garantia_tipo === 'com_garantia' && data.garantia_meses 
          ? calcularFimGarantia(data.garantia_meses)
          : undefined
      }

      await onConfirmar(dadosEntrega)
      setEncerradoComSucesso(true)
      toast.success('Ordem de serviço encerrada com sucesso!')
    } catch (error: unknown) {
      console.error('Erro ao entregar equipamento:', error)
      toast.error('Erro ao processar entrega')
    } finally {
      setLoading(false)
    }
  }

  const handleImprimir = () => {
    window.print()
  }

  const handleFechar = () => {
    reset()
    setEncerradoComSucesso(false)
    onClose()
  }

  if (!isOpen) return null

  // Se a OS foi encerrada com sucesso, mostrar opções de impressão
  if (encerradoComSucesso) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-lg max-w-md w-full p-6">
          <div className="text-center mb-6">
            <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <CheckCircle className="w-10 h-10 text-green-600" />
            </div>
            <h2 className="text-2xl font-bold text-gray-900 mb-2">
              OS Encerrada com Sucesso!
            </h2>
            <p className="text-gray-600">
              A ordem de serviço foi encerrada e está pronta para entrega.
            </p>
          </div>

          <Card className="p-4 mb-6 bg-blue-50 border-blue-200">
            <div className="text-center">
              <Printer className="w-8 h-8 text-blue-600 mx-auto mb-2" />
              <p className="text-sm text-blue-900 font-medium">
                Deseja imprimir a OS agora?
              </p>
            </div>
          </Card>

          <div className="flex gap-3">
            <Button
              variant="outline"
              onClick={handleFechar}
              className="flex-1"
            >
              Não, obrigado
            </Button>
            <Button
              onClick={handleImprimir}
              className="flex-1 gap-2 bg-blue-600 hover:bg-blue-700"
            >
              <Printer className="w-4 h-4" />
              Imprimir OS
            </Button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-3">
              <Package className="w-6 h-6 text-green-600" />
              <h2 className="text-xl font-semibold text-gray-900">
                Encerrar Ordem de Serviço
              </h2>
            </div>
            <div className="flex items-center gap-2">
              <BackButton customAction={onClose} variant="ghost" size="sm">
                Cancelar
              </BackButton>
              <button
                onClick={onClose}
                className="text-gray-400 hover:text-gray-600 p-1 rounded"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>

          {/* Informações do Reparo */}
          <Card className="p-4 mb-6 bg-green-50 border-green-200">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="flex items-center gap-3">
                <Calendar className="w-5 h-5 text-green-600" />
                <div>
                  <div className="text-sm text-gray-600">Data de Entrada</div>
                  <div className="font-medium text-gray-900">
                    {formatarData(ordem.data_entrada)}
                  </div>
                </div>
              </div>
              
              <div className="flex items-center gap-3">
                <Clock className="w-5 h-5 text-green-600" />
                <div>
                  <div className="text-sm text-gray-600">Tempo de Reparo</div>
                  <div className="font-medium text-gray-900">
                    {calcularTempoReparo()} dias
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <CheckCircle className="w-5 h-5 text-green-600" />
                <div>
                  <div className="text-sm text-gray-600">Data de Entrega</div>
                  <div className="font-medium text-gray-900">
                    {formatarData(new Date().toISOString())}
                  </div>
                </div>
              </div>
            </div>
          </Card>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
            
            {/* Valor Final */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Valor Final do Serviço (R$)
              </label>
              <input
                {...register('valor_final', { valueAsNumber: true })}
                type="number"
                min="0"
                step="0.01"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                placeholder="0,00"
              />
              {errors.valor_final && (
                <span className="text-red-500 text-sm">{errors.valor_final.message}</span>
              )}
            </div>

            {/* Garantia */}
            <div className="space-y-4">
              <label className="block text-sm font-medium text-gray-700">
                <Shield className="w-4 h-4 inline mr-2" />
                Garantia do Serviço
              </label>
              
              <div className="space-y-3">
                <label className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50">
                  <input
                    {...register('garantia_tipo')}
                    type="radio"
                    value="sem_garantia"
                    className="text-green-600 focus:ring-green-500"
                  />
                  <div>
                    <div className="font-medium text-gray-900">Sem Garantia</div>
                    <div className="text-sm text-gray-600">O equipamento será entregue sem garantia do serviço</div>
                  </div>
                </label>
                
                <label className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-gray-50">
                  <input
                    {...register('garantia_tipo')}
                    type="radio"
                    value="com_garantia"
                    className="text-green-600 focus:ring-green-500"
                  />
                  <div>
                    <div className="font-medium text-gray-900">Com Garantia</div>
                    <div className="text-sm text-gray-600">Especificar período de garantia em meses</div>
                  </div>
                </label>
              </div>

              {/* Campo de meses quando garantia está selecionada */}
              {garantiaTipo === 'com_garantia' && (
                <div className="ml-8">
                  <label className="block text-sm font-medium text-gray-700 mb-3">
                    Período de Garantia
                  </label>
                  
                  {/* Opções rápidas de garantia */}
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-2 mb-3">
                    {[3, 6, 12, 24].map((meses) => (
                      <button
                        key={meses}
                        type="button"
                        onClick={() => setValue('garantia_meses', meses)}
                        className="px-3 py-2 text-sm border border-gray-300 rounded-md hover:bg-green-50 hover:border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500"
                      >
                        {meses} meses
                      </button>
                    ))}
                  </div>
                  
                  <div className="flex gap-3 items-center">
                    <input
                      {...register('garantia_meses', { valueAsNumber: true })}
                      type="number"
                      min="1"
                      max="60"
                      className="w-32 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
                      placeholder="12"
                    />
                    <div className="text-sm text-gray-600">
                      meses (máximo 60 meses)
                    </div>
                  </div>
                  
                  {errors.garantia_meses && (
                    <span className="text-red-500 text-sm">{errors.garantia_meses.message}</span>
                  )}
                  
                  {/* Mostrar previsão de fim da garantia */}
                  {garantiaMeses && garantiaMeses > 0 && (
                    <div className="mt-3 p-3 bg-blue-50 rounded-lg border border-blue-200">
                      <div className="flex items-center gap-2">
                        <Shield className="w-4 h-4 text-blue-600" />
                        <span className="text-sm font-medium text-blue-900">
                          Fim da Garantia: 
                        </span>
                        <span className="text-sm text-blue-700">
                          {formatarData(calcularFimGarantia(garantiaMeses))}
                        </span>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Resumo Final */}
            <Card className="p-4 bg-gray-50 border-gray-200">
              <h3 className="text-sm font-medium text-gray-900 mb-3">📋 Resumo do Encerramento</h3>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-600">Data/Hora de Entrega:</span>
                  <span className="font-medium">{formatarData(new Date().toISOString())}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Valor Final:</span>
                  <span className="font-medium text-green-600">
                    R$ {(watch('valor_final') || 0).toFixed(2)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Garantia:</span>
                  <span className="font-medium">
                    {garantiaTipo === 'com_garantia' && garantiaMeses 
                      ? `${garantiaMeses} meses (até ${formatarData(calcularFimGarantia(garantiaMeses)).split(' ')[0]})`
                      : 'Sem garantia'
                    }
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Tempo de Reparo:</span>
                  <span className="font-medium">{calcularTempoReparo()} dias</span>
                </div>
              </div>
            </Card>

            {/* Botões de Ação */}
            <div className="flex gap-3 pt-4 border-t">
              <Button
                type="button"
                variant="outline"
                onClick={onClose}
                disabled={loading}
                className="flex-1"
              >
                Cancelar
              </Button>
              <Button
                type="submit"
                loading={loading}
                className="flex-1 gap-2"
              >
                <CheckCircle className="w-4 h-4" />
                Encerrar OS
              </Button>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}
