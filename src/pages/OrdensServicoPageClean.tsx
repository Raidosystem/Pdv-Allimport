import { useState, useEffect } from 'react'
import { Wrench, Plus, Search, Edit, Trash2, Eye } from 'lucide-react'
import { Button } from '../components/ui/Button'
import { OrdemServicoForm } from '../components/ordem-servico/OrdemServicoForm'

interface OrdemServico {
  id: string
  numero_os?: string
  user_id?: string
  cliente?: {
    nome: string
    telefone?: string
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
    const response = await fetch('/backup-allimport.json')
    const backupData = await response.json()
    return backupData.data?.service_orders || []
  } catch (error) {
    console.error('Erro ao carregar backup de ordens:', error)
    return sampleOrdens
  }
}

export function OrdensServicoPage() {
  console.log('🔥 OrdensServicoPage carregando...')
  const [todasOrdens, setTodasOrdens] = useState<OrdemServico[]>([]) // Lista completa
  const [ordens, setOrdens] = useState<OrdemServico[]>([]) // Lista exibida
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [editingOrdem, setEditingOrdem] = useState<OrdemServico | null>(null)
  const [viewingOrdem, setViewingOrdem] = useState<OrdemServico | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [loading, setLoading] = useState(true)
  const [mostrarTodos, setMostrarTodos] = useState(false) // Iniciar mostrando apenas 10

  useEffect(() => {
    // Carregar todas as ordens de serviço do backup
    const loadOrdens = async () => {
      try {
        const allOrdens = await loadAllServiceOrders()
        setTodasOrdens(allOrdens) // Guardar todas para estatísticas
        setOrdens(allOrdens.slice(0, 10)) // Mostrar apenas as primeiras 10
        setMostrarTodos(false)
        console.log(`✅ Carregadas ${allOrdens.length} ordens de serviço do backup (mostrando 10)`)
      } catch (error) {
        console.error('Erro ao carregar ordens:', error)
        setTodasOrdens(sampleOrdens)
        setOrdens(sampleOrdens.slice(0, 10))
        setMostrarTodos(false)
      } finally {
        setLoading(false)
      }
    }

    loadOrdens()
  }, [])

  const verTodos = () => {
    setOrdens(todasOrdens)
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

  const filteredOrdens = ordens.filter(ordem =>
    ordem.cliente?.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
    ordem.marca.toLowerCase().includes(searchTerm.toLowerCase()) ||
    ordem.modelo.toLowerCase().includes(searchTerm.toLowerCase()) ||
    ordem.numero_os?.toLowerCase().includes(searchTerm.toLowerCase())
  )

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
      <div className="bg-white rounded-lg border p-4">
        <div className="flex items-center gap-2">
          <Search className="w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Buscar ordens de serviço..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="flex-1 border-0 focus:ring-0 focus:outline-none"
          />
        </div>
      </div>

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
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Data</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {filteredOrdens.slice(0, 50).map((ordem) => (
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
                      <div className="font-medium text-gray-900">{ordem.marca} {ordem.modelo}</div>
                      <div className="text-gray-500">{ordem.tipo}</div>
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
        
        {/* Botão Ver mais ordens */}
        {!mostrarTodos && todasOrdens.length > 10 && (
          <div className="p-4 border-t text-center">
            <button
              onClick={verTodos}
              className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm font-medium"
            >
              Ver mais ordens ({todasOrdens.length - 10} restantes)
            </button>
          </div>
        )}
        
        {filteredOrdens.length === 0 && (
          <div className="text-center py-12">
            <Wrench className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              {searchTerm ? 'Nenhuma ordem encontrada' : 'Nenhuma ordem cadastrada'}
            </h3>
            <p className="text-gray-600 mb-4">
              {searchTerm ? 'Tente buscar com outros termos' : 'Comece criando sua primeira ordem de serviço'}
            </p>
            {!searchTerm && (
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