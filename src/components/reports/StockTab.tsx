import React, { useState, useEffect } from 'react'
import { reportsService } from '../../services/reportsService'

interface StockTabProps {
  formatCurrency: (value: number) => string
}

export const StockTab: React.FC<StockTabProps> = ({
  formatCurrency
}) => {
  const [loading, setLoading] = useState(false)
  const [stockData, setStockData] = useState<any>(null)

  useEffect(() => {
    const loadStockData = async () => {
      setLoading(true)
      try {
        const data = await reportsService.getDashboardMetrics()
        setStockData(data)
      } catch (error) {
        console.error('Erro ao carregar dados de estoque:', error)
      } finally {
        setLoading(false)
      }
    }

    loadStockData()
  }, [])

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-orange-500"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900">Relatório de Estoque</h2>
      
      {/* Resumo de Estoque */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Resumo do Estoque</h3>
        {stockData ? (
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Total de Produtos</div>
              <div className="text-2xl font-bold text-blue-600">
                {stockData.productsCount || 0}
              </div>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Valor Total</div>
              <div className="text-2xl font-bold text-green-600">
                {formatCurrency(0)} {/* TODO: Calcular valor total do estoque */}
              </div>
            </div>
            <div className="bg-yellow-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Estoque Baixo</div>
              <div className="text-2xl font-bold text-yellow-600">
                0 {/* TODO: Implementar produtos com estoque baixo */}
              </div>
            </div>
            <div className="bg-red-50 p-4 rounded-lg">
              <div className="text-sm text-gray-600">Sem Estoque</div>
              <div className="text-2xl font-bold text-red-600">
                0 {/* TODO: Implementar produtos sem estoque */}
              </div>
            </div>
          </div>
        ) : (
          <div className="text-center text-gray-500 py-8">
            Nenhum dado disponível
          </div>
        )}
      </div>

      {/* Produtos com Estoque Baixo */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Produtos com Estoque Baixo</h3>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr className="bg-gray-50">
                <th className="border border-gray-300 p-2 text-left">Produto</th>
                <th className="border border-gray-300 p-2 text-left">Categoria</th>
                <th className="border border-gray-300 p-2 text-left">Estoque Atual</th>
                <th className="border border-gray-300 p-2 text-left">Estoque Mínimo</th>
                <th className="border border-gray-300 p-2 text-left">Valor Unitário</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td colSpan={5} className="border border-gray-300 p-4 text-center text-gray-500">
                  Nenhum produto com estoque baixo
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      {/* Produtos Mais Vendidos */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Produtos Mais Vendidos</h3>
        <div className="space-y-3">
          {[1, 2, 3, 4, 5].map((item) => (
            <div key={item} className="flex justify-between items-center p-3 bg-gray-50 rounded">
              <div>
                <div className="font-medium">Produto {item}</div>
                <div className="text-sm text-gray-500">Categoria Exemplo</div>
              </div>
              <div className="text-right">
                <div className="font-semibold">0 vendas</div>
                <div className="text-sm text-gray-500">{formatCurrency(0)}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Movimentação de Estoque */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Movimentação de Estoque (Últimos 30 dias)</h3>
        <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
          <span className="text-gray-500">Gráfico de movimentação de estoque (a implementar)</span>
        </div>
      </div>

      {/* Produtos Sem Movimento */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-lg font-semibold mb-4">Produtos Sem Movimento (30 dias)</h3>
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr className="bg-gray-50">
                <th className="border border-gray-300 p-2 text-left">Produto</th>
                <th className="border border-gray-300 p-2 text-left">Categoria</th>
                <th className="border border-gray-300 p-2 text-left">Estoque</th>
                <th className="border border-gray-300 p-2 text-left">Valor Investido</th>
                <th className="border border-gray-300 p-2 text-left">Dias Sem Venda</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td colSpan={5} className="border border-gray-300 p-4 text-center text-gray-500">
                  Nenhum produto sem movimento
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default StockTab