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
import { SalesTabComponent } from '../components/reports/SalesTab'
import { FinancialTab } from '../components/reports/FinancialTab'
import { StockTab } from '../components/reports/StockTab'
import { ClientsTab } from '../components/reports/ClientsTab'
// import { NotificationPanel } from '../components/reports/NotificationPanel'
// import { GoalsManagerPanel } from '../components/reports/GoalsManagerPanel'
import type { DashboardMetrics, ReportFilters } from '../types/reports'
import { format } from 'date-fns'
import { ptBR } from 'date-fns/locale'
import toast from 'react-hot-toast'

export default function ReportsPage() {
  const navigate = useNavigate()
  const [activeTab, setActiveTab] = useState('dashboard')
  const [loading, setLoading] = useState(false)
  const [dashboardData, setDashboardData] = useState<DashboardMetrics | null>(null)
  // const [showNotifications, setShowNotifications] = useState(false)
  // const [showGoals, setShowGoals] = useState(false)
  const [filters, setFilters] = useState<ReportFilters>({
    data_inicio: format(new Date(), 'yyyy-MM-dd'),
    data_fim: format(new Date(), 'yyyy-MM-dd')
  })

  // Carrega métricas do dashboard
  useEffect(() => {
    loadDashboard()
  }, [])

  const loadDashboard = async () => {
    try {
      setLoading(true)
      const data = await reportsService.getDashboardMetrics()
      setDashboardData(data)
    } catch (error: any) {
      console.error('Erro ao carregar dashboard:', error)
      toast.error('Erro ao carregar dashboard: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value)
  }

  const tabs = [
    { id: 'dashboard', label: 'Dashboard', icon: BarChart3 },
    { id: 'vendas', label: 'Vendas', icon: ShoppingCart },
    { id: 'financeiro', label: 'Financeiro', icon: DollarSign },
    { id: 'estoque', label: 'Estoque', icon: Package },
    { id: 'clientes', label: 'Clientes', icon: Users }
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => navigate('/')}
                className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
              >
                <ArrowLeft className="h-5 w-5" />
              </button>
              <h1 className="text-2xl font-bold text-gray-900">
                Relatórios e Analytics
              </h1>
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
            </div>
          </div>

          {/* Tabs */}
          <div className="flex space-x-1 mt-6">
            {tabs.map((tab) => {
              const IconComponent = tab.icon
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center space-x-2 px-4 py-2 rounded-lg font-medium transition-colors ${
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

      {/* Content */}
      <div className="p-6">
        {activeTab === 'dashboard' && (
          <DashboardTab 
            data={dashboardData} 
            loading={loading} 
            formatCurrency={formatCurrency}
          />
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
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="bg-white p-6 rounded-xl shadow-sm animate-pulse">
            <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
            <div className="h-8 bg-gray-200 rounded w-1/2 mb-2"></div>
            <div className="h-4 bg-gray-200 rounded w-2/3"></div>
          </div>
        ))}
      </div>
    )
  }

  if (!data) return null

  const cards = [
    {
      title: 'Vendas Hoje',
      value: formatCurrency(data.vendas_hoje.valor),
      subtitle: `${data.vendas_hoje.quantidade} vendas`,
      change: data.vendas_hoje.crescimento,
      icon: ShoppingCart,
      color: 'blue'
    },
    {
      title: 'Vendas do Mês',
      value: formatCurrency(data.vendas_mes.valor),
      subtitle: `${data.vendas_mes.quantidade} vendas`,
      change: data.vendas_mes.crescimento,
      icon: TrendingUp,
      color: 'green'
    },
    {
      title: 'Estoque Baixo',
      value: data.produtos_estoque_baixo.toString(),
      subtitle: 'produtos',
      icon: AlertTriangle,
      color: 'orange'
    },
    {
      title: 'Meta do Dia',
      value: `${data.receita_vs_meta.percentual.toFixed(1)}%`,
      subtitle: `${formatCurrency(data.receita_vs_meta.atual)} / ${formatCurrency(data.receita_vs_meta.meta)}`,
      icon: DollarSign,
      color: 'purple'
    }
  ]

  return (
    <div className="space-y-6">
      {/* Cards principais */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {cards.map((card, index) => {
          const IconComponent = card.icon
          const isNegative = card.change && card.change < 0
          
          return (
            <div key={index} className="bg-white p-6 rounded-xl shadow-sm hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between mb-4">
                <div className={`p-3 rounded-lg bg-${card.color}-100`}>
                  <IconComponent className={`h-6 w-6 text-${card.color}-600`} />
                </div>
                {card.change !== undefined && (
                  <div className={`flex items-center space-x-1 ${isNegative ? 'text-red-600' : 'text-green-600'}`}>
                    {isNegative ? <ArrowDown className="h-4 w-4" /> : <ArrowUp className="h-4 w-4" />}
                    <span className="text-sm font-medium">
                      {Math.abs(card.change).toFixed(1)}%
                    </span>
                  </div>
                )}
              </div>
              
              <div>
                <h3 className="text-sm font-medium text-gray-600 mb-1">{card.title}</h3>
                <p className="text-2xl font-bold text-gray-900 mb-1">{card.value}</p>
                <p className="text-sm text-gray-500">{card.subtitle}</p>
              </div>
            </div>
          )
        })}
      </div>

      {/* Gráfico de vendas dos últimos 7 dias */}
      {data.vendas_ultimos_7_dias.length > 0 && (
        <div className="bg-white p-6 rounded-xl shadow-sm">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Vendas dos Últimos 7 Dias
          </h3>
          <div className="h-64 flex items-end justify-between space-x-2">
            {data.vendas_ultimos_7_dias.map((item, index) => {
              const maxValue = Math.max(...data.vendas_ultimos_7_dias.map(v => v.valor))
              const height = maxValue > 0 ? (item.valor / maxValue) * 100 : 0
              
              return (
                <div key={index} className="flex-1 flex flex-col items-center">
                  <div 
                    className="w-full bg-blue-500 rounded-t transition-all duration-300 hover:bg-blue-600"
                    style={{ height: `${height}%` }}
                    title={`${formatCurrency(item.valor)} em ${format(new Date(item.data), 'dd/MM', { locale: ptBR })}`}
                  />
                  <div className="text-xs text-gray-500 mt-2">
                    {format(new Date(item.data), 'dd/MM', { locale: ptBR })}
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* Notification System */}
      {/* {showNotifications && (
        <NotificationPanel
          isOpen={showNotifications}
          onClose={() => setShowNotifications(false)}
        />
      )} */}

      {/* Goals Manager */}
      {/* {showGoals && (
        <GoalsManagerPanel
          isOpen={showGoals}
          onClose={() => setShowGoals(false)}
        />
      )} */}
    </div>
  )
}

// Placeholder components for other tabs
