import { useState, useEffect } from 'react'
import { Wrench, Plus, Search, Edit, Trash2, Eye, Printer, X, Lock } from 'lucide-react'
import { toast } from 'react-hot-toast'
import { Button } from '../components/ui/Button'
import { Input } from '../components/ui/Input'
import { Card } from '../components/ui/Card'
import { OrdemServicoForm } from '../components/ordem-servico/OrdemServicoForm'
import { formatarCpfCnpj } from '../utils/formatacao'
import { onlyDigits } from '../lib/cpf'
import { supabase } from '../lib/supabase'
import { usePermissions } from '../hooks/usePermissions'

interface OrdemServico {
  id: string
  numero_os?: string
  user_id?: string
  cliente_id?: string
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
  status: 'Em análise' | 'Orçamento' | 'Aguardando aprovação' | 'Aguardando peças' | 'Em conserto' | 'Pronto' | 'Entregue' | 'Cancelado'
  data_entrada: string
  data_previsao?: string
  data_entrega?: string
  data_finalizacao?: string
  garantia_meses?: number
  observacoes?: string
  checklist?: any
  senha_aparelho?: {
    tipo: 'nenhuma' | 'texto' | 'pin' | 'desenho'
    valor: string | null
  } | null
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

// Função para carregar todas as ordens de serviço - BACKUP DESABILITADO
const loadAllServiceOrders = async (): Promise<OrdemServico[]> => {
  try {
    console.log('🔄 BACKUP DESABILITADO - Carregando ordens apenas do Supabase...')
    
    /*
    // 1. Carregar dados do backup - DESABILITADO
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
    */
    
    // Carregar ordens apenas do Supabase (respeitando RLS)
    let supabaseOrders: any[] = []
    try {
      console.log('🔍 [OrdensServico] Iniciando consulta ao Supabase...')
      const { data: ordensSupabase, error: orderError } = await supabase
        .from('ordens_servico')
        .select(`
          *,
          cor,
          numero_serie,
          senha_aparelho,
          checklist,
          clientes(*)
        `)
        .order('data_entrada', { ascending: false })
      
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
    
    // Usar apenas clientes do Supabase (respeitando RLS)
    const allClients = [...supabaseClients]
    console.log('🔍 [OS] BACKUP DESABILITADO - Usando apenas clientes do Supabase')
    
    /*
    // 4. Combinar todos os clientes - BACKUP DESABILITADO
    const allClients = [...backupClients, ...supabaseClients]
    */
    
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
    
    // Usar apenas ordens do Supabase (respeitando RLS)
    const ordersMap = new Map()
    console.log('🔍 [OS] BACKUP DESABILITADO - Usando apenas ordens do Supabase')
    
    /*
    // 5. Combinar e deduplicar ordens (evitar duplicatas avançado) - BACKUP DESABILITADO
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
    */
    
    // Adicionar apenas ordens do Supabase
    supabaseOrders.forEach((order: any) => {
      if (order.id) {
        ordersMap.set(order.id, { ...order, source: 'supabase' })
      }
    })
    
    const allOrders = Array.from(ordersMap.values())
    
    console.log(`📊 Total após usar apenas Supabase: ${clientsMap.size} clientes e ${allOrders.length} ordens`)
    console.log(`📊 Ordens do Supabase: ${supabaseOrders.length} → ${allOrders.length} final`)
    
    // 6. Validar e limpar dados de todas as ordens
    
    // 🆕 ANÁLISE CRÍTICA: Verificar quantas ordens têm cliente_id
    const ordensComCliente = allOrders.filter((o: any) => o.cliente_id || o.client_id).length
    const ordensComClientName = allOrders.filter((o: any) => o.client_name || o.cliente_nome).length
    console.log('🚨 [ANÁLISE CRÍTICA DAS ORDENS]')
    console.log(`   Total de ordens: ${allOrders.length}`)
    console.log(`   Ordens COM cliente_id: ${ordensComCliente}`)
    console.log(`   Ordens COM client_name: ${ordensComClientName}`)
    console.log('   Exemplo de ordem COM cliente_id:', allOrders.find((o: any) => o.cliente_id || o.client_id))
    console.log('   Exemplo de ordem SEM cliente_id:', allOrders.find((o: any) => !(o.cliente_id || o.client_id)))
    
    const validOrders = allOrders.map((order: any) => {
      // Buscar dados do cliente pelo ID (pode vir do backup ou Supabase)
      const clientData = clientsMap.get(order.client_id || order.cliente_id)
      
      // Log para debugging dos campos do equipamento (apenas primeiras 10 ordens)
      if (order.source === 'supabase' && allOrders.indexOf(order) < 10) {
        console.log('🔧 Ordem Supabase - Campos disponíveis:', {
          id: order.id,
          cliente_id: order.cliente_id,
          client_id: order.client_id,
          client_name: order.client_name,
          cliente_nome: order.cliente_nome,
          clientes: order.clientes, // ← VERIFICAR SE O JOIN ESTÁ FUNCIONANDO!
          equipamento_tipo: order.equipamento_tipo,
          equipamento_modelo: order.equipamento_modelo,
          equipamento_marca: order.equipamento_marca,
          marca: order.marca,
          modelo: order.modelo,
          tipo: order.tipo
        })
      }
      
      // Normalizar status para o padrão do sistema
      let status = order.status || 'Em análise';
      
      // Se já está em um dos status válidos, manter
      const statusValidos = ['Em análise', 'Aguardando aprovação', 'Aguardando peças', 'Em conserto', 'Pronto', 'Entregue', 'Cancelado'];
      if (!statusValidos.includes(status)) {
        // Mapear status antigos
        if (status === 'fechada' || status === 'fechado' || status === 'concluida' || status === 'pago') {
          status = 'Entregue';
        } else if (status === 'cancelada') {
          status = 'Cancelado';
        } else if (status === 'pendente' || status === 'aberta') {
          status = 'Em análise';
        } else {
          status = 'Em análise';
        }
      }

      // Mapear equipamento com múltiplas tentativas de campos
      const equipamentoModelo = order.equipamento_modelo || order.device_model || order.modelo || 'Modelo não informado'
      const equipamentoMarca = order.equipamento_marca || order.marca || equipamentoModelo?.split(' ')[0] || 'Marca não informada'
      const equipamentoTipo = order.equipamento_tipo || order.device_name || order.tipo || 'Tipo não informado'

      return {
        id: order.id || Date.now().toString(),
        cliente_id: order.cliente_id || order.client_id || order.clientes?.id || '',
        cliente: {
          id: order.cliente_id || order.client_id || order.clientes?.id || '',
          nome: order.clientes?.nome || order.client_name || order.cliente_nome || clientData?.name || 'Cliente não informado',
          telefone: order.clientes?.telefone || order.client_phone || order.cliente_telefone || clientData?.phone || '',
          cpf_cnpj: order.clientes?.cpf_cnpj || clientData?.cpf_cnpj || ''
        },
        marca: equipamentoMarca,
        modelo: equipamentoModelo,
        tipo: equipamentoTipo,
        numero_os: order.numero_os || order.id?.slice(-6) || '',
        status: status as any,
        defeito_relatado: order.defeito_relatado || order.defect || 'Defeito não informado',
        data_entrada: order.data_entrada || order.opening_date || new Date().toISOString().split('T')[0],
        data_entrega: order.data_entrega || order.closing_date || '',
        valor_orcamento: order.valor_orcamento || order.total_amount || undefined,
        valor_final: order.valor_final || order.total_amount || undefined,
        observacoes: order.observacoes || order.observations || '',
        garantia_meses: order.garantia_meses || (order.warranty_days ? Math.ceil(order.warranty_days / 30) : undefined),
        created_at: order.criado_em || order.created_at || new Date().toISOString(),
        updated_at: order.atualizado_em || order.updated_at || new Date().toISOString(),
        // ✅ Campos adicionais do equipamento
        cor: order.cor || '',
        numero_serie: order.numero_serie || '',
        senha_aparelho: order.senha_aparelho || null,
        checklist: order.checklist || null
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
  const { can } = usePermissions()
  
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
  const [showEncerrarModal, setShowEncerrarModal] = useState(false)
  const [ordemParaEncerrar, setOrdemParaEncerrar] = useState<OrdemServico | null>(null)
  const [garantiaMeses, setGarantiaMeses] = useState<number>(3)
  const [garantiaPersonalizada, setGarantiaPersonalizada] = useState<string>('')
  const [servicoRealizado, setServicoRealizado] = useState<string>('')
  const [resultadoReparo, setResultadoReparo] = useState<'reparado' | 'sem_reparo' | 'condenado'>('reparado')

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
    console.log('✏️ [EDITAR] Ordem selecionada para edição:', ordem)
    setEditingOrdem(ordem)
    setViewMode('form')
  }

  const handleVisualizarOrdem = (ordem: OrdemServico) => {
    setViewingOrdem(ordem)
    setViewMode('view')
  }

  const handleSalvarOrdem = async (ordemSalva?: any) => {
    try {
      console.log('💾 [SALVAR] Ordem salva:', ordemSalva)
      
      // Recarregar a lista de ordens
      const allOrdens = await loadAllServiceOrders()
      setTodasOrdens(allOrdens)
      
      setViewMode('list')
      setEditingOrdem(null)
      
      toast.success(editingOrdem ? 'Ordem atualizada com sucesso!' : 'Ordem criada com sucesso!')
      console.log('✅ Ordem salva e lista recarregada!')
    } catch (error) {
      console.error('❌ Erro ao salvar ordem:', error)
      toast.error('Erro ao salvar ordem')
    }
  }

  const handleCancelar = () => {
    setViewMode('list')
    setEditingOrdem(null)
    setViewingOrdem(null)
  }

  const handleEncerrarOrdem = async (ordem: OrdemServico) => {
    setOrdemParaEncerrar(ordem)
    setGarantiaMeses(ordem.garantia_meses || 3)
    setGarantiaPersonalizada('')
    setServicoRealizado('') // Sempre vazio para o usuário preencher manualmente
    setResultadoReparo('reparado') // Resetar para o padrão
    setShowEncerrarModal(true)
  }

  const confirmarEncerramentoOrdem = async () => {
    if (!ordemParaEncerrar) return
    
    try {
      // Só aplicar garantia se foi reparado
      const garantiaFinal = resultadoReparo === 'reparado' 
        ? (garantiaPersonalizada.trim() !== '' ? parseInt(garantiaPersonalizada) : garantiaMeses)
        : 0

      // Registrar timestamps: ISO para DB, localizado para UI
      const dataFinalISO = new Date().toISOString()
      const dataFinalDisplay = new Date().toLocaleString('pt-BR')

      console.log('🔧 [DEBUG ENCERRAMENTO]', {
        resultadoReparo,
        garantiaPersonalizada,
        garantiaMeses,
        garantiaFinal,
        tipo: typeof garantiaFinal
      })

      const { error } = await supabase
        .from('ordens_servico')
        .update({ 
          status: 'Entregue',
          data_finalizacao: dataFinalISO,
          data_entrega: dataFinalISO,
          garantia_meses: garantiaFinal,
          observacoes: servicoRealizado
        })
        .eq('id', ordemParaEncerrar.id)

      if (error) throw error

      // Atualizar a ordem no estado local (usar formato localizado para exibição imediata)
      const ordemAtualizada = {
        ...ordemParaEncerrar,
        status: 'Entregue' as any,
        garantia_meses: garantiaFinal,
        observacoes: servicoRealizado,
        data_finalizacao: dataFinalDisplay,
        data_entrega: dataFinalDisplay
      }
      
      console.log('📄 [DEBUG IMPRESSÃO] Ordem a ser impressa:', {
        id: ordemAtualizada.id,
        garantia_meses: ordemAtualizada.garantia_meses,
        resultadoReparo: resultadoReparo,
        tipo: typeof ordemAtualizada.garantia_meses
      })
      
      setTodasOrdens(prev => 
        prev.map(o => 
          o.id === ordemParaEncerrar.id 
            ? ordemAtualizada
            : o
        )
      )
      
      // Atualizar a ordem sendo visualizada
      if (viewingOrdem?.id === ordemParaEncerrar.id) {
        setViewingOrdem(ordemAtualizada)
      }
      
      setShowEncerrarModal(false)
      
      // Perguntar se deseja imprimir
      const desejaImprimir = window.confirm('✅ Ordem encerrada com sucesso!\n\nDeseja imprimir o comprovante de entrega?')
      if (desejaImprimir) {
        imprimirComprovanteEntrega(ordemAtualizada)
      }
    } catch (error) {
      console.error('Erro ao encerrar ordem:', error)
      alert('❌ Erro ao encerrar ordem. Tente novamente.')
    }
  }

  const imprimirComprovanteEntrega = async (ordem: OrdemServico) => {
    console.log('🖨️ [DEBUG IMPRESSÃO] Iniciando impressão com garantia:', {
      garantia_meses: ordem.garantia_meses,
      tipo: typeof ordem.garantia_meses,
      ordem_completa: ordem
    })
    
    // Buscar configurações de impressão
    let cabecalho = 'COMPROVANTE DE ENTREGA'
    let rodape = 'Obrigado pela preferência!'
    
    try {
      const { data: user } = await supabase.auth.getUser()
      if (user?.user) {
        const { data: config } = await supabase
          .from('configuracoes_impressao')
          .select('cabecalho, rodape')
          .eq('user_id', user.user.id)
          .single()
        
        if (config) {
          cabecalho = config.cabecalho || cabecalho
          rodape = config.rodape || rodape
          console.log('✅ [IMPRESSÃO] Configurações carregadas:', { cabecalho, rodape })
        }
      }
    } catch (error) {
      console.log('⚠️ [IMPRESSÃO] Usando configurações padrão:', error)
    }
    
    const dataEntrega = new Date().toLocaleDateString('pt-BR')
    const dataGarantia = new Date()
    const mesesGarantia = ordem.garantia_meses || 3
    dataGarantia.setMonth(dataGarantia.getMonth() + mesesGarantia)
    const dataGarantiaFormatada = dataGarantia.toLocaleDateString('pt-BR')
    
    console.log('📅 [DEBUG IMPRESSÃO] Cálculo de garantia:', {
      mesesGarantia,
      dataEntrega,
      dataGarantiaFormatada
    })
    
    const conteudo = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Comprovante de Entrega - OS ${ordem.numero_os || ordem.id.slice(-6)}</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            padding: 20mm;
            max-width: 210mm;
            margin: 0 auto;
          }
          .header {
            text-align: center;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
            margin-bottom: 20px;
          }
          .header h1 {
            margin: 0;
            font-size: 24px;
          }
          .header p {
            margin: 5px 0;
            color: #666;
          }
          .info-section {
            margin-bottom: 20px;
          }
          .info-section h2 {
            font-size: 16px;
            color: #333;
            border-bottom: 1px solid #ddd;
            padding-bottom: 5px;
            margin-bottom: 10px;
          }
          .info-row {
            display: flex;
            margin-bottom: 8px;
          }
          .info-label {
            font-weight: bold;
            width: 180px;
            color: #555;
          }
          .info-value {
            flex: 1;
            color: #333;
          }
          .garantia-box {
            background-color: #f0f9ff;
            border: 2px solid #3b82f6;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
          }
          .garantia-box h3 {
            margin: 0 0 10px 0;
            color: #1e40af;
          }
          .garantia-box p {
            margin: 5px 0;
            font-size: 14px;
          }
          .assinaturas {
            margin-top: 50px;
            display: flex;
            justify-content: space-between;
          }
          .assinatura {
            width: 45%;
            text-align: center;
          }
          .assinatura-linha {
            border-top: 1px solid #333;
            margin-top: 60px;
            padding-top: 5px;
          }
          .footer {
            margin-top: 30px;
            text-align: center;
            font-size: 12px;
            color: #666;
            white-space: pre-line;
          }
          @media print {
            body {
              padding: 10mm;
            }
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>${cabecalho}</h1>
          <p>Ordem de Serviço: <strong>#${ordem.numero_os || ordem.id.slice(-6)}</strong></p>
          <p>Data de Entrega: ${dataEntrega}</p>
        </div>

        <div class="info-section">
          <h2>Dados do Cliente</h2>
          <div class="info-row">
            <span class="info-label">Nome:</span>
            <span class="info-value">${ordem.cliente?.nome || 'Não informado'}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Telefone:</span>
            <span class="info-value">${ordem.cliente?.telefone || 'Não informado'}</span>
          </div>
          ${ordem.cliente?.cpf_cnpj ? `
          <div class="info-row">
            <span class="info-label">CPF/CNPJ:</span>
            <span class="info-value">${formatarCpfCnpj(ordem.cliente.cpf_cnpj)}</span>
          </div>
          ` : ''}
        </div>

        <div class="info-section">
          <h2>Dados do Equipamento</h2>
          <div class="info-row">
            <span class="info-label">Tipo:</span>
            <span class="info-value">${ordem.tipo}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Marca:</span>
            <span class="info-value">${ordem.marca}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Modelo:</span>
            <span class="info-value">${ordem.modelo}</span>
          </div>
          ${ordem.cor ? `
          <div class="info-row">
            <span class="info-label">Cor:</span>
            <span class="info-value">${ordem.cor}</span>
          </div>
          ` : ''}
          ${ordem.numero_serie ? `
          <div class="info-row">
            <span class="info-label">Número de Série:</span>
            <span class="info-value">${ordem.numero_serie}</span>
          </div>
          ` : ''}
        </div>

        <div class="info-section">
          <h2>Serviço Realizado</h2>
          <div class="info-row">
            <span class="info-label">Defeito Relatado:</span>
            <span class="info-value">${ordem.defeito_relatado}</span>
          </div>
          ${ordem.observacoes ? `
          <div class="info-row">
            <span class="info-label">Serviço Executado:</span>
            <span class="info-value">${ordem.observacoes}</span>
          </div>
          ` : ''}
          ${ordem.valor_final && ordem.valor_final > 0 ? `
          <div class="info-row">
            <span class="info-label">Valor Total:</span>
            <span class="info-value">R$ ${ordem.valor_final.toFixed(2).replace('.', ',')}</span>
          </div>
          ` : ''}
        </div>

        ${ordem.garantia_meses && ordem.garantia_meses > 0 ? `
        <div class="garantia-box">
          <h3>⚠️ GARANTIA DO SERVIÇO</h3>
          <p><strong>Prazo de Garantia:</strong> ${ordem.garantia_meses} ${ordem.garantia_meses === 1 ? 'mês' : 'meses'}</p>
          <p><strong>Válida até:</strong> ${dataGarantiaFormatada}</p>
          <p style="margin-top: 10px; font-size: 12px;">
            A garantia cobre defeitos relacionados ao serviço executado. 
            Não cobre danos causados por mau uso, quedas, água ou modificações não autorizadas.
          </p>
        </div>
        ` : ''}

        <div class="assinaturas">
          <div class="assinatura">
            <div class="assinatura-linha">
              Assinatura do Cliente
            </div>
          </div>
          <div class="assinatura">
            <div class="assinatura-linha">
              Assinatura da Empresa
            </div>
          </div>
        </div>

        <div class="footer">
          ${rodape}
        </div>

        <script>
          window.onload = function() {
            window.print();
          }
        </script>
      </body>
      </html>
    `
    
    const janelaImpressao = window.open('', '_blank')
    if (janelaImpressao) {
      janelaImpressao.document.write(conteudo)
      janelaImpressao.document.close()
    }
  }

  const formatPrice = (price: number) => {
    return price.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    })
  }

  const formatDate = (dateString: string) => {
    if (!dateString) return '-'
    
    // Se já está formatado (contém "/"), retornar direto
    if (dateString.includes('/')) {
      return dateString.split(' ')[0] // Pegar só a data, sem hora
    }
    
    // Caso contrário, formatar ISO para pt-BR
    try {
      return new Date(dateString).toLocaleDateString('pt-BR')
    } catch (e) {
      return dateString
    }
  }

  const formatDateTime = (dateString: string) => {
    if (!dateString) return '-'
    
    // Se já está formatado (contém "/"), retornar direto
    if (dateString.includes('/')) {
      return dateString
    }
    
    // Caso contrário, formatar ISO para pt-BR
    try {
      return new Date(dateString).toLocaleString('pt-BR')
    } catch (e) {
      return dateString
    }
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
    console.log('📝 [FORM MODE] editingOrdem:', editingOrdem ? `ID: ${editingOrdem.id}` : 'null')
    
    return (
      <>
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
                  <p className="text-sm text-gray-600">
                    {editingOrdem 
                      ? `Editando OS #${editingOrdem.numero_os || editingOrdem.id?.slice(-6)}`
                      : 'Preencha os dados da ordem de serviço'
                    }
                  </p>
                </div>
              </div>
              
              <Button
                onClick={handleCancelar}
                className="bg-orange-600 hover:bg-orange-700 text-white"
              >
                Voltar para Lista
              </Button>
            </div>

            <OrdemServicoForm
              key={editingOrdem?.id || 'new'}
              ordem={editingOrdem}
              onSuccess={handleSalvarOrdem}
              onCancel={handleCancelar}
            />
          </main>
        </div>

        {/* Modal de Encerramento */}
        {showEncerrarModal && ordemParaEncerrar && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
              <div className="p-6">
                {/* Header do Modal */}
                <div className="flex items-center justify-between mb-6">
                  <div>
                    <h2 className="text-2xl font-bold text-gray-900">Encerrar Ordem de Serviço</h2>
                    <p className="text-sm text-gray-600 mt-1">
                      OS #{ordemParaEncerrar.numero_os || ordemParaEncerrar.id.slice(-6)}
                    </p>
                  </div>
                  <button
                    onClick={() => setShowEncerrarModal(false)}
                    className="text-gray-400 hover:text-gray-600 transition-colors"
                  >
                    <X className="w-6 h-6" />
                  </button>
                </div>

                {/* Informações do Equipamento */}
                <div className="bg-blue-50 rounded-lg p-4 mb-6">
                  <h3 className="font-semibold text-blue-900 mb-2">Equipamento</h3>
                  <div className="space-y-1 text-sm">
                    <p><span className="font-medium">Cliente:</span> {ordemParaEncerrar.cliente?.nome}</p>
                    <p><span className="font-medium">Equipamento:</span> {ordemParaEncerrar.marca} {ordemParaEncerrar.modelo}</p>
                    <p><span className="font-medium">Defeito:</span> {ordemParaEncerrar.defeito_relatado}</p>
                  </div>
                </div>

                {/* Formulário de Encerramento */}
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Serviço Realizado *
                    </label>
                    <textarea
                      value={servicoRealizado}
                      onChange={(e) => setServicoRealizado(e.target.value)}
                      placeholder="Descreva o serviço que foi executado..."
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 min-h-[100px]"
                      required
                    />
                    <p className="text-xs text-gray-500 mt-1">
                      Esta informação será incluída no comprovante de entrega
                    </p>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Garantia do Serviço *
                    </label>
                    <div className="grid grid-cols-4 gap-2 mb-3">
                      {[1, 3, 6, 12].map((meses) => (
                        <button
                          key={meses}
                          type="button"
                          onClick={() => {
                            setGarantiaMeses(meses)
                            setGarantiaPersonalizada('')
                          }}
                          className={`px-4 py-3 rounded-lg border-2 transition-all ${
                            garantiaMeses === meses && garantiaPersonalizada === ''
                              ? 'border-blue-600 bg-blue-50 text-blue-700 font-semibold'
                              : 'border-gray-300 hover:border-gray-400 text-gray-700'
                          }`}
                        >
                          {meses} {meses === 1 ? 'mês' : 'meses'}
                        </button>
                      ))}
                    </div>
                    
                    <div className="bg-orange-50 border-2 border-orange-400 rounded-lg p-3">
                      <label className="block text-sm font-medium text-orange-700 mb-2">
                        Meses Personalizados da Garantia
                      </label>
                      <div className="relative">
                        <input
                          type="number"
                          min="1"
                          max="120"
                          value={garantiaPersonalizada}
                          onChange={(e) => setGarantiaPersonalizada(e.target.value)}
                          placeholder="Digite o mês"
                          className="w-full px-3 py-2 border-2 border-orange-400 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                        />
                        <span className="absolute right-3 top-2 text-sm text-gray-500">meses</span>
                      </div>
                    </div>
                  </div>

                  {/* Preview da Garantia */}
                  <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                    <div className="flex items-start gap-3">
                      <div className="text-green-600 text-2xl">✓</div>
                      <div className="flex-1">
                        <h4 className="font-semibold text-green-900 mb-1">Garantia do Serviço</h4>
                        <p className="text-sm text-green-700">
                          O equipamento terá <strong>{garantiaPersonalizada || garantiaMeses} {(garantiaPersonalizada ? parseInt(garantiaPersonalizada) : garantiaMeses) === 1 ? 'mês' : 'meses'}</strong> de garantia
                        </p>
                        <p className="text-xs text-green-600 mt-1">
                          Válida até: {new Date(new Date().setMonth(new Date().getMonth() + (garantiaPersonalizada ? parseInt(garantiaPersonalizada) : garantiaMeses))).toLocaleDateString('pt-BR')}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Ações do Modal */}
                <div className="flex gap-3 mt-6 pt-6 border-t">
                  <Button
                    onClick={() => setShowEncerrarModal(false)}
                    variant="outline"
                    className="flex-1"
                  >
                    Cancelar
                  </Button>
                  <Button
                    onClick={confirmarEncerramentoOrdem}
                    disabled={!servicoRealizado.trim()}
                    className="flex-1 bg-green-600 hover:bg-green-700 text-white disabled:bg-gray-300 disabled:cursor-not-allowed"
                  >
                    <Printer className="w-4 h-4 mr-2" />
                    Encerrar e Imprimir
                  </Button>
                </div>

                <p className="text-xs text-gray-500 text-center mt-4">
                  Após encerrar, você poderá imprimir o comprovante de entrega com os dados da garantia
                </p>
              </div>
            </div>
          </div>
        )}
      </>
    )
  }

  // View de visualização da ordem
  if (viewMode === 'view' && viewingOrdem) {
    return (
      <>
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
              {viewingOrdem.status === 'Entregue' ? (
                <Button
                  disabled
                  className="bg-green-600 text-white cursor-not-allowed opacity-90"
                >
                  ✓ OS Encerrada
                </Button>
              ) : viewingOrdem.status !== 'Cancelado' ? (
                <Button
                  onClick={() => handleEncerrarOrdem(viewingOrdem)}
                  className="bg-green-600 hover:bg-green-700 text-white"
                >
                  ✓ Encerrar OS
                </Button>
              ) : null}
              
              {viewingOrdem.status === 'Entregue' ? (
                <Button
                  disabled
                  className="bg-gray-400 text-white cursor-not-allowed opacity-60"
                  title="Não é possível editar OS encerrada"
                >
                  🔒 Editar Bloqueado
                </Button>
              ) : (
                <Button
                  onClick={() => handleEditarOrdem(viewingOrdem)}
                  className="bg-blue-600 hover:bg-blue-700 text-white"
                >
                  Editar Ordem
                </Button>
              )}
              
              <Button
                onClick={handleCancelar}
                className="bg-orange-600 hover:bg-orange-700 text-white"
              >
                Voltar para Lista
              </Button>
            </div>
          </div>

          {/* Card de visualização da ordem - LAYOUT 3 COLUNAS COMPACTO */}
          <div className="bg-white rounded-lg border p-3">
            {/* Grid 3 colunas com auto-fill */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-2 auto-rows-auto">
              {/* Card 1: Cliente */}
              <div className="bg-blue-50 rounded p-2 border border-blue-200">
                <label className="text-[10px] font-semibold text-blue-700 uppercase block mb-1">Cliente</label>
                <p className="text-xs text-gray-900 font-semibold">{viewingOrdem.cliente?.nome || 'Não informado'}</p>
                {viewingOrdem.cliente?.cpf_cnpj && (
                  <p className="text-[10px] text-gray-600">CPF/CNPJ: {viewingOrdem.cliente.cpf_cnpj}</p>
                )}
                {viewingOrdem.cliente?.telefone && (
                  <p className="text-[10px] text-gray-600">Tel: {viewingOrdem.cliente.telefone}</p>
                )}
              </div>
              
              {/* Card 2: Equipamento */}
              <div className="bg-purple-50 rounded p-2 border border-purple-200">
                <label className="text-[10px] font-semibold text-purple-700 uppercase block mb-1">Equipamento</label>
                <p className="text-xs text-gray-900 font-semibold">{viewingOrdem.tipo}</p>
                <p className="text-xs text-gray-700">{viewingOrdem.marca} {viewingOrdem.modelo}</p>
                {viewingOrdem.cor && <p className="text-[10px] text-gray-600">Cor: {viewingOrdem.cor}</p>}
                {viewingOrdem.numero_serie && <p className="text-[10px] text-gray-600">Série: {viewingOrdem.numero_serie}</p>}
              </div>
              
              {/* Card 3: Status */}
              <div className="bg-gray-50 rounded p-2 border">
                <label className="text-[10px] font-semibold text-gray-700 uppercase block mb-1">Status</label>
                <span className={`inline-flex px-2 py-0.5 text-[10px] font-semibold rounded ${
                  viewingOrdem.status === 'Em análise' ? 'bg-yellow-100 text-yellow-800' :
                  viewingOrdem.status === 'Orçamento' ? 'bg-orange-100 text-orange-800' :
                  viewingOrdem.status === 'Em conserto' ? 'bg-blue-100 text-blue-800' :
                  viewingOrdem.status === 'Pronto' ? 'bg-cyan-500 text-white' :
                  viewingOrdem.status === 'Entregue' ? 'bg-green-100 text-green-800' :
                  'bg-red-100 text-red-800'
                }`}>
                  {viewingOrdem.status}
                </span>
                <div className="text-[10px] text-gray-600 mt-1 space-y-0.5">
                  <div><span className="font-medium">Entrada:</span> {formatDateTime(viewingOrdem.data_entrada)}</div>
                  {viewingOrdem.data_previsao && <div><span className="font-medium">Previsão:</span> {formatDate(viewingOrdem.data_previsao)}</div>}
                  {viewingOrdem.data_entrega && <div><span className="font-medium">Entrega:</span> {formatDateTime(viewingOrdem.data_entrega)}</div>}
                </div>
              </div>
              
              {/* Card 4: Defeito - sempre visível */}
              <div className="bg-orange-50 rounded p-2 border border-orange-200">
                <label className="text-[10px] font-semibold text-orange-700 uppercase block mb-1">Defeito</label>
                <p className="text-xs text-gray-900">{viewingOrdem.defeito_relatado || 'Não informado'}</p>
              </div>
              
              {/* Card 5: Observações - só aparece se existir e não estiver vazio */}
              {viewingOrdem.observacoes && viewingOrdem.observacoes.trim() !== '' && (
                <div className="bg-yellow-50 rounded p-2 border border-yellow-200">
                  <label className="text-[10px] font-semibold text-yellow-700 uppercase block mb-1">Observações</label>
                  <p className="text-xs text-gray-900">{viewingOrdem.observacoes}</p>
                </div>
              )}
              
              {/* Card 6: Orçamento - só aparece se tiver valor maior que zero */}
              {viewingOrdem.valor_orcamento && Number(viewingOrdem.valor_orcamento) > 0 && (
                <div className="bg-green-50 rounded p-2 border border-green-200">
                  <label className="text-[10px] font-semibold text-green-700 uppercase block mb-1">Orçamento</label>
                  <p className="text-sm font-bold text-green-600">{formatPrice(viewingOrdem.valor_orcamento)}</p>
                </div>
              )}
              
              {/* Card 7: Valor Final - só aparece se tiver valor maior que zero */}
              {viewingOrdem.valor_final && Number(viewingOrdem.valor_final) > 0 && (
                <div className="bg-blue-50 rounded p-2 border border-blue-200">
                  <label className="text-[10px] font-semibold text-blue-700 uppercase block mb-1">Valor Final</label>
                  <p className="text-sm font-bold text-blue-600">{formatPrice(viewingOrdem.valor_final)}</p>
                </div>
              )}
              
              {/* Card 8: Garantia - só aparece se tiver garantia e data de entrega */}
              {viewingOrdem.garantia_meses && Number(viewingOrdem.garantia_meses) > 0 && viewingOrdem.data_entrega && (
                <div className="bg-indigo-50 rounded p-2 border border-indigo-200">
                  <label className="text-[10px] font-semibold text-indigo-700 uppercase block mb-1">Garantia</label>
                  <div className="space-y-1">
                    <div className="text-xs">
                      <span className="font-semibold text-indigo-700">Período:</span> {viewingOrdem.garantia_meses} {viewingOrdem.garantia_meses === 1 ? 'mês' : 'meses'}
                    </div>
                    <div className="text-[10px] text-gray-700">
                      <span className="font-medium">Início:</span> {formatDate(viewingOrdem.data_entrega)}
                    </div>
                    <div className="text-[10px] text-gray-700">
                      <span className="font-medium">Término:</span> {(() => {
                        const dataEntrega = new Date(viewingOrdem.data_entrega)
                        const dataFimGarantia = new Date(dataEntrega)
                        dataFimGarantia.setMonth(dataFimGarantia.getMonth() + viewingOrdem.garantia_meses)
                        return formatDate(dataFimGarantia.toISOString())
                      })()}
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Checklist e Senha - LADO A LADO */}
            {((viewingOrdem.checklist && Object.keys(viewingOrdem.checklist).length > 0) || 
              (viewingOrdem.senha_aparelho && viewingOrdem.senha_aparelho.tipo !== 'nenhuma')) && (
              <div className="mt-4 pt-4 border-t">
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
                  {/* Checklist Técnico - 9 colunas (3/4 da largura) */}
                  {viewingOrdem.checklist && Object.keys(viewingOrdem.checklist).length > 0 && (
                    <div className={viewingOrdem.senha_aparelho && viewingOrdem.senha_aparelho.tipo !== 'nenhuma' ? 'lg:col-span-9' : 'lg:col-span-12'}>
                      <h3 className="text-sm font-semibold text-gray-900 mb-2 flex items-center gap-2">
                        <svg className="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                        </svg>
                        Checklist Técnico
                      </h3>
                      
                      <div className="grid grid-cols-3 gap-2">
                        {Object.entries(viewingOrdem.checklist).map(([key, value]) => {
                          const isChecked = Boolean(value)
                          return (
                            <div 
                              key={key}
                              className={`flex items-center gap-1.5 p-2 rounded border text-xs ${
                                isChecked 
                                  ? 'bg-green-50 border-green-300' 
                                  : 'bg-gray-50 border-gray-300'
                              }`}
                            >
                              <div className={`flex-shrink-0 w-3.5 h-3.5 rounded border flex items-center justify-center ${
                                isChecked 
                                  ? 'bg-green-500 border-green-500' 
                                  : 'bg-white border-gray-400'
                              }`}>
                                {isChecked && (
                                  <svg className="w-2.5 h-2.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                                  </svg>
                                )}
                              </div>
                              <span className={`truncate ${isChecked ? 'text-green-900 font-medium' : 'text-gray-600'}`}>
                                {key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                              </span>
                            </div>
                          )
                        })}
                      </div>
                    </div>
                  )}

                  {/* Senha do Aparelho - 3 colunas (1/4 da largura) */}
                  {viewingOrdem.senha_aparelho && viewingOrdem.senha_aparelho.tipo !== 'nenhuma' && (
                    <div className="lg:col-span-3">
                      <h3 className="text-sm font-semibold text-gray-900 mb-2 flex items-center gap-2">
                        <svg className="w-4 h-4 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                        </svg>
                        Senha
                      </h3>
                      
                      <div className="bg-orange-50 border border-orange-200 rounded-lg p-2.5">
                        <div className="text-center">
                          <div className="text-lg mb-1">
                            {viewingOrdem.senha_aparelho.tipo === 'texto' && '🔤'}
                            {viewingOrdem.senha_aparelho.tipo === 'pin' && '🔢'}
                            {viewingOrdem.senha_aparelho.tipo === 'desenho' && '✏️'}
                          </div>
                          <p className="text-[10px] font-medium text-gray-600 mb-2">
                            {
                              viewingOrdem.senha_aparelho.tipo === 'texto' ? 'Alfanumérica' :
                              viewingOrdem.senha_aparelho.tipo === 'pin' ? 'PIN' :
                              'Padrão'
                            }
                          </p>
                          
                          {viewingOrdem.senha_aparelho.tipo === 'desenho' ? (
                            <div className="bg-white rounded border p-1 inline-block">
                              <img 
                                src={viewingOrdem.senha_aparelho.valor || ''} 
                                alt="Padrão"
                                className="rounded"
                                style={{ width: '100px', height: '100px', objectFit: 'contain' }}
                              />
                            </div>
                          ) : (
                            <p className="text-sm font-mono font-bold text-gray-900 bg-white rounded px-2 py-1 break-all">
                              {viewingOrdem.senha_aparelho.valor}
                            </p>
                          )}
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Histórico de Aparelhos do Cliente */}
            {viewingOrdem.cliente_id && (() => {
              const ordensDoCliente = todasOrdens.filter((o: OrdemServico) => 
                o.cliente_id === viewingOrdem.cliente_id
              ).sort((a: OrdemServico, b: OrdemServico) => 
                new Date(b.data_entrada).getTime() - new Date(a.data_entrada).getTime()
              )
              
              if (ordensDoCliente.length > 1) {
                return (
                  <div className="mt-4 pt-4 border-t">
                    <h3 className="text-sm font-semibold text-gray-900 mb-2 flex items-center gap-2">
                      <svg className="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      Histórico do Cliente ({ordensDoCliente.length} ordens)
                    </h3>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-1.5">
                      {ordensDoCliente.slice(0, 6).map((ordem: OrdemServico) => {
                        const isAtual = ordem.id === viewingOrdem.id
                        
                        return (
                          <div 
                            key={ordem.id}
                            onClick={() => !isAtual && handleVisualizarOrdem(ordem)}
                            className={`p-1.5 rounded border ${
                              isAtual 
                                ? 'bg-blue-100 border-blue-400 ring-1 ring-blue-300' 
                                : 'bg-gray-50 border-gray-200 hover:border-blue-300 hover:bg-blue-50 cursor-pointer transition-all'
                            } ${
                              ordem.status === 'Pronto' ? 'border-green-200' :
                              ordem.status === 'Em conserto' ? 'border-blue-200' :
                              ordem.status === 'Em análise' ? 'border-yellow-200' : ''
                            }`}
                          >
                            {/* Header compacto */}
                            <div className="flex items-center justify-between mb-1">
                              <div className="flex items-center gap-1">
                                {isAtual && (
                                  <span className="bg-blue-600 text-white text-[8px] px-1 py-0.5 rounded font-semibold">
                                    ATUAL
                                  </span>
                                )}
                                <span className={`px-1 py-0.5 text-[8px] font-semibold rounded ${
                                  ordem.status === 'Em análise' ? 'bg-yellow-200 text-yellow-800' :
                                  ordem.status === 'Orçamento' ? 'bg-orange-200 text-orange-800' :
                                  ordem.status === 'Em conserto' ? 'bg-blue-200 text-blue-800' :
                                  ordem.status === 'Pronto' ? 'bg-cyan-500 text-white' :
                                  ordem.status === 'Entregue' ? 'bg-green-200 text-green-800' :
                                  'bg-red-200 text-red-800'
                                }`}>
                                  {ordem.status}
                                </span>
                              </div>
                            </div>
                            
                            {/* Informações compactas */}
                            <div className="space-y-0.5">
                              <div className="flex items-start justify-between gap-1">
                                <p className="text-[10px] font-semibold text-gray-900 truncate flex-1">
                                  {ordem.marca} {ordem.modelo}
                                </p>
                                {(ordem.valor_final && Number(ordem.valor_final) > 0) || (ordem.valor_orcamento && Number(ordem.valor_orcamento) > 0) ? (
                                  <p className="text-[10px] font-bold text-gray-900 whitespace-nowrap">
                                    {ordem.valor_final && Number(ordem.valor_final) > 0
                                      ? formatPrice(Number(ordem.valor_final)) 
                                      : formatPrice(Number(ordem.valor_orcamento))
                                    }
                                  </p>
                                ) : null}
                              </div>
                              
                              <p className="text-[9px] text-gray-700 truncate" title={ordem.defeito_relatado}>
                                {ordem.defeito_relatado || 'Não informado'}
                              </p>
                              
                              <div className="text-[8px] text-gray-600 pt-0.5 border-t border-gray-200">
                                <div>Entrada: {formatDate(ordem.data_entrada)}</div>
                                {ordem.data_entrega && (
                                  <div>Entrega: {formatDate(ordem.data_entrega)}</div>
                                )}
                              </div>
                            </div>
                          </div>
                        )
                      })}
                    </div>
                    
                    {ordensDoCliente.length > 6 && (
                      <p className="text-xs text-gray-500 text-center mt-2">
                        + {ordensDoCliente.length - 6} ordem(ns) não exibida(s)
                      </p>
                    )}
                  </div>
                )
              }
              return null
            })()}
          </div>
        </main>
      </div>

      {/* Modal de Encerramento */}
      {showEncerrarModal && ordemParaEncerrar && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              {/* Header do Modal */}
              <div className="flex items-center justify-between mb-6">
                <div>
                  <h2 className="text-2xl font-bold text-gray-900">Encerrar Ordem de Serviço</h2>
                  <p className="text-sm text-gray-600 mt-1">
                    OS #{ordemParaEncerrar.numero_os || ordemParaEncerrar.id.slice(-6)}
                  </p>
                </div>
                <button
                  onClick={() => setShowEncerrarModal(false)}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>

              {/* Informações do Equipamento */}
              <div className="bg-blue-50 rounded-lg p-4 mb-6">
                <h3 className="font-semibold text-blue-900 mb-2">Equipamento</h3>
                <div className="space-y-1 text-sm">
                  <p><span className="font-medium">Cliente:</span> {ordemParaEncerrar.cliente?.nome}</p>
                  <p><span className="font-medium">Equipamento:</span> {ordemParaEncerrar.marca} {ordemParaEncerrar.modelo}</p>
                  <p><span className="font-medium">Defeito:</span> {ordemParaEncerrar.defeito_relatado}</p>
                </div>
              </div>

              {/* Formulário de Encerramento */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Serviço Realizado *
                  </label>
                  <textarea
                    value={servicoRealizado}
                    onChange={(e) => setServicoRealizado(e.target.value)}
                    placeholder="Descreva o serviço que foi executado..."
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 min-h-[100px]"
                    required
                  />
                  <p className="text-xs text-gray-500 mt-1">
                    Esta informação será incluída no comprovante de entrega
                  </p>
                </div>

                {/* Resultado do Reparo */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Resultado do Reparo *
                  </label>
                  <select
                    value={resultadoReparo}
                    onChange={(e) => {
                      setResultadoReparo(e.target.value as 'reparado' | 'sem_reparo' | 'condenado')
                      // Se não for reparado, zerar garantia
                      if (e.target.value !== 'reparado') {
                        setGarantiaMeses(0)
                        setGarantiaPersonalizada('')
                      } else {
                        setGarantiaMeses(3) // Restaurar garantia padrão
                      }
                    }}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="reparado">Aparelho Reparado</option>
                    <option value="sem_reparo">Aparelho Sem Reparo</option>
                    <option value="condenado">Aparelho Condenado</option>
                  </select>
                  <p className="text-xs text-gray-500 mt-1">
                    {resultadoReparo === 'reparado' 
                      ? 'Reparo realizado com sucesso - garantia disponível'
                      : resultadoReparo === 'sem_reparo'
                      ? 'Cliente optou por não realizar o reparo'
                      : 'Aparelho não tem condições de reparo'}
                  </p>
                </div>

                {/* Garantia - Só aparece se for reparado */}
                {resultadoReparo === 'reparado' && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Garantia do Serviço *
                  </label>
                  <div className="grid grid-cols-4 gap-2 mb-3">
                    {[1, 3, 6, 12].map((meses) => (
                      <button
                        key={meses}
                        type="button"
                        onClick={() => {
                          setGarantiaMeses(meses)
                          setGarantiaPersonalizada('')
                        }}
                        className={`px-4 py-3 rounded-lg border-2 transition-all ${
                          garantiaMeses === meses && garantiaPersonalizada === ''
                            ? 'border-blue-600 bg-blue-50 text-blue-700 font-semibold'
                            : 'border-gray-300 hover:border-gray-400 text-gray-700'
                        }`}
                      >
                        {meses} {meses === 1 ? 'mês' : 'meses'}
                      </button>
                    ))}
                  </div>
                  
                  <div className="bg-orange-50 border-2 border-orange-400 rounded-lg p-3">
                    <label className="block text-sm font-medium text-orange-700 mb-2">
                      Meses Personalizados da Garantia
                    </label>
                    <div className="relative">
                      <input
                        type="number"
                        min="1"
                        max="120"
                        value={garantiaPersonalizada}
                        onChange={(e) => setGarantiaPersonalizada(e.target.value)}
                        placeholder="Digite o mês"
                        className="w-full px-3 py-2 border-2 border-orange-400 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                      />
                      <span className="absolute right-3 top-2 text-sm text-gray-500">meses</span>
                    </div>
                  </div>
                </div>
                )}

                {/* Preview da Garantia - Só aparece se for reparado */}
                {resultadoReparo === 'reparado' && (
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <div className="flex items-start gap-3">
                    <div className="text-green-600 text-2xl">✓</div>
                    <div className="flex-1">
                      <h4 className="font-semibold text-green-900 mb-1">Garantia do Serviço</h4>
                      <p className="text-sm text-green-700">
                        O equipamento terá <strong>{garantiaPersonalizada || garantiaMeses} {(garantiaPersonalizada ? parseInt(garantiaPersonalizada) : garantiaMeses) === 1 ? 'mês' : 'meses'}</strong> de garantia
                      </p>
                      <p className="text-xs text-green-600 mt-1">
                        Válida até: {new Date(new Date().setMonth(new Date().getMonth() + (garantiaPersonalizada ? parseInt(garantiaPersonalizada) : garantiaMeses))).toLocaleDateString('pt-BR')}
                      </p>
                    </div>
                  </div>
                </div>
                )}
              </div>

              {/* Ações do Modal */}
              <div className="flex gap-3 mt-6 pt-6 border-t">
                <Button
                  onClick={() => setShowEncerrarModal(false)}
                  variant="outline"
                  className="flex-1"
                >
                  Cancelar
                </Button>
                <Button
                  onClick={confirmarEncerramentoOrdem}
                  disabled={!servicoRealizado.trim()}
                  className="flex-1 bg-green-600 hover:bg-green-700 text-white disabled:bg-gray-300 disabled:cursor-not-allowed"
                >
                  <Printer className="w-4 h-4 mr-2" />
                  Encerrar e Imprimir
                </Button>
              </div>

              <p className="text-xs text-gray-500 text-center mt-4">
                Após encerrar, você poderá imprimir o comprovante de entrega com os dados da garantia
              </p>
            </div>
          </div>
        </div>
      )}
    </>
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
                      ordem.status === 'Orçamento' ? 'bg-orange-100 text-orange-800' :
                      ordem.status === 'Em conserto' ? 'bg-blue-100 text-blue-800' :
                      ordem.status === 'Pronto' ? 'bg-cyan-500 text-white' :
                      ordem.status === 'Entregue' ? 'bg-green-100 text-green-800' :
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
                      {ordem.status === 'Entregue' ? (
                        <button 
                          className="p-1 text-gray-400 cursor-not-allowed opacity-50"
                          title="Não é possível editar OS encerrada"
                          disabled
                        >
                          <Lock className="w-4 h-4" />
                        </button>
                      ) : (
                        <button 
                          className="p-1 text-green-600 hover:text-green-800"
                          title="Editar ordem"
                          onClick={() => handleEditarOrdem(ordem)}
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                      )}
                      {can('ordens_servico', 'delete') && (
                        <button 
                          className="p-1 text-red-600 hover:text-red-800"
                          title="Excluir ordem"
                          onClick={async () => {
                            console.log('🗑️ Tentando excluir ordem:', ordem.id);
                            if (confirm(`Deseja realmente excluir a ordem "${ordem.numero_os || ordem.id.slice(-6)}"?`)) {
                              try {
                                const { error } = await supabase
                                  .from('ordens_servico')
                                  .delete()
                                  .eq('id', ordem.id)
                                
                                if (error) {
                                  console.error('❌ Erro ao excluir:', error)
                                  toast.error(`Erro ao excluir ordem: ${error.message}`)
                                } else {
                                  console.log('✅ Ordem excluída com sucesso!')
                                  toast.success('Ordem excluída com sucesso!')
                                  // Remover da lista local
                                  setTodasOrdens(prev => prev.filter((o: OrdemServico) => o.id !== ordem.id))
                                }
                              } catch (err) {
                                console.error('❌ Erro:', err)
                                toast.error('Erro ao excluir ordem')
                              }
                            }
                          }}
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
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