import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { 
  Settings,
  Calendar,
  DollarSign,
  Save
} from 'lucide-react'
import { Button } from '../ui/Button'
import { BackButton } from '../ui/BackButton'
import { Card } from '../ui/Card'
import { ClienteSelector } from '../ui/ClienteSelectorSimples'
import { ordemServicoService } from '../../services/ordemServicoService'
import type { 
  NovaOrdemServicoForm, 
  TipoEquipamento, 
  ChecklistOS 
} from '../../types/ordemServico'
import type { Cliente } from '../../types/cliente'

// Schema de validação
const ordemServicoSchema = z.object({
  tipo: z.enum(['Celular', 'Notebook', 'Console', 'Tablet', 'Outro']),
  marca: z.string().min(2, 'Marca é obrigatória'),
  modelo: z.string().min(2, 'Modelo é obrigatório'),
  cor: z.string().optional(),
  numero_serie: z.string().optional(),
  defeito_relatado: z.string().min(5, 'Defeito relatado é obrigatório (mínimo 5 caracteres)'),
  observacoes: z.string().optional(),
  data_previsao: z.string().optional().refine((val) => {
    // Se for uma string vazia, permitir
    if (!val || val === '') return true
    // Se tiver valor, deve ser uma data válida
    const date = new Date(val)
    return !isNaN(date.getTime())
  }, 'Data deve ser válida'),
  valor_orcamento: z.number().min(0, 'Valor deve ser positivo').optional()
})

type FormData = z.infer<typeof ordemServicoSchema>

interface OrdemServicoFormProps {
  onSuccess?: (ordem: Record<string, unknown>) => void
  onCancel?: () => void
}

const TIPOS_EQUIPAMENTO_BASE: { value: TipoEquipamento; label: string }[] = [
  { value: 'Celular', label: 'Celular' },
  { value: 'Notebook', label: 'Notebook' },
  { value: 'Console', label: 'Console' },
  { value: 'Tablet', label: 'Tablet' }
]

