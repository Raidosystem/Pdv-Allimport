import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { 
  Calendar,
  DollarSign,
  Save,
  ArrowLeft,
  Settings
} from 'lucide-react'
import { Button } from '../components/ui/Button'
import { BackButton } from '../components/ui/BackButton'
import { Card } from '../components/ui/Card'
import { ClienteSelector } from '../components/ui/ClienteSelectorSimples'
import { ordemServicoService } from '../services/ordemServicoService'
import type { 
  OrdemServico,
  TipoEquipamento, 
  ChecklistOS,
  StatusOS
} from '../types/ordemServico'
import type { Cliente } from '../types/cliente'

// Schema de validação
const ordemServicoEditSchema = z.object({
  tipo: z.enum(['Celular', 'Notebook', 'Console', 'Tablet', 'Outro']),
  marca: z.string().min(2, 'Marca é obrigatória'),
  modelo: z.string().min(2, 'Modelo é obrigatório'),
  cor: z.string().optional(),
  numero_serie: z.string().optional(),
  defeito_relatado: z.string().min(5, 'Defeito relatado é obrigatório (mínimo 5 caracteres)'),
  observacoes: z.string().optional(),
  data_previsao: z.string().optional().refine((val) => {
    if (!val || val === '') return true
    const date = new Date(val)
    return !isNaN(date.getTime())
  }, 'Data deve ser válida'),
  valor_orcamento: z.number().min(0, 'Valor deve ser positivo').optional(),
  valor_final: z.number().min(0, 'Valor deve ser positivo').optional(),
  status: z.enum(['Em análise', 'Aguardando aprovação', 'Aguardando peças', 'Em conserto', 'Pronto', 'Entregue', 'Cancelado']),
  garantia_meses: z.number().min(0).max(60).optional()
})

type EditFormData = z.infer<typeof ordemServicoEditSchema>

const TIPOS_EQUIPAMENTO_BASE: { value: TipoEquipamento; label: string }[] = [
  { value: 'Celular', label: 'Celular' },
  { value: 'Notebook', label: 'Notebook' },
  { value: 'Console', label: 'Console' },
  { value: 'Tablet', label: 'Tablet' }
]

const STATUS_OPTIONS: { value: StatusOS; label: string; color: string }[] = [
  { value: 'Em análise', label: 'Em análise', color: 'bg-blue-100 text-blue-800' },
  { value: 'Aguardando aprovação', label: 'Aguardando aprovação', color: 'bg-yellow-100 text-yellow-800' },
  { value: 'Aguardando peças', label: 'Aguardando peças', color: 'bg-orange-100 text-orange-800' },
  { value: 'Em conserto', label: 'Em conserto', color: 'bg-purple-100 text-purple-800' },
  { value: 'Pronto', label: 'Pronto', color: 'bg-green-100 text-green-800' },
  { value: 'Entregue', label: 'Entregue', color: 'bg-gray-100 text-gray-800' },
  { value: 'Cancelado', label: 'Cancelado', color: 'bg-red-100 text-red-800' }
]

