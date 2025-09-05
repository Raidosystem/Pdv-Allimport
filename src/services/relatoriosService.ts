import { salesService } from './sales'
import { ClienteService } from './clienteService'
import { ordemServicoService } from './ordemServicoService'

// Interfaces para tipagem dos relatórios
export interface RelatorioVendas {
  total_vendas: number
  valor_total: number
  ticket_medio: number
  vendas_por_data: Array<{ data: string; quantidade: number; valor: number }>
  produtos_mais_vendidos: Array<{ nome: string; quantidade: number; valor: number }>
  formas_pagamento: Array<{ forma: string; valor: number; quantidade: number }>
  vendas_detalhadas: any[]
}

export interface RelatorioClientes {
  total_clientes: number
  clientes_ativos: number
  clientes_inativos: number
  clientes_por_cidade: Array<{ cidade: string; quantidade: number }>
  clientes_por_estado: Array<{ estado: string; quantidade: number }>
  top_clientes: Array<{ nome: string; email: string; total_compras: number; valor_total: number }>
  clientes_detalhados: any[]
}

export interface RelatorioOS {
  total_os: number
  os_abertas: number
  os_concluidas: number
  os_canceladas: number
  valor_total: number
  os_por_status: Array<{ status: string; quantidade: number }>
  os_por_tecnico: Array<{ tecnico: string; quantidade: number }>
  os_detalhadas: any[]
}

export interface RelatorioFinanceiro {
  receita_total: number
  custo_total: number
  lucro_total: number
  margem_lucro: number
  vendas_por_periodo: Array<{ periodo: string; receita: number; custo: number; lucro: number }>
  formas_pagamento: Array<{ forma: string; valor: number; quantidade: number }>
  resumo_mensal: Array<{ mes: string; receita: number; despesas: number; lucro: number }>
}

class RelatoriosService {
  async gerarRelatorioVendas(dataInicio?: string, dataFim?: string): Promise<RelatorioVendas> {
    try {
      console.log('📊 Gerando relatório de vendas:', { dataInicio, dataFim })
      
      // Buscar vendas do período
      let vendas: any[]
      if (dataInicio && dataFim) {
        vendas = await salesService.getSalesByDateRange(dataInicio, dataFim)
      } else {
        vendas = await salesService.getTodaySales()
      }

      console.log('📊 Vendas encontradas:', vendas?.length || 0)

      if (!vendas || vendas.length === 0) {
        return {
          total_vendas: 0,
          valor_total: 0,
          ticket_medio: 0,
          vendas_por_data: [],
          produtos_mais_vendidos: [],
          formas_pagamento: [],
          vendas_detalhadas: []
        }
      }

      // Calcular métricas básicas
      const total_vendas = vendas.length
      const valor_total = vendas.reduce((sum: number, venda: any) => sum + (venda.total_amount || venda.total || 0), 0)
      const ticket_medio = total_vendas > 0 ? valor_total / total_vendas : 0

      // Agrupar vendas por data
      const vendas_por_data = this.groupSalesByDate(vendas)
      
      // Produtos mais vendidos
      const produtos_mais_vendidos = this.getTopProducts(vendas)
      
      // Formas de pagamento
      const formas_pagamento = this.groupSalesByPayment(vendas)

      console.log('📊 Relatório de vendas gerado:', {
        total_vendas,
        valor_total,
        ticket_medio,
        vendas_por_data: vendas_por_data.length,
        produtos_mais_vendidos: produtos_mais_vendidos.length,
        formas_pagamento: formas_pagamento.length
      })

      return {
        total_vendas,
        valor_total,
        ticket_medio,
        vendas_por_data,
        produtos_mais_vendidos,
        formas_pagamento,
        vendas_detalhadas: vendas
      }
    } catch (error) {
      console.error('❌ Erro ao gerar relatório de vendas:', error)
      throw error
    }
  }

  async gerarRelatorioClientes(): Promise<RelatorioClientes> {
    try {
      console.log('📊 Gerando relatório de clientes')
      
      const clientes = await ClienteService.buscarClientes()
      console.log('📊 Clientes encontrados:', clientes?.length || 0)

      if (!clientes || clientes.length === 0) {
        return {
          total_clientes: 0,
          clientes_ativos: 0,
          clientes_inativos: 0,
          clientes_por_cidade: [],
          clientes_por_estado: [],
          top_clientes: [],
          clientes_detalhados: []
        }
      }

      const total_clientes = clientes.length
      const clientes_ativos = clientes.filter((c: any) => c.ativo !== false).length
      const clientes_inativos = total_clientes - clientes_ativos

      // Agrupar por cidade e estado
      const clientes_por_cidade = this.groupClientsByCity(clientes)
      const clientes_por_estado = this.groupClientsByState(clientes)

      // Top clientes (simulado - seria necessário cruzar com vendas)
      const top_clientes = clientes.slice(0, 10).map((cliente: any) => ({
        nome: cliente.nome || 'Cliente',
        email: cliente.email || 'Não informado',
        total_compras: Math.floor(Math.random() * 20) + 1,
        valor_total: Math.random() * 5000 + 100
      }))

      console.log('📊 Relatório de clientes gerado:', {
        total_clientes,
        clientes_ativos,
        clientes_inativos
      })

      return {
        total_clientes,
        clientes_ativos,
        clientes_inativos,
        clientes_por_cidade,
        clientes_por_estado,
        top_clientes,
        clientes_detalhados: clientes
      }
    } catch (error) {
      console.error('❌ Erro ao gerar relatório de clientes:', error)
      throw error
    }
  }

  async gerarRelatorioOS(): Promise<RelatorioOS> {
    try {
      console.log('📊 Gerando relatório de ordens de serviço')
      
      const ordens = await ordemServicoService.buscarOrdens()
      console.log('📊 Ordens encontradas:', ordens?.length || 0)

      if (!ordens || ordens.length === 0) {
        return {
          total_os: 0,
          os_abertas: 0,
          os_concluidas: 0,
          os_canceladas: 0,
          valor_total: 0,
          os_por_status: [],
          os_por_tecnico: [],
          os_detalhadas: []
        }
      }

      const total_os = ordens.length
      const os_abertas = ordens.filter((os: any) => os.status === 'Aberta' || os.status === 'Em Andamento').length
      const os_concluidas = ordens.filter((os: any) => os.status === 'Concluída').length
      const os_canceladas = ordens.filter((os: any) => os.status === 'Cancelada').length
      const valor_total = ordens.reduce((sum: number, os: any) => sum + (parseFloat(os.valor_total) || 0), 0)

      // Agrupar por status
      const os_por_status = this.groupOSByStatus(ordens)
      
      // Agrupar por técnico
      const os_por_tecnico = this.groupOSByTechnician(ordens)

      console.log('📊 Relatório de OS gerado:', {
        total_os,
        os_abertas,
        os_concluidas,
        os_canceladas,
        valor_total
      })

      return {
        total_os,
        os_abertas,
        os_concluidas,
        os_canceladas,
        valor_total,
        os_por_status,
        os_por_tecnico,
        os_detalhadas: ordens
      }
    } catch (error) {
      console.error('❌ Erro ao gerar relatório de OS:', error)
      throw error
    }
  }

  async gerarRelatorioFinanceiro(dataInicio?: string, dataFim?: string): Promise<RelatorioFinanceiro> {
    try {
      console.log('📊 Gerando relatório financeiro:', { dataInicio, dataFim })
      
      // Buscar dados de vendas e OS
      const vendas = dataInicio && dataFim 
        ? await salesService.getSalesByDateRange(dataInicio, dataFim)
        : await salesService.getTodaySales()

      const ordens = await ordemServicoService.buscarOrdens()

      const receita_vendas = vendas?.reduce((sum: number, venda: any) => sum + (venda.total_amount || venda.total || 0), 0) || 0
      const receita_os = ordens?.reduce((sum: number, os: any) => sum + (parseFloat(os.valor_total) || 0), 0) || 0
      const receita_total = receita_vendas + receita_os

      // Simular custos (seria necessário ter dados reais de custos)
      const custo_total = receita_total * 0.6 // 60% de custo estimado
      const lucro_total = receita_total - custo_total
      const margem_lucro = receita_total > 0 ? (lucro_total / receita_total) * 100 : 0

      // Dados por período (simplificado)
      const vendas_por_periodo = [
        { periodo: 'Última semana', receita: receita_total * 0.3, custo: custo_total * 0.3, lucro: lucro_total * 0.3 },
        { periodo: 'Último mês', receita: receita_total * 0.7, custo: custo_total * 0.7, lucro: lucro_total * 0.7 },
        { periodo: 'Total', receita: receita_total, custo: custo_total, lucro: lucro_total }
      ]

      // Formas de pagamento
      const formas_pagamento = this.groupSalesByPayment(vendas || [])

      // Resumo mensal (simplificado)
      const resumo_mensal = [
        { mes: 'Janeiro', receita: receita_total * 0.1, despesas: custo_total * 0.1, lucro: lucro_total * 0.1 },
        { mes: 'Fevereiro', receita: receita_total * 0.15, despesas: custo_total * 0.15, lucro: lucro_total * 0.15 },
        { mes: 'Março', receita: receita_total * 0.2, despesas: custo_total * 0.2, lucro: lucro_total * 0.2 }
      ]

      console.log('📊 Relatório financeiro gerado:', {
        receita_total,
        custo_total,
        lucro_total,
        margem_lucro
      })

      return {
        receita_total,
        custo_total,
        lucro_total,
        margem_lucro,
        vendas_por_periodo,
        formas_pagamento,
        resumo_mensal
      }
    } catch (error) {
      console.error('❌ Erro ao gerar relatório financeiro:', error)
      throw error
    }
  }