export function OrdemServicoForm({ onSuccess, onCancel }: OrdemServicoFormProps) {
  const [loading, setLoading] = useState(false)
  const [clienteSelecionado, setClienteSelecionado] = useState<Cliente | null>(null)
  const [checklist, setChecklist] = useState<ChecklistOS>({})
  const [tipoPersonalizado, setTipoPersonalizado] = useState('')
  const [mostrarCampoPersonalizado, setMostrarCampoPersonalizado] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue
  } = useForm<FormData>({
    resolver: zodResolver(ordemServicoSchema),
    defaultValues: {
      tipo: 'Celular'
    }
  })

  // Atualizar checklist
  const atualizarChecklist = (campo: keyof ChecklistOS, valor: boolean) => {
    setChecklist(prev => ({
      ...prev,
      [campo]: valor
    }))
  }

  // Submeter formulário
  const onSubmit = async (data: FormData) => {
    if (!clienteSelecionado) {
      toast.error('Selecione um cliente para continuar')
      return
    }

    setLoading(true)
    
    try {
      const novaOrdem: NovaOrdemServicoForm = {
        cliente_nome: clienteSelecionado.nome,
        cliente_telefone: clienteSelecionado.telefone,
        cliente_email: clienteSelecionado.email,
        tipo: data.tipo,
        marca: data.marca,
        modelo: data.modelo,
        cor: data.cor,
        numero_serie: data.numero_serie,
        checklist,
        observacoes: data.observacoes,
        defeito_relatado: data.defeito_relatado,
        data_previsao: data.data_previsao,
        valor_orcamento: data.valor_orcamento
      }

      const ordem = await ordemServicoService.criarOrdem(novaOrdem)
      
      toast.success('Ordem de serviço criada com sucesso!')
      
      // Sinalizar que a lista de OS precisa ser recarregada
      localStorage.setItem('os_list_needs_refresh', 'true')
      
      if (onSuccess) {
        onSuccess(ordem as unknown as Record<string, unknown>)
      }
    } catch (error: unknown) {
      console.error('Erro ao criar ordem:', error)
      const errorMessage = error instanceof Error ? error.message : 'Erro ao criar ordem de serviço'
      toast.error(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Nova Ordem de Serviço</h1>
        <div className="flex gap-2">
          <BackButton />
          {onCancel && (
            <Button variant="outline" onClick={onCancel}>
              Cancelar
            </Button>
          )}
        </div>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6" noValidate>
        
        {/* Seção: Cliente */}
        <ClienteSelector 
          onClienteSelect={setClienteSelecionado}
          clienteSelecionado={clienteSelecionado}
        />

        {/* Seção: Informações do Aparelho */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <Settings className="w-5 h-5 text-green-600" />
            <h2 className="text-lg font-semibold text-gray-900">Informações do Aparelho</h2>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo de Equipamento *
              </label>
              <select
                {...register('tipo')}
                onChange={(e) => {
                  const valor = e.target.value as TipoEquipamento
                  setValue('tipo', valor)
                  setMostrarCampoPersonalizado(valor === 'Outro')
                }}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {TIPOS_EQUIPAMENTO_BASE.map((tipo) => (
                  <option key={tipo.value} value={tipo.value}>
                    {tipo.label}
                  </option>
                ))}
                <option value="Outro">Outro (personalizado)</option>
              </select>
              {errors.tipo && (
                <span className="text-red-500 text-sm">{errors.tipo.message}</span>
              )}
            </div>

            {mostrarCampoPersonalizado && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Especifique o Tipo
                </label>
                <input
                  type="text"
                  value={tipoPersonalizado}
                  onChange={(e) => setTipoPersonalizado(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Ex: Smartwatch, Drone, etc."
                />
                <p className="text-xs text-gray-500 mt-1">
                  Tipo personalizado para este equipamento
                </p>
              </div>
            )}
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Marca *
              </label>
              <input
                {...register('marca')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Samsung, Apple, Dell..."
              />
              {errors.marca && (
                <span className="text-red-500 text-sm">{errors.marca.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Modelo *
              </label>
              <input
                {...register('modelo')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Galaxy S21, iPhone 13..."
              />
              {errors.modelo && (
                <span className="text-red-500 text-sm">{errors.modelo.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Cor
              </label>
              <input
                {...register('cor')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Preto, Branco, Azul..."
              />
            </div>
            
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Número de Série
              </label>
              <input
                {...register('numero_serie')}
                type="text"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="IMEI ou número de série"
              />
            </div>
          </div>
        </Card>

        {/* Seção: Checklist Técnico */}
        <Card className="p-6">
          <div className="flex items-center gap-2 mb-4">
            <Settings className="w-5 h-5 text-purple-600" />
            <h2 className="text-lg font-semibold text-gray-900">Checklist Técnico</h2>
          </div>
          
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {[
              { key: 'liga', label: 'Aparelho liga?' },
              { key: 'tela_quebrada', label: 'Tela quebrada?' },
              { key: 'molhado', label: 'Aparelho molhado?' },
              { key: 'com_senha', label: 'Com senha?' },
              { key: 'bateria_boa', label: 'Bateria boa?' },
              { key: 'tampa_presente', label: 'Tampa presente?' },
              { key: 'acessorios', label: 'Acessórios entregues?' },
              { key: 'carregador', label: 'Carregador?' }
            ].map((item) => (
              <label key={item.key} className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={checklist[item.key as keyof ChecklistOS] || false}
                  onChange={(e) => atualizarChecklist(item.key as keyof ChecklistOS, e.target.checked)}
                  className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                />
                <span className="text-sm text-gray-700">{item.label}</span>
              </label>
            ))}
          </div>
        </Card>

        {/* Seção: Detalhes do Problema */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Detalhes do Problema</h2>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Defeito Relatado *
              </label>
              <textarea
                {...register('defeito_relatado')}
                rows={3}
                required={false}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Ex: Celular não liga, tela quebrada, bateria não carrega..."
              />
              {errors.defeito_relatado && (
                <span className="text-red-500 text-sm">{errors.defeito_relatado.message}</span>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Observações Adicionais
              </label>
              <textarea
                {...register('observacoes')}
                rows={2}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Observações gerais, estado do aparelho, etc..."
              />
            </div>
          </div>
        </Card>

        {/* Seção: Prazos e Valores */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Prazos e Valores</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Previsão de Entrega
              </label>
              <div className="relative">
                <Calendar className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                <input
                  {...register('data_previsao')}
                  type="date"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Valor do Orçamento (R$)
              </label>
              <div className="relative">
                <DollarSign className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                <input
                  {...register('valor_orcamento', { valueAsNumber: true })}
                  type="number"
                  min="0"
                  step="0.01"
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="0,00"
                />
              </div>
              {errors.valor_orcamento && (
                <span className="text-red-500 text-sm">{errors.valor_orcamento.message}</span>
              )}
            </div>
          </div>
        </Card>

        {/* Botões de Ação */}
        <div className="flex gap-4 justify-end">
          {onCancel && (
            <Button type="button" variant="outline" onClick={onCancel}>
              Cancelar
            </Button>
          )}
          
          <Button type="submit" loading={loading} className="gap-2">
            <Save className="w-4 h-4" />
            Criar Ordem de Serviço
          </Button>
        </div>
      </form>
    </div>
  )
}
