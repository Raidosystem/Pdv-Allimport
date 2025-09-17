import React, { useState, useEffect } from 'react';
import { RefreshCw } from 'lucide-react';
import { realReportsService } from '../services/realReportsService';

// Import all report components
import ReportsOverviewPage from './reports/ReportsOverviewPage';
import ReportsDetailedTable from './reports/ReportsDetailedTable';
import ReportsRankingPage from './reports/ReportsRankingPage';
import ReportsChartsPage from './reports/ReportsChartsPage';
import ReportsExportsPage from './reports/ReportsExportsPage';
import ReportsAnalyticsPage from './reports/ReportsAnalyticsPage';

// Tab navigation constants
const TABS = [
  { id: 'overview', label: 'Visão Geral', emoji: '📊' },
  { id: 'detailed', label: 'Detalhado', emoji: '📋' },
  { id: 'ranking', label: 'Rankings', emoji: '🏆' },
  { id: 'charts', label: 'Gráficos', emoji: '📈' },
  { id: 'exports', label: 'Exportações', emoji: '📤' },
  { id: 'analytics', label: 'Analytics', emoji: '🧠' }
] as const;

const RelatoriosPage: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [period, setPeriod] = useState<'week' | 'month' | 'quarter' | 'all'>('month');
  const [activeSection, setActiveSection] = useState<string>('overview');
  const [error, setError] = useState<string | null>(null);

  const loadData = async () => {
    setLoading(true);
    setError(null);
    
    try {
      console.log('🔄 Carregando dados reais dos relatórios...');
      
      const [sales, clients, services] = await Promise.all([
        realReportsService.getSalesReport(period === 'all' ? 'quarter' : period),
        realReportsService.getClientsReport(period === 'all' ? 'quarter' : period),
        realReportsService.getServiceOrdersReport(period)
      ]);
      
      console.log('✅ Dados carregados:', { sales, clients, services });
    } catch (err) {
      console.error('❌ Erro ao carregar dados:', err);
      setError('Erro ao carregar dados. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [period]);

  // Função para renderizar a seção ativa
  const renderActiveSection = () => {
    switch (activeSection) {
      case 'overview':
        return <ReportsOverviewPage />;
      case 'detailed':
        return <ReportsDetailedTable />;
      case 'ranking':
        return <ReportsRankingPage />;
      case 'charts':
        return <ReportsChartsPage />;
      case 'exports':
        return <ReportsExportsPage />;
      case 'analytics':
        return <ReportsAnalyticsPage />;
      default:
        return <ReportsOverviewPage />;
    }
  };

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-xl font-bold text-red-600 mb-2">Erro ao carregar dados</h2>
          <p className="text-gray-600 mb-4">{error}</p>
          <button
            onClick={loadData}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Tentar Novamente
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="bg-white shadow-sm border-b border-gray-200 px-6 py-4">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">📊 Relatórios Profissionais</h1>
              <p className="text-gray-600">Sistema completo de análise e reportes do PDV</p>
            </div>
            
            <div className="flex items-center gap-4 mt-4 lg:mt-0">
              <select
                value={period}
                onChange={(e) => setPeriod(e.target.value as 'week' | 'month' | 'quarter' | 'all')}
                className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="week">Última Semana</option>
                <option value="month">Último Mês</option>
                <option value="quarter">Último Trimestre</option>
                <option value="all">Todos os Períodos</option>
              </select>
              
              <button
                onClick={loadData}
                disabled={loading}
                className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors"
              >
                <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                {loading ? 'Atualizando...' : 'Atualizar'}
              </button>
            </div>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="bg-white border-b border-gray-200 px-6">
          <div className="flex overflow-x-auto">
            {TABS.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveSection(tab.id)}
                className={`flex items-center gap-2 px-6 py-4 text-sm font-medium border-b-2 transition-colors whitespace-nowrap ${
                  activeSection === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <span className="text-lg">{tab.emoji}</span>
                {tab.label}
              </button>
            ))}
          </div>
        </div>

        {/* Content */}
        <div className="min-h-screen">
          {renderActiveSection()}
        </div>

        {/* Footer */}
        <div className="bg-white p-6 border-t border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-gray-900">Sistema PDV Allimport</p>
              <p className="text-sm text-gray-600">
                Última atualização: {new Date().toLocaleString('pt-BR')} • 
                {loading ? ' Sincronizando...' : ' Online'}
              </p>
            </div>
            <div className="text-sm text-gray-500">
              Dados reais do banco • Período: {
                period === 'week' ? 'Semanal' : 
                period === 'month' ? 'Mensal' : 
                period === 'quarter' ? 'Trimestral' : 
                'Todos os Períodos'
              }
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RelatoriosPage;