import React, { useState, useEffect } from 'react'
import { reportsService } from '../../services/reportsService'
import type { ReportFilters } from '../../types/reports'

interface FinancialTabProps {
  filters: ReportFilters
  setFilters: (filters: ReportFilters) => void
  formatCurrency: (value: number) => string
}

export const FinancialTab: React.FC<FinancialTabProps> = ({
  filters,
  setFilters,
  formatCurrency
}) => {
  const [loading, setLoading] = useState(false)
  const [financialData, setFinancialData] = useState<any>(null)

  useEffect(() => {
    const loadFinancialData = async () => {
      setLoading(true)
      try {
        const data = await reportsService.getDashboardMetrics(filters)
        setFinancialData(data)
      } catch (error) {
        console.error('Erro ao carregar dados financeiros:', error)
      } finally {
        setLoading(false)
      }
    }

    loadFinancialData()
  }, [filters])

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-green-500"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900">Relatório Financeiro</h2>
      
      {/* Filtros */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Período</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Data Inicial
            </label>
            <input
              type="date"
              value={filters.startDate || ''}
              onChange={(e) => setFilters({ ...filters, startDate: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
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
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
            />
          </div>
        </div>
      </div>

      {/* Resumo Financeiro */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Resumo Financeiro</h3>
        {financialData ? (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-green-50 p-6 rounded-lg">
              <div className="text-sm text-gray-600">Receitas</div>
              <div className="text-3xl font-bold text-green-600">
                {formatCurrency(financialData.totalSales || 0)}
              </div>
              <div className="text-sm text-green-500 mt-1">
                {financialData.salesCount || 0} vendas
              </div>
            </div>
            <div className="bg-red-50 p-6 rounded-lg">
              <div className="text-sm text-gray-600">Despesas</div>
              <div className="text-3xl font-bold text-red-600">
                {formatCurrency(0)} {/* TODO: Implementar despesas */}
              </div>
              <div className="text-sm text-red-500 mt-1">
                0 lançamentos
              </div>
            </div>
            <div className="bg-blue-50 p-6 rounded-lg">
              <div className="text-sm text-gray-600">Lucro Líquido</div>
              <div className="text-3xl font-bold text-blue-600">
                {formatCurrency(financialData.totalSales || 0)}
              </div>
              <div className="text-sm text-blue-500 mt-1">
                Margem: 100% {/* TODO: Calcular margem real */}
              </div>
            </div>
          </div>
        ) : (
          <div className="text-center text-gray-500 py-8">
            Nenhum dado disponível
          </div>
        )}
      </div>

      {/* Formas de Pagamento */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Formas de Pagamento</h3>
        <div className="space-y-3">
          {financialData ? (
            <>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded">
                <span>PIX</span>
                <span className="font-semibold">{formatCurrency(0)}</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded">
                <span>Cartão de Crédito</span>
                <span className="font-semibold">{formatCurrency(0)}</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded">
                <span>Dinheiro</span>
                <span className="font-semibold">{formatCurrency(0)}</span>
              </div>
            </>
          ) : (
            <div className="text-center text-gray-500 py-4">
              Nenhum dado disponível
            </div>
          )}
        </div>
      </div>

      {/* Evolução Mensal */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Evolução Mensal</h3>
        <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
          <span className="text-gray-500">Gráfico de evolução mensal (a implementar)</span>
        </div>
      </div>
    </div>
  )
}

export default FinancialTab