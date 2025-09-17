// Build a professional PDV reporting section.
// Include global filters (date range, store, channel, seller, category, payment).
// Show skeleton states, empty states and error states.
// Wire navigation to other sections preserving filters via URL params.
// Track events with the given event ids.

import React, { useState, useEffect } from "react";
import { Trophy, TrendingUp, TrendingDown, Award, Crown, Target, Star, Medal } from "lucide-react";
import { formatCurrency } from "../../utils/format";
import { realReportsService } from "../../services/realReportsService";

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

// ===== Mock Data REMOVIDO - usando dados reais =====

// ===== Mock Data para Ordens de Serviço (REMOVIDO - usando dados reais) =====

// ===== Ranking Card Component =====
interface RankingCardProps {
  title: string;
  icon: React.ReactNode;
  data: any[];
  renderItem: (item: any, index: number) => React.ReactNode;
  emptyMessage?: string;
}

const RankingCard: React.FC<RankingCardProps> = ({ title, icon, data, renderItem, emptyMessage }) => (
  <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
    <div className="p-6 border-b border-gray-200">
      <div className="flex items-center gap-3">
        <div className="p-2 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-lg text-white">
          {icon}
        </div>
        <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
      </div>
    </div>
    
    <div className="p-6">
      {data.length === 0 ? (
        <div className="text-center py-8">
          <div className="text-gray-400 text-4xl mb-2">🏆</div>
          <p className="text-gray-500">{emptyMessage || "Nenhum dado disponível"}</p>
        </div>
      ) : (
        <div className="space-y-4">
          {data.slice(0, 5).map((item, index) => renderItem(item, index))}
        </div>
      )}
    </div>
  </div>
);

