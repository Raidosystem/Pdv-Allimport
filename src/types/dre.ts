// ============================================
// TIPOS TYPESCRIPT - SISTEMA DRE
// ============================================

// ===== COMPRAS =====

export interface Compra {
  id: string;
  empresa_id: string;
  user_id: string;
  numero_nota?: string;
  fornecedor_nome: string;
  fornecedor_cnpj?: string;
  data_compra: string;
  valor_total: number;
  observacoes?: string;
  status: 'pendente' | 'finalizada' | 'cancelada';
  criado_em: string;
  atualizado_em: string;
  // Relacionamentos
  itens?: ItemCompra[];
}

export interface ItemCompra {
  id: string;
  compra_id: string;
  produto_id: string;
  empresa_id: string;
  user_id: string;
  quantidade: number;
  custo_unitario: number;
  custo_total: number;
  criado_em: string;
  // Relacionamentos
  produto?: Produto;
}

export interface CompraForm {
  fornecedor_nome: string;
  fornecedor_cnpj?: string;
  numero_nota?: string;
  data_compra: Date;
  observacoes?: string;
  itens: {
    produto_id: string;
    quantidade: number;
    custo_unitario: number;
  }[];
}

// ===== MOVIMENTAÇÕES DE ESTOQUE =====

export interface MovimentacaoEstoque {
  id: string;
  produto_id: string;
  empresa_id: string;
  user_id: string;
  tipo_movimentacao: 'entrada' | 'saida' | 'ajuste' | 'inventario';
  quantidade: number;
  custo_unitario: number;
  custo_medio_anterior?: number;
  custo_medio_novo?: number;
  estoque_anterior?: number;
  estoque_novo?: number;
  referencia_tipo?: 'compra' | 'venda' | 'ajuste' | 'inventario';
  referencia_id?: string;
  observacao?: string;
  data_movimentacao: string;
  criado_em: string;
  // Relacionamentos
  produto?: Produto;
}

// ===== DESPESAS =====

export type CategoriaDespesa =
  | 'aluguel'
  | 'salarios'
  | 'energia'
  | 'agua'
  | 'telefone'
  | 'material'
  | 'manutencao'
  | 'marketing'
  | 'outras';

export interface Despesa {
  id: string;
  empresa_id: string;
  user_id: string;
  descricao: string;
  categoria: CategoriaDespesa;
  valor: number;
  data_despesa: string;
  data_vencimento?: string;
  data_pagamento?: string;
  status: 'pendente' | 'pago' | 'cancelado';
  forma_pagamento?: string;
  observacoes?: string;
  criado_em: string;
  atualizado_em: string;
}

export interface DespesaForm {
  descricao: string;
  categoria: CategoriaDespesa;
  valor: number;
  data_despesa: Date;
  data_vencimento?: Date;
  status: 'pendente' | 'pago' | 'cancelado';
  forma_pagamento?: string;
  observacoes?: string;
}

// ===== OUTRAS MOVIMENTAÇÕES FINANCEIRAS =====

export type CategoriaOutrasMovimentacoes =
  | 'juros_recebidos'
  | 'juros_pagos'
  | 'desconto_obtido'
  | 'desconto_concedido'
  | 'multa'
  | 'outras';

export interface OutraMovimentacaoFinanceira {
  id: string;
  empresa_id: string;
  user_id: string;
  tipo: 'receita' | 'despesa';
  descricao: string;
  categoria: CategoriaOutrasMovimentacoes;
  valor: number;
  data_movimentacao: string;
  observacoes?: string;
  criado_em: string;
  atualizado_em: string;
}

export interface OutraMovimentacaoForm {
  tipo: 'receita' | 'despesa';
  descricao: string;
  categoria: CategoriaOutrasMovimentacoes;
  valor: number;
  data_movimentacao: Date;
  observacoes?: string;
}

// ===== DRE (DEMONSTRAÇÃO DO RESULTADO DO EXERCÍCIO) =====

export interface DRE {
  receita_bruta: number;
  deducoes: number;
  receita_liquida: number;
  cmv: number; // Custo da Mercadoria Vendida
  lucro_bruto: number;
  despesas_operacionais: number;
  resultado_operacional: number;
  outras_receitas: number;
  outras_despesas: number;
  resultado_liquido: number;
}

export interface FiltrosDRE {
  data_inicio: Date;
  data_fim: Date;
  empresa_id?: string;
}

export interface KPIsDRE {
  margem_bruta_percentual: number; // (Lucro Bruto / Receita Líquida) * 100
  margem_operacional_percentual: number; // (Resultado Operacional / Receita Líquida) * 100
  margem_liquida_percentual: number; // (Resultado Líquido / Receita Líquida) * 100
  markup_medio: number; // (Receita Bruta / CMV) - 1
  ticket_medio: number;
  total_vendas: number;
}

