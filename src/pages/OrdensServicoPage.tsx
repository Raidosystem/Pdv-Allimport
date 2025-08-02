import { useState } from 'react'
import { Link } from 'react-router-dom'
import { toast } from 'react-hot-toast'
import { 
  Plus, 
  Search, 
  Filter, 
  Eye, 
  Edit, 
  Printer,
  Calendar,
  User,
  Phone,
  RefreshCw
} from 'lucide-react'
import { Button } from '../components/ui/Button'
import { Card } from '../components/ui/Card'
import { ordemServicoService } from '../services/ordemServicoService'
import { OrdemServicoForm } from '../components/ordem-servico/OrdemServicoForm'
import { StatusCardsOS } from '../components/ordem-servico/StatusCardsOS'
import { useOrdensServico } from '../hooks/useOrdensServico'
import type { 
  FiltrosOS, 
  StatusOS, 
  TipoEquipamento 
} from '../types/ordemServico'
import { STATUS_COLORS, TIPO_ICONS } from '../types/ordemServico'

const STATUS_OPTIONS: StatusOS[] = [
  'Em análise',
  'Aguardando aprovação', 
  'Aguardando peças',
  'Em conserto',
  'Pronto',
  'Entregue',
  'Cancelado'
]

const TIPO_OPTIONS: TipoEquipamento[] = [
  'Celular',
  'Notebook', 
  'Console',
  'Tablet',
  'Outro'
]