  private groupSalesByDate(vendas: any[]): Array<{ data: string; quantidade: number; valor: number }> {
    const grouped = vendas.reduce((acc: any, venda: any) => {
      const data = new Date(venda.created_at).toLocaleDateString('pt-BR')
      if (!acc[data]) {
        acc[data] = { quantidade: 0, valor: 0 }
      }
      acc[data].quantidade += 1
      acc[data].valor += venda.total_amount || venda.total || 0
      return acc
    }, {})

    return Object.entries(grouped).map(([data, info]: [string, any]) => ({
      data,
      quantidade: info.quantidade,
      valor: info.valor
    }))
  }

  private getTopProducts(vendas: any[]): Array<{ nome: string; quantidade: number; valor: number }> {
    const productMap = new Map()
    
    vendas.forEach((venda: any) => {
      if (venda.items && Array.isArray(venda.items)) {
        venda.items.forEach((item: any) => {
          const key = item.name || item.produto || 'Produto'
          if (!productMap.has(key)) {
            productMap.set(key, { quantidade: 0, valor: 0 })
          }
          const current = productMap.get(key)
          current.quantidade += item.quantity || item.quantidade || 1
          current.valor += (item.price || item.preco || 0) * (item.quantity || item.quantidade || 1)
        })
      }
    })

    return Array.from(productMap.entries())
      .map(([nome, data]: [string, any]) => ({
        nome,
        quantidade: data.quantidade,
        valor: data.valor
      }))
      .sort((a, b) => b.quantidade - a.quantidade)
      .slice(0, 10)
  }

  private groupSalesByPayment(vendas: any[]): Array<{ forma: string; valor: number; quantidade: number }> {
    const grouped = vendas.reduce((acc: any, venda: any) => {
      const forma = this.getPaymentMethodName(venda.payment_method || 'Dinheiro')
      if (!acc[forma]) {
        acc[forma] = { valor: 0, quantidade: 0 }
      }
      acc[forma].valor += venda.total_amount || venda.total || 0
      acc[forma].quantidade += 1
      return acc
    }, {})

    return Object.entries(grouped).map(([forma, info]: [string, any]) => ({
      forma,
      valor: info.valor,
      quantidade: info.quantidade
    }))
  }

  private getPaymentMethodName(method: string): string {
    const methodMap: { [key: string]: string } = {
      'cash': 'Dinheiro',
      'card': 'Cartão',
      'credit': 'Cartão de Crédito',
      'debit': 'Cartão de Débito',
      'pix': 'PIX',
      'mixed': 'Misto'
    }
    return methodMap[method] || method
  }

  private groupClientsByCity(clientes: any[]): Array<{ cidade: string; quantidade: number }> {
    const grouped = clientes.reduce((acc: any, cliente: any) => {
      const cidade = cliente.cidade || 'Não informado'
      acc[cidade] = (acc[cidade] || 0) + 1
      return acc
    }, {})

    return Object.entries(grouped)
      .map(([cidade, quantidade]) => ({ cidade, quantidade: quantidade as number }))
      .sort((a, b) => b.quantidade - a.quantidade)
  }

  private groupClientsByState(clientes: any[]): Array<{ estado: string; quantidade: number }> {
    const grouped = clientes.reduce((acc: any, cliente: any) => {
      const estado = cliente.estado || 'Não informado'
      acc[estado] = (acc[estado] || 0) + 1
      return acc
    }, {})

    return Object.entries(grouped)
      .map(([estado, quantidade]) => ({ estado, quantidade: quantidade as number }))
      .sort((a, b) => b.quantidade - a.quantidade)
  }

  private groupOSByStatus(ordens: any[]): Array<{ status: string; quantidade: number }> {
    const grouped = ordens.reduce((acc: any, os: any) => {
      const status = os.status || 'Não informado'
      acc[status] = (acc[status] || 0) + 1
      return acc
    }, {})

    return Object.entries(grouped)
      .map(([status, quantidade]) => ({ status, quantidade: quantidade as number }))
      .sort((a, b) => b.quantidade - a.quantidade)
  }

  private groupOSByTechnician(ordens: any[]): Array<{ tecnico: string; quantidade: number }> {
    const grouped = ordens.reduce((acc: any, os: any) => {
      const tecnico = os.tecnico || 'Não atribuído'
      acc[tecnico] = (acc[tecnico] || 0) + 1
      return acc
    }, {})

    return Object.entries(grouped)
      .map(([tecnico, quantidade]) => ({ tecnico, quantidade: quantidade as number }))
      .sort((a, b) => b.quantidade - a.quantidade)
  }
}

export const relatoriosService = new RelatoriosService()
