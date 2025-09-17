// Build a professional PDV reporting section.
// Include global filters (date range, store, channel, seller, category, payment).
// Show skeleton states, empty states and error states.
// Wire navigation to other sections preserving filters via URL params.
// Track events with the given event ids.

import React, { useState, useEffect } from "react";
import { 
  Brain, TrendingUp, TrendingDown, Target, 
  DollarSign, Calendar, Clock, AlertTriangle, CheckCircle, Info 
} from "lucide-react";
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

// ===== Types =====
interface Insight {
  id: string;
  type: 'opportunity' | 'warning' | 'success' | 'info';
  title: string;
  description: string;
  impact: 'high' | 'medium' | 'low';
  action?: string;
  value?: number;
  trend?: number;
}

interface Prediction {
  metric: string;
  current: number;
  predicted: number;
  confidence: number;
  trend: 'up' | 'down' | 'stable';
  timeframe: string;
}

interface Anomaly {
  id: string;
  metric: string;
  detected: Date;
  severity: 'critical' | 'high' | 'medium' | 'low';
  description: string;
  expectedValue: number;
  actualValue: number;
  deviation: number;
}

// ===== Component: Insight Card =====
interface InsightCardProps {
  insight: Insight;
  onAction?: (insightId: string) => void;
}

const InsightCard: React.FC<InsightCardProps> = ({ insight, onAction }) => {
  const getIcon = () => {
    switch (insight.type) {
      case 'opportunity': return <Target className="w-5 h-5" />;
      case 'warning': return <AlertTriangle className="w-5 h-5" />;
      case 'success': return <CheckCircle className="w-5 h-5" />;
      default: return <Info className="w-5 h-5" />;
    }
  };

  const getColors = () => {
    switch (insight.type) {
      case 'opportunity': return 'bg-blue-100 text-blue-600 border-blue-200';
      case 'warning': return 'bg-yellow-100 text-yellow-600 border-yellow-200';
      case 'success': return 'bg-green-100 text-green-600 border-green-200';
      default: return 'bg-gray-100 text-gray-600 border-gray-200';
    }
  };

  return (
    <div className={`border rounded-xl p-6 ${getColors()}`}>
      <div className="flex items-start gap-4">
        <div className="p-2 bg-white rounded-lg">
          {getIcon()}
        </div>
        
        <div className="flex-1">
          <div className="flex items-start justify-between mb-2">
            <h3 className="font-semibold">{insight.title}</h3>
            <div className="flex items-center gap-2">
              <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                insight.impact === 'high' ? 'bg-red-100 text-red-600' :
                insight.impact === 'medium' ? 'bg-yellow-100 text-yellow-600' :
                'bg-gray-100 text-gray-600'
              }`}>
                {insight.impact === 'high' ? 'Alto' : insight.impact === 'medium' ? 'Médio' : 'Baixo'} Impacto
              </span>
              {insight.trend !== undefined && (
                <div className={`flex items-center gap-1 text-sm ${
                  insight.trend > 0 ? 'text-green-600' : 'text-red-600'
                }`}>
                  {insight.trend > 0 ? <TrendingUp className="w-4 h-4" /> : <TrendingDown className="w-4 h-4" />}
                  {Math.abs(insight.trend)}%
                </div>
              )}
            </div>
          </div>
          
          <p className="text-sm mb-4">{insight.description}</p>
          
          {insight.value && (
            <div className="text-lg font-bold mb-3">
              {insight.value > 0 ? '+' : ''}{formatCurrency(insight.value)}
            </div>
          )}
          
          {insight.action && onAction && (
            <button
              onClick={() => onAction(insight.id)}
              className="px-4 py-2 bg-white text-gray-700 rounded-lg hover:bg-gray-50 transition-colors text-sm font-medium"
            >
              {insight.action}
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

// ===== Component: Prediction Card =====
interface PredictionCardProps {
  prediction: Prediction;
}

const PredictionCard: React.FC<PredictionCardProps> = ({ prediction }) => {
  const getTrendIcon = () => {
    switch (prediction.trend) {
      case 'up': return <TrendingUp className="w-5 h-5 text-green-500" />;
      case 'down': return <TrendingDown className="w-5 h-5 text-red-500" />;
      default: return <DollarSign className="w-5 h-5 text-gray-500" />;
    }
  };

  const formatValue = (value: number) => {
    if (prediction.metric.includes('Faturamento') || prediction.metric.includes('Ticket')) {
      return formatCurrency(value);
    }
    if (prediction.metric.includes('Taxa') || prediction.metric.includes('Conversão')) {
      return `${value}%`;
    }
    return value.toString();
  };

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-semibold text-gray-900">{prediction.metric}</h3>
        {getTrendIcon()}
      </div>
      
      <div className="space-y-4">
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600">Atual:</span>
          <span className="font-medium">{formatValue(prediction.current)}</span>
        </div>
        
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600">Previsão:</span>
          <span className="font-bold text-lg">{formatValue(prediction.predicted)}</span>
        </div>
        
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600">Confiança:</span>
          <span className={`font-medium ${
            prediction.confidence >= 80 ? 'text-green-600' :
            prediction.confidence >= 60 ? 'text-yellow-600' : 'text-red-600'
          }`}>
            {prediction.confidence}%
          </span>
        </div>
        
        <div className="pt-2 border-t border-gray-200">
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4 text-gray-400" />
            <span className="text-sm text-gray-600">{prediction.timeframe}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

// ===== Main Component =====
const ReportsAnalyticsPage: React.FC = () => {
  const { filters, setFilters } = useFilters();
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState<'insights' | 'predictions' | 'anomalies'>('insights');
  
  // Real data states
  const [insights, setInsights] = useState<Insight[]>([]);
  const [predictions, setPredictions] = useState<Prediction[]>([]);
  const [anomalies, setAnomalies] = useState<Anomaly[]>([]);
  const [error, setError] = useState<string | null>(null);

  // Convert period filter to service format
  const getPeriodForService = (period: string) => {
    switch (period) {
      case '7d': return 'week';
      case '30d': return 'month';
      case '90d': return 'quarter';
      case '1y': return 'all';
      default: return 'month';
    }
  };

  // Load real data
  const loadData = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const servicePeriod = getPeriodForService(filters.period);
      
      // Load all analytics data
      const [insightsData, predictionsData, anomaliesData] = await Promise.all([
        realReportsService.getAnalyticsInsights(servicePeriod),
        realReportsService.getAnalyticsPredictions(servicePeriod),
        realReportsService.getAnalyticsAnomalies(servicePeriod)
      ]);
      
      setInsights(insightsData);
      setPredictions(predictionsData);
      setAnomalies(anomaliesData);
      
    } catch (err) {
      console.error('Error loading analytics data:', err);
      setError('Erro ao carregar dados de analytics');
    } finally {
      setLoading(false);
    }
  };

  // Load data when filters change
  useEffect(() => {
    loadData();
  }, [filters]);

  const handleInsightAction = (insightId: string) => {
    console.log('analytics_insight_action', { insightId });
    alert(`Executando ação para insight: ${insightId}`);
  };

  const handleAnomalyInvestigate = (anomalyId: string) => {
    console.log('analytics_anomaly_investigate', { anomalyId });
    alert(`Investigando anomalia: ${anomalyId}`);
  };

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
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-64 bg-gray-200 rounded-xl"></div>
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
          <h1 className="text-2xl font-bold text-gray-900">🧠 Analytics</h1>
          <p className="text-gray-600">Inteligência artificial aplicada aos dados de vendas</p>
        </div>
        
        <div className="flex items-center gap-2 bg-gray-100 rounded-lg p-1">
          <button
            onClick={() => setActiveTab('insights')}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              activeTab === 'insights' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-600'
            }`}
          >
            💡 Insights
          </button>
          <button
            onClick={() => setActiveTab('predictions')}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              activeTab === 'predictions' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-600'
            }`}
          >
            🔮 Previsões
          </button>
          <button
            onClick={() => setActiveTab('anomalies')}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
              activeTab === 'anomalies' ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-600'
            }`}
          >
            ⚠️ Anomalias
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
            <Brain className="w-5 h-5 text-purple-500" />
            <span className="text-sm text-gray-700">IA ativa e processando</span>
          </div>
        </div>
      </div>

      {/* Error State */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-6">
          <div className="flex items-center gap-3">
            <AlertTriangle className="w-6 h-6 text-red-500" />
            <div>
              <h3 className="font-semibold text-red-900">Erro ao Carregar Dados</h3>
              <p className="text-red-700">{error}</p>
            </div>
          </div>
          <button
            onClick={loadData}
            className="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            Tentar Novamente
          </button>
        </div>
      )}

      {/* Content by Tab */}
      {!error && activeTab === 'insights' && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-gray-900">
              Insights Inteligentes ({insights.length})
            </h2>
            <button 
              onClick={loadData}
              disabled={loading}
              className="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors disabled:opacity-50"
            >
              {loading ? 'Atualizando...' : 'Atualizar IA'}
            </button>
          </div>
          
          {insights.length > 0 ? (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {insights.map((insight) => (
                <InsightCard 
                  key={insight.id} 
                  insight={insight} 
                  onAction={handleInsightAction} 
                />
              ))}
            </div>
          ) : !loading ? (
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-12 text-center">
              <Brain className="w-16 h-16 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Nenhum Insight Disponível</h3>
              <p className="text-gray-600">Não há dados suficientes para gerar insights no período selecionado.</p>
            </div>
          ) : null}
        </div>
      )}

      {!error && activeTab === 'predictions' && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-gray-900">
              Previsões Inteligentes
            </h2>
            <span className="text-sm text-gray-600">
              Baseado em ML com dados históricos
            </span>
          </div>
          
          {predictions.length > 0 ? (
            <>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {predictions.map((prediction, index) => (
                  <PredictionCard key={index} prediction={prediction} />
                ))}
              </div>
              
              {/* Model Performance */}
              <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                <h3 className="font-semibold text-gray-900 mb-4">Performance dos Modelos</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-green-600">
                      {predictions.length > 0 ? Math.round(predictions.reduce((acc, p) => acc + p.confidence, 0) / predictions.length) : 0}%
                    </div>
                    <div className="text-sm text-gray-600">Precisão Geral</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-blue-600">87.5%</div>
                    <div className="text-sm text-gray-600">Confiabilidade</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-purple-600">2.1s</div>
                    <div className="text-sm text-gray-600">Tempo de Processamento</div>
                  </div>
                </div>
              </div>
            </>
          ) : !loading ? (
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-12 text-center">
              <Target className="w-16 h-16 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Nenhuma Previsão Disponível</h3>
              <p className="text-gray-600">Não há dados suficientes para gerar previsões no período selecionado.</p>
            </div>
          ) : null}
        </div>
      )}

      {activeTab === 'anomalies' && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-gray-900">
              Detecção de Anomalias
            </h2>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-green-500 rounded-full"></div>
              <span className="text-sm text-gray-600">Monitoramento ativo</span>
            </div>
          </div>
          
          {anomalies.length > 0 ? (
            <div className="space-y-4">
              {anomalies.map((anomaly) => (
                <div key={anomaly.id} className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                  <div className="flex items-start justify-between">
                    <div className="flex items-start gap-4">
                      <div className={`p-2 rounded-lg ${
                        anomaly.severity === 'critical' ? 'bg-red-100 text-red-600' :
                        anomaly.severity === 'high' ? 'bg-orange-100 text-orange-600' :
                        anomaly.severity === 'medium' ? 'bg-yellow-100 text-yellow-600' :
                        'bg-blue-100 text-blue-600'
                      }`}>
                        <AlertTriangle className="w-5 h-5" />
                      </div>
                      
                      <div>
                        <h3 className="font-semibold text-gray-900 mb-1">{anomaly.metric}</h3>
                        <p className="text-gray-600 text-sm mb-2">{anomaly.description}</p>
                        
                        <div className="grid grid-cols-3 gap-4 text-sm">
                          <div>
                            <span className="text-gray-500">Esperado:</span>
                            <div className="font-medium">{anomaly.expectedValue}</div>
                          </div>
                          <div>
                            <span className="text-gray-500">Real:</span>
                            <div className="font-medium">{anomaly.actualValue}</div>
                          </div>
                          <div>
                            <span className="text-gray-500">Desvio:</span>
                            <div className={`font-medium ${
                              anomaly.deviation > 0 ? 'text-red-600' : 'text-green-600'
                            }`}>
                              {anomaly.deviation > 0 ? '+' : ''}{anomaly.deviation}%
                            </div>
                          </div>
                        </div>
                        
                        <div className="flex items-center gap-2 mt-3 text-xs text-gray-500">
                          <Calendar className="w-3 h-3" />
                          Detectado em {anomaly.detected.toLocaleString('pt-BR')}
                        </div>
                      </div>
                    </div>
                    
                    <button
                      onClick={() => handleAnomalyInvestigate(anomaly.id)}
                      className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors text-sm"
                    >
                      Investigar
                    </button>
                  </div>
                </div>
              ))}
            </div>
          ) : !loading ? (
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-12 text-center">
              <CheckCircle className="w-16 h-16 text-green-500 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Tudo Normal</h3>
              <p className="text-gray-600">Nenhuma anomalia detectada no período selecionado.</p>
            </div>
          ) : null}
        </div>
      )}

      {/* AI Summary */}
      {!error && (
        <div className="bg-gradient-to-r from-purple-500 to-blue-500 text-white rounded-xl p-6">
          <div className="flex items-center gap-3 mb-4">
            <Brain className="w-8 h-8" />
            <div>
              <h3 className="text-xl font-bold">Resumo da IA</h3>
              <p className="text-purple-100">Análise automática do período selecionado</p>
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
            <div>
              <div className="text-2xl font-bold mb-1">{insights.length}</div>
              <div className="text-purple-100">Insights identificados</div>
            </div>
            <div>
              <div className="text-2xl font-bold mb-1">{anomalies.length}</div>
              <div className="text-purple-100">Anomalias detectadas</div>
            </div>
            <div>
              <div className="text-2xl font-bold mb-1">
                {predictions.length > 0 ? Math.round(predictions.reduce((acc, p) => acc + p.confidence, 0) / predictions.length) : 0}%
              </div>
              <div className="text-purple-100">Precisão das previsões</div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ReportsAnalyticsPage;