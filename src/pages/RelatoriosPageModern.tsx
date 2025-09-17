import React, { useState } from 'react';
import { 
  TrendingUp,
  TrendingDown,
  Users,
  DollarSign,
  ArrowLeft,
  RefreshCw,
  Download,
  Filter,
  Eye,
  Target,
  Zap,
  Activity
} from 'lucide-react';
import {
  AreaChart,
  Area,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Line,
  Legend,
  ComposedChart
} from 'recharts';
import { formatCurrency } from '../utils/format';

// ✅ PÁGINA DE RELATÓRIOS MODERNA COM GRÁFICOS AVANÇADOS

interface ModernChartProps {
  title: string;
  height?: number;
  children: React.ReactElement;
  className?: string;
}

const ModernChart: React.FC<ModernChartProps> = ({ 
  title, 
  height = 300, 
  children, 
  className = "" 
}) => (
  <div className={`bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden ${className}`}>
    <div className="p-6 border-b border-gray-100">
      <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
    </div>
    <div className="p-6">
      <ResponsiveContainer width="100%" height={height}>
        {children}
      </ResponsiveContainer>
    </div>
  </div>
);

interface KPICardProps {
  title: string;
  value: string | number;
  change?: {
    value: string;
    isPositive: boolean;
  };
  icon: React.ComponentType<any>;
  gradient: string;
  description?: string;
}

const KPICard: React.FC<KPICardProps> = ({ 
  title, 
  value, 
  change, 
  icon: Icon, 
  gradient,
  description 
}) => (
  <div className="bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden">
    <div className={`h-2 bg-gradient-to-r ${gradient}`}></div>
    <div className="p-6">
      <div className="flex items-center justify-between mb-3">
        <div className={`p-3 rounded-lg bg-gradient-to-br ${gradient} bg-opacity-10`}>
          <Icon className="w-6 h-6 text-gray-700" />
        </div>
        {change && (
          <div className={`flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium ${
            change.isPositive 
              ? 'bg-green-100 text-green-700' 
              : 'bg-red-100 text-red-700'
          }`}>
            {change.isPositive ? (
              <TrendingUp className="w-3 h-3" />
            ) : (
              <TrendingDown className="w-3 h-3" />
            )}
            {change.value}
          </div>
        )}
      </div>
      
      <div className="space-y-1">
        <p className="text-2xl font-bold text-gray-900">{value}</p>
        <p className="text-sm text-gray-600">{title}</p>
        {description && (
          <p className="text-xs text-gray-500">{description}</p>
        )}
      </div>
    </div>
  </div>
);

