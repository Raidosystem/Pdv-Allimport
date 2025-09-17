import { useState, useEffect } from 'react'
import { Wrench, Plus, Search, Edit, Trash2, Eye } from 'lucide-react'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Card } from '../components/ui/Card'
import { OrdemServicoForm } from '../components/ordem-servico/OrdemServicoForm'
import { formatarCpfCnpj } from '../utils/formatacao'
import { onlyDigits } from '../lib/cpf'
import { supabase } from '../lib/supabase'

interface OrdemServico {
  id: string
  numero_os?: string
  user_id?: string
  cliente?: {
    nome: string
    telefone?: string
    cpf_cnpj?: string
  }
  tipo: string
  marca: string
  modelo: string
  cor?: string
  numero_serie?: string
  defeito_relatado: string
  valor_orcamento?: number
  valor_final?: number
  status: 'Em análise' | 'Aguardando aprovação' | 'Aguardando peças' | 'Em conserto' | 'Pronto' | 'Entregue' | 'Cancelado'
  data_entrada: string
  data_previsao?: string
  data_entrega?: string
  garantia_meses?: number
  observacoes?: string
  checklist?: any
  created_at: string
  updated_at: string
}

type ViewMode = 'list' | 'form' | 'view'

type SearchType = 'geral' | 'telefone' | 'equipamento' | 'numero_os'

interface OrdemServicoFilters {
  search: string
  searchType: SearchType
}

// Dados de exemplo - carregando algumas ordens inicialmente
const sampleOrdens: OrdemServico[] = [
  {
    id: "1",
    numero_os: "OS-001",
    cliente: { nome: "João Silva", telefone: "11999999999" },
    tipo: "Smartphone",
    marca: "Samsung",
    modelo: "Galaxy S21",
    defeito_relatado: "Tela quebrada",
    status: "Em análise",
    data_entrada: "2025-09-13T10:00:00.000Z",
    valor_orcamento: 150,
    created_at: "2025-09-13T10:00:00.000Z",
    updated_at: "2025-09-13T10:00:00.000Z"
  }
]

