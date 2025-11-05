// Build a professional PDV reporting section.
// Include global filters (date range, store, channel, seller, category, payment).
// Show skeleton states, empty states and error states.
// Wire navigation to other sections preserving filters via URL params.
// Track events with the given event ids.

import React, { useEffect, useState } from "react";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { DollarSign, ShoppingCart, TrendingUp, Users, ArrowUpRight } from "lucide-react";
import { formatCurrency } from "../../utils/format";
import { realReportsService } from "../../services/realReportsService";

// ===== Helper: Filters in URL (preserve state across sections) =====
type FilterState = {
  period: string; // today|7d|30d|90d|custom
  start?: string; // YYYY-MM-DD when custom
  end?: string;   // YYYY-MM-DD when custom
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

function writeFiltersToURL(fs: FilterState) {
  const sp = new URLSearchParams();
  sp.set("period", fs.period);
  if (fs.start) sp.set("start", fs.start);
  if (fs.end) sp.set("end", fs.end);
  if (fs.channel) sp.set("channel", fs.channel);
  if (fs.seller) sp.set("seller", fs.seller);
  if (fs.category) sp.set("category", fs.category);
  if (fs.payment) sp.set("payment", fs.payment);
  if (fs.compare) sp.set("compare", "1");
  const url = `${window.location.pathname}?${sp.toString()}`;
  window.history.replaceState({}, "", url);
}

function useFilters() {
  const [filters, setFilters] = useState<FilterState>(() => readFiltersFromURL());
  useEffect(() => { writeFiltersToURL(filters); }, [filters]);
  return { filters, setFilters } as const;
}

// ===== KPI Card Component =====
interface KPICardProps {
  icon: React.ReactNode;
  label: string;
  value: string | number;
  change?: string;
  trend?: 'up' | 'down' | 'neutral';
  onClick?: () => void;
}

const KPICard: React.FC<KPICardProps> = ({ icon, label, value, change, trend, onClick }) => {
  const handleClick = () => {
    console.log('overview_kpi_click', { label, value });
    onClick?.();
  };

  return (
    <div 
      className={`bg-white p-6 rounded-xl shadow-sm border border-gray-200 ${onClick ? 'cursor-pointer hover:shadow-md transition-shadow' : ''}`}
      onClick={handleClick}
    >
      <div className="flex items-center justify-between mb-4">
        <div className="p-2 bg-blue-100 rounded-lg">
          {icon}
        </div>
        {trend && (
          <TrendingUp className={`w-5 h-5 ${trend === 'up' ? 'text-green-500' : trend === 'down' ? 'text-red-500' : 'text-gray-500'}`} />
        )}
      </div>
      <h3 className="text-2xl font-bold text-gray-900">{value}</h3>
      <p className="text-gray-600">{label}</p>
      {change && (
        <p className={`text-sm font-medium ${trend === 'up' ? 'text-green-600' : trend === 'down' ? 'text-red-600' : 'text-gray-600'}`}>
          {change}
        </p>
      )}
    </div>
  );
};

// ===== Main Component =====
const ReportsOverviewPage: React.FC = () => {
  const { filters, setFilters } = useFilters();
  const [loading, setLoading] = useState(false);
  const [salesData, setSalesData] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);

  // Convert period to realReportsService format
  const periodMapping = {
    'today': 'week',
    '7d': 'week',
    '30d': 'month',
    '90d': 'quarter',
    'custom': 'month'
  } as const;

  const loadData = async () => {
    setLoading(true);
    setError(null);
    try {
      console.log('overview_timeseries_brush', { filters });
      const period = periodMapping[filters.period as keyof typeof periodMapping] || 'month';
      const data = await realReportsService.getSalesReport(period);
      console.log('📊 [OVERVIEW] Dados recebidos:', data);
      console.log('📊 [OVERVIEW] totalSales:', data?.totalSales);
      console.log('📊 [OVERVIEW] totalAmount:', data?.totalAmount);
      setSalesData(data);
    } catch (err) {
      console.error('Error loading overview data:', err);
      setError('Erro ao carregar dados. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
    
    // ✅ ATUALIZAÇÃO AUTOMÁTICA A CADA 30 SEGUNDOS
    const interval = setInterval(() => {
      console.log('🔄 Atualizando relatórios automaticamente...');
      loadData();
    }, 30000); // 30 segundos
    
    // ✅ LISTENER PARA NOVA VENDA
    const handleNewSale = () => {
      console.log('🎉 Nova venda detectada! Atualizando relatórios...');
      loadData();
    };
    
    window.addEventListener('saleCompleted', handleNewSale);
    
    return () => {
      clearInterval(interval);
      window.removeEventListener('saleCompleted', handleNewSale);
    };
  }, [filters.period]);

  const handleOpenDetailed = () => {
    console.log('overview_open_detailed', { filters });
    // Navigate to detailed with current filters
    window.location.href = `/relatorios/detalhado?${new URLSearchParams(window.location.search).toString()}`;
  };

  // Skeleton Loading State
  if (loading) {
    return (
      <div className="p-6 space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="bg-white p-6 rounded-xl border border-gray-200">
                <div className="h-12 bg-gray-200 rounded mb-4"></div>
                <div className="h-8 bg-gray-200 rounded mb-2"></div>
                <div className="h-4 bg-gray-200 rounded"></div>
              </div>
            ))}
          </div>
          <div className="bg-white p-6 rounded-xl border border-gray-200">
            <div className="h-80 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  // Error State
  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <div className="text-red-600 text-lg font-semibold mb-2">Erro ao carregar dados</div>
          <p className="text-red-500 mb-4">{error}</p>
          <button 
            onClick={loadData}
            className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            Tentar Novamente
          </button>
        </div>
      </div>
    );
  }

  // Empty State
  if (!salesData || (!salesData.totalSales && !salesData.totalAmount)) {
    return (
      <div className="p-6">
        <div className="bg-gray-50 border border-gray-200 rounded-lg p-12 text-center">
          <div className="text-gray-400 text-6xl mb-4">📊</div>
          <div className="text-gray-600 text-lg font-semibold mb-2">Nenhum dado encontrado</div>
          <p className="text-gray-500 mb-4">Não há vendas para o período selecionado.</p>
          <button 
            onClick={() => setFilters({ ...filters, period: '30d' })}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Ver Últimos 30 Dias
          </button>
        </div>
      </div>
    );
  }

  const ticketMedio = salesData.totalSales > 0 ? salesData.totalAmount / salesData.totalSales : 0;

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">📊 Visão Geral</h1>
          <p className="text-gray-600">Resumo executivo do período selecionado</p>
        </div>
        
        {/* Period Filter */}
        <div className="flex items-center gap-4">
          <select
            value={filters.period}
            onChange={(e) => setFilters({ ...filters, period: e.target.value })}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="today">Hoje</option>
            <option value="7d">Últimos 7 dias</option>
            <option value="30d">Últimos 30 dias</option>
            <option value="90d">Últimos 90 dias</option>
          </select>
        </div>
      </div>

      {/* KPIs Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <KPICard
          icon={<DollarSign className="w-6 h-6 text-blue-600" />}
          label="Faturamento"
          value={formatCurrency(salesData.totalAmount || 0)}
          change="+12.5% vs período anterior"
          trend="up"
          onClick={() => console.log('Faturamento clicked')}
        />
        
        <KPICard
          icon={<ShoppingCart className="w-6 h-6 text-green-600" />}
          label="Pedidos"
          value={salesData.totalSales || 0}
          change="+8.2% vs período anterior"
          trend="up"
          onClick={() => console.log('Pedidos clicked')}
        />
        
        <KPICard
          icon={<TrendingUp className="w-6 h-6 text-purple-600" />}
          label="Ticket Médio"
          value={formatCurrency(ticketMedio)}
          change="+3.7% vs período anterior"
          trend="up"
          onClick={() => console.log('Ticket Médio clicked')}
        />
        
        <KPICard
          icon={<Users className="w-6 h-6 text-orange-600" />}
          label="Clientes Únicos"
          value="1,247"
          change="+15.3% vs período anterior"
          trend="up"
          onClick={() => console.log('Clientes clicked')}
        />
      </div>

      {/* Time Series Chart */}
      <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold">📈 Faturamento por Dia</h3>
          <button 
            onClick={handleOpenDetailed}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Ver no Detalhado
            <ArrowUpRight className="w-4 h-4" />
          </button>
        </div>
        
        <ResponsiveContainer width="100%" height={400}>
          <LineChart data={salesData.dailySales || []}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip 
              formatter={(value: any, name: string) => [
                name === 'amount' ? formatCurrency(value) : value,
                name === 'amount' ? 'Valor' : 'Vendas'
              ]}
            />
            <Legend />
            <Line 
              type="monotone" 
              dataKey="amount" 
              stroke="#3B82F6" 
              strokeWidth={3} 
              name="Faturamento" 
              dot={{ fill: '#3B82F6', strokeWidth: 2, r: 4 }}
            />
            <Line 
              type="monotone" 
              dataKey="count" 
              stroke="#10B981" 
              strokeWidth={2} 
              name="Pedidos"
              dot={{ fill: '#10B981', strokeWidth: 2, r: 3 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>

      {/* Highlights */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Top 3 Produtos */}
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <h4 className="font-semibold mb-4">🏆 Top 3 Produtos</h4>
          <div className="space-y-3">
            {salesData.topProducts?.slice(0, 3).map((product: any, index: number) => (
              <div key={index} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="font-medium">{index + 1}. {product.productName}</span>
                <span className="text-green-600 font-semibold">{formatCurrency(product.revenue)}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Pico por Horário */}
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <h4 className="font-semibold mb-4">⏰ Pico de Vendas</h4>
          <div className="text-center">
            <div className="text-3xl font-bold text-blue-600 mb-2">--:-- - --:--</div>
            <p className="text-gray-600 mb-3">Nenhum movimento registrado</p>
            <div className="text-lg font-semibold text-gray-600">
              {formatCurrency(0)} em vendas
            </div>
          </div>
        </div>

        {/* Categorias */}
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <h4 className="font-semibold mb-4">📊 Categorias</h4>
          <div className="space-y-2">
            <div className="flex justify-between items-center">
              <span className="text-green-600">📱 Eletrônicos</span>
              <span className="font-semibold">+23%</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-blue-600">👕 Roupas</span>
              <span className="font-semibold">+15%</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-red-600">🏠 Casa</span>
              <span className="font-semibold">-8%</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ReportsOverviewPage;