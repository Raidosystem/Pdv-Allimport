// Arquivo de compatibilidade - usando realReportsService

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

// Export vazio para compatibilidade
export const reportsService = {
  // Funções básicas para compatibilidade
};