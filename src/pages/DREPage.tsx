import React, { useState, useEffect } from 'react';
import { useDRE } from '../hooks/useDRE';
import { Download, Calendar, TrendingUp, DollarSign, Package, AlertCircle } from 'lucide-react';

export default function DREPage() {
  const { dre, kpis, loading, calcularDRE, exportarCSV } = useDRE();
  
  // Definir data de fim como hoje e data de início como 30 dias atrás
  const hoje = new Date();
  const trintaDiasAtras = new Date();
  trintaDiasAtras.setDate(hoje.getDate() - 30);
  
  const [dataInicio, setDataInicio] = useState(trintaDiasAtras);
  const [dataFim, setDataFim] = useState(hoje);

  const handleCalcular = () => {
    console.log('🔍 [DRE] Calculando com período:', { dataInicio, dataFim });
    calcularDRE({ data_inicio: dataInicio, data_fim: dataFim });
  };

  useEffect(() => {
    handleCalcular();
    
    // ✅ ATUALIZAÇÃO AUTOMÁTICA A CADA 30 SEGUNDOS
    const interval = setInterval(() => {
      console.log('🔄 Atualizando DRE automaticamente...');
      handleCalcular();
    }, 30000);
    
    // ✅ LISTENER PARA NOVA VENDA/COMPRA
    const handleUpdate = () => {
      console.log('🎉 Atualização detectada! Recalculando DRE...');
      handleCalcular();
    };
    
    window.addEventListener('saleCompleted', handleUpdate);
    window.addEventListener('purchaseCompleted', handleUpdate);
    window.addEventListener('expenseAdded', handleUpdate);
    
    return () => {
      clearInterval(interval);
      window.removeEventListener('saleCompleted', handleUpdate);
      window.removeEventListener('purchaseCompleted', handleUpdate);
      window.removeEventListener('expenseAdded', handleUpdate);
    };
  }, []);

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(value);
  };

  const formatPercent = (value: number) => {
    return `${value.toFixed(2)}%`;
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="flex flex-col lg:flex-row justify-between items-start lg:items-center mb-6 gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">📊 DRE - Demonstração do Resultado do Exercício</h1>
          <p className="text-gray-600 mt-1">Análise completa de receitas, custos e resultado líquido</p>
        </div>
        <button
          onClick={exportarCSV}
          disabled={!dre || loading}
          className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          <Download size={20} />
          Exportar CSV
        </button>
      </div>

      {/* Filtros de Período */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <Calendar size={20} className="text-blue-600" />
          Período de Análise
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Data Início
            </label>
            <input
              type="date"
              value={dataInicio.toISOString().split('T')[0]}
              onChange={(e) => setDataInicio(new Date(e.target.value))}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Data Fim
            </label>
            <input
              type="date"
              value={dataFim.toISOString().split('T')[0]}
              onChange={(e) => setDataFim(new Date(e.target.value))}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <div className="flex items-end">
            <button
              onClick={handleCalcular}
              disabled={loading}
              className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors flex items-center justify-center gap-2"
            >
              <Calendar size={20} />
              {loading ? 'Calculando...' : 'Calcular DRE'}
            </button>
          </div>
        </div>
      </div>

      {loading && (
        <div className="flex items-center justify-center py-12">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
            <p className="text-gray-600">Calculando DRE...</p>
          </div>
        </div>
      )}

      {!loading && !dre && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 flex items-start gap-3">
          <AlertCircle className="text-yellow-600 flex-shrink-0 mt-1" size={20} />
          <div>
            <h3 className="font-semibold text-yellow-900 mb-1">Nenhum dado encontrado</h3>
            <p className="text-yellow-700 text-sm">
              Não há vendas ou movimentações registradas no período selecionado.
              Certifique-se de ter vendas e compras cadastradas.
            </p>
          </div>
        </div>
      )}

      {dre && kpis && (
        <>
          {/* KPIs Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg shadow-lg p-6 text-white">
              <div className="flex items-center justify-between mb-2">
                <h3 className="text-sm font-medium opacity-90">Margem Bruta</h3>
                <TrendingUp size={20} className="opacity-75" />
              </div>
              <p className="text-3xl font-bold">{formatPercent(kpis.margem_bruta_percentual)}</p>
              <p className="text-xs mt-2 opacity-75">Lucro Bruto / Receita Líquida</p>
            </div>

            <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-lg shadow-lg p-6 text-white">
              <div className="flex items-center justify-between mb-2">
                <h3 className="text-sm font-medium opacity-90">Margem Operacional</h3>
                <Package size={20} className="opacity-75" />
              </div>
              <p className="text-3xl font-bold">{formatPercent(kpis.margem_operacional_percentual)}</p>
              <p className="text-xs mt-2 opacity-75">Resultado Operacional / Receita Líquida</p>
            </div>

            <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-lg shadow-lg p-6 text-white">
              <div className="flex items-center justify-between mb-2">
                <h3 className="text-sm font-medium opacity-90">Margem Líquida</h3>
                <DollarSign size={20} className="opacity-75" />
              </div>
              <p className="text-3xl font-bold">{formatPercent(kpis.margem_liquida_percentual)}</p>
              <p className="text-xs mt-2 opacity-75">Resultado Líquido / Receita Líquida</p>
            </div>

            <div className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-lg shadow-lg p-6 text-white">
              <div className="flex items-center justify-between mb-2">
                <h3 className="text-sm font-medium opacity-90">Markup Médio</h3>
                <TrendingUp size={20} className="opacity-75" />
              </div>
              <p className="text-3xl font-bold">{formatPercent(kpis.markup_medio * 100)}</p>
              <p className="text-xs mt-2 opacity-75">Receita Bruta / CMV</p>
            </div>
          </div>

          {/* DRE Table */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-4">
              <h2 className="text-xl font-bold text-white">Demonstração do Resultado do Exercício</h2>
              <p className="text-blue-100 text-sm mt-1">
                Período: {dataInicio.toLocaleDateString('pt-BR')} até {dataFim.toLocaleDateString('pt-BR')}
              </p>
            </div>
            
            <div className="p-6">
              <table className="w-full">
                <tbody className="divide-y divide-gray-200">
                  {/* Receita Bruta */}
                  <tr className="hover:bg-gray-50">
                    <td className="py-3 font-semibold text-gray-900">Receita Bruta</td>
                    <td className="py-3 text-right font-bold text-green-600 text-lg">
                      {formatCurrency(dre.receita_bruta)}
                    </td>
                  </tr>

                  {/* Deduções */}
                  <tr className="hover:bg-gray-50">
                    <td className="py-3 pl-6 text-gray-700">(-) Deduções (descontos)</td>
                    <td className="py-3 text-right text-red-600">
                      {formatCurrency(dre.deducoes)}
                    </td>
                  </tr>

                  {/* Receita Líquida */}
                  <tr className="bg-blue-50 border-t-2 border-blue-200">
                    <td className="py-3 font-bold text-gray-900">(=) Receita Líquida</td>
                    <td className="py-3 text-right font-bold text-blue-700 text-lg">
                      {formatCurrency(dre.receita_liquida)}
                    </td>
                  </tr>

                  {/* Espaçador */}
                  <tr><td colSpan={2} className="h-4"></td></tr>

                  {/* CMV */}
                  <tr className="hover:bg-gray-50">
                    <td className="py-3 pl-6 text-gray-700">(-) CMV (Custo da Mercadoria Vendida)</td>
                    <td className="py-3 text-right text-red-600">
                      {formatCurrency(dre.cmv)}
                    </td>
                  </tr>

                  {/* Lucro Bruto */}
                  <tr className="bg-green-50 border-t-2 border-green-200">
                    <td className="py-3 font-bold text-gray-900">
                      (=) Lucro Bruto
                      <span className="ml-2 text-xs font-normal text-gray-600">
                        (Margem: {formatPercent(kpis.margem_bruta_percentual)})
                      </span>
                    </td>
                    <td className="py-3 text-right font-bold text-green-700 text-lg">
                      {formatCurrency(dre.lucro_bruto)}
                    </td>
                  </tr>

                  {/* Espaçador */}
                  <tr><td colSpan={2} className="h-4"></td></tr>

                  {/* Despesas Operacionais */}
                  <tr className="hover:bg-gray-50">
                    <td className="py-3 pl-6 text-gray-700">(-) Despesas Operacionais</td>
                    <td className="py-3 text-right text-red-600">
                      {formatCurrency(dre.despesas_operacionais)}
                    </td>
                  </tr>

                  {/* Resultado Operacional */}
                  <tr className="bg-yellow-50 border-t-2 border-yellow-200">
                    <td className="py-3 font-bold text-gray-900">
                      (=) Resultado Operacional
                      <span className="ml-2 text-xs font-normal text-gray-600">
                        (Margem: {formatPercent(kpis.margem_operacional_percentual)})
                      </span>
                    </td>
                    <td className="py-3 text-right font-bold text-yellow-700 text-lg">
                      {formatCurrency(dre.resultado_operacional)}
                    </td>
                  </tr>

                  {/* Espaçador */}
                  <tr><td colSpan={2} className="h-4"></td></tr>

                  {/* Outras Receitas */}
                  <tr className="hover:bg-gray-50">
                    <td className="py-3 pl-6 text-gray-700">(+) Outras Receitas</td>
                    <td className="py-3 text-right text-green-600">
                      {formatCurrency(dre.outras_receitas)}
                    </td>
                  </tr>

                  {/* Outras Despesas */}
                  <tr className="hover:bg-gray-50">
                    <td className="py-3 pl-6 text-gray-700">(-) Outras Despesas</td>
                    <td className="py-3 text-right text-red-600">
                      {formatCurrency(dre.outras_despesas)}
                    </td>
                  </tr>

                  {/* Resultado Líquido */}
                  <tr className="bg-gradient-to-r from-purple-100 to-purple-50 border-t-4 border-purple-500">
                    <td className="py-4 font-bold text-gray-900 text-lg">
                      (=) RESULTADO LÍQUIDO
                      <span className="ml-2 text-sm font-normal text-gray-600">
                        (Margem: {formatPercent(kpis.margem_liquida_percentual)})
                      </span>
                    </td>
                    <td className={`py-4 text-right font-bold text-2xl ${
                      dre.resultado_liquido >= 0 ? 'text-purple-700' : 'text-red-700'
                    }`}>
                      {formatCurrency(dre.resultado_liquido)}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          {/* Informações Adicionais */}
          <div className="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h3 className="font-semibold text-blue-900 mb-2">📌 Informações</h3>
            <ul className="text-sm text-blue-800 space-y-1">
              <li>• <strong>CMV</strong> = Custo da Mercadoria Vendida (calculado pelo custo médio móvel)</li>
              <li>• <strong>Margem Bruta</strong> = (Lucro Bruto / Receita Líquida) × 100</li>
              <li>• <strong>Margem Operacional</strong> = (Resultado Operacional / Receita Líquida) × 100</li>
              <li>• <strong>Margem Líquida</strong> = (Resultado Líquido / Receita Líquida) × 100</li>
            </ul>
          </div>
        </>
      )}
    </div>
  );
}