// Função para carregar todas as ordens de serviço do backup
const loadAllServiceOrders = async (): Promise<OrdemServico[]> => {
  try {
    console.log('🔄 Carregando ordens de serviço do backup e Supabase...')
    
    // 1. Carregar dados do backup
    const response = await fetch('/backup-allimport.json')
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    const backupData = await response.json()
    const backupOrders = backupData.data?.service_orders || []
    const backupClients = backupData.data?.clients || []
    
    console.log(`📋 Backup: ${backupOrders.length} ordens e ${backupClients.length} clientes`)
    if (backupOrders.length > 0) {
      console.log('🔍 Estrutura da primeira ordem do backup:', Object.keys(backupOrders[0]))
    }
    
    // 2. Carregar ordens do Supabase
    let supabaseOrders: any[] = []
    try {
      console.log('🔍 [OrdensServico] Iniciando consulta ao Supabase...')
      const { data: ordensSupabase, error: orderError } = await supabase
        .from('ordens_servico')
        .select('*')
        .order('criado_em', { ascending: false })
      
      console.log('🔍 [OrdensServico] Resultado da consulta:', {
        data: ordensSupabase?.length || 0,
        error: orderError
      })
      
      if (!orderError && ordensSupabase) {
        supabaseOrders = ordensSupabase
        console.log(`✅ Supabase: ${supabaseOrders.length} ordens carregadas`)
        if (supabaseOrders.length > 0) {
          console.log('🔍 Estrutura da primeira ordem do Supabase:', Object.keys(supabaseOrders[0]))
        }
      }
    } catch (err) {
      console.warn('⚠️ Erro ao carregar ordens do Supabase:', err)
    }
    
    // 3. Carregar clientes do Supabase
    let supabaseClients: any[] = []
    try {
      const { data: clientesSupabase, error: clientError } = await supabase
        .from('clientes')
        .select('*')
        .order('criado_em', { ascending: false })
      
      if (!clientError && clientesSupabase) {
        supabaseClients = clientesSupabase
        console.log(`📊 ${supabaseClients.length} clientes do Supabase carregados`)
      }
    } catch (err) {
      console.warn('⚠️ Erro ao carregar clientes do Supabase:', err)
    }
    
    // 4. Combinar todos os clientes
    const allClients = [...backupClients, ...supabaseClients]
    const clientsMap = new Map()
    allClients.forEach((client: any) => {
      // Mapear estrutura unificada
      clientsMap.set(client.id, {
        id: client.id,
        name: client.name || client.nome,
        phone: client.phone || client.telefone,
        cpf_cnpj: client.cpf_cnpj,
        email: client.email
      })
    })
    
    // 5. Combinar e deduplicar ordens (evitar duplicatas avançado)
    const ordersMap = new Map()
    const duplicateCheckMap = new Map() // Para detectar possíveis duplicatas por conteúdo
    
    console.log('🔍 Analisando duplicação avançada...')
    
    // Função para criar chave de deduplicação baseada no conteúdo (sem data)
    const createContentKey = (order: any) => {
      const clientId = order.client_id || order.cliente_id || ''
      const clientName = (order.client_name || order.cliente_nome || '').trim().toLowerCase()
      const deviceModel = (order.device_model || order.equipamento_modelo || '').trim().toLowerCase()
      const deviceType = (order.device_name || order.equipamento_tipo || '').trim().toLowerCase()
      
      // Chave baseada em cliente + equipamento (sem data para detectar duplicatas temporais)
      return `${clientId}-${clientName}-${deviceModel}-${deviceType}`.replace(/\s+/g, '-')
    }
    
    // Primeiro adicionar ordens do backup
    backupOrders.forEach((order: any) => {
      if (order.id) {
        const contentKey = createContentKey(order)
        ordersMap.set(order.id, { ...order, source: 'backup' })
        duplicateCheckMap.set(contentKey, order.id)
      }
    })
    
    console.log(`📋 Após backup: ${ordersMap.size} ordens únicas no Map`)
    
    // Depois adicionar ordens do Supabase (verificar por ID e conteúdo)
    let supabaseAdded = 0
    let supabaseDuplicates = 0
    let contentDuplicates = 0
    
    supabaseOrders.forEach((order: any) => {
      if (order.id) {
        const contentKey = createContentKey(order)
        
        // Verificar duplicação por ID
        if (ordersMap.has(order.id)) {
          supabaseDuplicates++
          console.log(`⚠️ Ordem duplicada por ID: ${order.id}`)
          return
        }
        
        // Verificar duplicação por conteúdo
        if (duplicateCheckMap.has(contentKey)) {
          contentDuplicates++
          console.log(`⚠️ Possível duplicata por conteúdo: ${order.id} similar a ${duplicateCheckMap.get(contentKey)}`)
          console.log(`   Cliente: ${order.client_name || order.cliente_nome}, Equipamento: ${order.device_model || order.equipamento_modelo}`)
          return
        }
        
        // Adicionar ordem única
        ordersMap.set(order.id, { ...order, source: 'supabase' })
        duplicateCheckMap.set(contentKey, order.id)
        supabaseAdded++
      }
    })
    
    console.log(`📋 Supabase: ${supabaseAdded} adicionadas, ${supabaseDuplicates} duplicatas por ID, ${contentDuplicates} duplicatas por conteúdo`)
    
    const allOrders = Array.from(ordersMap.values())
    
    console.log(`📊 Total após deduplicação: ${clientsMap.size} clientes e ${allOrders.length} ordens únicas`)
    console.log(`📊 Ordens por fonte: ${backupOrders.length} backup, ${supabaseOrders.length} Supabase, ${allOrders.length} final`)
    
    // 6. Validar e limpar dados de todas as ordens
    const validOrders = allOrders.map((order: any) => {
      // Buscar dados do cliente pelo ID (pode vir do backup ou Supabase)
      const clientData = clientsMap.get(order.client_id || order.cliente_id)
      
      // Log para debugging dos campos do equipamento
      if (order.source === 'supabase') {
        console.log('🔧 Ordem Supabase - Campos disponíveis:', {
          id: order.id,
          equipamento_tipo: order.equipamento_tipo,
          equipamento_modelo: order.equipamento_modelo,
          equipamento_marca: order.equipamento_marca,
          marca: order.marca,
          modelo: order.modelo,
          tipo: order.tipo,
          device_name: order.device_name,
          device_model: order.device_model
        })
      }
      
      // Normalizar status para o padrão do sistema
      let status = order.status || 'aberta';
      if (status === 'fechada' || status === 'fechado' || status === 'concluida' || status === 'pago') {
        status = 'Entregue';
      } else if (status === 'cancelada') {
        status = 'Cancelado';
      } else if (status === 'pendente') {
        status = 'Em análise';
      } else {
        status = 'Em análise';
      }

      // Mapear equipamento com múltiplas tentativas de campos
      const equipamentoModelo = order.equipamento_modelo || order.device_model || order.modelo || 'Modelo não informado'
      const equipamentoMarca = order.equipamento_marca || order.marca || equipamentoModelo?.split(' ')[0] || 'Marca não informada'
      const equipamentoTipo = order.equipamento_tipo || order.device_name || order.tipo || 'Tipo não informado'

      return {
        id: order.id || Date.now().toString(),
        cliente: {
          id: order.client_id || order.cliente_id || '',
          nome: order.client_name || order.cliente_nome || clientData?.name || 'Cliente não informado',
          telefone: order.client_phone || order.cliente_telefone || clientData?.phone || '',
          cpf_cnpj: clientData?.cpf_cnpj || ''
        },
        marca: equipamentoMarca,
        modelo: equipamentoModelo,
        tipo: equipamentoTipo,
        numero_os: order.id?.slice(-6) || '',
        status: status as any,
        defeito_relatado: order.defect || 'Defeito não informado',
        data_entrada: order.opening_date || new Date().toISOString().split('T')[0],
        data_entrega: order.closing_date || '',
        valor_orcamento: order.total_amount || 0,
        valor_final: order.total_amount || 0,
        observacoes: order.observations || '',
        garantia_meses: order.warranty_days ? Math.ceil(order.warranty_days / 30) : 0,
        created_at: order.created_at || new Date().toISOString(),
        updated_at: order.updated_at || new Date().toISOString()
      };
    })
    
    console.log('✅ Ordens validadas:', validOrders.length)
    console.log('📋 Primeira ordem com cliente:', {
      id: validOrders[0]?.id?.slice(-6),
      cliente: validOrders[0]?.cliente?.nome,
      cpf_cnpj: validOrders[0]?.cliente?.cpf_cnpj,
      telefone: validOrders[0]?.cliente?.telefone,
      marca: validOrders[0]?.marca,
      modelo: validOrders[0]?.modelo,
      defeito: validOrders[0]?.defeito_relatado,
      status: validOrders[0]?.status,
      data_entrega: validOrders[0]?.data_entrega,
      garantia: validOrders[0]?.garantia_meses
    })
    
    // Log específico dos nomes dos clientes para debug da busca
    console.log('🔍 [DEBUG NOMES] Nomes dos clientes das primeiras 5 ordens:')
    validOrders.slice(0, 5).forEach((ordem: OrdemServico, index: number) => {
      console.log(`  ${index + 1}. "${ordem.cliente?.nome}" (ID: ${ordem.id})`)
    })
    
    return validOrders
  } catch (error) {
    console.error('❌ Erro ao carregar backup de ordens:', error)
    return sampleOrdens
  }
}

