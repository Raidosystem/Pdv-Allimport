import React, { useState } from 'react'
import { Plus, Search, Filter, Edit, Trash2, Wrench, Clock, CheckCircle } from 'lucide-react'
import { useOrdemServico } from '../hooks/useOrdemServico'
import { OrdemServicoForm } from '../components/ordem-servico/OrdemServicoForm'
import type { OrdemServico, StatusOS } from '../types/ordemServico'
import { STATUS_COLORS, TIPO_ICONS } from '../types/ordemServico'

type ViewMode = 'list' | 'form'

export function OrdensServicoPage() {
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<StatusOS | ''>('')

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

  // Estatísticas
  const stats = {
    total: ordensServico.length,
    emAnalise: ordensServico.filter((os: OrdemServico) => os.status === 'Em análise').length,
    emAndamento: ordensServico.filter((os: OrdemServico) => os.status === 'Em conserto').length,
    prontas: ordensServico.filter((os: OrdemServico) => os.status === 'Pronto').length,
    entregues: ordensServico.filter((os: OrdemServico) => os.status === 'Entregue').length
  }

  const handleDelete = async (id: string) => {
    if (confirm('Tem certeza que deseja excluir esta OS?')) {
      try {
        await deletarOS(id)
      } catch (error) {
        console.error('Erro ao deletar OS:', error)
      }
    }
  }

  const handleNewOS = () => {
    setViewMode('form')
  }

  const handleFormSuccess = () => {
    setViewMode('list')
  }

  const handleFormCancel = () => {
    setViewMode('list')
  }

  const formatCurrency = (value: number | undefined) => {
    if (!value) return 'R$ 0,00'
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString('pt-BR')
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
                            onClick={() => console.log('Editar OS:', ordem.id)}
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