export function OrdemServicoEditPage() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const [loading, setLoading] = useState(false)
  const [loadingData, setLoadingData] = useState(true)
  const [ordem, setOrdem] = useState<OrdemServico | null>(null)
  const [clienteSelecionado, setClienteSelecionado] = useState<Cliente | null>(null)
  const [checklist, setChecklist] = useState<ChecklistOS>({})
  const [tipoPersonalizado, setTipoPersonalizado] = useState('')
  const [mostrarCampoPersonalizado, setMostrarCampoPersonalizado] = useState(false)

  // Debug log
  console.log('📝 OrdemServicoEditPage carregada com ID:', id)

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue
  } = useForm<EditFormData>({
    resolver: zodResolver(ordemServicoEditSchema)
  })

  // Carregar dados da ordem
  useEffect(() => {
    if (id) {
      carregarOrdem()
    }
  }, [id])

  const carregarOrdem = async () => {
    if (!id) return
    
    setLoadingData(true)
    try {
      const dados = await ordemServicoService.buscarPorId(id)
      if (!dados) {
        throw new Error('Ordem não encontrada')
      }
      
      setOrdem(dados)
      
      // Verificar se a OS já foi entregue - impedir edição
      if (dados.status === 'Entregue') {
        toast.error('Esta ordem de serviço já foi entregue e não pode ser editada')
        navigate('/ordens-servico')
        return
      }
      
      // Preencher formulário
      setValue('tipo', dados.tipo)
      setValue('marca', dados.marca)
      setValue('modelo', dados.modelo)
      setValue('cor', dados.cor || '')
      setValue('numero_serie', dados.numero_serie || '')
      setValue('defeito_relatado', dados.defeito_relatado || '')
      setValue('observacoes', dados.observacoes || '')
      setValue('data_previsao', dados.data_previsao ? dados.data_previsao.split('T')[0] : '')
      setValue('valor_orcamento', dados.valor_orcamento || 0)
      setValue('valor_final', dados.valor_final || 0)
      setValue('status', dados.status)
      setValue('garantia_meses', dados.garantia_meses || 0)
      
      // Configurar checklist
      setChecklist(dados.checklist || {})
      
      // Configurar cliente (se houver relacionamento)
      if (dados.cliente) {
        setClienteSelecionado(dados.cliente)
      }
      
    } catch (error: any) {
      console.error('Erro ao carregar ordem:', error)
      toast.error('Erro ao carregar ordem de serviço')
      navigate('/ordens-servico')
    } finally {
      setLoadingData(false)
    }
  }

  // Atualizar checklist
  const atualizarChecklist = (campo: keyof ChecklistOS, valor: boolean) => {
    setChecklist(prev => ({
      ...prev,
      [campo]: valor
    }))
  }

  // Submeter formulário
  const onSubmit = async (data: EditFormData) => {
    if (!id || !ordem) {
      toast.error('Ordem de serviço não encontrada')
      return
    }

    setLoading(true)
    
    try {
      const dadosAtualizacao: Partial<OrdemServico> = {
        tipo: data.tipo,
        marca: data.marca,
        modelo: data.modelo,
        cor: data.cor,
        numero_serie: data.numero_serie,
        defeito_relatado: data.defeito_relatado,
        observacoes: data.observacoes,
        data_previsao: data.data_previsao || undefined,
        valor_orcamento: data.valor_orcamento,
        valor_final: data.valor_final,
        status: data.status,
        garantia_meses: data.garantia_meses,
        checklist
      }

      await ordemServicoService.atualizarOrdem(id, dadosAtualizacao)
      
      toast.success('Ordem de serviço atualizada com sucesso!')
      
      // Sinalizar que a lista de OS precisa ser recarregada
      localStorage.setItem('os_list_needs_refresh', 'true')
      
      navigate(`/ordens-servico/${id}`)
      
    } catch (error: any) {
      console.error('Erro ao atualizar ordem:', error)
      toast.error('Erro ao atualizar ordem de serviço')
    } finally {
      setLoading(false)
    }
  }

  if (loadingData) {
    return (
      <div className="flex justify-center items-center min-h-[400px]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p>Carregando ordem de serviço...</p>
        </div>
      </div>
    )
  }

  if (!ordem) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500 mb-4">Ordem de serviço não encontrada</p>
        <Button 
          variant="outline" 
          onClick={() => navigate('/ordens-servico')}
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Voltar para Ordens
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <BackButton customAction={() => navigate('/ordens-servico')} />
          <h1 className="text-2xl font-bold text-gray-900 mt-2">
            Editar Ordem de Serviço #{ordem.id.slice(-6)}
          </h1>
          <p className="text-gray-600">
            Edite as informações da ordem de serviço
          </p>
        </div>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Informações do Cliente */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Settings className="w-5 h-5" />
            Informações do Cliente
          </h2>
          
          <div className="space-y-4">
            <ClienteSelector
              clienteSelecionado={clienteSelecionado}
              onClienteSelect={setClienteSelecionado}
              titulo="Cliente (não pode ser alterado)"
            />
            
            {clienteSelecionado && (
              <div className="bg-gray-50 p-4 rounded-lg">
                <p><strong>Nome:</strong> {clienteSelecionado.nome}</p>
                <p><strong>Telefone:</strong> {clienteSelecionado.telefone}</p>
                {clienteSelecionado.email && (
                  <p><strong>Email:</strong> {clienteSelecionado.email}</p>
                )}
              </div>
            )}
          </div>
        </Card>

        {/* Tipo de Equipamento */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Settings className="w-5 h-5" />
            Tipo de Equipamento
          </h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Selecione o Tipo *
              </label>
              <select
                {...register('tipo')}
                onChange={(e) => {
                  const valor = e.target.value as TipoEquipamento
                  setValue('tipo', valor)
                  setMostrarCampoPersonalizado(valor === 'Outro')
                }}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                {TIPOS_EQUIPAMENTO_BASE.map(tipo => (
                  <option key={tipo.value} value={tipo.value}>
                    {tipo.label}
                  </option>
                ))}
                <option value="Outro">Outro (personalizado)</option>
              </select>
              {errors.tipo && (
                <p className="text-red-500 text-sm mt-1">{errors.tipo.message}</p>
              )}
            </div>

            {mostrarCampoPersonalizado && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Especifique o Tipo
                </label>
                <input
                  type="text"
                  value={tipoPersonalizado}
                  onChange={(e) => setTipoPersonalizado(e.target.value)}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="Ex: Smartwatch, Drone, etc."
                />
                <p className="text-xs text-gray-500 mt-1">
                  Este será usado como tipo personalizado para este equipamento
                </p>
              </div>
            )}
          </div>
        </Card>

        {/* Informações do Equipamento */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold mb-4">Informações do Equipamento</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Marca *
              </label>
              <input
                type="text"
                {...register('marca')}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Ex: Apple, Samsung, Dell..."
              />
              {errors.marca && (
                <p className="text-red-500 text-sm mt-1">{errors.marca.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Modelo *
              </label>
              <input
                type="text"
                {...register('modelo')}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Ex: iPhone 13, Galaxy S21..."
              />
              {errors.modelo && (
                <p className="text-red-500 text-sm mt-1">{errors.modelo.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Cor
              </label>
              <input
                type="text"
                {...register('cor')}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Ex: Preto, Branco, Azul..."
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Número de Série
              </label>
              <input
                type="text"
                {...register('numero_serie')}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Ex: ABC123DEF456"
              />
            </div>
          </div>
        </Card>

        {/* Status e Valores */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold mb-4">Status e Valores</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Status
              </label>
              {ordem?.status === 'Entregue' ? (
                <div className="w-full px-3 py-2 bg-green-100 border-2 border-green-500 rounded-lg">
                  <span className="text-green-800 font-semibold flex items-center gap-2">
                    ✓ Entregue (Finalizado)
                  </span>
                  <input type="hidden" {...register('status')} value="Entregue" />
                </div>
              ) : (
                <select
                  {...register('status')}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  {STATUS_OPTIONS.filter(status => status.value !== 'Entregue').map(status => (
                    <option key={status.value} value={status.value}>
                      {status.label}
                    </option>
                  ))}
                </select>
              )}
            </div>

            <div>
              <label className="text-sm font-medium text-gray-700 mb-2 flex items-center gap-1">
                <Calendar className="w-4 h-4" />
                Previsão de Entrega
              </label>
              <input
                type="date"
                {...register('data_previsao')}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="text-sm font-medium text-gray-700 mb-2 flex items-center gap-1">
                <DollarSign className="w-4 h-4" />
                Valor Orçamento
              </label>
              <input
                type="number"
                step="0.01"
                min="0"
                {...register('valor_orcamento', { valueAsNumber: true })}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="0,00"
              />
            </div>

            <div>
              <label className="text-sm font-medium text-gray-700 mb-2 flex items-center gap-1">
                <DollarSign className="w-4 h-4" />
                Valor Final
              </label>
              <input
                type="number"
                step="0.01"
                min="0"
                {...register('valor_final', { valueAsNumber: true })}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="0,00"
              />
            </div>
          </div>
        </Card>

        {/* Defeito e Observações */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold mb-4">Defeito e Observações</h2>
          
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Defeito Relatado *
              </label>
              <textarea
                {...register('defeito_relatado')}
                rows={3}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-vertical"
                placeholder="Descreva o defeito relatado pelo cliente..."
              />
              {errors.defeito_relatado && (
                <p className="text-red-500 text-sm mt-1">{errors.defeito_relatado.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Observações Técnicas
              </label>
              <textarea
                {...register('observacoes')}
                rows={4}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-vertical"
                placeholder="Observações técnicas, detalhes do reparo, peças utilizadas..."
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Garantia (meses)
              </label>
              <input
                type="number"
                min="0"
                max="60"
                {...register('garantia_meses', { valueAsNumber: true })}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="0"
              />
            </div>
          </div>
        </Card>

        {/* Checklist Técnico */}
        <Card className="p-6">
          <h2 className="text-lg font-semibold mb-4">Checklist Técnico</h2>
          
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
            {[
              { key: 'liga', label: 'Liga' },
              { key: 'tela_quebrada', label: 'Tela Quebrada' },
              { key: 'molhado', label: 'Molhado' },
              { key: 'com_senha', label: 'Com Senha' },
              { key: 'bateria_boa', label: 'Bateria Boa' },
              { key: 'tampa_presente', label: 'Tampa Presente' },
              { key: 'acessorios', label: 'Acessórios' },
              { key: 'carregador', label: 'Carregador' },
              { key: 'fone_ouvido', label: 'Fone de Ouvido' },
              { key: 'capa_pelicula', label: 'Capa/Película' }
            ].map(({ key, label }) => (
              <label key={key} className="flex items-center space-x-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={checklist[key as keyof ChecklistOS] || false}
                  onChange={(e) => atualizarChecklist(key as keyof ChecklistOS, e.target.checked)}
                  className="rounded border-gray-300 text-blue-600 focus:ring-blue-500 focus:ring-2"
                />
                <span className="text-sm font-medium text-gray-700">{label}</span>
              </label>
            ))}
          </div>
        </Card>

        {/* Botões */}
        <div className="flex justify-end space-x-4">
          <Button
            type="button"
            variant="outline"
            onClick={() => navigate(`/ordens-servico/${id}`)}
            disabled={loading}
          >
            Cancelar
          </Button>
          
          <Button
            type="submit"
            disabled={loading}
          >
            {loading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Salvando...
              </>
            ) : (
              <>
                <Save className="w-4 h-4 mr-2" />
                Salvar Alterações
              </>
            )}
          </Button>
        </div>
      </form>
    </div>
  )
}