const RelatoriosPageModern: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [timeRange, setTimeRange] = useState('7d');

  // Dados simulados mais realistas
  const [salesData] = useState([
    { date: '10/09', day: 'Seg', vendas: 0, pedidos: 0, meta: 0 },
    { date: '11/09', day: 'Ter', vendas: 0, pedidos: 0, meta: 0 },
    { date: '12/09', day: 'Qua', vendas: 0, pedidos: 0, meta: 0 },
    { date: '13/09', day: 'Qui', vendas: 0, pedidos: 0, meta: 0 },
    { date: '14/09', day: 'Sex', vendas: 0, pedidos: 0, meta: 0 },
    { date: '15/09', day: 'Sáb', vendas: 0, pedidos: 0, meta: 0 },
    { date: '16/09', day: 'Dom', vendas: 0, pedidos: 0, meta: 0 }
  ]);

  const [monthlyData] = useState([
    { mes: 'Mar', receita: 0, lucro: 0, despesas: 0 },
    { mes: 'Abr', receita: 0, lucro: 0, despesas: 0 },
    { mes: 'Mai', receita: 0, lucro: 0, despesas: 0 },
    { mes: 'Jun', receita: 0, lucro: 0, despesas: 0 },
    { mes: 'Jul', receita: 0, lucro: 0, despesas: 0 },
    { mes: 'Ago', receita: 0, lucro: 0, despesas: 0 },
    { mes: 'Set', receita: 0, lucro: 0, despesas: 0 }
  ]);

  const [categoriesData] = useState([
    { name: 'Nenhuma categoria', value: 100, fill: '#6B7280' }
  ]);

  const [paymentMethods] = useState([
    { method: 'Nenhum registro', value: 100, color: '#6B7280', amount: 0 }
  ]);

  const [topProducts] = useState([
    { produto: 'Nenhum produto vendido', vendas: 0, receita: 0, categoria: 'N/A' }
  ]);

  const [customerMetrics] = useState([
    { mes: 'Jan', novos: 0, ativos: 0, total: 0 },
    { mes: 'Fev', novos: 0, ativos: 0, total: 0 },
    { mes: 'Mar', novos: 0, ativos: 0, total: 0 },
    { mes: 'Abr', novos: 0, ativos: 0, total: 0 },
    { mes: 'Mai', novos: 0, ativos: 0, total: 0 },
    { mes: 'Jun', novos: 0, ativos: 0, total: 0 },
    { mes: 'Jul', novos: 0, ativos: 0, total: 0 }
  ]);

  // KPIs Calculados
  const kpis = {
    totalVendas: salesData.reduce((acc, item) => acc + item.vendas, 0),
    totalPedidos: salesData.reduce((acc, item) => acc + item.pedidos, 0),
    ticketMedio: salesData.reduce((acc, item) => acc + item.vendas, 0) / salesData.reduce((acc, item) => acc + item.pedidos, 0) || 0,
    metaAtingida: (salesData.reduce((acc, item) => acc + item.vendas, 0) / (salesData[0]?.meta * 7)) * 100 || 0,
    crescimento: 0,
    clientesAtivos: 0,
    produtosVendidos: 0
  };

  const updateData = async () => {
    setLoading(true);
    // Simular carregamento de dados
    setTimeout(() => setLoading(false), 1000);
  };

  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-white p-4 border border-gray-200 rounded-lg shadow-lg">
          <p className="font-medium text-gray-900">{label}</p>
          {payload.map((entry: any, index: number) => (
            <p key={index} style={{ color: entry.color }} className="text-sm">
              {entry.name}: {entry.name.includes('R$') || entry.name.includes('receita') || entry.name.includes('vendas') 
                ? formatCurrency(entry.value) 
                : entry.value}
            </p>
          ))}
        </div>
      );
    }
    return null;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 p-6">
      <div className="max-w-7xl mx-auto space-y-8">
        
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button
              onClick={() => window.history.back()}
              className="flex items-center gap-2 px-4 py-2 bg-white text-gray-700 rounded-lg border border-gray-200 hover:bg-gray-50 transition-colors shadow-sm"
            >
              <ArrowLeft className="w-4 h-4" />
              Voltar
            </button>
            
            <div className="flex items-center gap-3">
              <div className="p-3 bg-blue-500 rounded-xl">
                <Activity className="w-8 h-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Analytics Avançado</h1>
                <p className="text-gray-600">Dashboard inteligente com insights em tempo real</p>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <select
              value={timeRange}
              onChange={(e) => setTimeRange(e.target.value)}
              className="px-4 py-2 border border-gray-200 rounded-lg bg-white text-gray-700 text-sm"
            >
              <option value="7d">Últimos 7 dias</option>
              <option value="30d">Últimos 30 dias</option>
              <option value="90d">Últimos 3 meses</option>
            </select>
            
            <button
              onClick={updateData}
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              Atualizar
            </button>
          </div>
        </div>

        {/* KPIs Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <KPICard
            title="Vendas no Período"
            value={formatCurrency(kpis.totalVendas)}
            change={{ value: `+${kpis.crescimento}%`, isPositive: true }}
            icon={DollarSign}
            gradient="from-green-400 to-emerald-500"
            description={`${kpis.totalPedidos} pedidos realizados`}
          />
          
          <KPICard
            title="Ticket Médio"
            value={formatCurrency(kpis.ticketMedio)}
            change={{ value: "+8.2%", isPositive: true }}
            icon={Target}
            gradient="from-blue-400 to-indigo-500"
            description="Por venda realizada"
          />
          
          <KPICard
            title="Meta Atingida"
            value={`${kpis.metaAtingida.toFixed(1)}%`}
            change={{ value: "+12.5%", isPositive: true }}
            icon={Zap}
            gradient="from-orange-400 to-red-500"
            description="Da meta mensal"
          />
          
          <KPICard
            title="Clientes Ativos"
            value={kpis.clientesAtivos}
            change={{ value: "+23", isPositive: true }}
            icon={Users}
            gradient="from-purple-400 to-pink-500"
            description="Compraram no período"
          />
        </div>

        {/* Gráfico Principal - Vendas com Área */}
        <ModernChart 
          title="📈 Performance de Vendas vs Meta" 
          height={400}
          className="lg:col-span-2"
        >
          <ComposedChart data={salesData}>
            <defs>
              <linearGradient id="salesGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.8}/>
                <stop offset="95%" stopColor="#3B82F6" stopOpacity={0.1}/>
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
            <XAxis dataKey="day" />
            <YAxis yAxisId="left" orientation="left" />
            <YAxis yAxisId="right" orientation="right" />
            <Tooltip content={<CustomTooltip />} />
            <Legend />
            <Area
              yAxisId="left"
              type="monotone"
              dataKey="vendas"
              stroke="#3B82F6"
              fill="url(#salesGradient)"
              name="Vendas (R$)"
            />
            <Line
              yAxisId="left"
              type="monotone"
              dataKey="meta"
              stroke="#EF4444"
              strokeWidth={2}
              strokeDasharray="5 5"
              name="Meta"
            />
            <Bar
              yAxisId="right"
              dataKey="pedidos"
              fill="#10B981"
              name="Pedidos"
              opacity={0.7}
            />
          </ComposedChart>
        </ModernChart>

        {/* Grid de Gráficos Secundários */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          
          {/* Receita Mensal */}
          <ModernChart title="💰 Receita vs Lucro Mensal">
            <AreaChart data={monthlyData}>
              <defs>
                <linearGradient id="receitaGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#10B981" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="#10B981" stopOpacity={0.1}/>
                </linearGradient>
                <linearGradient id="lucroGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#F59E0B" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="#F59E0B" stopOpacity={0.1}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis dataKey="mes" />
              <YAxis />
              <Tooltip content={<CustomTooltip />} />
              <Area
                type="monotone"
                dataKey="receita"
                stackId="1"
                stroke="#10B981"
                fill="url(#receitaGradient)"
                name="Receita"
              />
              <Area
                type="monotone"
                dataKey="lucro"
                stackId="2"
                stroke="#F59E0B"
                fill="url(#lucroGradient)"
                name="Lucro"
              />
            </AreaChart>
          </ModernChart>

          {/* Vendas por Categoria */}
          <ModernChart title="🎯 Vendas por Categoria">
            <PieChart>
              <Pie
                data={categoriesData}
                cx="50%"
                cy="50%"
                outerRadius={100}
                dataKey="value"
                label={({ name, percent }) => `${name}: ${((percent || 0) * 100).toFixed(0)}%`}
              >
                {categoriesData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.fill} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ModernChart>
        </div>

        {/* Formas de Pagamento e Produtos Top */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          
          {/* Formas de Pagamento com Barras Radiais */}
          <div className="bg-white rounded-xl shadow-lg border border-gray-100 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-6">💳 Formas de Pagamento</h3>
            
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={paymentMethods}
                  cx="50%"
                  cy="50%"
                  outerRadius={100}
                  dataKey="value"
                >
                  {paymentMethods.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip formatter={(value: number, _name: string, props: any) => [
                  `${value}% - ${formatCurrency(props.payload.amount)}`,
                  props.payload.method
                ]} />
              </PieChart>
            </ResponsiveContainer>
            
            <div className="grid grid-cols-2 gap-4 mt-4">
              {paymentMethods.map((method, index) => (
                <div key={index} className="flex items-center gap-3">
                  <div 
                    className="w-3 h-3 rounded-full" 
                    style={{ backgroundColor: method.color }}
                  />
                  <div>
                    <p className="text-sm font-medium text-gray-900">{method.method}</p>
                    <p className="text-xs text-gray-600">{formatCurrency(method.amount)}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Top Produtos */}
          <div className="bg-white rounded-xl shadow-lg border border-gray-100 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-6">🏆 Produtos Mais Vendidos</h3>
            
            <div className="space-y-4">
              {topProducts.map((produto, index) => (
                <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-blue-500 rounded-lg flex items-center justify-center text-white font-bold text-sm">
                      {index + 1}
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">{produto.produto}</p>
                      <p className="text-xs text-gray-600">{produto.categoria}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold text-gray-900">{formatCurrency(produto.receita)}</p>
                    <p className="text-xs text-gray-600">{produto.vendas} vendas</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Crescimento de Clientes */}
        <ModernChart title="👥 Evolução de Clientes" height={350}>
          <AreaChart data={customerMetrics}>
            <defs>
              <linearGradient id="novosGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#8B5CF6" stopOpacity={0.8}/>
                <stop offset="95%" stopColor="#8B5CF6" stopOpacity={0.1}/>
              </linearGradient>
              <linearGradient id="ativosGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#06B6D4" stopOpacity={0.8}/>
                <stop offset="95%" stopColor="#06B6D4" stopOpacity={0.1}/>
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
            <XAxis dataKey="mes" />
            <YAxis />
            <Tooltip content={<CustomTooltip />} />
            <Legend />
            <Area
              type="monotone"
              dataKey="novos"
              stackId="1"
              stroke="#8B5CF6"
              fill="url(#novosGradient)"
              name="Novos Clientes"
            />
            <Area
              type="monotone"
              dataKey="ativos"
              stackId="1"
              stroke="#06B6D4"
              fill="url(#ativosGradient)"
              name="Clientes Ativos"
            />
            <Line
              type="monotone"
              dataKey="total"
              stroke="#EF4444"
              strokeWidth={3}
              name="Total Acumulado"
            />
          </AreaChart>
        </ModernChart>

        {/* Footer com Ações */}
        <div className="flex items-center justify-between bg-white rounded-xl shadow-lg border border-gray-100 p-6">
          <div className="flex items-center gap-4">
            <div className="p-2 bg-green-100 rounded-lg">
              <Eye className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <p className="font-medium text-gray-900">Relatório Atualizado</p>
              <p className="text-sm text-gray-600">
                Última atualização: {new Date().toLocaleString('pt-BR')}
              </p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <button className="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors">
              <Filter className="w-4 h-4" />
              Filtros
            </button>
            
            <button className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors">
              <Download className="w-4 h-4" />
              Exportar PDF
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RelatoriosPageModern;