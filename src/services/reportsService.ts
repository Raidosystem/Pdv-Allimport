import { supabase } from '../lib/supabase'
import type { 
  Sale, 
  FinancialMovement, 
  ReportFilters, 
  SalesReport, 
  FinancialReport, 
  StockReport, 
  ClientsReport, 
  DashboardMetrics 
} from '../types/reports'

export class ReportsService {
  
  // Obter usuário atual
  private async getCurrentUser(): Promise<string> {
    const { data: { user }, error } = await supabase.auth.getUser()
    if (error || !user) {
      throw new Error('Usuário não autenticado')
    }
    return user.id
  }

  // Relatório de Vendas
  async getSalesReport(filters: ReportFilters): Promise<SalesReport> {
    const userId = await this.getCurrentUser()
    
    // Buscar vendas com filtros
    let query = supabase
      .from('sales')
      .select(`
        *,
        cliente:clientes(id, nome, email, telefone),
        itens:sale_items(id, produto_nome, quantidade, preco_unitario, subtotal)
      `)
      .eq('user_id', userId)
      .gte('data_venda', filters.data_inicio)
      .lte('data_venda', filters.data_fim + ' 23:59:59')
      .order('data_venda', { ascending: false })

    if (filters.cliente_id) {
      query = query.eq('cliente_id', filters.cliente_id)
    }

    if (filters.vendedor) {
      query = query.eq('vendedor', filters.vendedor)
    }

    if (filters.forma_pagamento) {
      query = query.eq('forma_pagamento', filters.forma_pagamento)
    }

    const { data: vendas, error } = await query

    if (error) throw error

    // Calcular resumos
    const total_vendas = vendas?.length || 0
    const total_valor = vendas?.reduce((acc, v) => acc + v.total, 0) || 0
    const total_desconto = vendas?.reduce((acc, v) => acc + (v.desconto || 0), 0) || 0
    const ticket_medio = total_vendas > 0 ? total_valor / total_vendas : 0

    // Vendas por dia
    const vendas_por_dia = this.groupSalesByDay(vendas || [])
    
    // Formas de pagamento
    const formas_pagamento = this.groupSalesByPayment(vendas || [])
    
    // Top clientes
    const top_clientes = this.getTopClients(vendas || [])
    
    // Top produtos
    const top_produtos = this.getTopProducts(vendas || [])

    return {
      vendas: vendas || [],
      resumo: {
        total_vendas,
        total_valor,
        total_desconto,
        ticket_medio,
        vendas_por_dia,
        formas_pagamento,
        top_clientes,
        top_produtos
      }
    }
  }

  // Relatório Financeiro
  async getFinancialReport(filters: ReportFilters): Promise<FinancialReport> {
    const userId = await this.getCurrentUser()
    
    let query = supabase
      .from('financial_movements')
      .select('*')
      .eq('user_id', userId)
      .gte('data_movimento', filters.data_inicio)
      .lte('data_movimento', filters.data_fim)
      .order('data_movimento', { ascending: false })

    if (filters.tipo && filters.tipo !== 'todas') {
      query = query.eq('tipo', filters.tipo)
    }

    if (filters.categoria) {
      query = query.eq('categoria', filters.categoria)
    }

    const { data: movimentacoes, error } = await query

    if (error) throw error

    const total_entradas = movimentacoes?.filter(m => m.tipo === 'entrada').reduce((acc, m) => acc + m.valor, 0) || 0
    const total_saidas = movimentacoes?.filter(m => m.tipo === 'saida').reduce((acc, m) => acc + m.valor, 0) || 0
    const saldo = total_entradas - total_saidas

    const entradas_por_categoria = this.groupMovementsByCategory(movimentacoes?.filter(m => m.tipo === 'entrada') || [])
    const saidas_por_categoria = this.groupMovementsByCategory(movimentacoes?.filter(m => m.tipo === 'saida') || [])
    const movimentacoes_por_dia = this.groupMovementsByDay(movimentacoes || [])

    return {
      movimentacoes: movimentacoes || [],
      resumo: {
        total_entradas,
        total_saidas,
        saldo,
        entradas_por_categoria,
        saidas_por_categoria,
        movimentacoes_por_dia
      }
    }
  }

  // Relatório de Estoque
  async getStockReport(): Promise<StockReport> {
    const userId = await this.getCurrentUser()
    
    // Produtos com estoque baixo
    const { data: produtos_estoque_baixo } = await supabase
      .from('produtos')
      .select('id, nome, estoque, estoque_minimo, preco')
      .eq('user_id', userId)
      .filter('estoque', 'lte', 'estoque_minimo')
      .eq('ativo', true)

    // Valor total do estoque
    const { data: todos_produtos } = await supabase
      .from('produtos')
      .select('estoque, preco')
      .eq('user_id', userId)
      .eq('ativo', true)

    const valor_total_estoque = todos_produtos?.reduce((acc, p) => acc + (p.estoque * p.preco), 0) || 0

    // Produtos mais vendidos (últimos 30 dias)
    const dataLimite = new Date()
    dataLimite.setDate(dataLimite.getDate() - 30)

    const { data: produtos_mais_vendidos } = await supabase
      .from('sale_items')
      .select(`
        produto_nome,
        quantidade,
        preco_unitario,
        sale_id,
        sales!inner(data_venda)
      `)
      .eq('user_id', userId)
      .gte('sales.data_venda', dataLimite.toISOString())

    const produtos_vendidos_agrupados = this.groupProductSales(produtos_mais_vendidos || [])

    return {
      produtos_estoque_baixo: produtos_estoque_baixo?.map(p => ({
        id: p.id,
        nome: p.nome,
        estoque_atual: p.estoque,
        estoque_minimo: p.estoque_minimo || 0,
        valor_investido: p.estoque * p.preco
      })) || [],
      valor_total_estoque,
      produtos_sem_movimento: [], // TODO: Implementar lógica para produtos sem movimento
      produtos_mais_vendidos: produtos_vendidos_agrupados.map(p => ({
        produto: p.produto,
        quantidade_vendida: p.quantidade,
        valor_total: p.valor
      }))
    }
  }

  // Relatório de Clientes
  async getClientsReport(): Promise<ClientsReport> {
    const userId = await this.getCurrentUser()
    
    // Buscar todos os clientes do usuário
    const { data: clientes_data, error: clientes_error } = await supabase
      .from('clientes')
      .select('id, nome, email, telefone, created_at')
      .eq('user_id', userId)
      .order('nome', { ascending: true })

    if (clientes_error) throw clientes_error

    // Buscar todas as vendas com cliente_id
    const { data: vendas_data, error: vendas_error } = await supabase
      .from('sales')
      .select('cliente_id, total, data_venda')
      .eq('user_id', userId)
      .not('cliente_id', 'is', null)

    if (vendas_error) throw vendas_error

    // Processar dados dos clientes com suas vendas
    const clientes = clientes_data?.map(cliente => {
      const vendas_cliente = vendas_data?.filter(v => v.cliente_id === cliente.id) || []
      const total_compras = vendas_cliente.length
      const valor_total = vendas_cliente.reduce((acc, v) => acc + v.total, 0)
      const ultima_compra = vendas_cliente.length > 0 ? 
        new Date(Math.max(...vendas_cliente.map(v => new Date(v.data_venda).getTime()))).toISOString() : 
        ''
      const ticket_medio = total_compras > 0 ? valor_total / total_compras : 0

      return {
        id: cliente.id,
        nome: cliente.nome,
        email: cliente.email || '',
        telefone: cliente.telefone || '',
        total_compras,
        valor_total,
        ultima_compra,
        ticket_medio
      }
    }) || []

    const total_clientes = clientes.length
    const clientes_ativos = clientes.filter(c => c.total_compras > 0).length
    const clientes_inativos = total_clientes - clientes_ativos
    const clientes_com_compras = clientes.filter(c => c.total_compras > 0)
    const ticket_medio_geral = clientes_com_compras.length > 0 ? 
      clientes_com_compras.reduce((acc, c) => acc + c.valor_total, 0) / clientes_com_compras.length : 0

    return {
      clientes,
      resumo: {
        total_clientes,
        clientes_ativos,
        clientes_inativos,
        ticket_medio_geral
      }
    }
  }

  // Dashboard com métricas principais
  async getDashboardMetrics(): Promise<DashboardMetrics> {
    const userId = await this.getCurrentUser()
    const hoje = new Date().toISOString().split('T')[0]
    const ontem = new Date(Date.now() - 86400000).toISOString().split('T')[0]
    const mes_atual = new Date().toISOString().slice(0, 7) // YYYY-MM
    
    // Vendas hoje
    const { data: vendas_hoje } = await supabase
      .from('sales')
      .select('total')
      .eq('user_id', userId)
      .gte('data_venda', hoje)
      .lte('data_venda', hoje + ' 23:59:59')

    const { data: vendas_ontem } = await supabase
      .from('sales')
      .select('total')
      .eq('user_id', userId)
      .gte('data_venda', ontem)
      .lte('data_venda', ontem + ' 23:59:59')

    // Vendas do mês atual
    const { data: vendas_mes } = await supabase
      .from('sales')
      .select('total')
      .eq('user_id', userId)
      .gte('data_venda', mes_atual + '-01')
      .lte('data_venda', mes_atual + '-31')

    const valor_hoje = vendas_hoje?.reduce((acc, v) => acc + v.total, 0) || 0
    const valor_ontem = vendas_ontem?.reduce((acc, v) => acc + v.total, 0) || 0
    const valor_mes = vendas_mes?.reduce((acc, v) => acc + v.total, 0) || 0
    const crescimento_hoje = valor_ontem > 0 ? ((valor_hoje - valor_ontem) / valor_ontem) * 100 : 0

    // Clientes ativos (com pelo menos uma compra nos últimos 90 dias)
    const noventa_dias_atras = new Date(Date.now() - 90 * 86400000).toISOString().split('T')[0]
    const { data: clientes_com_vendas } = await supabase
      .from('sales')
      .select('cliente_id')
      .eq('user_id', userId)
      .gte('data_venda', noventa_dias_atras)
      .not('cliente_id', 'is', null)

    const clientes_ativos_set = new Set(clientes_com_vendas?.map(v => v.cliente_id) || [])
    const clientes_ativos = clientes_ativos_set.size

    // Produtos com estoque baixo
    const { count: produtos_estoque_baixo } = await supabase
      .from('produtos')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .filter('estoque', 'lte', 'estoque_minimo')
      .eq('ativo', true)

    // Top produtos (mais vendidos nos últimos 30 dias)
    const trinta_dias_atras = new Date(Date.now() - 30 * 86400000).toISOString().split('T')[0]
    const { data: top_produtos_data } = await supabase
      .from('sale_items')
      .select(`
        produto_nome,
        quantidade,
        sales!inner(user_id, data_venda)
      `)
      .eq('sales.user_id', userId)
      .gte('sales.data_venda', trinta_dias_atras)

    // Agrupar produtos por nome e somar quantidades
    const produtos_agrupados = (top_produtos_data || []).reduce((acc: any, item: any) => {
      const nome = item.produto_nome
      if (!acc[nome]) {
        acc[nome] = { nome, quantidade: 0, valor: 0 }
      }
      acc[nome].quantidade += item.quantidade
      return acc
    }, {})

    const top_produtos = Object.values(produtos_agrupados)
      .sort((a: any, b: any) => b.quantidade - a.quantidade)
      .slice(0, 5) as { nome: string; quantidade: number; valor: number }[]

    // Vendas últimos 7 dias
    const sete_dias_atras = new Date(Date.now() - 7 * 86400000).toISOString().split('T')[0]
    const { data: vendas_7_dias } = await supabase
      .from('sales')
      .select('data_venda, total')
      .eq('user_id', userId)
      .gte('data_venda', sete_dias_atras)
      .order('data_venda', { ascending: true })

    const vendas_ultimos_7_dias = vendas_7_dias?.map(v => ({
      data: v.data_venda.split('T')[0],
      valor: v.total,
      quantidade: 1
    })) || []

    return {
      vendas_hoje: {
        quantidade: vendas_hoje?.length || 0,
        valor: valor_hoje,
        crescimento: crescimento_hoje
      },
      vendas_mes: {
        quantidade: vendas_mes?.length || 0,
        valor: valor_mes,
        crescimento: 0 // TODO: Comparar com mês anterior
      },
      produtos_estoque_baixo: produtos_estoque_baixo || 0,
      clientes_ativos,
      receita_vs_meta: {
        atual: valor_mes,
        meta: 10000, // TODO: Tornar configurável
        percentual: (valor_mes / 10000) * 100
      },
      top_produtos,
      vendas_ultimos_7_dias
    }
  }

  // Métodos auxiliares
  private groupSalesByDay(vendas: Sale[]): { data: string; valor: number; quantidade: number }[] {
    const grupos = vendas.reduce((acc, venda) => {
      const data = venda.data_venda.split('T')[0]
      if (!acc[data]) {
        acc[data] = { valor: 0, quantidade: 0 }
      }
      acc[data].valor += venda.total
      acc[data].quantidade += 1
      return acc
    }, {} as Record<string, { valor: number; quantidade: number }>)

    return Object.entries(grupos).map(([data, info]) => ({
      data,
      ...info
    }))
  }

  private groupSalesByPayment(vendas: Sale[]): { forma: string; valor: number; quantidade: number }[] {
    const grupos = vendas.reduce((acc, venda) => {
      const forma = venda.forma_pagamento
      if (!acc[forma]) {
        acc[forma] = { valor: 0, quantidade: 0 }
      }
      acc[forma].valor += venda.total
      acc[forma].quantidade += 1
      return acc
    }, {} as Record<string, { valor: number; quantidade: number }>)

    return Object.entries(grupos).map(([forma, info]) => ({
      forma,
      ...info
    }))
  }

  private getTopClients(vendas: Sale[]): { cliente: string; valor: number; quantidade: number }[] {
    const grupos = vendas.reduce((acc, venda) => {
      const cliente = venda.cliente?.nome || 'Cliente não informado'
      if (!acc[cliente]) {
        acc[cliente] = { valor: 0, quantidade: 0 }
      }
      acc[cliente].valor += venda.total
      acc[cliente].quantidade += 1
      return acc
    }, {} as Record<string, { valor: number; quantidade: number }>)

    return Object.entries(grupos)
      .map(([cliente, info]) => ({ cliente, ...info }))
      .sort((a, b) => b.valor - a.valor)
      .slice(0, 10)
  }

  private getTopProducts(vendas: Sale[]): { produto: string; valor: number; quantidade: number }[] {
    const produtos = vendas.flatMap(v => v.itens || [])
    
    const grupos = produtos.reduce((acc, item) => {
      const produto = item.produto_nome
      if (!acc[produto]) {
        acc[produto] = { valor: 0, quantidade: 0 }
      }
      acc[produto].valor += item.subtotal
      acc[produto].quantidade += item.quantidade
      return acc
    }, {} as Record<string, { valor: number; quantidade: number }>)

    return Object.entries(grupos)
      .map(([produto, info]) => ({ produto, ...info }))
      .sort((a, b) => b.valor - a.valor)
      .slice(0, 10)
  }

  private groupMovementsByCategory(movimentacoes: FinancialMovement[]): { categoria: string; valor: number }[] {
    const grupos = movimentacoes.reduce((acc, mov) => {
      if (!acc[mov.categoria]) {
        acc[mov.categoria] = 0
      }
      acc[mov.categoria] += mov.valor
      return acc
    }, {} as Record<string, number>)

    return Object.entries(grupos).map(([categoria, valor]) => ({ categoria, valor }))
  }

  private groupMovementsByDay(movimentacoes: FinancialMovement[]): { data: string; entradas: number; saidas: number }[] {
    const grupos = movimentacoes.reduce((acc, mov) => {
      const data = mov.data_movimento
      if (!acc[data]) {
        acc[data] = { entradas: 0, saidas: 0 }
      }
      if (mov.tipo === 'entrada') {
        acc[data].entradas += mov.valor
      } else {
        acc[data].saidas += mov.valor
      }
      return acc
    }, {} as Record<string, { entradas: number; saidas: number }>)

    return Object.entries(grupos).map(([data, info]) => ({ data, ...info }))
  }

  private groupProductSales(items: any[]): { produto: string; valor: number; quantidade: number }[] {
    const grupos = items.reduce((acc, item) => {
      const produto = item.produto_nome
      if (!acc[produto]) {
        acc[produto] = { valor: 0, quantidade: 0 }
      }
      acc[produto].valor += item.preco_unitario * item.quantidade
      acc[produto].quantidade += item.quantidade
      return acc
    }, {} as Record<string, { valor: number; quantidade: number }>)

    return Object.entries(grupos)
      .map(([produto, info]) => ({ 
        produto, 
        valor: (info as { valor: number; quantidade: number }).valor, 
        quantidade: (info as { valor: number; quantidade: number }).quantidade 
      }))
      .sort((a, b) => b.quantidade - a.quantidade)
      .slice(0, 10)
  }
}

export const reportsService = new ReportsService()
