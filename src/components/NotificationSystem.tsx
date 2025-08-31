import { useState, useEffect } from 'react'
import { Bell, X, AlertTriangle, TrendingDown, Users } from 'lucide-react'
import { reportsService } from '../services/reportsService'
import toast from 'react-hot-toast'

interface Alert {
  id: string
  type: 'warning' | 'danger' | 'info' | 'success'
  title: string
  message: string
  action?: () => void
  actionLabel?: string
  timestamp: Date
}

interface NotificationSystemProps {
  showNotifications?: boolean
  onToggle?: () => void
}

export function NotificationSystem({ showNotifications = false, onToggle }: NotificationSystemProps) {
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    loadAlerts()
    
    // Verificar alertas a cada 5 minutos
    const interval = setInterval(loadAlerts, 5 * 60 * 1000)
    
    return () => clearInterval(interval)
  }, [])

  const loadAlerts = async () => {
    try {
      setLoading(true)
      const newAlerts: Alert[] = []

      // Verificar estoque baixo
      const stockData = await reportsService.getStockReport()
      if (stockData.produtos_estoque_baixo.length > 0) {
        newAlerts.push({
          id: 'stock-low',
          type: 'warning',
          title: 'Estoque Baixo',
          message: `${stockData.produtos_estoque_baixo.length} produto(s) com estoque baixo`,
          action: () => window.location.href = '/relatorios?tab=estoque',
          actionLabel: 'Ver Produtos',
          timestamp: new Date()
        })
      }

      // Verificar produtos sem estoque
      const semEstoque = stockData.produtos_estoque_baixo.filter(p => p.estoque_atual === 0)
      if (semEstoque.length > 0) {
        newAlerts.push({
          id: 'stock-zero',
          type: 'danger',
          title: 'Produtos Sem Estoque',
          message: `${semEstoque.length} produto(s) sem estoque`,
          action: () => window.location.href = '/relatorios?tab=estoque',
          actionLabel: 'Ver Produtos',
          timestamp: new Date()
        })
      }

      // Verificar meta de vendas diária (exemplo)
      const dashboardData = await reportsService.getDashboardMetrics()
      if (dashboardData.receita_vs_meta.percentual < 50 && new Date().getHours() > 16) {
        newAlerts.push({
          id: 'sales-goal',
          type: 'warning',
          title: 'Meta de Vendas',
          message: `Apenas ${dashboardData.receita_vs_meta.percentual.toFixed(1)}% da meta diária alcançada`,
          action: () => window.location.href = '/relatorios?tab=vendas',
          actionLabel: 'Ver Vendas',
          timestamp: new Date()
        })
      }

      // Verificar clientes inativos
      const clientsData = await reportsService.getClientsReport()
      const clientesInativos = clientsData.clientes.filter(c => {
        if (!c.ultima_compra) return false
        const diasSemComprar = Math.floor((Date.now() - new Date(c.ultima_compra).getTime()) / (1000 * 60 * 60 * 24))
        return diasSemComprar > 90 && c.total_compras > 0
      })

      if (clientesInativos.length > 5) {
        newAlerts.push({
          id: 'inactive-clients',
          type: 'info',
          title: 'Clientes Inativos',
          message: `${clientesInativos.length} clientes há mais de 90 dias sem comprar`,
          action: () => window.location.href = '/relatorios?tab=clientes',
          actionLabel: 'Ver Clientes',
          timestamp: new Date()
        })
      }

      setAlerts(newAlerts)

      // Mostrar toast para alertas críticos
      const criticalAlerts = newAlerts.filter(a => a.type === 'danger')
      criticalAlerts.forEach(alert => {
        toast.error(`${alert.title}: ${alert.message}`)
      })

    } catch (error) {
      console.error('Erro ao carregar alertas:', error)
    } finally {
      setLoading(false)
    }
  }

  const removeAlert = (alertId: string) => {
    setAlerts(alerts.filter(a => a.id !== alertId))
  }

  const getAlertIcon = (type: Alert['type']) => {
    switch (type) {
      case 'warning':
        return <AlertTriangle className="h-5 w-5 text-yellow-500" />
      case 'danger':
        return <AlertTriangle className="h-5 w-5 text-red-500" />
      case 'info':
        return <Users className="h-5 w-5 text-blue-500" />
      case 'success':
        return <TrendingDown className="h-5 w-5 text-green-500" />
      default:
        return <Bell className="h-5 w-5 text-gray-500" />
    }
  }

  const getAlertBgColor = (type: Alert['type']) => {
    switch (type) {
      case 'warning':
        return 'bg-yellow-50 border-yellow-200'
      case 'danger':
        return 'bg-red-50 border-red-200'
      case 'info':
        return 'bg-blue-50 border-blue-200'
      case 'success':
        return 'bg-green-50 border-green-200'
      default:
        return 'bg-gray-50 border-gray-200'
    }
  }

  return (
    <>
      {/* Botão de notificações */}
      <div className="relative">
        <button
          onClick={onToggle}
          className="relative p-2 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <Bell className="h-6 w-6" />
          {alerts.length > 0 && (
            <span className="absolute top-0 right-0 block h-2 w-2 rounded-full ring-2 ring-white bg-red-400"></span>
          )}
        </button>

        {/* Badge com contador */}
        {alerts.length > 0 && (
          <span className="absolute -top-1 -right-1 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-red-100 bg-red-600 rounded-full">
            {alerts.length}
          </span>
        )}
      </div>

      {/* Painel de notificações */}
      {showNotifications && (
        <div className="fixed inset-0 z-50 overflow-hidden" aria-labelledby="slide-over-title" role="dialog" aria-modal="true">
          <div className="absolute inset-0 overflow-hidden">
            {/* Overlay */}
            <div className="absolute inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onClick={onToggle}></div>

            <div className="fixed inset-y-0 right-0 pl-10 max-w-full flex">
              <div className="w-screen max-w-md">
                <div className="h-full flex flex-col bg-white shadow-xl overflow-y-scroll">
                  {/* Header */}
                  <div className="px-4 py-6 bg-gray-50 sm:px-6">
                    <div className="flex items-center justify-between">
                      <h2 className="text-lg font-medium text-gray-900">Notificações e Alertas</h2>
                      <button
                        onClick={onToggle}
                        className="rounded-md bg-gray-50 text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      >
                        <X className="h-6 w-6" />
                      </button>
                    </div>
                    <div className="mt-1">
                      <p className="text-sm text-gray-500">
                        {alerts.length === 0 ? 'Nenhum alerta no momento' : `${alerts.length} alerta(s) ativo(s)`}
                      </p>
                    </div>
                  </div>

                  {/* Conteúdo */}
                  <div className="flex-1 px-4 py-6 sm:px-6">
                    {loading ? (
                      <div className="text-center">
                        <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                        <p className="mt-2 text-sm text-gray-500">Carregando alertas...</p>
                      </div>
                    ) : alerts.length === 0 ? (
                      <div className="text-center">
                        <Bell className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                        <p className="text-sm text-gray-500">Tudo certo! Nenhum alerta no momento.</p>
                      </div>
                    ) : (
                      <div className="space-y-4">
                        {alerts.map((alert) => (
                          <div
                            key={alert.id}
                            className={`rounded-lg border p-4 ${getAlertBgColor(alert.type)}`}
                          >
                            <div className="flex items-start">
                              <div className="flex-shrink-0">
                                {getAlertIcon(alert.type)}
                              </div>
                              <div className="ml-3 flex-1">
                                <h3 className="text-sm font-medium text-gray-900">
                                  {alert.title}
                                </h3>
                                <div className="mt-1 text-sm text-gray-700">
                                  {alert.message}
                                </div>
                                {alert.action && alert.actionLabel && (
                                  <div className="mt-3">
                                    <button
                                      onClick={alert.action}
                                      className="inline-flex items-center px-3 py-1 border border-transparent text-xs font-medium rounded text-blue-700 bg-blue-100 hover:bg-blue-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                                    >
                                      {alert.actionLabel}
                                    </button>
                                  </div>
                                )}
                                <div className="mt-2 text-xs text-gray-500">
                                  {alert.timestamp.toLocaleTimeString('pt-BR', { 
                                    hour: '2-digit', 
                                    minute: '2-digit' 
                                  })}
                                </div>
                              </div>
                              <div className="ml-3 flex-shrink-0">
                                <button
                                  onClick={() => removeAlert(alert.id)}
                                  className="inline-flex text-gray-400 hover:text-gray-500 focus:outline-none"
                                >
                                  <X className="h-4 w-4" />
                                </button>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Footer */}
                  <div className="border-t border-gray-200 px-4 py-4 sm:px-6">
                    <button
                      onClick={loadAlerts}
                      disabled={loading}
                      className="w-full inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-blue-700 bg-blue-100 hover:bg-blue-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
                    >
                      {loading ? 'Atualizando...' : 'Atualizar Alertas'}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  )
}
