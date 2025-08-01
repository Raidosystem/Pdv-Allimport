/**
 * Formatar valor como moeda brasileira
 */
export function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(value)
}

/**
 * Formatar número como percentual
 */
export function formatPercentage(value: number): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'percent',
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  }).format(value / 100)
}

/**
 * Formatar CPF
 */
export function formatCPF(cpf: string): string {
  const cleaned = cpf.replace(/\D/g, '')
  const match = cleaned.match(/^(\d{3})(\d{3})(\d{3})(\d{2})$/)
  
  if (match) {
    return `${match[1]}.${match[2]}.${match[3]}-${match[4]}`
  }
  
  return cpf
}

/**
 * Formatar CNPJ
 */
export function formatCNPJ(cnpj: string): string {
  const cleaned = cnpj.replace(/\D/g, '')
  const match = cleaned.match(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/)
  
  if (match) {
    return `${match[1]}.${match[2]}.${match[3]}/${match[4]}-${match[5]}`
  }
  
  return cnpj
}

/**
 * Formatar telefone
 */
export function formatPhone(phone: string): string {
  const cleaned = phone.replace(/\D/g, '')
  
  if (cleaned.length === 11) {
    const match = cleaned.match(/^(\d{2})(\d{5})(\d{4})$/)
    if (match) {
      return `(${match[1]}) ${match[2]}-${match[3]}`
    }
  } else if (cleaned.length === 10) {
    const match = cleaned.match(/^(\d{2})(\d{4})(\d{4})$/)
    if (match) {
      return `(${match[1]}) ${match[2]}-${match[3]}`
    }
  }
  
  return phone
}

/**
 * Formatar CEP
 */
export function formatZipCode(zipCode: string): string {
  const cleaned = zipCode.replace(/\D/g, '')
  const match = cleaned.match(/^(\d{5})(\d{3})$/)
  
  if (match) {
    return `${match[1]}-${match[2]}`
  }
  
  return zipCode
}

/**
 * Parse valor de moeda para número
 */
export function parseCurrency(value: string): number {
  const cleaned = value.replace(/[^\d,]/g, '').replace(',', '.')
  return parseFloat(cleaned) || 0
}

/**
 * Validar CPF
 */
export function isValidCPF(cpf: string): boolean {
  const cleaned = cpf.replace(/\D/g, '')
  
  if (cleaned.length !== 11 || /^(\d)\1{10}$/.test(cleaned)) {
    return false
  }
  
  let sum = 0
  for (let i = 0; i < 9; i++) {
    sum += parseInt(cleaned.charAt(i)) * (10 - i)
  }
  
  let checkDigit = 11 - (sum % 11)
  if (checkDigit === 10 || checkDigit === 11) {
    checkDigit = 0
  }
  
  if (checkDigit !== parseInt(cleaned.charAt(9))) {
    return false
  }
  
  sum = 0
  for (let i = 0; i < 10; i++) {
    sum += parseInt(cleaned.charAt(i)) * (11 - i)
  }
  
  checkDigit = 11 - (sum % 11)
  if (checkDigit === 10 || checkDigit === 11) {
    checkDigit = 0
  }
  
  return checkDigit === parseInt(cleaned.charAt(10))
}

/**
 * Validar CNPJ
 */
export function isValidCNPJ(cnpj: string): boolean {
  const cleaned = cnpj.replace(/\D/g, '')
  
  if (cleaned.length !== 14 || /^(\d)\1{13}$/.test(cleaned)) {
    return false
  }
  
  const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  
  let sum = 0
  for (let i = 0; i < 12; i++) {
    sum += parseInt(cleaned.charAt(i)) * weights1[i]
  }
  
  let checkDigit = sum % 11 < 2 ? 0 : 11 - (sum % 11)
  if (checkDigit !== parseInt(cleaned.charAt(12))) {
    return false
  }
  
  sum = 0
  for (let i = 0; i < 13; i++) {
    sum += parseInt(cleaned.charAt(i)) * weights2[i]
  }
  
  checkDigit = sum % 11 < 2 ? 0 : 11 - (sum % 11)
  return checkDigit === parseInt(cleaned.charAt(13))
}
