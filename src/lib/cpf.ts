/**
 * Utilitários para validação e formatação de CPF e CNPJ
 */

/**
 * Remove todos os caracteres não numéricos
 */
export function onlyDigits(value: string): string {
  return value.replace(/\D/g, '')
}

/**
 * Aplica máscara de CPF (000.000.000-00)
 */
export function formatCPF(value: string): string {
  const digits = onlyDigits(value)
  
  if (digits.length <= 3) return digits
  if (digits.length <= 6) return `${digits.slice(0, 3)}.${digits.slice(3)}`
  if (digits.length <= 9) return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6)}`
  
  return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9, 11)}`
}

/**
 * Aplica máscara de CNPJ (00.000.000/0000-00)
 */
export function formatCNPJ(value: string): string {
  const digits = onlyDigits(value)
  
  if (digits.length <= 2) return digits
  if (digits.length <= 5) return `${digits.slice(0, 2)}.${digits.slice(2)}`
  if (digits.length <= 8) return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5)}`
  if (digits.length <= 12) return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5, 8)}/${digits.slice(8)}`
  
  return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5, 8)}/${digits.slice(8, 12)}-${digits.slice(12, 14)}`
}

/**
 * Formata automaticamente como CPF ou CNPJ baseado no número de dígitos
 */
export function formatCpfCnpj(value: string): string {
  const digits = onlyDigits(value)
  
  // Se tem até 11 dígitos, formatar como CPF
  if (digits.length <= 11) {
    return formatCPF(value)
  }
  
  // Se tem mais de 11 dígitos, formatar como CNPJ
  return formatCNPJ(value)
}

/**
 * Valida CPF usando o algoritmo oficial dos dígitos verificadores
 */
export function isValidCPF(value: string): boolean {
  const cpf = onlyDigits(value)
  
  // CPF deve ter exatamente 11 dígitos
  if (cpf.length !== 11) return false
  
  // Rejeita sequências repetidas (000.000.000-00, 111.111.111-11, etc.)
  if (/^(\d)\1{10}$/.test(cpf)) return false
  
  // Valida primeiro dígito verificador
  let sum = 0
  for (let i = 0; i < 9; i++) {
    sum += parseInt(cpf.charAt(i)) * (10 - i)
  }
  
  let remainder = (sum * 10) % 11
  if (remainder === 10 || remainder === 11) remainder = 0
  if (remainder !== parseInt(cpf.charAt(9))) return false
  
  // Valida segundo dígito verificador
  sum = 0
  for (let i = 0; i < 10; i++) {
    sum += parseInt(cpf.charAt(i)) * (11 - i)
  }
  
  remainder = (sum * 10) % 11
  if (remainder === 10 || remainder === 11) remainder = 0
  if (remainder !== parseInt(cpf.charAt(10))) return false
  
  return true
}

/**
 * Valida CNPJ usando o algoritmo oficial dos dígitos verificadores
 */
export function isValidCNPJ(value: string): boolean {
  const cnpj = onlyDigits(value)
  
  // CNPJ deve ter exatamente 14 dígitos
  if (cnpj.length !== 14) return false
  
  // Rejeita sequências repetidas (00000000000000, 11111111111111, etc.)
  if (/^(\d)\1{13}$/.test(cnpj)) return false
  
  // Valida primeiro dígito verificador
  let sum = 0
  const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  
  for (let i = 0; i < 12; i++) {
    sum += parseInt(cnpj.charAt(i)) * weights1[i]
  }
  
  let remainder = sum % 11
  const digit1 = remainder < 2 ? 0 : 11 - remainder
  
  if (digit1 !== parseInt(cnpj.charAt(12))) return false
  
  // Valida segundo dígito verificador
  sum = 0
  const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  
  for (let i = 0; i < 13; i++) {
    sum += parseInt(cnpj.charAt(i)) * weights2[i]
  }
  
  remainder = sum % 11
  const digit2 = remainder < 2 ? 0 : 11 - remainder
  
  if (digit2 !== parseInt(cnpj.charAt(13))) return false
  
  return true
}

/**
 * Valida CPF ou CNPJ automaticamente baseado no número de dígitos
 */
export function isValidCpfCnpj(value: string): boolean {
  const digits = onlyDigits(value)
  
  if (digits.length === 11) {
    return isValidCPF(value)
  }
  
  if (digits.length === 14) {
    return isValidCNPJ(value)
  }
  
  return false
}

/**
 * Testes básicos para validação
 */
export const CPF_TESTS = {
  valid: [
    '11144477735', // CPF válido real
    '12345678909', // CPF válido real
    '52998224725'  // CPF válido real
  ],
  invalid: [
    '12345678901', // Dígitos verificadores errados
    '00000000000', // Sequência repetida
    '11111111111', // Sequência repetida
    '123456789',   // Muito curto
    '123456789012', // Muito longo
    '',            // Vazio
    'abcdefghijk'  // Não numérico
  ]
}