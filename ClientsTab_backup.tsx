import { useState, useEffect } from 'react'
import { Search, Download, Users, UserCheck, UserX, TrendingUp, Printer } from 'lucide-react'
import { reportsService } from '../../services/reportsService'
import { ExportService } from '../../services/exportService'
import type { ClientsReport } from '../../types/reports'
import toast from 'react-hot-toast'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'

interface ClientsTabProps {
  formatCurrency: (value: number) => string
}

export function ClientsTab({ formatCurrency }: ClientsTabProps) {
  const [loading, setLoading] = useState(false)
  const [clientsData, setClientsData] = useState<ClientsReport | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [sortBy, setSortBy] = useState<'nome' | 'valor_total' | 'total_compras' | 'ultima_compra'>('valor_total')

  useEffect(() => {
    loadClientsReport()
  }, [])

  const loadClientsReport = async () => {
    try {
      setLoading(true)
      console.log('🔄 ClientsTab: Carregando relatório de clientes...')
      const data = await reportsService.getClientsReport()
      console.log('✅ ClientsTab: Dados carregados:', data)
      setClientsData(data)
    } catch (error: any) {
      console.error('❌ ClientsTab: Erro ao carregar relatório:', error)
      toast.error('Erro ao carregar relatório: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const handleExportPDF = async () => {
    if (!clientsData) {
      toast.error('Nenhum dado de clientes para exportar')
      return
    }
    
    try {
      await ExportService.exportClientsToPDF(clientsData)
      toast.success('PDF exportado com sucesso!')
    } catch (error: any) {
      console.error('Erro ao exportar PDF:', error)
      toast.error('Erro ao exportar PDF: ' + error.message)
    }
  }

  const handleExportExcel = async () => {
    if (!clientsData) {
      toast.error('Nenhum dado de clientes para exportar')
      return
    }
    
    try {
      await ExportService.exportClientsToExcel(clientsData)
      toast.success('Excel exportado com sucesso!')
    } catch (error: any) {
      console.error('Erro ao exportar Excel:', error)
      toast.error('Erro ao exportar Excel: ' + error.message)
    }
  }

  const handlePrint = () => {
    if (!clientsData) {
      toast.error('Nenhum dado de clientes para imprimir')
      return
    }
    
    try {
      ExportService.printElement('clients-report')
      toast.success('Impressão iniciada!')
    } catch (error: any) {
      console.error('Erro ao imprimir:', error)
      toast.error('Erro ao imprimir: ' + error.message)
    }
  }

  const exportToPDF = async () => {
    if (!clientsData) {
      toast.error('Nenhum dado para exportar')
      return
    }
    
    try {
      await ExportService.exportClientsToPDF(clientsData)
      toast.success('Relatório PDF gerado com sucesso!')
    } catch (error) {
      console.error('Erro ao exportar PDF:', error)
      toast.error('Erro ao gerar PDF')
    }
  }

  const exportToExcel = async () => {
    if (!clientsData) {
      toast.error('Nenhum dado para exportar')
      return
    }
    
    try {
      await ExportService.exportClientsToExcel(clientsData)
      toast.success('Planilha Excel gerada com sucesso!')
    } catch (error) {
      console.error('Erro ao exportar Excel:', error)
      toast.error('Erro ao gerar planilha')
    }
  }

  const filteredAndSortedClients = clientsData?.clientes
    .filter(cliente =>
      cliente.nome?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      cliente.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      cliente.telefone?.includes(searchTerm)
    )
    .sort((a, b) => {
      switch (sortBy) {
        case 'nome':
          return a.nome.localeCompare(b.nome)
        case 'valor_total':
          return b.valor_total - a.valor_total
        case 'total_compras':
          return b.total_compras - a.total_compras
        case 'ultima_compra':
          return new Date(b.ultima_compra || 0).getTime() - new Date(a.ultima_compra || 0).getTime()
        default:
          return 0
      }
    }) || []

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="bg-white p-8 rounded-xl shadow-sm">
          <div className="animate-pulse space-y-4">
            <div className="h-4 bg-gray-200 rounded w-1/4"></div>
            <div className="space-y-2">
              {Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="h-4 bg-gray-200 rounded"></div>
              ))}
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* DEBUG: Seção de Debug com Botões Coloridos */}
      <div className="border-2 border-yellow-400 bg-yellow-50 p-4 rounded">
        <h4 className="text-sm font-bold text-yellow-800 mb-2">🔧 DEBUG: Testar Funcionalidades</h4>
        <div className="flex flex-wrap gap-2 mb-4">
          <button
            onClick={() => {
              console.log('🔴 Debug: Teste PDF clicado')
              toast.success('🔴 Teste: Botão PDF está funcionando!')
              handleExportPDF()
            }}
            className="bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded text-sm font-medium"
          >
            🔴 Teste PDF
          </button>
          <button
            onClick={() => {
              console.log('🟢 Debug: Teste Excel clicado')
              toast.success('🟢 Teste: Botão Excel está funcionando!')
              handleExportExcel()
            }}
            className="bg-green-600 hover:bg-green-700 text-white px-3 py-1 rounded text-sm font-medium"
          >
            🟢 Teste Excel
          </button>
          <button
            onClick={() => {
              console.log('⚫ Debug: Teste Print clicado')
              toast.success('⚫ Teste: Botão Print está funcionando!')
              handlePrint()
            }}
            className="bg-gray-600 hover:bg-gray-700 text-white px-3 py-1 rounded text-sm font-medium"
          >
            ⚫ Teste Print
          </button>
          <button
            onClick={() => {
              console.log('🔄 Debug: Recarregando dados...')
              toast.loading('Recarregando dados de clientes...')
              loadClientsReport()
            }}
            className="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1 rounded text-sm font-medium"
          >
            🔄 Recarregar Dados
          </button>
        </div>
        <div className="text-xs text-yellow-700">
          <p><strong>Estado atual:</strong> {loading ? 'Carregando...' : clientsData ? `${clientsData.clientes.length} clientes carregados` : 'Sem dados'}</p>
          <p><strong>Filtrados:</strong> {filteredAndSortedClients.length} clientes</p>
        </div>
      </div>
      {/* Debug: Sempre mostrar botões */}
      <div className="bg-yellow-100 p-4 rounded-lg border-2 border-yellow-300">
        <h3 className="font-bold text-yellow-800 mb-2">🔧 BOTÕES DE TESTE - Sempre Visíveis:</h3>
        <div className="flex space-x-2">
          <button
            onClick={exportToPDF}
            className="flex items-center space-x-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            <Download className="h-4 w-4" />
            <span>PDF Teste</span>
          </button>
          <button
            onClick={exportToExcel}
            className="flex items-center space-x-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            <Download className="h-4 w-4" />
            <span>Excel Teste</span>
          </button>
          <button
            onClick={handlePrint}
            className="flex items-center space-x-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
          >
            <Printer className="h-4 w-4" />
            <span>Imprimir Teste</span>
          </button>
        </div>
        <p className="text-xs text-yellow-700 mt-2">
          Loading: {loading ? 'SIM' : 'NÃO'} | 
          Dados: {clientsData ? 'TEM DADOS' : 'SEM DADOS'} | 
          Clientes: {clientsData?.clientes?.length || 0}
        </p>
      </div>

      {/* Cards de resumo - Sempre mostrar dados ou dados de exemplo */}
      {(clientsData || true) && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div className="bg-white p-6 rounded-xl shadow-sm">
            <div className="flex items-center justify-between mb-2">
              <div className="p-3 rounded-lg bg-blue-100">
                <Users className="h-6 w-6 text-blue-600" />
              </div>
            </div>
            <h3 className="text-sm font-medium text-gray-600">Total de Clientes</h3>
            <p className="text-2xl font-bold text-gray-900">
              {clientsData?.resumo.total_clientes || 0}
            </p>
            <p className="text-sm text-gray-500">clientes cadastrados</p>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm">
            <div className="flex items-center justify-between mb-2">
              <div className="p-3 rounded-lg bg-green-100">
                <UserCheck className="h-6 w-6 text-green-600" />
              </div>
            </div>
            <h3 className="text-sm font-medium text-gray-600">Clientes Ativos</h3>
            <p className="text-2xl font-bold text-green-600">
              {clientsData?.resumo.clientes_ativos || 0}
            </p>
            <p className="text-sm text-gray-500">com compras</p>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm">
            <div className="flex items-center justify-between mb-2">
              <div className="p-3 rounded-lg bg-orange-100">
                <UserX className="h-6 w-6 text-orange-600" />
              </div>
            </div>
            <h3 className="text-sm font-medium text-gray-600">Clientes Inativos</h3>
            <p className="text-2xl font-bold text-orange-600">
              {clientsData?.resumo.clientes_inativos || 0}
            </p>
            <p className="text-sm text-gray-500">sem compras</p>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm">
            <div className="flex items-center justify-between mb-2">
              <div className="p-3 rounded-lg bg-purple-100">
                <TrendingUp className="h-6 w-6 text-purple-600" />
              </div>
            </div>
            <h3 className="text-sm font-medium text-gray-600">Ticket Médio</h3>
            <p className="text-2xl font-bold text-purple-600">
              {formatCurrency(clientsData?.resumo.ticket_medio_geral || 0)}
            </p>
            <p className="text-sm text-gray-500">por cliente</p>
          </div>
        </div>
      )}

      {/* Lista de clientes */}
      <div id="clients-report-content" className="bg-white rounded-xl shadow-sm">
        <div className="p-6 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-900">Relatório de Clientes</h3>
            <div className="flex items-center space-x-3">
              <div className="relative">
                <Search className="h-4 w-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input
                  type="text"
                  placeholder="Buscar clientes..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as any)}
                className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="valor_total">Ordenar por Valor Total</option>
                <option value="total_compras">Ordenar por Nº de Compras</option>
                <option value="ultima_compra">Ordenar por Última Compra</option>
                <option value="nome">Ordenar por Nome</option>
              </select>
              <button
                onClick={exportToPDF}
                className="flex items-center space-x-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
              >
                <Download className="h-4 w-4" />
                <span>PDF</span>
              </button>
              <button
                onClick={exportToExcel}
                className="flex items-center space-x-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
              >
                <Download className="h-4 w-4" />
                <span>Excel</span>
              </button>
              <button
                onClick={handlePrint}
                className="flex items-center space-x-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                <Printer className="h-4 w-4" />
                <span>Imprimir</span>
              </button>
            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Cliente
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Contato
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Total Compras
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Valor Total
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ticket Médio
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Última Compra
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredAndSortedClients.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-8 text-center">
                    <div className="text-gray-500">
                      <Users className="h-12 w-12 text-gray-300 mx-auto mb-4" />
                      <p className="text-lg font-medium">Nenhum cliente encontrado</p>
                      <p className="text-sm">Clique em "Criar Dados de Teste" acima para adicionar clientes de exemplo</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredAndSortedClients.map((cliente) => {
                  const ultimaCompraDate = cliente.ultima_compra ? new Date(cliente.ultima_compra) : null
                  const diasSemComprar = ultimaCompraDate ? 
                    Math.floor((Date.now() - ultimaCompraDate.getTime()) / (1000 * 60 * 60 * 24)) : 0
                  
                  return (
                    <tr key={cliente.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{cliente.nome}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{cliente.email || '-'}</div>
                        <div className="text-sm text-gray-500">{cliente.telefone || '-'}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {cliente.total_compras}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {formatCurrency(cliente.valor_total)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {formatCurrency(cliente.ticket_medio)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {ultimaCompraDate ? 
                          format(ultimaCompraDate, 'dd/MM/yyyy', { locale: ptBR }) : 
                          '-'
                        }
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          cliente.total_compras === 0 
                            ? 'bg-gray-100 text-gray-800'
                            : diasSemComprar > 90
                            ? 'bg-red-100 text-red-800'
                            : diasSemComprar > 30
                            ? 'bg-yellow-100 text-yellow-800'
                            : 'bg-green-100 text-green-800'
                        }`}>
                          {cliente.total_compras === 0 
                            ? 'Nunca comprou'
                            : diasSemComprar > 90
                            ? 'Inativo'
                            : diasSemComprar > 30
                            ? 'Pouco ativo'
                            : 'Ativo'
                          }
                        </span>
                      </td>
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
        </div>

        {filteredAndSortedClients.length === 0 && (
          <div className="text-center py-12">
            <Users className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-sm font-medium text-gray-900">Nenhum cliente encontrado</h3>
            <p className="text-sm text-gray-500">Tente ajustar o termo de busca</p>
          </div>
        )}
      </div>

      {/* Top clientes */}
      {clientsData && clientsData.clientes.length > 0 && (
        <div className="bg-white rounded-xl shadow-sm">
          <div className="p-6 border-b border-gray-200">
            <h3 className="text-lg font-semibold text-gray-900">Top 10 Clientes por Valor</h3>
          </div>
          <div className="p-6">
            <div className="space-y-4">
              {clientsData.clientes
                .sort((a, b) => b.valor_total - a.valor_total)
                .slice(0, 10)
                .map((cliente, index) => (
                  <div key={cliente.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                    <div className="flex items-center space-x-4">
                      <div className="flex items-center justify-center w-8 h-8 bg-blue-100 rounded-full">
                        <span className="text-sm font-medium text-blue-600">{index + 1}</span>
                      </div>
                      <div>
                        <div className="text-sm font-medium text-gray-900">{cliente.nome}</div>
                        <div className="text-sm text-gray-500">
                          {cliente.total_compras} compras • Ticket médio: {formatCurrency(cliente.ticket_medio)}
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-medium text-gray-900">{formatCurrency(cliente.valor_total)}</div>
                      <div className="text-sm text-gray-500">total gasto</div>
                    </div>
                  </div>
                ))
              }
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
