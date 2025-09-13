import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { 
  BarChart3, 
  TrendingUp, 
  DollarSign, 
  Users, 
  Package, 
  ShoppingCart,
  Download,
  ArrowLeft,
  AlertTriangle,
  ArrowUp,
  ArrowDown
} from 'lucide-react'
import { reportsService } from '../services/reportsService'
import { debugDatabase } from '../utils/debugDatabase'
import { createSampleData } from '../utils/createSampleData'
import { testSupabaseConnection } from '../utils/testSupabase'
import { SalesTabComponent } from '../components/reports/SalesTab'
import { FinancialTab } from '../components/reports/FinancialTab'
import { StockTab } from '../components/reports/StockTab'
import { ClientsTab } from '../components/reports/ClientsTab'
// import { NotificationPanel } from '../components/reports/NotificationPanel'
// import { GoalsManagerPanel } from '../components/reports/GoalsManagerPanel'
import type { DashboardMetrics, ReportFilters } from '../types/reports'

export default function ReportsPage() {
  const navigate = useNavigate()
  const [loading, setLoading] = useState(false)
  const [data, setData] = useState<DashboardMetrics | null>(null)
  const [activeTab, setActiveTab] = useState('dashboard')
  const [debugInfo, setDebugInfo] = useState<string | null>(null)
  const [filters, setFilters] = useState<ReportFilters>({})

  const formatCurrency = (value: number): string => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const loadDashboardData = async () => {
    setLoading(true)
    try {
      const metrics = await reportsService.getDashboardMetrics(filters)
      setData(metrics)
    } catch (error) {
      console.error('Erro ao carregar métricas:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadDashboardData()
  }, [filters])

  const tabs = [
    {
      id: 'dashboard',
      label: 'Dashboard',
      icon: BarChart3
    },
    {
      id: 'vendas',
      label: 'Vendas',
      icon: ShoppingCart
    },
    {
      id: 'financeiro',
      label: 'Financeiro',
      icon: DollarSign
    },
    {
      id: 'estoque',
      label: 'Estoque',
      icon: Package
    },
    {
      id: 'clientes',
      label: 'Clientes',
      icon: Users
    }
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => navigate(-1)}
                className="flex items-center space-x-2 px-3 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
              >
                <ArrowLeft className="h-4 w-4" />
                <span>Voltar</span>
              </button>
              <h1 className="text-2xl font-bold text-gray-900">Relatórios</h1>
            </div>
            
            <div className="flex items-center space-x-3">
              {/* <button 
                onClick={() => setShowNotifications(true)}
                className="flex items-center space-x-2 px-4 py-2 bg-amber-600 text-white rounded-lg hover:bg-amber-700 transition-colors"
              >
                <Bell className="h-4 w-4" />
                <span>Alertas</span>
              </button>
              <button 
                onClick={() => setShowGoals(true)}
                className="flex items-center space-x-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
              >
                <Target className="h-4 w-4" />
                <span>Metas</span>
              </button> */}
              <button className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                <Download className="h-4 w-4" />
                <span>Exportar</span>
              </button>
              <button 
                onClick={() => debugDatabase()}
                className="flex items-center space-x-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
              >
                <span>Debug DB</span>
              </button>
            </div>
          </div>

          {/* Tabs */}
          <div className="border-b border-gray-200">
            <div className="flex space-x-8">
              {tabs.map((tab) => {
                const IconComponent = tab.icon
                return (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`flex items-center space-x-2 py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                      activeTab === tab.id
                        ? 'bg-blue-100 text-blue-700 border-b-2 border-blue-600'
                        : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                    }`}
                  >
                    <IconComponent className="h-4 w-4" />
                    <span>{tab.label}</span>
                  </button>
                )
              })}
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="p-6">
        {/* Debug Panel - Temporary */}
        {debugInfo && (
          <div className="mb-6 p-4 bg-gray-100 rounded-lg">
            <h3 className="font-bold mb-2">Debug Info:</h3>
            <pre className="text-xs overflow-auto max-h-40">{debugInfo}</pre>
          </div>
        )}
        {activeTab === 'dashboard' && (
          <div>
            <div className="mb-4">
              <button 
                onClick={async () => {
                  const test = await testSupabaseConnection()
                  setDebugInfo(JSON.stringify(test, null, 2))
                }}
                className="mr-2 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
              >
                Test Supabase
              </button>
              <button 
                onClick={async () => {
                  const sample = await createSampleData()
                  setDebugInfo(JSON.stringify(sample, null, 2))
                }}
                className="mr-2 px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600"
              >
                Create Sample Data
              </button>
              <button 
                onClick={async () => {
                  const debug = await debugDatabase()
                  setDebugInfo(JSON.stringify(debug, null, 2))
                }}
                className="px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600"
              >
                Debug Database
              </button>
            </div>
            <DashboardTab 
              data={data} 
              loading={loading} 
              formatCurrency={formatCurrency}
            />
          </div>
        )}
        {activeTab === 'vendas' && (
          <SalesTabComponent 
            filters={filters}
            setFilters={setFilters}
            formatCurrency={formatCurrency}
          />
        )}
        {activeTab === 'financeiro' && (
          <FinancialTab 
            filters={filters}
            setFilters={setFilters}
            formatCurrency={formatCurrency}
          />
        )}
        {activeTab === 'estoque' && (
          <StockTab formatCurrency={formatCurrency} />
        )}
        {activeTab === 'clientes' && (
          <ClientsTab formatCurrency={formatCurrency} />
        )}
      </div>
    </div>
  )
}

