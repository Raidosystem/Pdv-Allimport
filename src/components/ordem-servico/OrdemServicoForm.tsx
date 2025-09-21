import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { toast } from 'react-hot-toast'
import { 
  Settings,
  Calendar,
  DollarSign,
  Save,
  History,
  Smartphone,
  Plus,
  X
} from 'lucide-react'
import { Button } from '../ui/Button'
import { Card } from '../ui/Card'
import { ClienteSelector } from '../ui/ClienteSelectorSimples'
import { ordemServicoService } from '../../services/ordemServicoService'
import type { 
  NovaOrdemServicoForm, 
  TipoEquipamento 
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
  const [checklist, setChecklist] = useState<Record<string, boolean>>({})
  const [tipoPersonalizado, setTipoPersonalizado] = useState('')
  const [mostrarCampoPersonalizado, setMostrarCampoPersonalizado] = useState(false)
  
  // Estados para checklist dinâmico
  const [itensChecklist, setItensChecklist] = useState<Array<{id: string, label: string}>>([
    { id: 'aparelho_liga', label: 'Aparelho liga?' }
  ])
  const [novoItemChecklist, setNovoItemChecklist] = useState('')
  const [mostrandoFormNovoItem, setMostrandoFormNovoItem] = useState(false)
  
  const [equipamentosAnteriores, setEquipamentosAnteriores] = useState<Array<{
    tipo: string
    marca: string
    modelo: string
    cor?: string
    defeitos: string[]
    ordens: Array<{
      id: string
      data: string
      defeito: string
      status: string
      valor?: number
    }>
    totalReparos: number
  }>>([])

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

  // Função para buscar equipamentos anteriores do cliente - BACKUP DESABILITADO
  const buscarEquipamentosAnteriores = async (_clienteId: string) => {
    console.log('🔍 BACKUP DESABILITADO - Não buscando equipamentos do backup')
    // BACKUP DESABILITADO - Retorna array vazio
    setEquipamentosAnteriores([])
  }

  // Efeito para buscar equipamentos quando cliente é selecionado
  useEffect(() => {
    console.log('👤 Cliente selecionado mudou:', clienteSelecionado)
    if (clienteSelecionado?.nome) {
      console.log('🔍 Iniciando busca para cliente Nome:', clienteSelecionado.nome)
      // Usar o nome como ID se não tiver ID
      const idParaBusca = clienteSelecionado.id || clienteSelecionado.nome
      buscarEquipamentosAnteriores(idParaBusca)
    } else {
      console.log('❌ Nenhum cliente selecionado, limpando equipamentos')
      setEquipamentosAnteriores([])
    }
  }, [clienteSelecionado])

  // Função de teste para buscar um cliente específico (apenas para debug)
  const testarBuscaCliente = async (nomeCliente: string) => {
    console.log('🧪 Testando busca para cliente:', nomeCliente)
    const clienteTeste = { nome: nomeCliente, id: nomeCliente }
    setClienteSelecionado(clienteTeste as any)
  }

  // Expor função de teste no console para debug
  useEffect(() => {
    ;(window as any).testarBuscaCliente = testarBuscaCliente
    ;(window as any).verificarEquipamentosAtual = () => {
      console.log('📊 Estado atual dos equipamentos:', equipamentosAnteriores)
      console.log('👤 Cliente atual:', clienteSelecionado)
    }
    ;(window as any).buscarEquipamentosDebug = buscarEquipamentosAnteriores
    ;(window as any).testeSimples = async () => {
      console.log('🧪 Teste simples - criando cliente fixo')
      const clienteTeste = { 
        id: 'test-id', 
        nome: 'EDVANIA DA SILVA', 
        telefone: '(11) 99999-9999',
        email: 'test@test.com'
      }
      setClienteSelecionado(clienteTeste as any)
      console.log('👤 Cliente definido:', clienteTeste)
      
      // Aguardar um pouco e buscar equipamentos
      setTimeout(() => {
        console.log('� Buscando equipamentos após 1 segundo')
        buscarEquipamentosAnteriores('EDVANIA DA SILVA')
      }, 1000)
    }
    console.log('�🛠️ Funções de teste disponíveis:')
    console.log('- window.testarBuscaCliente("EDVANIA DA SILVA")')
    console.log('- window.verificarEquipamentosAtual()')
    console.log('- window.buscarEquipamentosDebug("EDVANIA DA SILVA")')
    console.log('- window.testeSimples() // Teste com cliente fixo')
  }, [equipamentosAnteriores, clienteSelecionado])

  // Função para preencher dados do equipamento anterior
  const preencherEquipamentoAnterior = (equipamento: any) => {
    setValue('marca', equipamento.marca)
    setValue('modelo', equipamento.modelo)
    if (equipamento.cor) setValue('cor', equipamento.cor)
    
    // Tentar identificar o tipo
    const tipoEquipamento = equipamento.tipo.toLowerCase()
    if (tipoEquipamento.includes('celular') || tipoEquipamento.includes('smartphone')) {
      setValue('tipo', 'Celular')
    } else if (tipoEquipamento.includes('notebook') || tipoEquipamento.includes('laptop')) {
      setValue('tipo', 'Notebook')
    } else if (tipoEquipamento.includes('tablet')) {
      setValue('tipo', 'Tablet')
    } else if (tipoEquipamento.includes('console')) {
      setValue('tipo', 'Console')
    } else {
      setValue('tipo', 'Outro')
      setTipoPersonalizado(equipamento.tipo)
      setMostrarCampoPersonalizado(true)
    }
    
    toast.success('Dados do equipamento preenchidos!')
  }

  // Atualizar checklist
  const atualizarChecklist = (itemId: string, valor: boolean) => {
    setChecklist(prev => ({
      ...prev,
      [itemId]: valor
    }))
  }

  // Adicionar novo item ao checklist
  const adicionarItemChecklist = () => {
    if (novoItemChecklist.trim()) {
      const novoId = `item_${Date.now()}`
      setItensChecklist(prev => [...prev, { 
        id: novoId, 
        label: novoItemChecklist.trim() 
      }])
      setNovoItemChecklist('')
      setMostrandoFormNovoItem(false)
    }
  }

  // Remover item do checklist
  const removerItemChecklist = (itemId: string) => {
    setItensChecklist(prev => prev.filter(item => item.id !== itemId))
    setChecklist(prev => {
      const novoChecklist = { ...prev }
      delete novoChecklist[itemId]
      return novoChecklist
    })
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
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6" noValidate>
        
        {/* Seção: Cliente */}
        <ClienteSelector 
          onClienteSelect={setClienteSelecionado}
          clienteSelecionado={clienteSelecionado}
        />

        {/* Seção: Equipamentos Anteriores */}
        {equipamentosAnteriores.length > 0 && (
          <Card className="p-6 bg-blue-50 border-blue-200">
            <div className="flex items-center gap-2 mb-4">
              <History className="w-5 h-5 text-blue-600" />
              <h2 className="text-lg font-semibold text-gray-900">Histórico de Equipamentos</h2>
              <span className="text-sm text-gray-600">
                ({equipamentosAnteriores.length} equipamento{equipamentosAnteriores.length > 1 ? 's' : ''})
              </span>
            </div>
            
            {/* Grid responsivo para mostrar cards lado a lado - mais compacto */}
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3">
              {equipamentosAnteriores.map((equipamento, index) => (
                <div 
                  key={index}
                  className="bg-white p-3 rounded-lg border border-blue-200 hover:border-blue-400 hover:shadow-md transition-all cursor-pointer"
                  onClick={() => preencherEquipamentoAnterior(equipamento)}
                >
                  {/* Cabeçalho ultra compacto */}
                  <div className="flex items-start gap-2 mb-2">
                    <Smartphone className="w-4 h-4 text-blue-600 mt-0.5 flex-shrink-0" />
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-bold text-gray-900 truncate" title={`${equipamento.marca} ${equipamento.modelo}`}>
                        {equipamento.marca}
                      </div>
                      <div className="text-xs text-gray-600 truncate" title={equipamento.modelo}>
                        {equipamento.modelo}
                      </div>
                      <div className="text-xs text-gray-500 truncate">
                        {equipamento.tipo}
                      </div>
                    </div>
                  </div>
                  
                  {/* Badge de reparos mini */}
                  <div className="flex items-center justify-between mb-2">
                    <span className="inline-flex items-center bg-blue-100 text-blue-800 px-2 py-0.5 rounded-full text-xs font-medium">
                      {equipamento.totalReparos} rep.
                    </span>
                    {equipamento.cor && (
                      <span className="text-xs text-gray-500 truncate" title={`Cor: ${equipamento.cor}`}>
                        {equipamento.cor}
                      </span>
                    )}
                  </div>
                  
                  {/* Defeito mais recente (só 1) */}
                  {equipamento.defeitos.length > 0 && (
                    <div className="mb-2">
                      <div className="bg-orange-100 text-orange-800 px-2 py-0.5 rounded text-xs truncate" title={equipamento.defeitos[0]}>
                        {equipamento.defeitos[0].length > 20 ? 
                          equipamento.defeitos[0].substring(0, 20) + '...' : 
                          equipamento.defeitos[0]
                        }
                      </div>
                      {equipamento.defeitos.length > 1 && (
                        <div className="text-xs text-gray-400 mt-0.5">
                          +{equipamento.defeitos.length - 1} outros
                        </div>
                      )}
                    </div>
                  )}
                  
                  {/* Última ordem (ultra resumida) */}
                  {equipamento.ordens.length > 0 && (
                    <div className="bg-gray-50 p-2 rounded border-l-2 border-blue-300">
                      <div className="flex justify-between items-center mb-1">
                        <span className="text-xs text-gray-500">
                          {equipamento.ordens[0]?.data?.split('-').reverse().join('/') || '--/--'}
                        </span>
                        <span className={`text-xs px-1 py-0.5 rounded ${
                          equipamento.ordens[0]?.status === 'fechada' 
                            ? 'bg-green-100 text-green-700' 
                            : 'bg-yellow-100 text-yellow-700'
                        }`}>
                          {equipamento.ordens[0]?.status === 'fechada' ? '✓' : '⏳'}
                        </span>
                      </div>
                      {(equipamento.ordens[0]?.valor || 0) > 0 && (
                        <div className="text-xs font-medium text-green-600">
                          R$ {(equipamento.ordens[0]?.valor || 0).toFixed(0)}
                        </div>
                      )}
                    </div>
                  )}
                  
                  {/* Indicador de clique mini */}
                  <div className="text-xs text-blue-600 mt-1 text-center opacity-50 hover:opacity-100">
                    Clique aqui
                  </div>
                </div>
              ))}
            </div>
            
            <div className="mt-4 p-3 bg-blue-100 rounded-lg">
              <p className="text-sm text-blue-800">
                💡 <strong>Histórico Completo:</strong> Todos os aparelhos e reparos anteriores do cliente. 
                Clique no nome do equipamento para preencher automaticamente os dados.
              </p>
            </div>
          </Card>
        )}

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
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <Settings className="w-5 h-5 text-purple-600" />
              <h2 className="text-lg font-semibold text-gray-900">Checklist Técnico</h2>
              <span className="text-sm text-gray-500">({itensChecklist.length} itens)</span>
            </div>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setMostrandoFormNovoItem(true)}
              className="flex items-center gap-1"
            >
              <Plus className="w-4 h-4" />
              Adicionar Item
            </Button>
          </div>

          {/* Form para adicionar novo item */}
          {mostrandoFormNovoItem && (
            <div className="mb-4 p-4 bg-gray-50 rounded-lg border">
              <div className="flex gap-2">
                <input
                  type="text"
                  value={novoItemChecklist}
                  onChange={(e) => setNovoItemChecklist(e.target.value)}
                  placeholder="Ex: Tela funcionando? / Aparelho carrega? / etc..."
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  onKeyPress={(e) => e.key === 'Enter' && adicionarItemChecklist()}
                />
                <Button
                  type="button"
                  onClick={adicionarItemChecklist}
                  size="sm"
                  disabled={!novoItemChecklist.trim()}
                >
                  Adicionar
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    setMostrandoFormNovoItem(false)
                    setNovoItemChecklist('')
                  }}
                >
                  Cancelar
                </Button>
              </div>
              <p className="text-xs text-gray-500 mt-2">
                💡 Dica: Adicione verificações que você sempre faz, como "Tela quebrada?", "Aparelho liga?", etc.
              </p>
            </div>
          )}
          
          {/* Lista de itens do checklist */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {itensChecklist.map((item) => (
              <div key={item.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg border">
                <label className="flex items-center gap-2 cursor-pointer flex-1">
                  <input
                    type="checkbox"
                    checked={checklist[item.id] || false}
                    onChange={(e) => atualizarChecklist(item.id, e.target.checked)}
                    className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                  />
                  <span className="text-sm text-gray-700">{item.label}</span>
                </label>
                
                {/* Botão para remover item (só para itens personalizados) */}
                {item.id !== 'aparelho_liga' && (
                  <button
                    type="button"
                    onClick={() => removerItemChecklist(item.id)}
                    className="ml-2 p-1 text-red-500 hover:text-red-700 hover:bg-red-50 rounded"
                    title="Remover item"
                  >
                    <X className="w-3 h-3" />
                  </button>
                )}
              </div>
            ))}
            
            {/* Mensagem quando não há itens */}
            {itensChecklist.length === 0 && (
              <div className="col-span-full text-center py-8 text-gray-500">
                <Settings className="w-8 h-8 mx-auto mb-2 opacity-50" />
                <p>Nenhum item no checklist.</p>
                <p className="text-sm">Clique em "Adicionar Item" para começar.</p>
              </div>
            )}
          </div>

          {/* Sugestões rápidas */}
          {itensChecklist.length <= 3 && (
            <div className="mt-4 p-3 bg-blue-50 rounded-lg">
              <p className="text-sm text-blue-800 font-medium mb-2">💡 Sugestões de itens:</p>
              <div className="flex flex-wrap gap-2">
                {[
                  'Tela quebrada?',
                  'Aparelho molhado?', 
                  'Com senha?',
                  'Bateria boa?',
                  'Tampa presente?',
                  'Carregador entregue?'
                ].map((sugestao) => (
                  <button
                    key={sugestao}
                    type="button"
                    onClick={() => {
                      setNovoItemChecklist(sugestao)
                      setMostrandoFormNovoItem(true)
                    }}
                    className="text-xs bg-white text-blue-700 px-2 py-1 rounded border border-blue-200 hover:bg-blue-100"
                  >
                    + {sugestao}
                  </button>
                ))}
              </div>
            </div>
          )}
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