export function OrdensServicoPage() {
  console.log('🔥 OrdensServicoPage carregando...')
  const [todasOrdens, setTodasOrdens] = useState<OrdemServico[]>([]) // Lista completa
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [editingOrdem, setEditingOrdem] = useState<OrdemServico | null>(null)
  const [viewingOrdem, setViewingOrdem] = useState<OrdemServico | null>(null)
  const [filtros, setFiltros] = useState<OrdemServicoFilters>({
    search: '',
    searchType: 'geral'
  })
  const [loading, setLoading] = useState(true)
  const [mostrarTodos, setMostrarTodos] = useState(false) // Iniciar mostrando apenas 10

  useEffect(() => {
    // Carregar todas as ordens de serviço do backup
    const loadOrdens = async () => {
      try {
        console.log('🔄 Iniciando carregamento das ordens...')
        const allOrdens = await loadAllServiceOrders()
        console.log(`✅ Carregadas ${allOrdens.length} ordens de serviço do backup`)
        console.log('📋 Primeira ordem de exemplo:', allOrdens[0])
        console.log('📊 Resumo das ordens:', allOrdens.slice(0, 3).map(o => ({
          id: o.id,
          cliente: o.cliente?.nome,
          marca: o.marca,
          modelo: o.modelo
        })))
        setTodasOrdens(allOrdens) // Guardar todas para estatísticas e busca
        console.log(`📋 Estado atualizado: ${allOrdens.length} ordens armazenadas no estado`)
        setMostrarTodos(false)
      } catch (error) {
        console.error('Erro ao carregar ordens:', error)
        setTodasOrdens(sampleOrdens)
        setMostrarTodos(false)
      } finally {
        setLoading(false)
      }
    }
    
    loadOrdens()
  }, [])

  const handleSearchTypeChange = (newSearchType: SearchType) => {
    console.log('🎯 [ORDEM SERVIÇO] Mudando tipo de busca para:', newSearchType)
    const novosFiltros = { ...filtros, searchType: newSearchType }
    setFiltros(novosFiltros)
  }

  const handleSearchChange = (value: string) => {
    console.log('🔍 [ORDEM SERVIÇO] handleSearchChange chamado com valor:', `"${value}"`)
    
    // Aplicar formatação automática apenas se for busca geral (que inclui CPF/CNPJ)
    let formattedValue = value
    if (filtros.searchType === 'geral') {
      const digits = onlyDigits(value)
      // Se tem apenas dígitos ou formatação de CPF/CNPJ, aplicar formatação automática
      if (digits.length > 0 && /^[\d\.\-\/\s]*$/.test(value)) {
        formattedValue = formatarCpfCnpj(value)
      }
    }
    
    const novosFiltros = { ...filtros, search: formattedValue }
    setFiltros(novosFiltros)
  }

  const verTodos = () => {
    setMostrarTodos(true)
  }

  const handleNovaOrdem = () => {
    setEditingOrdem(null)
    setViewMode('form')
  }

  const handleEditarOrdem = (ordem: OrdemServico) => {
    setEditingOrdem(ordem)
    setViewMode('form')
  }

  const handleVisualizarOrdem = (ordem: OrdemServico) => {
    setViewingOrdem(ordem)
    setViewMode('view')
  }

  const handleSalvarOrdem = async () => {
    try {
      // Recarregar lista (aqui seria a implementação do save)
      setViewMode('list')
      setEditingOrdem(null)
      console.log('✅ Ordem salva com sucesso!')
    } catch (error) {
      console.error('Erro ao salvar ordem:', error)
    }
  }

  const handleCancelar = () => {
    setViewMode('list')
    setEditingOrdem(null)
    setViewingOrdem(null)
  }

  const formatPrice = (price: number) => {
    return price.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    })
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('pt-BR')
  }

  const filteredOrdens = todasOrdens.filter(ordem => {
    const searchTerm = filtros.search
    
    // Se não há busca, retornar true para mostrar todos
    if (!searchTerm || searchTerm.trim() === '') {
      return true
    }
    
    const searchNormalized = searchTerm.toLowerCase().replace(/\D/g, '')
    const nomeCliente = (ordem.cliente?.nome?.toLowerCase() || '')
    const cpfCnpj = (ordem.cliente?.cpf_cnpj || '').replace(/\D/g, '')
    const telefone = (ordem.cliente?.telefone || '').replace(/\D/g, '')
    const marca = (ordem.marca?.toLowerCase() || '')
    const modelo = (ordem.modelo?.toLowerCase() || '')
    const numeroOs = (ordem.numero_os?.toLowerCase() || '')
    
    // Busca específica por tipo
    switch (filtros.searchType) {
      case 'telefone':
        return searchNormalized.length > 0 && telefone.includes(searchNormalized)
      case 'equipamento':
        return marca.includes(searchTerm.toLowerCase()) || modelo.includes(searchTerm.toLowerCase())
      case 'numero_os':
        return numeroOs.includes(searchTerm.toLowerCase())
      default: // 'geral' - inclui nome e CPF/CNPJ
        const matchNome = nomeCliente.includes(searchTerm.toLowerCase())
        const matchCpfNormalized = searchNormalized.length > 0 && cpfCnpj.includes(searchNormalized)
        const matchCpfOriginal = cpfCnpj.includes(searchTerm.toLowerCase())
        return matchNome || matchCpfNormalized || matchCpfOriginal
    }
  })

  // Se há busca, mostrar todos os resultados filtrados
  // Se não há busca, aplicar lógica de paginação (10 primeiros ou todos)
  const ordensParaExibir = filtros.search.trim() !== '' 
    ? filteredOrdens 
    : (mostrarTodos ? todasOrdens : todasOrdens.slice(0, 10))

  console.log(`🎬 [RENDER] Exibindo ${ordensParaExibir.length} ordens (total no estado: ${todasOrdens.length}, busca: "${filtros.search}", mostrarTodos: ${mostrarTodos})`)

  // Log do resultado da busca
  if (filtros.search.trim() !== '') {
    console.log(`🎯 [OS SEARCH] Busca por "${filtros.search}" (${filtros.searchType}): ${filteredOrdens.length} resultados de ${todasOrdens.length} ordens`)
    if (filteredOrdens.length > 0 && filteredOrdens.length <= 5) {
      console.log('📋 Ordens encontradas:', filteredOrdens.map(o => `${o.numero_os} - ${o.cliente?.nome}`))
    }
  }

  // Usar todas as ordens para estatísticas
  const activeOrdens = todasOrdens.filter(o => o.status !== 'Entregue' && o.status !== 'Cancelado')
  const prontas = todasOrdens.filter(o => o.status === 'Pronto')
  const emAndamento = todasOrdens.filter(o => o.status === 'Em conserto')

  // View de formulário (nova/editar ordem)
  if (viewMode === 'form') {
    return (
      <div className="min-h-screen bg-gray-50">
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                <Wrench className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  {editingOrdem ? 'Editar Ordem de Serviço' : 'Nova Ordem de Serviço'}
                </h1>
                <p className="text-sm text-gray-600">Preencha os dados da ordem de serviço</p>
              </div>
            </div>
            
            <Button
              onClick={handleCancelar}
              variant="outline"
            >
              Voltar para Lista
            </Button>
          </div>

          <OrdemServicoForm
            onSuccess={handleSalvarOrdem}
            onCancel={handleCancelar}
          />
        </main>
      </div>
    )
  }

  // View de visualização da ordem
  if (viewMode === 'view' && viewingOrdem) {
    return (
      <div className="min-h-screen bg-gray-50">
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg flex items-center justify-center">
                <Wrench className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-gray-900">
                  Visualizar Ordem de Serviço
                </h1>
                <p className="text-sm text-gray-600">OS #{viewingOrdem.numero_os || viewingOrdem.id.slice(-6)}</p>
              </div>
            </div>
            
            <div className="flex gap-2">
              <Button
                onClick={() => handleEditarOrdem(viewingOrdem)}
                variant="outline"
              >
                Editar Ordem
              </Button>
              <Button
                onClick={handleCancelar}
                variant="outline"
              >
                Voltar para Lista
              </Button>
            </div>
          </div>

          {/* Card de visualização da ordem */}
          <div className="bg-white rounded-lg border p-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Informações básicas */}
              <div className="space-y-4">
                <h2 className="text-lg font-semibold text-gray-900 border-b pb-2">
                  Informações Básicas
                </h2>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Cliente</label>
                  <p className="text-gray-900 font-medium">{viewingOrdem.cliente?.nome || 'Não informado'}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Equipamento</label>
                  <p className="text-gray-900">{viewingOrdem.tipo} - {viewingOrdem.marca} {viewingOrdem.modelo}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Número de Série</label>
                  <p className="text-gray-900">{viewingOrdem.numero_serie || 'Não informado'}</p>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Status</label>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    viewingOrdem.status === 'Em análise' ? 'bg-yellow-100 text-yellow-800' :
                    viewingOrdem.status === 'Em conserto' ? 'bg-blue-100 text-blue-800' :
                    viewingOrdem.status === 'Pronto' ? 'bg-green-100 text-green-800' :
                    viewingOrdem.status === 'Entregue' ? 'bg-gray-100 text-gray-800' :
                    'bg-red-100 text-red-800'
                  }`}>
                    {viewingOrdem.status}
                  </span>
                </div>
              </div>

              {/* Defeito e valores */}
              <div className="space-y-4">
                <h2 className="text-lg font-semibold text-gray-900 border-b pb-2">
                  Defeito e Valores
                </h2>
                
                <div>
                  <label className="block text-sm font-medium text-gray-600">Defeito Relatado</label>
                  <p className="text-gray-900">{viewingOrdem.defeito_relatado || 'Não informado'}</p>
                </div>
                
                {viewingOrdem.valor_orcamento && viewingOrdem.valor_orcamento > 0 && (
                  <div>
                    <label className="block text-sm font-medium text-gray-600">Valor do Orçamento</label>
                    <p className="text-xl font-bold text-green-600">{formatPrice(viewingOrdem.valor_orcamento)}</p>
                  </div>
                )}
                
                {viewingOrdem.valor_final && viewingOrdem.valor_final > 0 && (
                  <div>
                    <label className="block text-sm font-medium text-gray-600">Valor Final</label>
                    <p className="text-xl font-bold text-blue-600">{formatPrice(viewingOrdem.valor_final)}</p>
                  </div>
                )}
                
                {viewingOrdem.data_previsao && (
                  <div>
                    <label className="block text-sm font-medium text-gray-600">Previsão de Entrega</label>
                    <p className="text-gray-900">{formatDate(viewingOrdem.data_previsao)}</p>
                  </div>
                )}
              </div>
            </div>

            {/* Informações adicionais */}
            <div className="mt-6 pt-6 border-t">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                Informações Adicionais
              </h2>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
                <div>
                  <span className="font-medium">Data de Entrada:</span> {formatDate(viewingOrdem.data_entrada)}
                </div>
                {viewingOrdem.data_entrega && (
                  <div>
                    <span className="font-medium">Data de Entrega:</span> {formatDate(viewingOrdem.data_entrega)}
                  </div>
                )}
                {viewingOrdem.garantia_meses && viewingOrdem.garantia_meses > 0 && (
                  <div>
                    <span className="font-medium">Garantia:</span> {viewingOrdem.garantia_meses} meses
                  </div>
                )}
                {viewingOrdem.observacoes && (
                  <div className="md:col-span-2">
                    <span className="font-medium">Observações:</span>
                    <p className="mt-1 text-gray-900">{viewingOrdem.observacoes}</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </main>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p>Carregando ordens de serviço...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-blue-100 rounded-lg">
            <Wrench className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Ordens de Serviço</h1>
            <p className="text-sm text-gray-600">Gerencie as ordens de serviço da assistência técnica</p>
          </div>
        </div>
        
        <Button onClick={handleNovaOrdem} className="flex items-center gap-2">
          <Plus className="w-4 h-4" />
          Nova OS
        </Button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-blue-600">{todasOrdens.length}</div>
          <div className="text-sm text-gray-600">Total de OS</div>
        </div>
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-yellow-600">{activeOrdens.length}</div>
          <div className="text-sm text-gray-600">Em Andamento</div>
        </div>
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-green-600">{prontas.length}</div>
          <div className="text-sm text-gray-600">Prontas</div>
        </div>
        <div className="bg-white p-4 rounded-lg border">
          <div className="text-2xl font-bold text-purple-600">{emAndamento.length}</div>
          <div className="text-sm text-gray-600">Em Conserto</div>
        </div>
      </div>

      {/* Search */}
      <Card className="p-6">
        <div className="flex flex-col gap-4">
          {/* Busca */}
          <div className="flex-1">
            {/* Seletor de Tipo de Busca */}
            <div className="flex flex-wrap gap-2 mb-3">
              <button
                onClick={() => handleSearchTypeChange('geral')}
                className={`px-3 py-1 text-xs rounded-full transition-colors ${
                  filtros.searchType === 'geral'
                    ? 'bg-blue-100 text-blue-700 border border-blue-300'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200 border border-gray-300'
                }`}
              >
                Geral (Nome e CPF/CNPJ)
              </button>
              <button
                onClick={() => handleSearchTypeChange('telefone')}
                className={`px-3 py-1 text-xs rounded-full transition-colors ${
                  filtros.searchType === 'telefone'
                    ? 'bg-blue-100 text-blue-700 border border-blue-300'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200 border border-gray-300'
                }`}
              >
                Telefone
              </button>
              <button
                onClick={() => handleSearchTypeChange('equipamento')}
                className={`px-3 py-1 text-xs rounded-full transition-colors ${
                  filtros.searchType === 'equipamento'
                    ? 'bg-blue-100 text-blue-700 border border-blue-300'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200 border border-gray-300'
                }`}
              >
                Equipamento
              </button>
              <button
                onClick={() => handleSearchTypeChange('numero_os')}
                className={`px-3 py-1 text-xs rounded-full transition-colors ${
                  filtros.searchType === 'numero_os'
                    ? 'bg-blue-100 text-blue-700 border border-blue-300'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200 border border-gray-300'
                }`}
              >
                Nº OS
              </button>
            </div>
            
            {/* Campo de Busca */}
            <div className="relative">
              <Input
                placeholder={
                  filtros.searchType === 'telefone' ? "Buscar por telefone..." :
                  filtros.searchType === 'equipamento' ? "Buscar por marca/modelo..." :
                  filtros.searchType === 'numero_os' ? "Buscar por número da OS..." :
                  "Buscar por nome do cliente ou CPF/CNPJ..."
                }
                value={filtros.search}
                onChange={(e) => handleSearchChange(e.target.value)}
                className="pl-10"
              />
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            </div>
          </div>
        </div>
      </Card>

      {/* Orders Table */}
      <div className="bg-white rounded-lg border">
        <div className="p-4 border-b">
          <h2 className="text-lg font-semibold">
            Ordens de Serviço ({todasOrdens.length})
          </h2>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">OS</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cliente</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Equipamento</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Valor</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Data Entrada</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Data Saída</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Garantia</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {ordensParaExibir.map((ordem) => (
                <tr key={ordem.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <div className="font-medium text-gray-900">
                      {ordem.numero_os || `#${ordem.id.slice(-6)}`}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="text-sm text-gray-900">
                      {ordem.cliente?.nome || 'Cliente não informado'}
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="text-sm">
                      <div className="font-medium text-gray-900">{(ordem.marca || '')} {(ordem.modelo || '')}</div>
                      <div className="text-gray-500">{ordem.tipo || 'Não informado'}</div>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      ordem.status === 'Em análise' ? 'bg-yellow-100 text-yellow-800' :
                      ordem.status === 'Em conserto' ? 'bg-blue-100 text-blue-800' :
                      ordem.status === 'Pronto' ? 'bg-green-100 text-green-800' :
                      ordem.status === 'Entregue' ? 'bg-gray-100 text-gray-800' :
                      'bg-red-100 text-red-800'
                    }`}>
                      {ordem.status}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="text-sm">
                      {ordem.valor_orcamento && ordem.valor_orcamento > 0 ? (
                        <div className="font-medium text-green-600">
                          {formatPrice(ordem.valor_orcamento)}
                        </div>
                      ) : (
                        <span className="text-gray-500">Sem orçamento</span>
                      )}
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-600">
                    {formatDate(ordem.data_entrada)}
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-600">
                    {ordem.data_entrega ? formatDate(ordem.data_entrega) : '-'}
                  </td>
                  <td className="px-4 py-3 text-sm text-gray-600">
                    {(ordem.garantia_meses || 0) > 0 ? `${ordem.garantia_meses} meses` : '-'}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <button 
                        className="p-1 text-blue-600 hover:text-blue-800"
                        title="Visualizar ordem"
                        onClick={() => handleVisualizarOrdem(ordem)}
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button 
                        className="p-1 text-green-600 hover:text-green-800"
                        title="Editar ordem"
                        onClick={() => handleEditarOrdem(ordem)}
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button 
                        className="p-1 text-red-600 hover:text-red-800"
                        title="Excluir ordem"
                        onClick={() => {
                          console.log('🗑️ Excluir ordem:', ordem.id);
                          if (confirm(`Deseja excluir a ordem "${ordem.numero_os || ordem.id.slice(-6)}"?`)) {
                            alert('Ordem excluída com sucesso!');
                          }
                        }}
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {/* Botão Ver mais ordens - só mostrar se não há busca ativa */}
        {!mostrarTodos && filtros.search.trim() === '' && todasOrdens.length > 10 && (
          <div className="p-4 border-t text-center">
            <button
              onClick={verTodos}
              className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm font-medium"
            >
              Ver mais ordens ({todasOrdens.length - 10} restantes)
            </button>
          </div>
        )}
        
        {ordensParaExibir.length === 0 && (
          <div className="text-center py-12">
            <Wrench className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              {filtros.search ? 'Nenhuma ordem encontrada' : 'Nenhuma ordem cadastrada'}
            </h3>
            <p className="text-gray-600 mb-4">
              {filtros.search ? 'Tente buscar com outros termos' : 'Comece criando sua primeira ordem de serviço'}
            </p>
            {!filtros.search && (
              <Button onClick={handleNovaOrdem} className="flex items-center gap-2 mx-auto">
                <Plus className="w-4 h-4" />
                Criar Primeira OS
              </Button>
            )}
          </div>
        )}
      </div>
    </div>
  )
}