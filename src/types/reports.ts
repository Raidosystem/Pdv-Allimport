// Tipos para o sistema de relatórios e analytics
export interface Sale {
  id: string
  user_id: string
  cliente_id?: string
  vendedor: string
  data_venda: string
  subtotal: number
  desconto: number
  total: number
  forma_pagamento: string
  status: string
  observacoes?: string
  created_at: string
  updated_at: string
  
  // Relacionamentos
  cliente?: {
    id: string
    nome: string
    email?: string
    telefone?: string
  }
  itens?: SaleItem[]
}

export interface SaleItem {
  id: string
  sale_id: string
  product_id: string
  user_id: string
  produto_nome: string
  quantidade: number
  preco_unitario: number
  subtotal: number
  created_at: string
}

export interface FinancialMovement {
  id: string
  user_id: string
  tipo: 'entrada' | 'saida'
  categoria: string
  descricao: string
  valor: number
  data_movimento: string
  referencia_id?: string
  observacoes?: string
  created_at: string
  updated_at: string
}

export interface ReportFilters {
  data_inicio: string
  data_fim: string
  cliente_id?: string
  vendedor?: string
  forma_pagamento?: string
  categoria?: string
  tipo?: 'entrada' | 'saida' | 'todas'
}

export interface SalesReport {
  vendas: Sale[]
  resumo: {
    total_vendas: number
    total_valor: number
    total_desconto: number
    ticket_medio: number
    vendas_por_dia: { data: string; valor: number; quantidade: number }[]
    formas_pagamento: { forma: string; valor: number; quantidade: number }[]
    top_clientes: { cliente: string; valor: number; quantidade: number }[]
    top_produtos: { produto: string; valor: number; quantidade: number }[]
  }
}

export interface FinancialReport {
  movimentacoes: FinancialMovement[]
  resumo: {
    total_entradas: number
    total_saidas: number
    saldo: number
    entradas_por_categoria: { categoria: string; valor: number }[]
    saidas_por_categoria: { categoria: string; valor: number }[]
    movimentacoes_por_dia: { data: string; entradas: number; saidas: number }[]
  }
}

export interface StockReport {
  produtos_estoque_baixo: {
    id: string
    nome: string
    estoque_atual: number
    estoque_minimo: number
    valor_investido: number
  }[]
  valor_total_estoque: number
  produtos_sem_movimento: {
    id: string
    nome: string
    estoque: number
    dias_sem_venda: number
  }[]
  produtos_mais_vendidos: {
    produto: string
    quantidade_vendida: number
    valor_total: number
  }[]
}

export interface ClientsReport {
  clientes: {
    id: string
    nome: string
    email?: string
    telefone?: string
    total_compras: number
    valor_total: number
    ultima_compra: string
    ticket_medio: number
  }[]
  resumo: {
    total_clientes: number
    clientes_ativos: number
    clientes_inativos: number
    ticket_medio_geral: number
  }
}

export interface DashboardMetrics {
  vendas_hoje: {
    quantidade: number
    valor: number
    crescimento: number // % comparado ao dia anterior
  }
  vendas_mes: {
    quantidade: number
    valor: number
    crescimento: number // % comparado ao mês anterior
  }
  produtos_estoque_baixo: number
  clientes_ativos: number
  receita_vs_meta: {
    atual: number
    meta: number
    percentual: number
  }
  top_produtos: {
    nome: string
    quantidade: number
    valor: number
  }[]
  vendas_ultimos_7_dias: {
    data: string
    valor: number
    quantidade: number
  }[]
}

export type ReportType = 'vendas' | 'financeiro' | 'estoque' | 'clientes' | 'dashboard'

export interface ExportOptions {
  formato: 'pdf' | 'excel' | 'csv'
  incluir_graficos: boolean
  periodo_personalizado: boolean
}