export function OrdensServicoPage() {
  const [filtros, setFiltros] = useState<FiltrosOS>({})
  const [mostrarFormulario, setMostrarFormulario] = useState(false)
  const [mostrarFiltros, setMostrarFiltros] = useState(false)
  const [atualizandoStatus, setAtualizandoStatus] = useState<string | null>(null)

  const { ordens, loading, recarregar } = useOrdensServico(filtros)

  // Atualizar status da ordem
  const atualizarStatus = async (id: string, novoStatus: StatusOS) => {
    setAtualizandoStatus(id)
    try {
      await ordemServicoService.atualizarStatus(id, novoStatus)
      toast.success('Status atualizado com sucesso!')
      recarregar()
    } catch (error: any) {
      console.error('Erro ao atualizar status:', error)
      toast.error('Erro ao atualizar status')
    } finally {
      setAtualizandoStatus(null)
    }
  }

  // Aplicar filtros
  const aplicarFiltros = (novosFiltros: Partial<FiltrosOS>) => {
    setFiltros(prev => ({ ...prev, ...novosFiltros }))
  }

  // Limpar filtros
  const limparFiltros = () => {
    setFiltros({})
  }

  // Formatar data
  const formatarData = (data: string) => {
    return new Date(data).toLocaleDateString('pt-BR')
  }

  // Formatar valor
  const formatarValor = (valor?: number) => {
    if (!valor) return '-'
    return valor.toLocaleString('pt-BR', { 
      style: 'currency', 
      currency: 'BRL' 
    })
  }

  if (mostrarFormulario) {
    return (
      <OrdemServicoForm
        onSuccess={() => {
          setMostrarFormulario(false)
          recarregar()
        }}
        onCancel={() => setMostrarFormulario(false)}
      />
    )
  }

  return (
    <div className="max-w-7xl mx-auto p-6 space-y-6">
      
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Ordens de Serviço</h1>
          <p className="text-gray-600">Gerencie suas ordens de serviço técnico</p>
        </div>
        
        <div className="flex gap-3">
          <Button
            variant="outline"
            onClick={() => setMostrarFiltros(!mostrarFiltros)}
            className="gap-2"
          >
            <Filter className="w-4 h-4" />
            Filtros
          </Button>
          
          <Button
            onClick={() => setMostrarFormulario(true)}
            className="gap-2"
          >
            <Plus className="w-4 h-4" />
            Nova OS
          </Button>
        </div>
      </div>

      {/* Filtros */}
      {mostrarFiltros && (
        <Card className="p-4">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Buscar
              </label>
              <div className="relative">
                <Search className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
                <input
                  type="text"
                  placeholder="Cliente, marca, modelo..."
                  value={filtros.busca || ''}
                  onChange={(e) => aplicarFiltros({ busca: e.target.value })}
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Status
              </label>
              <select
                value={filtros.status?.[0] || ''}
                onChange={(e) => aplicarFiltros({ 
                  status: e.target.value ? [e.target.value as StatusOS] : undefined 
                })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Todos os status</option>
                {STATUS_OPTIONS.map(status => (
                  <option key={status} value={status}>{status}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo
              </label>
              <select
                value={filtros.tipo?.[0] || ''}
                onChange={(e) => aplicarFiltros({ 
                  tipo: e.target.value ? [e.target.value as TipoEquipamento] : undefined 
                })}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Todos os tipos</option>
                {TIPO_OPTIONS.map(tipo => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
            </div>

            <div className="flex items-end">
              <Button
                variant="outline"
                onClick={limparFiltros}
                className="w-full"
              >
                Limpar Filtros
              </Button>
            </div>
          </div>
        </Card>
      )}

      {/* Estatísticas rápidas */}
      <StatusCardsOS />

      {/* Lista de Ordens */}
      <Card className="overflow-hidden">
        {loading ? (
          <div className="p-8 text-center">
            <RefreshCw className="w-6 h-6 text-blue-600 animate-spin mx-auto mb-2" />
            <p className="text-gray-600">Carregando ordens de serviço...</p>
          </div>
        ) : ordens.length === 0 ? (
          <div className="p-8 text-center">
            <div className="text-gray-400 mb-4">📋</div>
            <p className="text-gray-600 mb-4">Nenhuma ordem de serviço encontrada</p>
            <Button onClick={() => setMostrarFormulario(true)} className="gap-2">
              <Plus className="w-4 h-4" />
              Criar primeira OS
            </Button>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b">
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
                    Data Entrada
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Previsão
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Valor
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Ações
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {ordens.map((ordem) => (
                  <tr key={ordem.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        #{ordem.id.slice(-6).toUpperCase()}
                      </div>
                    </td>
                    
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <User className="w-4 h-4 text-gray-400 mr-2" />
                        <div>
                          <div className="text-sm font-medium text-gray-900">
                            {ordem.cliente?.nome}
                          </div>
                          <div className="text-sm text-gray-500 flex items-center">
                            <Phone className="w-3 h-3 mr-1" />
                            {ordem.cliente?.telefone}
                          </div>
                        </div>
                      </div>
                    </td>
                    
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <span className="text-lg mr-2">
                          {TIPO_ICONS[ordem.tipo]}
                        </span>
                        <div>
                          <div className="text-sm font-medium text-gray-900">
                            {ordem.marca} {ordem.modelo}
                          </div>
                          <div className="text-sm text-gray-500">
                            {ordem.tipo}
                          </div>
                        </div>
                      </div>
                    </td>
                    
                    <td className="px-6 py-4 whitespace-nowrap">
                      <select
                        value={ordem.status}
                        onChange={(e) => atualizarStatus(ordem.id, e.target.value as StatusOS)}
                        disabled={atualizandoStatus === ordem.id}
                        className={`text-xs px-2 py-1 rounded-full border font-medium ${STATUS_COLORS[ordem.status]} focus:outline-none focus:ring-2 focus:ring-blue-500`}
                      >
                        {STATUS_OPTIONS.map(status => (
                          <option key={status} value={status}>{status}</option>
                        ))}
                      </select>
                    </td>
                    
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center text-sm text-gray-900">
                        <Calendar className="w-4 h-4 text-gray-400 mr-2" />
                        {formatarData(ordem.data_entrada)}
                      </div>
                    </td>
                    
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-900">
                        {ordem.data_previsao ? formatarData(ordem.data_previsao) : '-'}
                      </div>
                    </td>
                    
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">
                        {formatarValor(ordem.valor_orcamento)}
                      </div>
                    </td>
                    
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <div className="flex items-center justify-end gap-2">
                        <Link
                          to={`/ordens-servico/${ordem.id}`}
                          className="text-blue-600 hover:text-blue-900 p-1 rounded"
                          title="Visualizar"
                        >
                          <Eye className="w-4 h-4" />
                        </Link>
                        
                        <Link
                          to={`/ordens-servico/${ordem.id}/editar`}
                          className="text-green-600 hover:text-green-900 p-1 rounded"
                          title="Editar"
                        >
                          <Edit className="w-4 h-4" />
                        </Link>
                        
                        <button
                          onClick={() => window.print()}
                          className="text-gray-600 hover:text-gray-900 p-1 rounded"
                          title="Imprimir"
                        >
                          <Printer className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </div>
  )
}
