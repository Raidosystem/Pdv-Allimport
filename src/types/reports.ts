export interface DashboardMetrics {
  totalSales: number
  salesCount: number
  serviceOrdersCount: number
  productsCount: number
  clientsCount: number
  averageTicket: number
  period: {
    start: string
    end: string
  }
}

export interface ReportFilters {
  startDate?: string
  endDate?: string
  clientId?: string
  productId?: string
  category?: string
  paymentMethod?: string
}

export interface SalesReportData {
  period: string
  sales: number
  count: number
  averageTicket: number
}

export interface ProductReportData {
  id: string
  name: string
  category: string
  stock: number
  sold: number
  revenue: number
}

export interface ClientReportData {
  id: string
  name: string
  totalPurchases: number
  totalSpent: number
  lastPurchase: string
}

export interface FinancialReportData {
  revenue: number
  expenses: number
  profit: number
  period: string
}

export type ReportType = 'sales' | 'products' | 'clients' | 'financial' | 'stock'