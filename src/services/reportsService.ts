import { supabase } from '../lib/supabase'
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

// ✅ NOVOS TIPOS PARA RELATÓRIOS DETALHADOS
export interface PaymentMethodReport {
  method: string
  count: number
  total: number
  percentage: number
}

export interface ClientReport {
  total_cadastrados: number
  novos_hoje: number
  novos_semana: number
  novos_mes: number
  mais_ativos: Array<{
    id: string
    name: string
    total_compras: number
    valor_total: number
  }>
}

export interface SalesMovementReport {
  vendas_hoje: number
  vendas_semana: number
  vendas_mes: number
  valor_hoje: number
  valor_semana: number
  valor_mes: number
  ticket_medio: number
  metodos_pagamento: PaymentMethodReport[]
}

export interface CashMovementReport {
  entradas_hoje: number
  saidas_hoje: number
  saldo_atual: number
  movimentacoes: Array<{
    tipo: string
    valor: number
    descricao: string
    data: string
  }>
}

export interface ServiceOrderReport {
  total_os: number
  abertas: number
  em_andamento: number
  finalizadas: number
  receita_servicos: number
}

class ReportsService {
  async getDashboardMetrics(filters?: ReportFilters): Promise<DashboardMetrics> {
    try {
      // ✅ NOVA IMPLEMENTAÇÃO: Usar dados do Supabase em tempo real
      const startDate = filters?.startDate || new Date().toISOString().split('T')[0]
      const endDate = filters?.endDate || new Date().toISOString().split('T')[0]
      
      // Buscar vendas
      const { data: sales } = await supabase
        .from('vendas')
        .select('*')
        .gte('created_at', startDate)
        .lte('created_at', endDate + 'T23:59:59')
      
      // Buscar ordens de serviço
      const { data: serviceOrders } = await supabase
        .from('ordens_servico')
        .select('*')
        .gte('criado_em', startDate)
        .lte('criado_em', endDate + 'T23:59:59')
      
      // Buscar produtos
      const { data: products } = await supabase
        .from('produtos')
        .select('*')
      
      // Buscar clientes
      const { data: clients } = await supabase
        .from('clientes')
        .select('*')

      // Calcular métricas
      const totalSales = sales?.reduce((sum, sale) => sum + (sale.total || 0), 0) || 0
      const totalServiceOrders = serviceOrders?.length || 0
      const totalProducts = products?.length || 0
      const totalClients = clients?.length || 0

      return {
        totalSales,
        salesCount: sales?.length || 0,
        serviceOrdersCount: totalServiceOrders,
        productsCount: totalProducts,
        clientsCount: totalClients,
        averageTicket: sales?.length ? totalSales / sales.length : 0,
        period: {
          start: startDate,
          end: endDate
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

  // ✅ NOVO MÉTODO: Relatório completo de movimentação financeira
  async getFinancialMovementReport(period: 'hoje' | 'semana' | 'mes' = 'hoje'): Promise<SalesMovementReport> {
    try {
      const now = new Date()
      let startDate: Date
      
      switch (period) {
        case 'hoje':
          startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
          break
        case 'semana':
          startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
          break
        case 'mes':
          startDate = new Date(now.getFullYear(), now.getMonth(), 1)
          break
      }
      
      // Buscar vendas do período
      const { data: sales } = await supabase
        .from('vendas')
        .select('total, metodo_pagamento, created_at')
        .gte('created_at', startDate.toISOString())
        .lte('created_at', now.toISOString())
      
      // Calcular estatísticas por período
      const hoje = new Date().toISOString().split('T')[0]
      const semanaAtras = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()
      const mesAtras = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()
      
      const vendas_hoje = sales?.filter(s => s.created_at.startsWith(hoje)).length || 0
      const vendas_semana = sales?.filter(s => s.created_at >= semanaAtras).length || 0
      const vendas_mes = sales?.filter(s => s.created_at >= mesAtras).length || 0
      
      const valor_hoje = sales?.filter(s => s.created_at.startsWith(hoje))
        .reduce((sum, s) => sum + s.total, 0) || 0
      const valor_semana = sales?.filter(s => s.created_at >= semanaAtras)
        .reduce((sum, s) => sum + s.total, 0) || 0
      const valor_mes = sales?.filter(s => s.created_at >= mesAtras)
        .reduce((sum, s) => sum + s.total, 0) || 0
      
      // Agrupar por método de pagamento
      const methodStats = new Map<string, { count: number; total: number }>()
      sales?.forEach(sale => {
        const method = sale.metodo_pagamento || 'Dinheiro'
        const current = methodStats.get(method) || { count: 0, total: 0 }
        methodStats.set(method, {
          count: current.count + 1,
          total: current.total + sale.total
        })
      })
      
      const totalVendas = sales?.length || 0
      const totalValor = sales?.reduce((sum, s) => sum + s.total, 0) || 0
      
      const metodos_pagamento: PaymentMethodReport[] = Array.from(methodStats.entries())
        .map(([method, stats]) => ({
          method,
          count: stats.count,
          total: stats.total,
          percentage: totalVendas > 0 ? (stats.count / totalVendas) * 100 : 0
        }))
      
      return {
        vendas_hoje,
        vendas_semana,
        vendas_mes,
        valor_hoje,
        valor_semana,
        valor_mes,
        ticket_medio: totalVendas > 0 ? totalValor / totalVendas : 0,
        metodos_pagamento
      }
      
    } catch (error) {
      console.error('Erro ao gerar relatório financeiro:', error)
      return {
        vendas_hoje: 0,
        vendas_semana: 0,
        vendas_mes: 0,
        valor_hoje: 0,
        valor_semana: 0,
        valor_mes: 0,
        ticket_medio: 0,
        metodos_pagamento: []
      }
    }
  }

  // ✅ NOVO MÉTODO: Relatório de clientes
  async getClientReport(): Promise<ClientReport> {
    try {
      const hoje = new Date().toISOString().split('T')[0]
      const semanaAtras = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()
      const mesAtras = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()
      
      // Buscar todos os clientes
      const { data: clients } = await supabase
        .from('clientes')
        .select('id, nome, criado_em')
      
      // Contar clientes por período
      const total_cadastrados = clients?.length || 0
      const novos_hoje = clients?.filter(c => c.criado_em?.startsWith(hoje)).length || 0
      const novos_semana = clients?.filter(c => c.criado_em >= semanaAtras).length || 0
      const novos_mes = clients?.filter(c => c.criado_em >= mesAtras).length || 0
      
      // Buscar clientes mais ativos (com mais compras)
      const { data: clientSales } = await supabase
        .from('vendas')
        .select('cliente_id, total')
        .not('cliente_id', 'is', null)
      
      const clientStats = new Map<string, { total_compras: number; valor_total: number }>()
      
      clientSales?.forEach(sale => {
        if (sale.cliente_id) {
          const current = clientStats.get(sale.cliente_id) || { total_compras: 0, valor_total: 0 }
          clientStats.set(sale.cliente_id, {
            total_compras: current.total_compras + 1,
            valor_total: current.valor_total + sale.total
          })
        }
      })
      
      // Buscar nomes dos clientes mais ativos
      const mais_ativos = await Promise.all(
        Array.from(clientStats.entries())
          .sort(([,a], [,b]) => b.total_compras - a.total_compras)
          .slice(0, 5)
          .map(async ([clientId, stats]) => {
            const client = clients?.find(c => c.id === clientId)
            return {
              id: clientId,
              name: client?.nome || 'Cliente não encontrado',
              total_compras: stats.total_compras,
              valor_total: stats.valor_total
            }
          })
      )
      
      return {
        total_cadastrados,
        novos_hoje,
        novos_semana,
        novos_mes,
        mais_ativos
      }
      
    } catch (error) {
      console.error('Erro ao gerar relatório de clientes:', error)
      return {
        total_cadastrados: 0,
        novos_hoje: 0,
        novos_semana: 0,
        novos_mes: 0,
        mais_ativos: []
      }
    }
  }

  // ✅ NOVO MÉTODO: Relatório de movimentação de caixa
  async getCashMovementReport(): Promise<CashMovementReport> {
    try {
      const hoje = new Date().toISOString().split('T')[0]
      
      // Buscar movimentações de hoje
      const { data: movements } = await supabase
        .from('movimentacoes_caixa')
        .select('tipo, valor, descricao, data')
        .gte('data', hoje)
        .lte('data', hoje + 'T23:59:59')
        .order('data', { ascending: false })
      
      // Buscar caixa atual
      const { data: currentCash } = await supabase
        .from('caixa')
        .select('valor_atual')
        .eq('status', 'aberto')
        .single()
      
      const entradas_hoje = movements?.filter(m => m.tipo === 'entrada')
        .reduce((sum, m) => sum + m.valor, 0) || 0
      
      const saidas_hoje = movements?.filter(m => m.tipo === 'saida')
        .reduce((sum, m) => sum + m.valor, 0) || 0
      
      return {
        entradas_hoje,
        saidas_hoje,
        saldo_atual: currentCash?.valor_atual || 0,
        movimentacoes: movements?.map(m => ({
          tipo: m.tipo,
          valor: m.valor,
          descricao: m.descricao,
          data: m.data
        })) || []
      }
      
    } catch (error) {
      console.error('Erro ao gerar relatório de caixa:', error)
      return {
        entradas_hoje: 0,
        saidas_hoje: 0,
        saldo_atual: 0,
        movimentacoes: []
      }
    }
  }

  // ✅ NOVO MÉTODO: Relatório de ordens de serviço
  async getServiceOrderReport(): Promise<ServiceOrderReport> {
    try {
      // Buscar todas as ordens de serviço
      const { data: orders } = await supabase
        .from('ordens_servico')
        .select('status, valor_final')
      
      const total_os = orders?.length || 0
      const abertas = orders?.filter(o => o.status === 'Em análise' || o.status === 'Aberta').length || 0
      const em_andamento = orders?.filter(o => o.status === 'Em andamento').length || 0
      const finalizadas = orders?.filter(o => o.status === 'Pronto' || o.status === 'Entregue').length || 0
      
      const receita_servicos = orders?.filter(o => o.valor_final)
        .reduce((sum, o) => sum + (o.valor_final || 0), 0) || 0
      
      return {
        total_os,
        abertas,
        em_andamento,
        finalizadas,
        receita_servicos
      }
      
    } catch (error) {
      console.error('Erro ao gerar relatório de OS:', error)
      return {
        total_os: 0,
        abertas: 0,
        em_andamento: 0,
        finalizadas: 0,
        receita_servicos: 0
      }
    }
  }

  async getSalesData(filters?: ReportFilters): Promise<Sale[]> {
    try {
      console.log('Filtros de vendas:', filters)
      
      // ✅ NOVA IMPLEMENTAÇÃO: Buscar dados reais do Supabase
      let query = supabase
        .from('vendas')
        .select(`
          id,
          total,
          metodo_pagamento,
          created_at,
          vendas_itens (
            id,
            quantidade,
            preco_unitario,
            subtotal,
            produtos (
              nome
            )
          )
        `)
      
      // Aplicar filtros se fornecidos
      if (filters?.startDate) {
        query = query.gte('created_at', filters.startDate)
      }
      if (filters?.endDate) {
        query = query.lte('created_at', filters.endDate + 'T23:59:59')
      }
      if (filters?.clientId) {
        query = query.eq('cliente_id', filters.clientId)
      }
      if (filters?.paymentMethod) {
        query = query.eq('metodo_pagamento', filters.paymentMethod)
      }
      
      const { data: sales, error } = await query.order('created_at', { ascending: false })
      
      if (error) throw error
      
      // Adaptar dados para formato esperado
      return sales?.map(sale => ({
        id: sale.id,
        total: sale.total,
        payment_method: sale.metodo_pagamento,
        created_at: sale.created_at,
        items: (sale.vendas_itens || []).map((item: any) => ({
          id: item.id,
          product_name: item.produtos?.nome || 'Produto não encontrado',
          quantity: item.quantidade,
          unit_price: item.preco_unitario,
          total_price: item.subtotal,
          date: sale.created_at
        }))
      })) || []
      
    } catch (error) {
      console.error('Erro ao buscar dados de vendas:', error)
      return []
    }
  }

  // ✅ NOVO MÉTODO: Relatório consolidado completo
  async getCompleteReport() {
    try {
      const [
        dashboardMetrics,
        financialReport,
        clientReport,
        cashReport,
        serviceOrderReport
      ] = await Promise.all([
        this.getDashboardMetrics(),
        this.getFinancialMovementReport('mes'),
        this.getClientReport(),
        this.getCashMovementReport(),
        this.getServiceOrderReport()
      ])
      
      return {
        dashboard: dashboardMetrics,
        financial: financialReport,
        clients: clientReport,
        cash: cashReport,
        serviceOrders: serviceOrderReport,
        generatedAt: new Date().toISOString()
      }
    } catch (error) {
      console.error('Erro ao gerar relatório completo:', error)
      throw error
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