// ===== PRODUTO (EXTENSÃO) =====

export interface Produto {
  id: string;
  empresa_id: string;
  user_id: string;
  nome: string;
  codigo_barras?: string;
  preco: number;
  custo_medio: number; // NOVO CAMPO
  quantidade_estoque: number; // NOVO CAMPO
  estoque_minimo: number; // NOVO CAMPO
  controla_estoque: boolean; // NOVO CAMPO
  categoria?: string;
  descricao?: string;
  ativo: boolean;
  criado_em: string;
  atualizado_em: string;
}

// ===== RELATÓRIOS E ANÁLISES =====

export interface RelatorioEstoque {
  produto_id: string;
  produto_nome: string;
  quantidade_estoque: number;
  custo_medio: number;
  valor_total_estoque: number;
  ultima_entrada?: string;
  ultima_saida?: string;
}

export interface RelatorioCMV {
  periodo: string;
  cmv_total: number;
  quantidade_vendida: number;
  custo_medio_periodo: number;
  produtos_mais_vendidos: {
    produto_nome: string;
    quantidade: number;
    cmv: number;
  }[];
}

export interface DREComparativo {
  periodo_atual: DRE;
  periodo_anterior: DRE;
  variacao_percentual: {
    receita_bruta: number;
    receita_liquida: number;
    lucro_bruto: number;
    resultado_liquido: number;
  };
}

// ===== FILTROS E PAGINAÇÃO =====

export interface FiltrosCompras {
  data_inicio?: Date;
  data_fim?: Date;
  fornecedor_nome?: string;
  status?: 'pendente' | 'finalizada' | 'cancelada';
  order_by?: 'data_compra' | 'valor_total' | 'fornecedor_nome';
  order_direction?: 'asc' | 'desc';
}

export interface FiltrosDespesas {
  data_inicio?: Date;
  data_fim?: Date;
  categoria?: CategoriaDespesa;
  status?: 'pendente' | 'pago' | 'cancelado';
  order_by?: 'data_despesa' | 'valor' | 'categoria';
  order_direction?: 'asc' | 'desc';
}

export interface FiltrosMovimentacoes {
  data_inicio?: Date;
  data_fim?: Date;
  produto_id?: string;
  tipo_movimentacao?: 'entrada' | 'saida' | 'ajuste' | 'inventario';
  order_by?: 'data_movimentacao' | 'quantidade';
  order_direction?: 'asc' | 'desc';
}

// ===== RESPOSTAS DE FUNÇÕES RPC =====

export interface RespostaAplicarCompra {
  sucesso: boolean;
  mensagem?: string;
  compra_id?: string;
}

export interface RespostaAplicarVenda {
  sucesso: boolean;
  mensagem?: string;
  venda_id?: string;
}

export interface RespostaCalcularDRE {
  dre: DRE;
  kpis: KPIsDRE;
}

// ===== CONSTANTES =====

export const CATEGORIAS_DESPESAS: { value: CategoriaDespesa; label: string }[] = [
  { value: 'aluguel', label: 'Aluguel' },
  { value: 'salarios', label: 'Salários' },
  { value: 'energia', label: 'Energia Elétrica' },
  { value: 'agua', label: 'Água' },
  { value: 'telefone', label: 'Telefone/Internet' },
  { value: 'material', label: 'Material de Expediente' },
  { value: 'manutencao', label: 'Manutenção' },
  { value: 'marketing', label: 'Marketing' },
  { value: 'outras', label: 'Outras Despesas' },
];

export const CATEGORIAS_OUTRAS_MOVIMENTACOES: {
  value: CategoriaOutrasMovimentacoes;
  label: string;
}[] = [
  { value: 'juros_recebidos', label: 'Juros Recebidos' },
  { value: 'juros_pagos', label: 'Juros Pagos' },
  { value: 'desconto_obtido', label: 'Desconto Obtido' },
  { value: 'desconto_concedido', label: 'Desconto Concedido' },
  { value: 'multa', label: 'Multa' },
  { value: 'outras', label: 'Outras' },
];

export const PERIODOS_DRE = [
  { value: 'hoje', label: 'Hoje' },
  { value: 'semana', label: 'Última Semana' },
  { value: 'mes', label: 'Último Mês' },
  { value: 'trimestre', label: 'Último Trimestre' },
  { value: 'semestre', label: 'Último Semestre' },
  { value: 'ano', label: 'Último Ano' },
  { value: 'personalizado', label: 'Período Personalizado' },
];
