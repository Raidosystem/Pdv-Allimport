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
  Activity,
  Calendar,
  ChevronDown,
  Settings
} from 'lucide-react';
import {
  Area,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Line,
  Legend,
  ComposedChart,
  ReferenceLine,
  Brush
} from 'recharts';
import { formatCurrency } from '../utils/format';

// ✅ PÁGINA DE RELATÓRIOS MODERNA COM GRÁFICOS AVANÇADOS E FILTROS

interface ModernChartProps {
  title: string;
  height?: number;
  children: React.ReactElement;
  className?: string;
  actions?: React.ReactNode;
}

const ModernChart: React.FC<ModernChartProps> = ({ 
  title, 
  height = 300, 
  children, 
  className = "",
  actions
}) => (
  <div className={`bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden ${className}`}>
    <div className="p-6 border-b border-gray-100 flex justify-between items-center">
      <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
      {actions && <div className="flex items-center gap-2">{actions}</div>}
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
  comparison?: {
    previous: string;
    label: string;
  };
}

const KPICard: React.FC<KPICardProps> = ({ 
  title, 
  value, 
  change, 
  icon: Icon, 
  gradient,
  description,
  comparison
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
        {comparison && (
          <div className="mt-2 pt-2 border-t border-gray-100">
            <p className="text-xs text-gray-500">
              {comparison.label}: <span className="font-medium">{comparison.previous}</span>
            </p>
          </div>
        )}
      </div>
    </div>
  </div>
);

interface FilterState {
  period: string;
  category: string;
  paymentMethod: string;
  dateRange: {
    start: string;
    end: string;
  };
}

const RelatoriosPageAdvanced: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState<FilterState>({
    period: '7d',
    category: 'all',
    paymentMethod: 'all',
    dateRange: {
      start: '',
      end: ''
    }
  });

  // Dados simulados mais realistas com comparações
  const [currentData] = useState([
    { date: '10/09', day: 'Seg', vendas: 0, pedidos: 0, meta: 0, vendasAnterior: 0 },
    { date: '11/09', day: 'Ter', vendas: 0, pedidos: 0, meta: 0, vendasAnterior: 0 },
    { date: '12/09', day: 'Qua', vendas: 0, pedidos: 0, meta: 0, vendasAnterior: 0 },
    { date: '13/09', day: 'Qui', vendas: 0, pedidos: 0, meta: 0, vendasAnterior: 0 },
    { date: '14/09', day: 'Sex', vendas: 0, pedidos: 0, meta: 0, vendasAnterior: 0 },
    { date: '15/09', day: 'Sáb', vendas: 0, pedidos: 0, meta: 0, vendasAnterior: 0 },
    { date: '16/09', day: 'Dom', vendas: 0, pedidos: 0, meta: 0, vendasAnterior: 0 }
  ]);

  const [monthlyTrends] = useState([
    { mes: 'Jan', atual: 0, anterior: 0, meta: 0, projecao: 0 },
    { mes: 'Fev', atual: 0, anterior: 0, meta: 0, projecao: 0 },
    { mes: 'Mar', atual: 0, anterior: 0, meta: 0, projecao: 0 },
    { mes: 'Abr', atual: 0, anterior: 0, meta: 0, projecao: 0 },
    { mes: 'Mai', atual: 0, anterior: 0, meta: 0, projecao: 0 },
    { mes: 'Jun', atual: 0, anterior: 0, meta: 0, projecao: 0 },
    { mes: 'Jul', atual: 0, anterior: 0, meta: 0, projecao: 0 }
  ]);

  const [categoriesPerformance] = useState([
    { categoria: 'Nenhuma categoria', vendas: 0, vendas_anterior: 0, crescimento: 0, participacao: 100 }
  ]);

  const [competitiveData] = useState([
    { periodo: 'Sem dados', nossaVenda: 0, mercado: 0, participacao: 0 }
  ]);

  // KPIs com comparações avançadas
  const kpis = {
    totalVendas: currentData.reduce((acc, item) => acc + item.vendas, 0),
    totalPedidos: currentData.reduce((acc, item) => acc + item.pedidos, 0),
    vendasAnteriores: currentData.reduce((acc, item) => acc + item.vendasAnterior, 0),
    ticketMedio: currentData.reduce((acc, item) => acc + item.vendas, 0) / currentData.reduce((acc, item) => acc + item.pedidos, 0),
    metaAtingida: (currentData.reduce((acc, item) => acc + item.vendas, 0) / (currentData[0]?.meta * 7)) * 100,
    crescimento: ((currentData.reduce((acc, item) => acc + item.vendas, 0) - currentData.reduce((acc, item) => acc + item.vendasAnterior, 0)) / currentData.reduce((acc, item) => acc + item.vendasAnterior, 0)) * 100 || 0,
    clientesAtivos: 0,
    novosClientes: 0
  };

  const updateData = async () => {
    setLoading(true);
    // Simular carregamento de dados com filtros
    await new Promise(resolve => setTimeout(resolve, 1500));
    setLoading(false);
  };

  const exportChart = (chartName: string) => {
    console.log(`Exportando gráfico: ${chartName}`);
    // Implementar exportação real aqui
  };

  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-white p-4 border border-gray-200 rounded-lg shadow-lg">
          <p className="font-medium text-gray-900 mb-2">{label}</p>
          {payload.map((entry: any, index: number) => (
            <div key={index} className="flex items-center gap-2">
              <div 
                className="w-3 h-3 rounded-full" 
                style={{ backgroundColor: entry.color }}
              />
              <span className="text-sm">
                {entry.name}: {entry.name.includes('R$') || entry.name.includes('vendas') || entry.dataKey.includes('vendas')
                  ? formatCurrency(entry.value) 
                  : entry.value}
              </span>
            </div>
          ))}
        </div>
      );
    }
    return null;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 p-6">
      <div className="max-w-7xl mx-auto space-y-8">
        
        {/* Header Avançado */}
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
              <div className="p-3 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl">
                <Activity className="w-8 h-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Analytics Avançado</h1>
                <p className="text-gray-600">Dashboard inteligente com insights e previsões</p>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <button
              onClick={() => setShowFilters(!showFilters)}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg border text-sm transition-colors ${
                showFilters 
                  ? 'bg-blue-500 text-white border-blue-500' 
                  : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'
              }`}
            >
              <Filter className="w-4 h-4" />
              Filtros Avançados
              <ChevronDown className={`w-4 h-4 transition-transform ${showFilters ? 'rotate-180' : ''}`} />
            </button>
            
            <button
              onClick={updateData}
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-lg hover:from-green-600 hover:to-emerald-700 transition-all disabled:opacity-50"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              {loading ? 'Atualizando...' : 'Atualizar'}
            </button>
          </div>
        </div>

        {/* Filtros Avançados */}
        {showFilters && (
          <div className="bg-white rounded-xl shadow-lg border border-gray-200 p-6 space-y-6">
            <div className="flex items-center gap-3">
              <Settings className="w-5 h-5 text-gray-600" />
              <h3 className="text-lg font-semibold text-gray-900">Filtros e Configurações</h3>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Período</label>
                <select
                  value={filters.period}
                  onChange={(e) => setFilters({...filters, period: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                >
                  <option value="7d">Últimos 7 dias</option>
                  <option value="30d">Últimos 30 dias</option>
                  <option value="90d">Últimos 3 meses</option>
                  <option value="1y">Último ano</option>
                  <option value="custom">Período customizado</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Categoria</label>
                <select
                  value={filters.category}
                  onChange={(e) => setFilters({...filters, category: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                >
                  <option value="all">Todas as categorias</option>
                  <option value="eletronicos">Eletrônicos</option>
                  <option value="informatica">Informática</option>
                  <option value="acessorios">Acessórios</option>
                  <option value="servicos">Serviços</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Forma de Pagamento</label>
                <select
                  value={filters.paymentMethod}
                  onChange={(e) => setFilters({...filters, paymentMethod: e.target.value})}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                >
                  <option value="all">Todas as formas</option>
                  <option value="pix">PIX</option>
                  <option value="credit">Cartão de Crédito</option>
                  <option value="debit">Cartão de Débito</option>
                  <option value="cash">Dinheiro</option>
                </select>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Comparar com</label>
                <select className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm">
                  <option value="previous">Período anterior</option>
                  <option value="last_year">Mesmo período ano passado</option>
                  <option value="average">Média histórica</option>
                  <option value="budget">Orçamento/Meta</option>
                </select>
              </div>
            </div>
            
            {filters.period === 'custom' && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Data Início</label>
                  <input
                    type="date"
                    value={filters.dateRange.start}
                    onChange={(e) => setFilters({
                      ...filters, 
                      dateRange: {...filters.dateRange, start: e.target.value}
                    })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Data Fim</label>
                  <input
                    type="date"
                    value={filters.dateRange.end}
                    onChange={(e) => setFilters({
                      ...filters, 
                      dateRange: {...filters.dateRange, end: e.target.value}
                    })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                  />
                </div>
              </div>
            )}
          </div>
        )}

        {/* KPIs Avançados com Comparações */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <KPICard
            title="Vendas no Período"
            value={formatCurrency(kpis.totalVendas)}
            change={{ 
              value: `${kpis.crescimento > 0 ? '+' : ''}${kpis.crescimento.toFixed(1)}%`, 
              isPositive: kpis.crescimento > 0 
            }}
            icon={DollarSign}
            gradient="from-green-400 to-emerald-500"
            description={`${kpis.totalPedidos} pedidos realizados`}
            comparison={{
              previous: formatCurrency(kpis.vendasAnteriores),
              label: 'Período anterior'
            }}
          />
          
          <KPICard
            title="Ticket Médio"
            value={formatCurrency(kpis.ticketMedio)}
            change={{ value: "+8.2%", isPositive: true }}
            icon={Target}
            gradient="from-blue-400 to-indigo-500"
            description="Por venda realizada"
            comparison={{
              previous: formatCurrency(kpis.ticketMedio * 0.92),
              label: 'Média anterior'
            }}
          />
          
          <KPICard
            title="Meta Atingida"
            value={`${kpis.metaAtingida.toFixed(1)}%`}
            change={{ value: "+12.5%", isPositive: true }}
            icon={Zap}
            gradient="from-orange-400 to-red-500"
            description="Da meta estabelecida"
            comparison={{
              previous: "82.4%",
              label: 'Período anterior'
            }}
          />
          
          <KPICard
            title="Novos Clientes"
            value={kpis.novosClientes}
            change={{ value: "+23", isPositive: true }}
            icon={Users}
            gradient="from-purple-400 to-pink-500"
            description={`${kpis.clientesAtivos} clientes ativos`}
            comparison={{
              previous: "18",
              label: 'Período anterior'
            }}
          />
        </div>

        {/* Gráfico Principal com Comparações Temporais */}
        <ModernChart 
          title="📈 Performance vs Período Anterior & Meta" 
          height={450}
          actions={
            <button
              onClick={() => exportChart('performance')}
              className="flex items-center gap-1 px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
            >
              <Download className="w-3 h-3" />
              Exportar
            </button>
          }
        >
          <ComposedChart data={currentData}>
            <defs>
              <linearGradient id="salesCurrentGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.8}/>
                <stop offset="95%" stopColor="#3B82F6" stopOpacity={0.1}/>
              </linearGradient>
              <linearGradient id="salesPreviousGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#9CA3AF" stopOpacity={0.6}/>
                <stop offset="95%" stopColor="#9CA3AF" stopOpacity={0.1}/>
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
            <XAxis dataKey="day" />
            <YAxis yAxisId="left" orientation="left" />
            <YAxis yAxisId="right" orientation="right" />
            <Tooltip content={<CustomTooltip />} />
            <Legend />
            
            {/* Área para vendas atuais */}
            <Area
              yAxisId="left"
              type="monotone"
              dataKey="vendas"
              stroke="#3B82F6"
              fill="url(#salesCurrentGradient)"
              name="Vendas Atuais (R$)"
            />
            
            {/* Área para vendas anteriores */}
            <Area
              yAxisId="left"
              type="monotone"
              dataKey="vendasAnterior"
              stroke="#9CA3AF"
              fill="url(#salesPreviousGradient)"
              name="Período Anterior (R$)"
            />
            
            {/* Linha de meta */}
            <Line
              yAxisId="left"
              type="monotone"
              dataKey="meta"
              stroke="#EF4444"
              strokeWidth={2}
              strokeDasharray="5 5"
              name="Meta Diária"
              dot={false}
            />
            
            {/* Barras para número de pedidos */}
            <Bar
              yAxisId="right"
              dataKey="pedidos"
              fill="#10B981"
              name="Número de Pedidos"
              opacity={0.7}
            />
            
            {/* Linha de referência para meta */}
            <ReferenceLine 
              yAxisId="left" 
              y={5000} 
              stroke="#EF4444" 
              strokeDasharray="8 8" 
              label="Meta: R$ 5.000"
            />
          </ComposedChart>
        </ModernChart>

        {/* Grid de Análises Avançadas */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          
          {/* Tendências Mensais com Projeções */}
          <ModernChart 
            title="💰 Tendências e Projeções Mensais" 
            actions={
              <button
                onClick={() => exportChart('tendencias')}
                className="flex items-center gap-1 px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
              >
                <Download className="w-3 h-3" />
                Exportar
              </button>
            }
          >
            <ComposedChart data={monthlyTrends}>
              <defs>
                <linearGradient id="currentMonthGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#10B981" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="#10B981" stopOpacity={0.1}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis dataKey="mes" />
              <YAxis />
              <Tooltip content={<CustomTooltip />} />
              <Legend />
              
              <Area
                type="monotone"
                dataKey="atual"
                stroke="#10B981"
                fill="url(#currentMonthGradient)"
                name="Mês Atual"
              />
              
              <Line
                type="monotone"
                dataKey="anterior"
                stroke="#9CA3AF"
                strokeWidth={2}
                name="Ano Anterior"
                strokeDasharray="3 3"
              />
              
              <Line
                type="monotone"
                dataKey="projecao"
                stroke="#F59E0B"
                strokeWidth={3}
                name="Projeção"
                strokeDasharray="8 4"
              />
              
              <Bar
                dataKey="meta"
                fill="#EF444450"
                name="Meta"
              />
              
              <Brush dataKey="mes" height={30} stroke="#3B82F6" />
            </ComposedChart>
          </ModernChart>

          {/* Performance por Categoria */}
          <ModernChart 
            title="🎯 Performance por Categoria" 
            actions={
              <button
                onClick={() => exportChart('categorias')}
                className="flex items-center gap-1 px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
              >
                <Download className="w-3 h-3" />
                Exportar
              </button>
            }
          >
            <div className="space-y-4">
              {categoriesPerformance.map((categoria, index) => (
                <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-blue-500 rounded-lg flex items-center justify-center text-white font-bold text-sm">
                      {index + 1}
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">{categoria.categoria}</p>
                      <p className="text-xs text-gray-600">{categoria.participacao}% do total</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold text-gray-900">{formatCurrency(categoria.vendas)}</p>
                    <p className={`text-xs font-medium ${
                      categoria.crescimento > 0 ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {categoria.crescimento > 0 ? '+' : ''}{categoria.crescimento.toFixed(1)}%
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </ModernChart>
        </div>

        {/* Análise Competitiva */}
        <ModernChart 
          title="🏆 Análise Competitiva e Market Share" 
          height={350}
          actions={
            <div className="flex gap-2">
              <button className="flex items-center gap-1 px-3 py-1 text-sm bg-blue-100 text-blue-700 rounded-lg">
                <Eye className="w-3 h-3" />
                Ver Detalhes
              </button>
              <button
                onClick={() => exportChart('competitivo')}
                className="flex items-center gap-1 px-3 py-1 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
              >
                <Download className="w-3 h-3" />
                Exportar
              </button>
            </div>
          }
        >
          <ComposedChart data={competitiveData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
            <XAxis dataKey="periodo" />
            <YAxis yAxisId="left" orientation="left" />
            <YAxis yAxisId="right" orientation="right" />
            <Tooltip content={<CustomTooltip />} />
            <Legend />
            
            <Bar
              yAxisId="left"
              dataKey="nossaVenda"
              fill="#3B82F6"
              name="Nossa Venda"
            />
            
            <Bar
              yAxisId="left"
              dataKey="mercado"
              fill="#E5E7EB"
              name="Total do Mercado"
            />
            
            <Line
              yAxisId="right"
              type="monotone"
              dataKey="participacao"
              stroke="#10B981"
              strokeWidth={3}
              name="Participação (%)"
            />
          </ComposedChart>
        </ModernChart>

        {/* Footer com Ações Avançadas */}
        <div className="flex items-center justify-between bg-white rounded-xl shadow-lg border border-gray-100 p-6">
          <div className="flex items-center gap-4">
            <div className="p-2 bg-green-100 rounded-lg">
              <Eye className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <p className="font-medium text-gray-900">Dashboard Analytics Atualizado</p>
              <p className="text-sm text-gray-600">
                Última atualização: {new Date().toLocaleString('pt-BR')} • {loading ? 'Sincronizando...' : 'Online'}
              </p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            <button className="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors">
              <Calendar className="w-4 h-4" />
              Agendar Relatório
            </button>
            
            <button className="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-lg hover:from-blue-600 hover:to-purple-700 transition-all">
              <Download className="w-4 h-4" />
              Exportar Dashboard
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RelatoriosPageAdvanced;