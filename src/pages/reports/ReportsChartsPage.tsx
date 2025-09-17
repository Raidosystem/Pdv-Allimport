// Build a professional PDV reporting section.
// Include global filters (date range, store, channel, seller, category, payment).
// Show skeleton states, empty states and error states.
// Wire navigation to other sections preserving filters via URL params.
// Track events with the given event ids.

import React, { useState, useEffect } from "react";
import { 
  BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, 
  ResponsiveContainer, PieChart, Pie, Cell, AreaChart, Area, 
  RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, Radar 
} from "recharts";
import { TrendingUp, BarChart3, PieChart as PieIcon, Activity, Download, Maximize2 } from "lucide-react";
import { formatCurrency } from "../../utils/format";

// ===== Helper: Filters (same as overview) =====
type FilterState = {
  period: string;
  start?: string;
  end?: string;
  channel?: string;
  seller?: string;
  category?: string;
  payment?: string;
  compare?: boolean;
};

function readFiltersFromURL(): FilterState {
  const sp = new URLSearchParams(window.location.search);
  return {
    period: sp.get("period") || "30d",
    start: sp.get("start") || undefined,
    end: sp.get("end") || undefined,
    channel: sp.get("channel") || undefined,
    seller: sp.get("seller") || undefined,
    category: sp.get("category") || undefined,
    payment: sp.get("payment") || undefined,
    compare: sp.get("compare") === "1",
  };
}

function useFilters() {
  const [filters, setFilters] = useState<FilterState>(() => readFiltersFromURL());
  return { filters, setFilters } as const;
}

// ===== Mock Data =====
const mockTimeSeriesData = [
  { date: "16/09", vendas: 12500, meta: 15000, tickets: 45 },
  { date: "17/09", vendas: 18750, meta: 15000, tickets: 68 },
  { date: "18/09", vendas: 22100, meta: 15000, tickets: 72 },
  { date: "19/09", vendas: 19800, meta: 15000, tickets: 58 },
  { date: "20/09", vendas: 25300, meta: 15000, tickets: 81 },
  { date: "21/09", vendas: 28900, meta: 15000, tickets: 95 },
  { date: "22/09", vendas: 32400, meta: 15000, tickets: 104 },
];

const mockCategoryData = [
  { name: "Eletrônicos", value: 42.5, sales: 667500, color: "#3B82F6" },
  { name: "Informática", value: 29.8, sales: 468000, color: "#8B5CF6" },
  { name: "Acessórios", value: 13.2, sales: 206700, color: "#10B981" },
  { name: "Casa & Jardim", value: 9.9, sales: 156000, color: "#F59E0B" },
  { name: "Outros", value: 4.6, sales: 72200, color: "#EF4444" },
];

const mockChannelData = [
  { channel: "Loja Física", jan: 45000, fev: 52000, mar: 48000, abr: 55000 },
  { channel: "Online", jan: 32000, fev: 38000, mar: 42000, abr: 46000 },
  { channel: "WhatsApp", jan: 18000, fev: 22000, mar: 25000, abr: 28000 },
  { channel: "Marketplace", jan: 12000, fev: 15000, mar: 18000, abr: 21000 },
];

const mockPerformanceData = [
  { subject: "Vendas", A: 120, B: 110, fullMark: 150 },
  { subject: "Conversão", A: 98, B: 85, fullMark: 150 },
  { subject: "Ticket Médio", A: 86, B: 90, fullMark: 150 },
  { subject: "Margem", A: 99, B: 95, fullMark: 150 },
  { subject: "Satisfação", A: 85, B: 88, fullMark: 150 },
  { subject: "Retenção", A: 65, B: 70, fullMark: 150 },
];

// ===== Chart Components =====
interface ChartCardProps {
  title: string;
  icon: React.ReactNode;
  children: React.ReactNode;
  actions?: React.ReactNode;
  className?: string;
}

const ChartCard: React.FC<ChartCardProps> = ({ title, icon, children, actions, className = "" }) => (
  <div className={`bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden ${className}`}>
    <div className="p-6 border-b border-gray-200">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-r from-blue-500 to-purple-500 rounded-lg text-white">
            {icon}
          </div>
          <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
        </div>
        {actions && <div className="flex items-center gap-2">{actions}</div>}
      </div>
    </div>
    <div className="p-6">{children}</div>
  </div>
);

// ===== Main Component =====
const ReportsChartsPage: React.FC = () => {
  const { filters, setFilters } = useFilters();
  const [loading, setLoading] = useState(false);
  const [chartType, setChartType] = useState<'line' | 'bar' | 'area'>('line');

  // Simulate loading
  useEffect(() => {
    setLoading(true);
    const timer = setTimeout(() => setLoading(false), 800);
    return () => clearTimeout(timer);
  }, [filters]);

  const handleExportChart = (chartName: string) => {
    console.log('charts_export_single', { chart: chartName });
    // Simulate chart export
    alert(`Exportando gráfico: ${chartName}`);
  };

  const handleFullscreen = (chartName: string) => {
    console.log('charts_fullscreen', { chart: chartName });
    // Simulate fullscreen
    alert(`Expandindo gráfico: ${chartName}`);
  };

  // Loading skeleton
  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-96 bg-gray-200 rounded-xl"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">📊 Gráficos</h1>
          <p className="text-gray-600">Visualizações interativas e análise visual</p>
        </div>
        
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2 bg-gray-100 rounded-lg p-1">
            <button
              onClick={() => setChartType('line')}
              className={`px-3 py-1 rounded-md text-sm font-medium transition-colors ${
                chartType === 'line' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-600'
              }`}
            >
              📈 Linha
            </button>
            <button
              onClick={() => setChartType('bar')}
              className={`px-3 py-1 rounded-md text-sm font-medium transition-colors ${
                chartType === 'bar' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-600'
              }`}
            >
              📊 Barras
            </button>
            <button
              onClick={() => setChartType('area')}
              className={`px-3 py-1 rounded-md text-sm font-medium transition-colors ${
                chartType === 'area' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-600'
              }`}
            >
              🌊 Área
            </button>
          </div>
          
          <button
            onClick={() => handleExportChart('all')}
            className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            <Download className="w-4 h-4" />
            Exportar Todos
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-200">
        <div className="flex items-center gap-4">
          <select
            value={filters.period}
            onChange={(e) => setFilters({ ...filters, period: e.target.value })}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          >
            <option value="7d">Últimos 7 dias</option>
            <option value="30d">Últimos 30 dias</option>
            <option value="90d">Últimos 90 dias</option>
            <option value="1y">Último ano</option>
          </select>

          <select
            value={filters.category || ''}
            onChange={(e) => setFilters({ ...filters, category: e.target.value || undefined })}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          >
            <option value="">Todas Categorias</option>
            <option value="eletronicos">Eletrônicos</option>
            <option value="informatica">Informática</option>
            <option value="acessorios">Acessórios</option>
          </select>

          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              id="compare-charts"
              checked={filters.compare}
              onChange={(e) => setFilters({ ...filters, compare: e.target.checked })}
              className="rounded border-gray-300"
            />
            <label htmlFor="compare-charts" className="text-sm text-gray-700">
              Comparar períodos
            </label>
          </div>
        </div>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Time Series Chart */}
        <ChartCard
          title="Evolução de Vendas"
          icon={<TrendingUp className="w-5 h-5" />}
          actions={
            <>
              <button
                onClick={() => handleFullscreen('vendas-evolucao')}
                className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Maximize2 className="w-4 h-4" />
              </button>
              <button
                onClick={() => handleExportChart('vendas-evolucao')}
                className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Download className="w-4 h-4" />
              </button>
            </>
          }
        >
          <ResponsiveContainer width="100%" height={300}>
            {chartType === 'line' ? (
              <LineChart data={mockTimeSeriesData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis tickFormatter={(value) => formatCurrency(value)} />
                <Tooltip 
                  formatter={(value, name) => [formatCurrency(Number(value)), name === 'vendas' ? 'Vendas' : 'Meta']}
                  labelFormatter={(label) => `Data: ${label}`}
                />
                <Line type="monotone" dataKey="vendas" stroke="#3B82F6" strokeWidth={3} dot={{ r: 4 }} />
                <Line type="monotone" dataKey="meta" stroke="#EF4444" strokeDasharray="5 5" />
              </LineChart>
            ) : chartType === 'bar' ? (
              <BarChart data={mockTimeSeriesData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis tickFormatter={(value) => formatCurrency(value)} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Bar dataKey="vendas" fill="#3B82F6" />
              </BarChart>
            ) : (
              <AreaChart data={mockTimeSeriesData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis tickFormatter={(value) => formatCurrency(value)} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Area type="monotone" dataKey="vendas" stroke="#3B82F6" fill="#3B82F6" fillOpacity={0.3} />
              </AreaChart>
            )}
          </ResponsiveContainer>
        </ChartCard>

        {/* Category Distribution */}
        <ChartCard
          title="Distribuição por Categoria"
          icon={<PieIcon className="w-5 h-5" />}
          actions={
            <>
              <button
                onClick={() => handleFullscreen('categorias-distribuicao')}
                className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Maximize2 className="w-4 h-4" />
              </button>
              <button
                onClick={() => handleExportChart('categorias-distribuicao')}
                className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Download className="w-4 h-4" />
              </button>
            </>
          }
        >
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={mockCategoryData}
                cx="50%"
                cy="50%"
                outerRadius={100}
                fill="#8884d8"
                dataKey="value"
                label={({ name, value }) => `${name}: ${value}%`}
              >
                {mockCategoryData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip 
                formatter={(value) => [`${value}%`, 'Participação']}
              />
            </PieChart>
          </ResponsiveContainer>
        </ChartCard>

        {/* Channel Performance */}
        <ChartCard
          title="Performance por Canal"
          icon={<BarChart3 className="w-5 h-5" />}
          actions={
            <>
              <button
                onClick={() => handleFullscreen('canais-performance')}
                className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Maximize2 className="w-4 h-4" />
              </button>
              <button
                onClick={() => handleExportChart('canais-performance')}
                className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Download className="w-4 h-4" />
              </button>
            </>
          }
        >
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={mockChannelData} layout="horizontal">
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis type="number" tickFormatter={(value) => formatCurrency(value)} />
              <YAxis dataKey="channel" type="category" width={100} />
              <Tooltip formatter={(value) => formatCurrency(Number(value))} />
              <Bar dataKey="jan" stackId="a" fill="#3B82F6" />
              <Bar dataKey="fev" stackId="a" fill="#8B5CF6" />
              <Bar dataKey="mar" stackId="a" fill="#10B981" />
              <Bar dataKey="abr" stackId="a" fill="#F59E0B" />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>

        {/* Performance Radar */}
        <ChartCard
          title="Análise de Performance"
          icon={<Activity className="w-5 h-5" />}
          actions={
            <>
              <button
                onClick={() => handleFullscreen('performance-radar')}
                className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Maximize2 className="w-4 h-4" />
              </button>
              <button
                onClick={() => handleExportChart('performance-radar')}
                className="p-1 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Download className="w-4 h-4" />
              </button>
            </>
          }
        >
          <ResponsiveContainer width="100%" height={300}>
            <RadarChart data={mockPerformanceData}>
              <PolarGrid />
              <PolarAngleAxis dataKey="subject" />
              <PolarRadiusAxis angle={30} domain={[0, 150]} />
              <Radar
                name="Atual"
                dataKey="A"
                stroke="#3B82F6"
                fill="#3B82F6"
                fillOpacity={0.3}
              />
              <Radar
                name="Meta"
                dataKey="B"
                stroke="#EF4444"
                fill="#EF4444"
                fillOpacity={0.3}
              />
              <Tooltip />
            </RadarChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-gradient-to-r from-blue-500 to-purple-500 text-white p-6 rounded-xl">
          <div className="flex items-center gap-3 mb-2">
            <TrendingUp className="w-6 h-6" />
            <span className="text-sm font-medium opacity-90">Tendência Geral</span>
          </div>
          <div className="text-2xl font-bold mb-1">📈 Crescimento</div>
          <div className="text-sm opacity-90">+12.4% vs período anterior</div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <div className="flex items-center gap-3 mb-2">
            <PieIcon className="w-6 h-6 text-blue-500" />
            <span className="text-sm font-medium text-gray-600">Categoria Líder</span>
          </div>
          <div className="text-2xl font-bold text-gray-900 mb-1">Eletrônicos</div>
          <div className="text-sm text-gray-600">42.5% do faturamento</div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <div className="flex items-center gap-3 mb-2">
            <BarChart3 className="w-6 h-6 text-green-500" />
            <span className="text-sm font-medium text-gray-600">Canal Top</span>
          </div>
          <div className="text-2xl font-bold text-gray-900 mb-1">Loja Física</div>
          <div className="text-sm text-gray-600">55% das vendas</div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <div className="flex items-center gap-3 mb-2">
            <Activity className="w-6 h-6 text-purple-500" />
            <span className="text-sm font-medium text-gray-600">Performance</span>
          </div>
          <div className="text-2xl font-bold text-gray-900 mb-1">Excelente</div>
          <div className="text-sm text-gray-600">92% da meta atingida</div>
        </div>
      </div>
    </div>
  );
};

export default ReportsChartsPage;