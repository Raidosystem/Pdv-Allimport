import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { Plus, Search, Filter, Edit, Trash2, Wrench, Clock, CheckCircle, Eye, ArrowLeft } from 'lucide-react'
import { useOrdemServico } from '../hooks/useOrdemServico'
import { OrdemServicoForm } from '../components/ordem-servico/OrdemServicoForm'
import { Button } from '../components/ui/Button'
import type { OrdemServico, StatusOS } from '../types/ordemServico'
import { STATUS_COLORS, TIPO_ICONS } from '../types/ordemServico'

type ViewMode = 'list' | 'form' | 'view'

// Função para carregar todas as ordens de serviço do backup
const loadAllServiceOrders = async (): Promise<OrdemServico[]> => {
  try {
    const response = await fetch('/backup-allimport.json')
    const backupData = await response.json()
    return backupData.data?.service_orders || []
  } catch (error) {
    console.error('Erro ao carregar backup de ordens:', error)
    return []
  }
}

export function OrdensServicoPage() {
  const navigate = useNavigate()
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<StatusOS | ''>('')
  const [editingOrdem, setEditingOrdem] = useState<OrdemServico | null>(null)
  const [viewingOrdem, setViewingOrdem] = useState<OrdemServico | null>(null)
  const [ordensServico, setOrdensServico] = useState<OrdemServico[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Carregar todas as ordens de serviço do backup
    const loadOrdens = async () => {
      try {
        const allOrdens = await loadAllServiceOrders()
        setOrdensServico(allOrdens)
        console.log(`✅ Carregadas ${allOrdens.length} ordens de serviço do backup`)
      } catch (error) {
        console.error('Erro ao carregar ordens:', error)
        setOrdensServico([])
      } finally {
        setLoading(false)
      }
    }
    
    loadOrdens()
  }, [])

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

  // Filtrar ordens
  const ordensFiltradas = ordensServico.filter((ordem: OrdemServico) => {
    const matchesSearch = ordem.cliente?.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         ordem.marca.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         ordem.modelo.toLowerCase().includes(searchTerm.toLowerCase())
    
    const matchesStatus = !statusFilter || ordem.status === statusFilter
    
    return matchesSearch && matchesStatus
  })

  // Estatísticas
  const stats = {
    total: ordensServico.length,
    emAnalise: ordensServico.filter((os: OrdemServico) => os.status === 'Em análise').length,
    emAndamento: ordensServico.filter((os: OrdemServico) => os.status === 'Em conserto').length,
    prontas: ordensServico.filter((os: OrdemServico) => os.status === 'Pronto').length,
    entregues: ordensServico.filter((os: OrdemServico) => os.status === 'Entregue').length
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
            ordemId={editingOrdem?.id}
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
                <p className="text-sm text-gray-600">OS #{viewingOrdem.numero_os}</p>
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
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${STATUS_COLORS[viewingOrdem.status] || 'bg-gray-100 text-gray-800'}`}>
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
                {viewingOrdem.observations && (
                  <div className="md:col-span-2">
                    <span className="font-medium">Observações:</span>
                    <p className="mt-1 text-gray-900">{viewingOrdem.observations}</p>
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

  // Função para delete (temporariamente desabilitada)
  const handleDelete = async (id: string) => {
    if (confirm('Tem certeza que deseja excluir esta OS?')) {
      try {
        // await deletarOS(id) // Implementar depois
        console.log('🗑️ Excluir OS:', id)
        alert('Função de exclusão temporariamente desabilitada')
      } catch (error) {
        console.error('Erro ao deletar OS:', error)
      }
    }
  }



  // Estatísticas Cards
  const StatCard = ({ title, value, icon: Icon, color }: {
    title: string
    value: number
    icon: React.ComponentType<any>
    color: string
  }) => (
    <div className={`bg-white p-6 rounded-lg shadow-sm border-l-4 ${color}`}>
      <div className="flex items-center">
        <div className="flex-shrink-0">
          <Icon className="h-6 w-6 text-gray-600" />
        </div>
        <div className="ml-5 w-0 flex-1">
          <dl>
            <dt className="text-sm font-medium text-gray-500 truncate">
              {title}
            </dt>
            <dd className="text-lg font-medium text-gray-900">
              {value}
            </dd>
          </dl>
        </div>
      </div>
    </div>
  )

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 p-4">
        <div className="max-w-7xl mx-auto">
          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            <p className="text-red-600">Erro: {error}</p>
          </div>
        </div>
      </div>
    )
  }

  if (viewMode === 'form') {
    return (
      <div className="min-h-screen bg-gray-50 p-4">
        <div className="max-w-4xl mx-auto">
          <OrdemServicoForm
            onSuccess={handleFormSuccess}
            onCancel={handleFormCancel}
          />
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Ordens de Serviço</h1>
            <p className="text-gray-600 mt-1">
              Gerencie as ordens de serviço da assistência técnica
            </p>
          </div>
          
          <button
            onClick={handleNewOS}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2 self-start sm:self-auto"
          >
            <Plus className="h-5 w-5" />
            Nova OS
          </button>
        </div>

        {/* Estatísticas */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <StatCard 
            title="Total de OS" 
            value={stats.total} 
            icon={Wrench} 
            color="border-blue-500" 
          />
          <StatCard 
            title="Em Análise" 
            value={stats.emAnalise} 
            icon={Clock} 
            color="border-yellow-500" 
          />
          <StatCard 
            title="Em Conserto" 
            value={stats.emAndamento} 
            icon={Wrench} 
            color="border-orange-500" 
          />
          <StatCard 
            title="Prontas" 
            value={stats.prontas} 
            icon={CheckCircle} 
            color="border-green-500" 
          />
        </div>

        {/* Filtros */}
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Buscar por cliente, marca ou modelo..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            
            <div className="relative">
              <Filter className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value as StatusOS | '')}
                className="pl-10 pr-8 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white"
              >
                <option value="">Todos os status</option>
                <option value="Em análise">Em análise</option>
                <option value="Aguardando aprovação">Aguardando aprovação</option>
                <option value="Em conserto">Em conserto</option>
                <option value="Pronto">Pronto</option>
                <option value="Entregue">Entregue</option>
                <option value="Cancelado">Cancelado</option>
              </select>
            </div>
          </div>
        </div>

        {/* Tabela de Ordens */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          {loading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-2 border-blue-600 border-t-transparent mx-auto mb-4" />
              <p className="text-gray-600">Carregando ordens de serviço...</p>
            </div>
          ) : ordensFiltradas.length === 0 ? (
            <div className="p-8 text-center">
              <Wrench className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600 text-lg">
                {searchTerm || statusFilter 
                  ? 'Nenhuma ordem encontrada com os filtros aplicados'
                  : 'Nenhuma ordem de serviço cadastrada'
                }
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 border-b">
                  <tr>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Cliente</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Equipamento</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Defeito</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Status</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Data</th>
                    <th className="text-left py-3 px-4 font-medium text-gray-700">Valor</th>
                    <th className="text-right py-3 px-4 font-medium text-gray-700">Ações</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {ordensFiltradas.map((ordem: OrdemServico) => (
                    <tr key={ordem.id} className="hover:bg-gray-50">
                      <td className="py-3 px-4">
                        <div>
                          <div className="font-medium text-gray-900">
                            {ordem.cliente?.nome}
                          </div>
                          <div className="text-sm text-gray-500">
                            {ordem.cliente?.telefone}
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          <span className="text-lg">
                            {TIPO_ICONS[ordem.tipo]}
                          </span>
                          <div>
                            <div className="font-medium text-gray-900">
                              {ordem.marca} {ordem.modelo}
                            </div>
                            <div className="text-sm text-gray-500">
                              {ordem.tipo}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="text-sm text-gray-900 max-w-xs truncate">
                          {ordem.defeito_relatado}
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${STATUS_COLORS[ordem.status]}`}>
                          {ordem.status}
                        </span>
                      </td>
                      <td className="py-3 px-4 text-sm text-gray-500">
                        {formatDate(ordem.data_entrada)}
                      </td>
                      <td className="py-3 px-4 text-sm text-gray-900">
                        {formatCurrency(ordem.valor_orcamento)}
                      </td>
                      <td className="py-3 px-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={(e) => {
                              e.preventDefault();
                              e.stopPropagation();
                              console.log('✏️ BOTÃO EDITAR OS CLICADO:', ordem.id);
                              console.log('Navegando para:', `/ordens-servico/${ordem.id}/editar`);
                              navigate(`/ordens-servico/${ordem.id}/editar`);
                            }}
                            className="p-1 text-blue-600 hover:text-blue-800"
                            title="Editar"
                          >
                            <Edit className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleDelete(ordem.id)}
                            className="p-1 text-red-600 hover:text-red-800"
                            title="Excluir"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
