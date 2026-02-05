/**
 * 💰 Utilitários para garantir precisão monetária
 * 
 * JavaScript usa IEEE 754 floats que causam erros de precisão:
 * Exemplo: 240.00 pode virar 239.99999999999997
 * 
 * Solução: Sempre arredondar para 2 casas decimais antes de salvar/usar
 */

/**
 * Arredonda valor monetário para 2 casas decimais com precisão
 * @param value - Valor a ser arredondado
 * @returns Valor com exatamente 2 casas decimais
 */
export function roundCurrency(value: number | undefined | null): number | undefined {
  if (value === undefined || value === null || isNaN(value)) {
    return undefined
  }
  
  // Multiplica por 100, arredonda para inteiro, divide por 100
  // Isso garante exatamente 2 casas decimais sem erros de float
  return Math.round(value * 100) / 100
}

/**
 * Formata valor monetário para exibição
 * @param value - Valor a ser formatado
 * @returns String formatada como moeda brasileira
 */
export function formatCurrency(value: number | undefined | null): string {
  if (value === undefined || value === null || isNaN(value)) {
    return 'R$ 0,00'
  }
  
  const rounded = roundCurrency(value)
  if (rounded === undefined) return 'R$ 0,00'
  
  return rounded.toLocaleString('pt-BR', {
    style: 'currency',
    currency: 'BRL',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

/**
 * Converte string de moeda brasileira para número
 * @param value - String no formato "R$ 1.234,56" ou "1234,56"
 * @returns Número com 2 casas decimais
 */
export function parseCurrency(value: string): number | undefined {
  if (!value) return undefined
  
  // Remove todos os caracteres exceto números, vírgula e ponto
  const cleaned = value.replace(/[^\d,.-]/g, '')
  
  // Substitui vírgula por ponto (padrão BR para US)
  const normalized = cleaned.replace(',', '.')
  
  const parsed = parseFloat(normalized)
  if (isNaN(parsed)) return undefined
  
  return roundCurrency(parsed)
}

/**
 * Valida se o valor é um valor monetário válido
 * @param value - Valor a ser validado
 * @returns true se for válido, false caso contrário
 */
export function isValidCurrency(value: number | undefined | null): boolean {
  if (value === undefined || value === null) return false
  if (isNaN(value)) return false
  if (value < 0) return false
  
  return true
}

/**
 * Soma valores monetários com precisão
 * @param values - Array de valores a serem somados
 * @returns Soma arredondada para 2 casas decimais
 */
export function sumCurrency(...values: (number | undefined | null)[]): number {
  const sum = values.reduce((acc: number, val) => {
    const rounded = roundCurrency(val)
    return acc + (rounded || 0)
  }, 0)
  
  return roundCurrency(sum) || 0
}

/**
 * Subtrai valores monetários com precisão
 * @param minuend - Valor a ser subtraído de
 * @param subtrahend - Valor a subtrair
 * @returns Diferença arredondada para 2 casas decimais
 */
export function subtractCurrency(
  minuend: number | undefined | null,
  subtrahend: number | undefined | null
): number {
  const a = roundCurrency(minuend) || 0
  const b = roundCurrency(subtrahend) || 0
  
  return roundCurrency(a - b) || 0
}

/**
 * Multiplica valor monetário por quantidade
 * @param value - Valor unitário
 * @param quantity - Quantidade
 * @returns Produto arredondado para 2 casas decimais
 */
export function multiplyCurrency(
  value: number | undefined | null,
  quantity: number
): number {
  const val = roundCurrency(value) || 0
  const result = val * quantity
  
  return roundCurrency(result) || 0
}

/**
 * Calcula percentual de um valor
 * @param value - Valor base
 * @param percentage - Percentual (ex: 10 para 10%)
 * @returns Percentual arredondado para 2 casas decimais
 */
export function calculatePercentage(
  value: number | undefined | null,
  percentage: number
): number {
  const val = roundCurrency(value) || 0
  const result = (val * percentage) / 100
  
  return roundCurrency(result) || 0
}
