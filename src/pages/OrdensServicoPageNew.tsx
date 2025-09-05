import { useState } from 'react'
import { Plus, Search, Filter, Edit, Trash2, Wrench, Clock, CheckCircle, Eye, EyeOff } from 'lucide-react'
import { useOrdemServico } from '../hooks/useOrdemServico'
import { OrdemServicoFormNew } from '../components/ordem-servico/OrdemServicoFormNew'
import { OrdemServicoFormEdit } from '../components/ordem-servico/OrdemServicoFormEdit'
import type { OrdemServico, StatusOS } from '../types/ordemServico'
import { STATUS_COLORS } from '../types/ordemServico'

type ViewMode = 'list' | 'form' | 'edit'

export function OrdensServicoPage() {
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<StatusOS | ''>('')
  const [editingOrdem, setEditingOrdem] = useState<OrdemServico | null>(null)
  const [showAllOrders, setShowAllOrders] = useState(false)

  // Função para abrir formulário de edição
  const handleEditOrdem = (ordem: OrdemServico) => {
    setEditingOrdem(ordem)
    setViewMode('edit')
  }

  // Função para fechar formulário de edição
  const handleCloseEditForm = () => {
    setViewMode('list')
    setEditingOrdem(null)
  }

  // Função chamada quando ordem é atualizada com sucesso
  const handleUpdateSuccess = () => {
    handleCloseEditForm()
    // Recarregar dados
    window.location.reload()
  }

  const {
    ordensServico,
    loading,
    error,
    deletarOS
  } = useOrdemServico()

  // Filtrar ordens
  const ordensFiltradas = ordensServico.filter((ordem: OrdemServico) => {
    const matchesSearch = ordem.cliente?.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         ordem.marca.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         ordem.modelo.toLowerCase().includes(searchTerm.toLowerCase())
    
    const matchesStatus = !statusFilter || ordem.status === statusFilter
    
    return matchesSearch && matchesStatus
  })

  // Função para nova OS
  const handleNewOS = () => setViewMode('form')
  const handleCloseForm = () => setViewMode('list')
  const handleFormSuccess = () => {
    handleCloseForm()
    window.location.reload()
  }

  // Estatísticas
  const stats = {
    total: ordensServico.length,
    em_analise: ordensServico.filter(os => os.status === 'Em análise').length,
    em_conserto: ordensServico.filter(os => os.status === 'Em conserto').length,
    pronto: ordensServico.filter(os => os.status === 'Pronto').length
  }

  // Cards de estatística
  const StatCard = ({ title, value, icon: Icon, color }: any) => (
    <div className={`bg-white p-6 rounded-lg shadow-sm border-l-4 ${color}`}>
      <div className="flex items-center">
        <Icon className="h-8 w-8 text-blue-500" />
        <div className="ml-4">
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className="text-2xl font-bold text-gray-900">{value}</p>
        </div>
      </div>
    </div>
  )

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 p-4 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="text-gray-600 mt-4">Carregando ordens de serviço...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 p-4 flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-600 text-xl mb-4">⚠️ Erro ao carregar dados</div>
          <p className="text-gray-600">{error}</p>
          <button 
            onClick={() => window.location.reload()}
            className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            Tentar Novamente
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-7xl mx-auto space-y-6">
        
        {viewMode === 'form' && (
          <OrdemServicoFormNew 
            onCancel={handleCloseForm}
            onSuccess={handleFormSuccess}
          />
        )}

        {viewMode === 'edit' && editingOrdem && (
          <OrdemServicoFormEdit 
            ordem={editingOrdem}
            onSuccess={handleUpdateSuccess}
          />
        )}

        {viewMode === 'list' && (
          <>
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Ordens de Serviço</h1>
                <p className="text-gray-600 mt-1">
                  Gerencie as ordens de serviço da assistência técnica
                </p>
              </div>
              
              <div className="flex gap-3 self-start sm:self-auto">
                <button
                  onClick={handleNewOS}
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center gap-2"
                >
                  <Plus className="h-5 w-5" />
                  Nova OS
                </button>
              </div>
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
                value={stats.em_analise} 
                icon={Clock} 
                color="border-yellow-500" 
              />
              <StatCard 
                title="Em Conserto" 
                value={stats.em_conserto} 
                icon={Edit} 
                color="border-orange-500" 
              />
              <StatCard 
                title="Pronto" 
                value={stats.pronto} 
                icon={CheckCircle} 
                color="border-green-500" 
              />
            </div>

            {/* Filtros */}
            <div className="bg-white rounded-lg shadow-sm p-4">
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="flex-1">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-5 w-5" />
                    <input
                      type="text"
                      placeholder="Pesquisar por cliente, marca ou modelo..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                </div>
                
                <div className="flex gap-2">
                  <div className="relative">
                    <Filter className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-5 w-5" />
                    <select
                      value={statusFilter}
                      onChange={(e) => setStatusFilter(e.target.value as StatusOS | '')}
                      className="pl-10 pr-8 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 appearance-none bg-white min-w-[160px]"
                    >
                      <option value="">Todos Status</option>
                      <option value="Em análise">Em análise</option>
                      <option value="Em conserto">Em conserto</option>
                      <option value="Aguardando peça">Aguardando peça</option>
                      <option value="Pronto">Pronto</option>
                      <option value="Entregue">Entregue</option>
                      <option value="Cancelado">Cancelado</option>
                    </select>
                  </div>

                  <button
                    onClick={() => setShowAllOrders(!showAllOrders)}
                    className="flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
                    title={showAllOrders ? "Mostrar apenas minhas ordens" : "Mostrar todas as ordens"}
                  >
                    {showAllOrders ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                    {showAllOrders ? "Minhas" : "Todas"}
                  </button>
                </div>
              </div>
            </div>

            {/* Lista de Ordens */}
            <div className="bg-white rounded-lg shadow-sm overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        OS
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Cliente
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Equipamento
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Status
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Valor
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Data
                      </th>
                      <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Ações
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {ordensFiltradas.map((ordem) => {
                      const statusColor = STATUS_COLORS[ordem.status] || 'bg-gray-100 text-gray-800'
                      
                      return (
                        <tr key={ordem.id} className="hover:bg-gray-50">
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="flex items-center">
                              <Wrench className="h-5 w-5 text-gray-400 mr-2" />
                              <span className="text-sm font-medium text-gray-900">
                                {ordem.numero_os}
                              </span>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="text-sm text-gray-900">
                              {ordem.cliente?.nome || 'N/A'}
                            </div>
                            <div className="text-sm text-gray-500">
                              {ordem.cliente?.telefone || 'Sem telefone'}
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="text-sm text-gray-900">
                              {ordem.marca} {ordem.modelo}
                            </div>
                            <div className="text-sm text-gray-500">
                              {ordem.equipamento}
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${statusColor}`}>
                              {ordem.status}
                            </span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            R$ {ordem.valor?.toFixed(2) || '0,00'}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            {new Date(ordem.data_entrada).toLocaleDateString()}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                            <button
                              onClick={() => handleEditOrdem(ordem)}
                              className="text-blue-600 hover:text-blue-900 inline-flex items-center"
                              title="Editar OS"
                            >
                              <Edit className="h-4 w-4" />
                            </button>
                            <button
                              onClick={() => {
                                if (window.confirm('Tem certeza que deseja excluir esta OS?')) {
                                  deletarOS(ordem.id)
                                  window.location.reload()
                                }
                              }}
                              className="text-red-600 hover:text-red-900 inline-flex items-center ml-2"
                              title="Excluir OS"
                            >
                              <Trash2 className="h-4 w-4" />
                            </button>
                          </td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>
                
                {ordensFiltradas.length === 0 && (
                  <div className="text-center py-12">
                    <Wrench className="mx-auto h-12 w-12 text-gray-400" />
                    <h3 className="mt-2 text-sm font-semibold text-gray-900">Nenhuma ordem encontrada</h3>
                    <p className="mt-1 text-sm text-gray-500">
                      {searchTerm || statusFilter 
                        ? 'Tente ajustar os filtros de pesquisa.'
                        : 'Comece criando uma nova ordem de serviço.'
                      }
                    </p>
                    {!searchTerm && !statusFilter && (
                      <div className="mt-6">
                        <button
                          onClick={handleNewOS}
                          className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                        >
                          <Plus className="h-5 w-5 mr-2" />
                          Nova Ordem de Serviço
                        </button>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  )
}
