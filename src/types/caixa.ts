// Types para o módulo de Caixa do sistema PDV Import

export interface Caixa {
  id: string;
  usuario_id: string;
  valor_inicial: number;
  valor_final?: number;
  data_abertura: string;
  data_fechamento?: string;
  status: 'aberto' | 'fechado';
  diferenca?: number;
  observacoes?: string;
  criado_em: string;
  atualizado_em: string;
}

export interface MovimentacaoCaixa {
  id: string;
  caixa_id: string;
  tipo: 'entrada' | 'saida';
  descricao: string;
  valor: number;
  usuario_id: string;
  venda_id?: string;
  data: string;
  criado_em: string;
}

export interface CaixaCompleto extends Caixa {
  movimentacoes?: MovimentacaoCaixa[];
  total_entradas: number;
  total_saidas: number;
  saldo_atual: number;
  total_movimentacoes: number;
}

export interface CaixaResumo {
  valor_inicial: number;
  total_entradas: number;
  total_saidas: number;
  saldo_atual: number;
  total_movimentacoes: number;
}

export interface AberturaCaixaForm {
  valor_inicial: number;
  observacoes?: string;
}

export interface FechamentoCaixaForm {
  valor_contado: number;
  observacoes?: string;
}

export interface MovimentacaoForm {
  tipo: 'entrada' | 'saida';
  descricao: string;
  valor: number;
}

export interface CaixaFiltros {
  status?: 'aberto' | 'fechado' | 'todos';
  data_inicio?: string;
  data_fim?: string;
  usuario_id?: string;
}

export interface HistoricoCaixa {
  id: string;
  data: string;
  descricao?: string;
  valor: number;
  data_abertura: string;
  status: 'aberto' | 'fechado';
  valor_inicial: number;
  valor_final?: number;
  diferenca?: number;
  data_fechamento?: string;
  observacoes?: string;
  movimentacoes?: Array<{
    id: string;
    tipo: 'entrada' | 'saida';
    descricao: string;
    valor: number;
    data: string;
  }>;
}