// Dashboard Tab Component
function DashboardTab({ data, loading, formatCurrency }: {
  data: DashboardMetrics | null
  loading: boolean
  formatCurrency: (value: number) => string
}) {
  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500"></div>
      </div>
    )
  }

  if (!data) {
    return (
      <div className="text-center text-gray-500 py-8">
        Nenhum dado disponível
      </div>
    )
  }

  const metrics = [
    {
      title: 'Vendas Hoje',
      value: formatCurrency(data.totalSales || 0),
      subtitle: `${data.salesCount || 0} vendas`,
      change: 0, // TODO: Calculate growth
      icon: ShoppingCart,
      color: 'blue'
    },
    {
      title: 'Vendas do Mês',
      value: formatCurrency(data.totalSales || 0),
      subtitle: `${data.salesCount || 0} vendas`,
      change: 0, // TODO: Calculate growth
      icon: TrendingUp,
      color: 'green'
    },
    {
      title: 'Estoque Baixo',
      value: '0', // TODO: Implement low stock
      subtitle: 'produtos',
      icon: AlertTriangle,
      color: 'orange'
    },
    {
      title: 'Meta do Dia',
      value: formatCurrency(1000), // TODO: Get from settings
      subtitle: `${Math.round(((data.totalSales || 0) / 1000) * 100)}% atingido`,
      icon: TrendingUp,
      color: 'purple'
    }
  ]

  return (
    <div className="space-y-6">
      {/* Metrics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {metrics.map((metric, index) => (
          <div key={index} className="bg-white rounded-lg p-6 shadow-sm">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">{metric.title}</p>
                <p className="text-2xl font-bold text-gray-900">{metric.value}</p>
                <p className="text-sm text-gray-500 flex items-center">
                  {metric.change !== undefined && metric.change > 0 && (
                    <ArrowUp className="h-3 w-3 text-green-500 mr-1" />
                  )}
                  {metric.change !== undefined && metric.change < 0 && (
                    <ArrowDown className="h-3 w-3 text-red-500 mr-1" />
                  )}
                  {metric.subtitle}
                </p>
              </div>
              <div className={`p-3 rounded-full bg-${metric.color}-100`}>
                <metric.icon className={`h-6 w-6 text-${metric.color}-600`} />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg p-6 shadow-sm">
        <h3 className="text-lg font-semibold mb-4">Ações Rápidas</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="flex items-center space-x-3 p-4 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors">
            <BarChart3 className="h-5 w-5 text-blue-600" />
            <span className="text-blue-700 font-medium">Ver Relatório de Vendas</span>
          </button>
          <button className="flex items-center space-x-3 p-4 bg-green-50 rounded-lg hover:bg-green-100 transition-colors">
            <Download className="h-5 w-5 text-green-600" />
            <span className="text-green-700 font-medium">Exportar Dados</span>
          </button>
          <button className="flex items-center space-x-3 p-4 bg-purple-50 rounded-lg hover:bg-purple-100 transition-colors">
            <Users className="h-5 w-5 text-purple-600" />
            <span className="text-purple-700 font-medium">Análise de Clientes</span>
          </button>
        </div>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg p-6 shadow-sm">
          <h3 className="text-lg font-semibold mb-4">Vendas dos Últimos 7 Dias</h3>
          <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
            <span className="text-gray-500">Gráfico de vendas (a implementar)</span>
          </div>
        </div>
        <div className="bg-white rounded-lg p-6 shadow-sm">
          <h3 className="text-lg font-semibold mb-4">Formas de Pagamento</h3>
          <div className="h-64 bg-gray-50 rounded-lg flex items-center justify-center">
            <span className="text-gray-500">Gráfico de formas de pagamento (a implementar)</span>
          </div>
        </div>
      </div>
    </div>
  )
}