// ===== Main Component =====
const ReportsRankingPage: React.FC = () => {
  const { filters, setFilters } = useFilters();
  const [loading, setLoading] = useState(false);
  const [activeView, setActiveView] = useState<'orders' | 'products' | 'categories'>('orders');

  // Estados para dados reais
  const [realClientRepairRanking, setRealClientRepairRanking] = useState<any[]>([]);
  const [realClientSpendingRanking, setRealClientSpendingRanking] = useState<any[]>([]);
  const [realOrderTypeRanking, setRealOrderTypeRanking] = useState<any[]>([]);
  const [realEquipmentProfitRanking, setRealEquipmentProfitRanking] = useState<any[]>([]);
  const [realProductRanking, setRealProductRanking] = useState<any[]>([]);
  const [realCategoryRanking, setRealCategoryRanking] = useState<any[]>([]);

  // Carregar dados reais
  useEffect(() => {
    const loadRealData = async () => {
      setLoading(true);
      try {
        const period = filters.period.replace('d', '').replace('30', 'month').replace('7', 'week').replace('90', 'quarter').replace('1y', 'all') as any;
        
        if (activeView === 'orders') {
          const [
            clientRepairData,
            clientSpendingData,
            orderTypeData,
            equipmentProfitData
          ] = await Promise.all([
            realReportsService.getClientRepairRanking(period),
            realReportsService.getClientSpendingRanking(period),
            realReportsService.getOrderTypeRanking(period),
            realReportsService.getEquipmentProfitRanking(period)
          ]);

          setRealClientRepairRanking(clientRepairData);
          setRealClientSpendingRanking(clientSpendingData);
          setRealOrderTypeRanking(orderTypeData);
          setRealEquipmentProfitRanking(equipmentProfitData);
        } else if (activeView === 'products') {
          const productData = await realReportsService.getProductRanking(period);
          setRealProductRanking(productData);
        } else if (activeView === 'categories') {
          const categoryData = await realReportsService.getCategoryRanking(period);
          setRealCategoryRanking(categoryData);
        }
      } catch (error) {
        console.error('❌ Erro ao carregar dados de ranking:', error);
      } finally {
        setLoading(false);
      }
    };

    loadRealData();
  }, [filters, activeView]);

  const handleViewChange = (view: 'orders' | 'products' | 'categories') => {
    console.log('ranking_view_change', { from: activeView, to: view });
    setActiveView(view);
  };

  const getRankingIcon = (position: number) => {
    switch (position) {
      case 0: return <Crown className="w-5 h-5 text-yellow-500" />;
      case 1: return <Medal className="w-5 h-5 text-gray-400" />;
      case 2: return <Award className="w-5 h-5 text-amber-600" />;
      default: return <Star className="w-5 h-5 text-gray-300" />;
    }
  };

  const renderProductItem = (product: any, index: number) => (
    <div key={product.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          {getRankingIcon(index)}
          <span className="text-2xl font-bold text-gray-400">#{index + 1}</span>
        </div>
        <div>
          <div className="font-semibold text-gray-900">{product.name}</div>
          <div className="text-sm text-gray-600">{product.category} • {product.units} unidades</div>
        </div>
      </div>
      
      <div className="text-right">
        <div className="font-bold text-lg text-gray-900">{formatCurrency(product.revenue)}</div>
        <div className="text-sm text-gray-600">Margem: {product.margin}%</div>
      </div>
    </div>
  );

  const renderCategoryItem = (category: any, index: number) => (
    <div key={category.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          {getRankingIcon(index)}
          <span className="text-2xl font-bold text-gray-400">#{index + 1}</span>
        </div>
        <div>
          <div className="font-semibold text-gray-900">{category.name}</div>
          <div className="text-sm text-gray-600">{category.sales} vendas • {category.participation}% do total</div>
        </div>
      </div>
      
      <div className="text-right">
        <div className="font-bold text-lg text-gray-900">{formatCurrency(category.revenue)}</div>
        <div className="flex items-center gap-2 text-sm">
          <span className="text-gray-600">Margem: {category.margin}%</span>
          <div className={`flex items-center gap-1 ${category.growth >= 0 ? 'text-green-600' : 'text-red-600'}`}>
            {category.growth >= 0 ? <TrendingUp className="w-4 h-4" /> : <TrendingDown className="w-4 h-4" />}
            <span>{Math.abs(category.growth)}%</span>
          </div>
        </div>
      </div>
    </div>
  );

  // ===== Render Functions para Ordens de Serviço =====
  const renderClientRepairItem = (client: any, index: number) => (
    <div key={client.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          {getRankingIcon(index)}
          <span className="text-2xl font-bold text-gray-400">#{index + 1}</span>
        </div>
        <div>
          <div className="font-semibold text-gray-900">{client.name}</div>
          <div className="text-sm text-gray-600">{client.orders} ordens • Último: {new Date(client.lastOrder).toLocaleDateString('pt-BR')}</div>
        </div>
      </div>
      
      <div className="text-right">
        <div className="font-bold text-lg text-gray-900">{formatCurrency(client.totalValue)}</div>
        <div className="text-sm text-gray-600">Ticket: {formatCurrency(client.avgValue)}</div>
      </div>
    </div>
  );

  const renderClientSpendingItem = (client: any, index: number) => (
    <div key={client.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          {getRankingIcon(index)}
          <span className="text-2xl font-bold text-gray-400">#{index + 1}</span>
        </div>
        <div>
          <div className="font-semibold text-gray-900">{client.name}</div>
          <div className="text-sm text-gray-600">{client.category} • {client.orders} ordens</div>
        </div>
      </div>
      
      <div className="text-right">
        <div className="font-bold text-lg text-gray-900">{formatCurrency(client.totalValue)}</div>
        <div className="text-sm text-gray-600">Ticket: {formatCurrency(client.avgValue)}</div>
      </div>
    </div>
  );

  const renderOrderTypeItem = (orderType: any, index: number) => (
    <div key={orderType.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          {getRankingIcon(index)}
          <span className="text-2xl font-bold text-gray-400">#{index + 1}</span>
        </div>
        <div>
          <div className="font-semibold text-gray-900">{orderType.type}</div>
          <div className="text-sm text-gray-600">{orderType.count} ordens • {orderType.percentage}% do total</div>
        </div>
      </div>
      
      <div className="text-right">
        <div className="font-bold text-lg text-gray-900">{formatCurrency(orderType.avgValue)}</div>
        <div className="text-sm text-gray-600">Tempo: {orderType.avgTime}</div>
      </div>
    </div>
  );

  const renderEquipmentProfitItem = (equipment: any, index: number) => (
    <div key={equipment.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2">
          {getRankingIcon(index)}
          <span className="text-2xl font-bold text-gray-400">#{index + 1}</span>
        </div>
        <div>
          <div className="font-semibold text-gray-900">{equipment.equipment}</div>
          <div className="text-sm text-gray-600">{equipment.count} reparos • Margem: {equipment.margin}%</div>
        </div>
      </div>
      
      <div className="text-right">
        <div className="font-bold text-lg text-gray-900">{formatCurrency(equipment.profit)}</div>
        <div className="text-sm text-gray-600">Receita: {formatCurrency(equipment.revenue)}</div>
      </div>
    </div>
  );

  // Loading skeleton
  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="flex gap-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-10 bg-gray-200 rounded w-32"></div>
            ))}
          </div>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {[...Array(4)].map((_, i) => (
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
          <h1 className="text-2xl font-bold text-gray-900">🏆 Rankings</h1>
          <p className="text-gray-600">Tops de performance e competição interna</p>
        </div>
        
        <div className="flex items-center gap-2 bg-gray-100 rounded-lg p-1">
          <button
            onClick={() => handleViewChange('orders')}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              activeView === 'orders' 
                ? 'bg-white text-gray-900 shadow-sm' 
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            �️ Ordens de Serviço
          </button>
          <button
            onClick={() => handleViewChange('products')}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              activeView === 'products' 
                ? 'bg-white text-gray-900 shadow-sm' 
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            📦 Produtos
          </button>
          <button
            onClick={() => handleViewChange('categories')}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              activeView === 'categories' 
                ? 'bg-white text-gray-900 shadow-sm' 
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            🏷️ Categorias
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

          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              id="compare"
              checked={filters.compare}
              onChange={(e) => setFilters({ ...filters, compare: e.target.checked })}
              className="rounded border-gray-300"
            />
            <label htmlFor="compare" className="text-sm text-gray-700">
              Comparar com período anterior
            </label>
          </div>
        </div>
      </div>

      {/* Rankings Grid */}
      {activeView === 'orders' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <RankingCard
            title="🔧 Clientes que Mais Arrumaram"
            icon={<Trophy className="w-5 h-5" />}
            data={realClientRepairRanking}
            renderItem={renderClientRepairItem}
            emptyMessage="Nenhum cliente encontrado no período"
          />
          
          <RankingCard
            title="� Clientes que Mais Gastaram"
            icon={<TrendingUp className="w-5 h-5" />}
            data={realClientSpendingRanking}
            renderItem={renderClientSpendingItem}
            emptyMessage="Dados de gastos indisponíveis"
          />
          
          <RankingCard
            title="📱 Tipos de OS Mais Frequentes"
            icon={<Target className="w-5 h-5" />}
            data={realOrderTypeRanking}
            renderItem={renderOrderTypeItem}
            emptyMessage="Dados de tipos de OS indisponíveis"
          />
          
          <RankingCard
            title="💸 Lucro por Tipo de Equipamento"
            icon={<Award className="w-5 h-5" />}
            data={realEquipmentProfitRanking}
            renderItem={renderEquipmentProfitItem}
            emptyMessage="Dados de lucro indisponíveis"
          />
        </div>
      )}

      {activeView === 'products' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <RankingCard
            title="🏆 Top Produtos por Faturamento"
            icon={<Trophy className="w-5 h-5" />}
            data={realProductRanking}
            renderItem={renderProductItem}
            emptyMessage="Nenhum produto encontrado no período"
          />
          
          <RankingCard
            title="📊 Produtos Mais Vendidos (Qtd)"
            icon={<Star className="w-5 h-5" />}
            data={[...realProductRanking].sort((a, b) => b.units - a.units)}
            renderItem={renderProductItem}
            emptyMessage="Dados de quantidade indisponíveis"
          />
          
          <RankingCard
            title="💰 Maior Margem de Lucro"
            icon={<Target className="w-5 h-5" />}
            data={[...realProductRanking].sort((a, b) => b.margin - a.margin)}
            renderItem={renderProductItem}
            emptyMessage="Dados de margem indisponíveis"
          />
          
          <RankingCard
            title="🔥 Produtos em Alta"
            icon={<TrendingUp className="w-5 h-5" />}
            data={realProductRanking}
            renderItem={renderProductItem}
            emptyMessage="Nenhuma tendência detectada"
          />
        </div>
      )}

      {activeView === 'categories' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <RankingCard
            title="🏆 Top Categorias por Faturamento"
            icon={<Trophy className="w-5 h-5" />}
            data={realCategoryRanking}
            renderItem={renderCategoryItem}
            emptyMessage="Nenhuma categoria encontrada no período"
          />
          
          <RankingCard
            title="📈 Crescimento por Categoria"
            icon={<TrendingUp className="w-5 h-5" />}
            data={[...realCategoryRanking].sort((a, b) => b.growth - a.growth)}
            renderItem={renderCategoryItem}
            emptyMessage="Dados de crescimento indisponíveis"
          />
          
          <RankingCard
            title="💰 Maior Margem por Categoria"
            icon={<Target className="w-5 h-5" />}
            data={[...realCategoryRanking].sort((a, b) => b.margin - a.margin)}
            renderItem={renderCategoryItem}
            emptyMessage="Dados de margem indisponíveis"
          />
          
          <RankingCard
            title="📊 Participação no Faturamento"
            icon={<Award className="w-5 h-5" />}
            data={[...realCategoryRanking].sort((a, b) => b.participation - a.participation)}
            renderItem={renderCategoryItem}
            emptyMessage="Dados de participação indisponíveis"
          />
        </div>
      )}

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white p-6 rounded-xl">
          <div className="flex items-center gap-3 mb-2">
            <Crown className="w-6 h-6" />
            <span className="text-sm font-medium opacity-90">Campeão Geral</span>
          </div>
          <div className="text-2xl font-bold mb-1">
            {activeView === 'orders' ? realClientSpendingRanking[0]?.name || 'Carregando...' :
             activeView === 'products' ? realProductRanking[0]?.name || 'Carregando...' :
             realCategoryRanking[0]?.name || 'Carregando...'}
          </div>
          <div className="text-sm opacity-90">
            {formatCurrency(
              activeView === 'orders' ? realClientSpendingRanking[0]?.totalValue || 0 :
              activeView === 'products' ? realProductRanking[0]?.revenue || 0 :
              realCategoryRanking[0]?.revenue || 0
            )}
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <div className="flex items-center gap-3 mb-2">
            <Medal className="w-6 h-6 text-gray-500" />
            <span className="text-sm font-medium text-gray-600">Competitividade</span>
          </div>
          <div className="text-2xl font-bold text-gray-900 mb-1">Alta</div>
          <div className="text-sm text-gray-600">Top 3 representam 65%</div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <div className="flex items-center gap-3 mb-2">
            <TrendingUp className="w-6 h-6 text-green-500" />
            <span className="text-sm font-medium text-gray-600">Crescimento Médio</span>
          </div>
          <div className="text-2xl font-bold text-gray-900 mb-1">+12.4%</div>
          <div className="text-sm text-gray-600">vs período anterior</div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <div className="flex items-center gap-3 mb-2">
            <Target className="w-6 h-6 text-blue-500" />
            <span className="text-sm font-medium text-gray-600">Oportunidades</span>
          </div>
          <div className="text-2xl font-bold text-gray-900 mb-1">3</div>
          <div className="text-sm text-gray-600">Posições para melhorar</div>
        </div>
      </div>
    </div>
  );
};

export default ReportsRankingPage;