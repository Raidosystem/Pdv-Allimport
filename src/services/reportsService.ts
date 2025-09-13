import type { DashboardMetrics, ReportFilters } from '../types/reports'

export interface SaleItem {
  id: string
  product_name: string
  quantity: number
  unit_price: number
  total_price: number
  date: string
}

export interface Sale {
  id: string
  total: number
  payment_method: string
  created_at: string
  items: SaleItem[]
}

class ReportsService {
  async getDashboardMetrics(filters?: ReportFilters): Promise<DashboardMetrics> {
    try {
      // Buscar dados do backup
      const response = await fetch('/backup-allimport.json')
      const backupData = await response.json()
      
      const sales = backupData.data?.sales || []
      const serviceOrders = backupData.data?.service_orders || []
      const products = backupData.data?.products || []
      const clients = backupData.data?.clients || []

      // Calcular métricas
      const totalSales = sales.reduce((sum: number, sale: any) => sum + (sale.total || 0), 0)
      const totalServiceOrders = serviceOrders.length
      const totalProducts = products.length
      const totalClients = clients.length

      return {
        totalSales,
        salesCount: sales.length,
        serviceOrdersCount: totalServiceOrders,
        productsCount: totalProducts,
        clientsCount: totalClients,
        averageTicket: sales.length > 0 ? totalSales / sales.length : 0,
        period: {
          start: filters?.startDate || new Date().toISOString(),
          end: filters?.endDate || new Date().toISOString()
        }
      }
    } catch (error) {
      console.error('Erro ao buscar métricas:', error)
      return {
        totalSales: 0,
        salesCount: 0,
        serviceOrdersCount: 0,
        productsCount: 0,
        clientsCount: 0,
        averageTicket: 0,
        period: {
          start: new Date().toISOString(),
          end: new Date().toISOString()
        }
      }
    }
  }

  async getSalesData(filters?: ReportFilters): Promise<Sale[]> {
    // TODO: Implementar filtros quando necessário
    console.log('Filtros de vendas:', filters)
    try {
      const response = await fetch('/backup-allimport.json')
      const backupData = await response.json()
      
      return backupData.data?.sales || []
    } catch (error) {
      console.error('Erro ao buscar dados de vendas:', error)
      return []
    }
  }

  async exportReport(type: string, data: any): Promise<void> {
    try {
      const blob = new Blob([JSON.stringify(data, null, 2)], { 
        type: 'application/json' 
      })
      
      const url = URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url
      link.download = `relatorio-${type}-${new Date().toISOString().split('T')[0]}.json`
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Erro ao exportar relatório:', error)
      throw error
    }
  }
}

export const reportsService = new ReportsService()