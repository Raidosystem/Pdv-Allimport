/**
 * Validadores de documentos brasileiros
 * CPF e CNPJ com validação de dígitos verificadores
 */

/**
 * Validar CPF
 * @param cpf - CPF com ou sem formatação
 * @returns true se válido
 */
export function validateCPF(cpf: string): boolean {
  // Remove formatação
  const cleaned = cpf.replace(/\D/g, '')
  
  // Verifica se tem 11 dígitos
  if (cleaned.length !== 11) {
    return false
  }
  
  // Verifica se todos os dígitos são iguais (inválido)
  if (/^(\d)\1{10}$/.test(cleaned)) {
    return false
  }
  
  // Valida dígitos verificadores
  let sum = 0
  let remainder
  
  // Primeiro dígito verificador
  for (let i = 1; i <= 9; i++) {
    sum += parseInt(cleaned.substring(i - 1, i)) * (11 - i)
  }
  
  remainder = (sum * 10) % 11
  if (remainder === 10 || remainder === 11) remainder = 0
  if (remainder !== parseInt(cleaned.substring(9, 10))) return false
  
  // Segundo dígito verificador
  sum = 0
  for (let i = 1; i <= 10; i++) {
    sum += parseInt(cleaned.substring(i - 1, i)) * (12 - i)
  }
  
  remainder = (sum * 10) % 11
  if (remainder === 10 || remainder === 11) remainder = 0
  if (remainder !== parseInt(cleaned.substring(10, 11))) return false
  
  return true
}

/**
 * Validar CNPJ
 * @param cnpj - CNPJ com ou sem formatação
 * @returns true se válido
 */
export function validateCNPJ(cnpj: string): boolean {
  // Remove formatação
  const cleaned = cnpj.replace(/\D/g, '')
  
  // Verifica se tem 14 dígitos
  if (cleaned.length !== 14) {
    return false
  }
  
  // Verifica se todos os dígitos são iguais (inválido)
  if (/^(\d)\1{13}$/.test(cleaned)) {
    return false
  }
  
  // Valida dígitos verificadores
  let length = cleaned.length - 2
  let numbers = cleaned.substring(0, length)
  const digits = cleaned.substring(length)
  let sum = 0
  let pos = length - 7
  
  // Primeiro dígito verificador
  for (let i = length; i >= 1; i--) {
    sum += parseInt(numbers.charAt(length - i)) * pos--
    if (pos < 2) pos = 9
  }
  
  let result = sum % 11 < 2 ? 0 : 11 - (sum % 11)
  if (result !== parseInt(digits.charAt(0))) return false
  
  // Segundo dígito verificador
  length = length + 1
  numbers = cleaned.substring(0, length)
  sum = 0
  pos = length - 7
  
  for (let i = length; i >= 1; i--) {
    sum += parseInt(numbers.charAt(length - i)) * pos--
    if (pos < 2) pos = 9
  }
  
  result = sum % 11 < 2 ? 0 : 11 - (sum % 11)
  if (result !== parseInt(digits.charAt(1))) return false
  
  return true
}

/**
 * Formatar CPF
 * @param cpf - CPF sem formatação
 * @returns CPF formatado (000.000.000-00)
 */
export function formatCPF(cpf: string): string {
  const cleaned = cpf.replace(/\D/g, '')
  
  if (cleaned.length !== 11) {
    return cpf
  }
  
  return cleaned.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4')
}

/**
 * Formatar CNPJ
 * @param cnpj - CNPJ sem formatação
 * @returns CNPJ formatado (00.000.000/0000-00)
 */
export function formatCNPJ(cnpj: string): string {
  const cleaned = cnpj.replace(/\D/g, '')
  
  if (cleaned.length !== 14) {
    return cnpj
  }
  
  return cleaned.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '$1.$2.$3/$4-$5')
}

/**
 * Formatar CPF ou CNPJ automaticamente
 * @param document - Documento sem formatação
 * @returns Documento formatado
 */
export function formatDocument(document: string): string {
  const cleaned = document.replace(/\D/g, '')
  
  if (cleaned.length === 11) {
    return formatCPF(cleaned)
  }
  
  if (cleaned.length === 14) {
    return formatCNPJ(cleaned)
  }
  
  return document
}

/**
 * Validar CPF ou CNPJ automaticamente
 * @param document - Documento com ou sem formatação
 * @returns true se válido
 */
export function validateDocument(document: string): boolean {
  const cleaned = document.replace(/\D/g, '')
  
  if (cleaned.length === 11) {
    return validateCPF(cleaned)
  }
  
  if (cleaned.length === 14) {
    return validateCNPJ(cleaned)
  }
  
  return false
}

/**
 * Máscara de CPF para input
 * @param value - Valor digitado
 * @returns Valor com máscara aplicada
 */
export function maskCPF(value: string): string {
  const cleaned = value.replace(/\D/g, '')
  
  if (cleaned.length <= 3) {
    return cleaned
  }
  
  if (cleaned.length <= 6) {
    return `${cleaned.slice(0, 3)}.${cleaned.slice(3)}`
  }
  
  if (cleaned.length <= 9) {
    return `${cleaned.slice(0, 3)}.${cleaned.slice(3, 6)}.${cleaned.slice(6)}`
  }
  
  return `${cleaned.slice(0, 3)}.${cleaned.slice(3, 6)}.${cleaned.slice(6, 9)}-${cleaned.slice(9, 11)}`
}

/**
 * Máscara de CNPJ para input
 * @param value - Valor digitado
 * @returns Valor com máscara aplicada
 */
export function maskCNPJ(value: string): string {
  const cleaned = value.replace(/\D/g, '')
  
  if (cleaned.length <= 2) {
    return cleaned
  }
  
  if (cleaned.length <= 5) {
    return `${cleaned.slice(0, 2)}.${cleaned.slice(2)}`
  }
  
  if (cleaned.length <= 8) {
    return `${cleaned.slice(0, 2)}.${cleaned.slice(2, 5)}.${cleaned.slice(5)}`
  }
  
  if (cleaned.length <= 12) {
    return `${cleaned.slice(0, 2)}.${cleaned.slice(2, 5)}.${cleaned.slice(5, 8)}/${cleaned.slice(8)}`
  }
  
  return `${cleaned.slice(0, 2)}.${cleaned.slice(2, 5)}.${cleaned.slice(5, 8)}/${cleaned.slice(8, 12)}-${cleaned.slice(12, 14)}`
}

/**
 * Máscara de telefone brasileiro para input
 * @param value - Valor digitado
 * @returns Valor com máscara aplicada
 */
export function maskPhone(value: string): string {
  const cleaned = value.replace(/\D/g, '')
  
  if (cleaned.length <= 2) {
    return cleaned
  }
  
  if (cleaned.length <= 6) {
    return `(${cleaned.slice(0, 2)}) ${cleaned.slice(2)}`
  }
  
  if (cleaned.length <= 10) {
    return `(${cleaned.slice(0, 2)}) ${cleaned.slice(2, 6)}-${cleaned.slice(6)}`
  }
  
  return `(${cleaned.slice(0, 2)}) ${cleaned.slice(2, 7)}-${cleaned.slice(7, 11)}`
}

/**
 * Remover formatação de documento
 * @param document - Documento formatado
 * @returns Apenas números
 */
export function unformatDocument(document: string): string {
  return document.replace(/\D/g, '')
}
