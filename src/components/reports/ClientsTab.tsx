import React, { useState, useEffect } from 'react'
import { reportsService } from '../../services/reportsService'

interface ClientsTabProps {
  formatCurrency: (value: number) => string
}

export const ClientsTab: React.FC<ClientsTabProps> = ({
  formatCurrency
}) => {
  const [loading, setLoading] = useState(false)
  const [clientsData, setClientsData] = useState<any>(null)

  useEffect(() => {
    const loadClientsData = async () => {
      setLoading(true)
      try {
        const data = await reportsService.getDashboardMetrics()
        setClientsData(data)
      } catch (error) {
        console.error('Erro ao carregar dados de clientes:', error)
      } finally {
        setLoading(false)
      }
    }

    loadClientsData()
  }, [])

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-purple-500"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900">Relatório de Clientes</h2>
      
      {/* Resumo de Clientes */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Resumo de Clientes</h3>
        {clientsData ? (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Total de Clientes</div>
              <div className="text-2xl font-bold text-blue-600">
                {clientsData.clientsCount || 0}
              </div>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Clientes Ativos</div>
              <div className="text-2xl font-bold text-green-600">
                {Math.floor((clientsData.clientsCount || 0) * 0.7)} {/* Simulação: 70% ativos */}
              </div>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Ticket Médio</div>
              <div className="text-2xl font-bold text-purple-600">
                {formatCurrency(clientsData.averageTicket || 0)}
              </div>
            </div>
            <div className="bg-yellow-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Novos este Mês</div>
              <div className="text-2xl font-bold text-yellow-600">
                {Math.floor((clientsData.clientsCount || 0) * 0.1)} {/* Simulação: 10% novos */}
              </div>
            </div>
          </div>
        ) : (
          <div className="text-center text-gray-500 py-8">
            Nenhum dado disponível
          </div>
        )}
      </div>

      {/* Top 10 Clientes */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Top 10 Clientes por Valor</h3>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr className="bg-gray-50">
                <th className="border border-gray-300 p-2 text-left">Posição</th>
                <th className="border border-gray-300 p-2 text-left">Cliente</th>
                <th className="border border-gray-300 p-2 text-left">Total Compras</th>
                <th className="border border-gray-300 p-2 text-left">Nº Pedidos</th>
                <th className="border border-gray-300 p-2 text-left">Ticket Médio</th>
                <th className="border border-gray-300 p-2 text-left">Última Compra</th>
              </tr>
            </thead>
            <tbody>
              {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((position) => (
                <tr key={position} className="hover:bg-gray-50">
                  <td className="border border-gray-300 p-2 text-center">
                    <span className={`inline-flex items-center justify-center w-6 h-6 rounded-full text-xs font-bold ${
                      position <= 3 ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-600'
                    }`}>
                      {position}
                    </span>
                  </td>
                  <td className="border border-gray-300 p-2">
                    <div>
                      <div className="font-medium">Cliente {position}</div>
                      <div className="text-sm text-gray-500">cliente{position}@email.com</div>
                    </div>
                  </td>
                  <td className="border border-gray-300 p-2 font-semibold">
                    {formatCurrency(0)}
                  </td>
                  <td className="border border-gray-300 p-2 text-center">0</td>
                  <td className="border border-gray-300 p-2">
                    {formatCurrency(0)}
                  </td>
                  <td className="border border-gray-300 p-2 text-sm text-gray-500">
                    Nunca
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Análise de Clientes */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Clientes por Frequência */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Clientes por Frequência</h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center p-3 bg-green-50 rounded">
              <span>Clientes Frequentes (5+ compras)</span>
              <span className="font-semibold text-green-600">0</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-blue-50 rounded">
              <span>Clientes Regulares (2-4 compras)</span>
              <span className="font-semibold text-blue-600">0</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-yellow-50 rounded">
              <span>Clientes Ocasionais (1 compra)</span>
              <span className="font-semibold text-yellow-600">0</span>
            </div>
          </div>
        </div>

        {/* Clientes por Período */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-lg font-semibold mb-4">Novos Clientes por Período</h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded">
              <span>Este Mês</span>
              <span className="font-semibold">0</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded">
              <span>Mês Passado</span>
              <span className="font-semibold">0</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded">
              <span>Últimos 3 Meses</span>
              <span className="font-semibold">0</span>
            </div>
          </div>
        </div>
      </div>

      {/* Gráfico de Evolução */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Evolução da Base de Clientes</h3>
        <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
          <span className="text-gray-500">Gráfico de evolução da base de clientes (a implementar)</span>
        </div>
      </div>

      {/* Clientes Inativos */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Clientes Inativos (sem compras há 30+ dias)</h3>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr className="bg-gray-50">
                <th className="border border-gray-300 p-2 text-left">Cliente</th>
                <th className="border border-gray-300 p-2 text-left">Última Compra</th>
                <th className="border border-gray-300 p-2 text-left">Total Histórico</th>
                <th className="border border-gray-300 p-2 text-left">Dias Inativo</th>
                <th className="border border-gray-300 p-2 text-left">Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td colSpan={5} className="border border-gray-300 p-4 text-center text-gray-500">
                  Nenhum cliente inativo
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default ClientsTab