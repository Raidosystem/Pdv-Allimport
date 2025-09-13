import React, { useState, useEffect } from 'react'
import { reportsService } from '../../services/reportsService'
import type { ReportFilters } from '../../types/reports'

interface SalesTabProps {
  filters: ReportFilters
  setFilters: (filters: ReportFilters) => void
  formatCurrency: (value: number) => string
}

export const SalesTabComponent: React.FC<SalesTabProps> = ({
  filters,
  setFilters,
  formatCurrency
}) => {
  const [loading, setLoading] = useState(false)
  const [salesData, setSalesData] = useState<any>(null)

  useEffect(() => {
    const loadSalesData = async () => {
      setLoading(true)
      try {
        const data = await reportsService.getDashboardMetrics(filters)
        setSalesData(data)
      } catch (error) {
        console.error('Erro ao carregar dados de vendas:', error)
      } finally {
        setLoading(false)
      }
    }

    loadSalesData()
  }, [filters])

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900">Relatório de Vendas</h2>
      
      {/* Filtros */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Filtros</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Data Inicial
            </label>
            <input
              type="date"
              value={filters.startDate || ''}
              onChange={(e) => setFilters({ ...filters, startDate: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Data Final
            </label>
            <input
              type="date"
              value={filters.endDate || ''}
              onChange={(e) => setFilters({ ...filters, endDate: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Forma de Pagamento
            </label>
            <select
              value={filters.paymentMethod || ''}
              onChange={(e) => setFilters({ ...filters, paymentMethod: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">Todos</option>
              <option value="pix">PIX</option>
              <option value="cartao">Cartão</option>
              <option value="dinheiro">Dinheiro</option>
            </select>
          </div>
        </div>
      </div>

      {/* Dados de Vendas */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Resumo de Vendas</h3>
        {salesData ? (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Total de Vendas</div>
              <div className="text-2xl font-bold text-blue-600">
                {formatCurrency(salesData.totalSales || 0)}
              </div>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Número de Vendas</div>
              <div className="text-2xl font-bold text-green-600">
                {salesData.salesCount || 0}
              </div>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Ticket Médio</div>
              <div className="text-2xl font-bold text-purple-600">
                {formatCurrency(salesData.averageTicket || 0)}
              </div>
            </div>
            <div className="bg-yellow-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Clientes Atendidos</div>
              <div className="text-2xl font-bold text-yellow-600">
                {salesData.clientsCount || 0}
              </div>
            </div>
          </div>
        ) : (
          <div className="text-center text-gray-500 py-8">
            Nenhum dado disponível
          </div>
        )}
      </div>
    </div>
  )
}

export default SalesTabComponent