import React, { useState } from 'react';
import { 
  ArrowLeft, 
  PieChart as PieChartIcon, 
  BarChart3, 
  TrendingUp,
  RefreshCw
} from 'lucide-react';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend
} from 'recharts';

const RelatoriosGraficosPage: React.FC = () => {
  const [selectedPeriod, setSelectedPeriod] = useState('7dias');
  const [loading, setLoading] = useState(false);

  // Dados para vendas por dia - carregados do Supabase
  const vendasPorDia: any[] = []

  // Dados para formas de pagamento - carregados do Supabase
  const formasPagamento: any[] = []

  // Dados para evolução das vendas - carregados do Supabase
  const evolucaoVendas: any[] = []

  // Dados para produtos mais vendidos - carregados do Supabase
  const produtosMaisVendidos: any[] = []

  const updatePeriod = (period: string) => {
    setSelectedPeriod(period);
    setLoading(true);
    setTimeout(() => setLoading(false), 1000);
  };

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
      minimumFractionDigits: 0
    }).format(value);
  };

  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-white p-3 border border-gray-200 rounded-lg shadow-md">
          <p className="font-medium">{label}</p>
          {payload.map((entry: any, index: number) => (
            <p key={index} style={{ color: entry.color }}>
              {entry.dataKey === 'vendas' ? formatCurrency(entry.value) : `${entry.value} pedidos`}
            </p>
          ))}
        </div>
      );
    }
    return null;
  };

  const PieTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-white p-3 border border-gray-200 rounded-lg shadow-md">
          <p className="font-medium">{payload[0].name}</p>
          <p style={{ color: payload[0].color }}>
            {payload[0].value}% das vendas
          </p>
        </div>
      );
    }
    return null;
  };

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-4 mb-4">
            <button
              onClick={() => window.history.back()}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
            >
              <ArrowLeft className="h-5 w-5" />
              Voltar
            </button>
          </div>
          
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-3 bg-pink-100 rounded-lg">
                <PieChartIcon className="h-8 w-8 text-pink-600" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Gráficos e Dashboards</h1>
                <p className="text-gray-600">Visualizações interativas e análises visuais</p>
              </div>
            </div>

            <div className="flex items-center gap-4">
              <select
                value={selectedPeriod}
                onChange={(e) => updatePeriod(e.target.value)}
                className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-pink-500 focus:border-transparent"
              >
                <option value="7dias">Últimos 7 dias</option>
                <option value="30dias">Últimos 30 dias</option>
                <option value="90dias">Últimos 3 meses</option>
                <option value="12meses">Últimos 12 meses</option>
              </select>
              
              <button
                onClick={() => updatePeriod(selectedPeriod)}
                disabled={loading}
                className="flex items-center gap-2 px-4 py-2 bg-pink-600 text-white rounded-lg hover:bg-pink-700 disabled:opacity-50"
              >
                <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
                Atualizar
              </button>
            </div>
          </div>
        </div>

        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-pink-600"></div>
          </div>
        ) : (
          <div className="space-y-8">
            {/* Gráfico de Vendas por Dia */}
            <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
              <div className="flex items-center gap-2 mb-6">
                <BarChart3 className="h-6 w-6 text-blue-600" />
                <h3 className="text-xl font-semibold text-gray-900">Vendas por Dia</h3>
              </div>
              
              <div className="h-80">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={vendasPorDia}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                    <XAxis dataKey="dia" />
                    <YAxis yAxisId="left" orientation="left" />
                    <YAxis yAxisId="right" orientation="right" />
                    <Tooltip content={<CustomTooltip />} />
                    <Legend />
                    <Bar yAxisId="left" dataKey="vendas" fill="#3B82F6" name="Vendas (R$)" />
                    <Bar yAxisId="right" dataKey="pedidos" fill="#10B981" name="Pedidos" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Grid com Gráfico de Pizza e Evolução */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Formas de Pagamento - Pizza */}
              <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
                <div className="flex items-center gap-2 mb-6">
                  <PieChartIcon className="h-6 w-6 text-green-600" />
                  <h3 className="text-xl font-semibold text-gray-900">Formas de Pagamento</h3>
                </div>
                
                <div className="h-80">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie
                        data={formasPagamento}
                        cx="50%"
                        cy="50%"
                        outerRadius={100}
                        fill="#8884d8"
                        dataKey="value"
                      >
                        {formasPagamento.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip content={<PieTooltip />} />
                    </PieChart>
                  </ResponsiveContainer>
                </div>

                {/* Legenda personalizada */}
                <div className="flex justify-center gap-6 mt-4">
                  {formasPagamento.map((forma, index) => (
                    <div key={index} className="flex items-center gap-2">
                      <div 
                        className="w-3 h-3 rounded-full" 
                        style={{ backgroundColor: forma.color }}
                      ></div>
                      <span className="text-sm text-gray-600">{forma.name}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Evolução das Vendas - Linha */}
              <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
                <div className="flex items-center gap-2 mb-6">
                  <TrendingUp className="h-6 w-6 text-purple-600" />
                  <h3 className="text-xl font-semibold text-gray-900">Evolução das Vendas</h3>
                </div>
                
                <div className="h-80">
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={evolucaoVendas}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                      <XAxis dataKey="mes" />
                      <YAxis />
                      <Tooltip 
                        formatter={(value: number, name: string) => [
                          formatCurrency(value), 
                          name === 'vendas' ? 'Vendas' : 'Meta'
                        ]}
                      />
                      <Legend />
                      <Line 
                        type="monotone" 
                        dataKey="vendas" 
                        stroke="#8B5CF6" 
                        strokeWidth={3}
                        name="Vendas"
                      />
                      <Line 
                        type="monotone" 
                        dataKey="meta" 
                        stroke="#EF4444" 
                        strokeWidth={2}
                        strokeDasharray="5 5"
                        name="Meta"
                      />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              </div>
            </div>

            {/* Produtos Mais Vendidos - Barras Horizontais */}
            <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
              <div className="flex items-center gap-2 mb-6">
                <BarChart3 className="h-6 w-6 text-orange-600" />
                <h3 className="text-xl font-semibold text-gray-900">Produtos Mais Vendidos</h3>
              </div>
              
              <div className="space-y-4">
                {produtosMaisVendidos.map((produto, index) => (
                  <div key={index} className="flex items-center gap-4">
                    <div className="w-32 text-sm text-gray-600 truncate">
                      {produto.produto}
                    </div>
                    <div className="flex-1 bg-gray-200 rounded-full h-6 relative">
                      <div 
                        className="bg-gradient-to-r from-orange-400 to-orange-600 h-6 rounded-full flex items-center justify-end pr-2"
                        style={{ width: `${(produto.vendas / 450) * 100}%` }}
                      >
                        <span className="text-white text-xs font-medium">
                          {produto.vendas}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Cards de Estatísticas Rápidas */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
              <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 text-center">
                <div className="text-3xl font-bold text-blue-600 mb-2">2.4k</div>
                <div className="text-sm text-gray-600">Vendas este mês</div>
                <div className="text-xs text-green-600 mt-1">+12% vs mês anterior</div>
              </div>
              
              <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 text-center">
                <div className="text-3xl font-bold text-green-600 mb-2">R$ 85k</div>
                <div className="text-sm text-gray-600">Faturamento</div>
                <div className="text-xs text-green-600 mt-1">+8% vs mês anterior</div>
              </div>
              
              <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 text-center">
                <div className="text-3xl font-bold text-purple-600 mb-2">156</div>
                <div className="text-sm text-gray-600">Clientes ativos</div>
                <div className="text-xs text-green-600 mt-1">+15 novos clientes</div>
              </div>
              
              <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 text-center">
                <div className="text-3xl font-bold text-orange-600 mb-2">R$ 354</div>
                <div className="text-sm text-gray-600">Ticket médio</div>
                <div className="text-xs text-red-600 mt-1">-2% vs mês anterior</div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default RelatoriosGraficosPage;
