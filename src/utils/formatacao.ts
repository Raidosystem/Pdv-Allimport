// Formatação de telefone
export const formatarTelefone = (valor: string): string => {
  const apenasNumeros = valor.replace(/\D/g, '')
  
  if (apenasNumeros.length <= 2) {
    return `(${apenasNumeros}`
  } else if (apenasNumeros.length <= 7) {
    return `(${apenasNumeros.slice(0, 2)}) ${apenasNumeros.slice(2)}`
  } else if (apenasNumeros.length <= 11) {
    return `(${apenasNumeros.slice(0, 2)}) ${apenasNumeros.slice(2, 7)}-${apenasNumeros.slice(7)}`
  } else {
    return `(${apenasNumeros.slice(0, 2)}) ${apenasNumeros.slice(2, 7)}-${apenasNumeros.slice(7, 11)}`
  }
}

// Formatação de CPF
export const formatarCPF = (valor: string): string => {
  const apenasNumeros = valor.replace(/\D/g, '')
  
  if (apenasNumeros.length <= 3) {
    return apenasNumeros
  } else if (apenasNumeros.length <= 6) {
    return `${apenasNumeros.slice(0, 3)}.${apenasNumeros.slice(3)}`
  } else if (apenasNumeros.length <= 9) {
    return `${apenasNumeros.slice(0, 3)}.${apenasNumeros.slice(3, 6)}.${apenasNumeros.slice(6)}`
  } else {
    return `${apenasNumeros.slice(0, 3)}.${apenasNumeros.slice(3, 6)}.${apenasNumeros.slice(6, 9)}-${apenasNumeros.slice(9, 11)}`
  }
}

// Formatação de CNPJ
export const formatarCNPJ = (valor: string): string => {
  const apenasNumeros = valor.replace(/\D/g, '')
  
  if (apenasNumeros.length <= 2) {
    return apenasNumeros
  } else if (apenasNumeros.length <= 5) {
    return `${apenasNumeros.slice(0, 2)}.${apenasNumeros.slice(2)}`
  } else if (apenasNumeros.length <= 8) {
    return `${apenasNumeros.slice(0, 2)}.${apenasNumeros.slice(2, 5)}.${apenasNumeros.slice(5)}`
  } else if (apenasNumeros.length <= 12) {
    return `${apenasNumeros.slice(0, 2)}.${apenasNumeros.slice(2, 5)}.${apenasNumeros.slice(5, 8)}/${apenasNumeros.slice(8)}`
  } else {
    return `${apenasNumeros.slice(0, 2)}.${apenasNumeros.slice(2, 5)}.${apenasNumeros.slice(5, 8)}/${apenasNumeros.slice(8, 12)}-${apenasNumeros.slice(12, 14)}`
  }
}

// Formatação automática de CPF ou CNPJ
export const formatarCpfCnpj = (valor: string): string => {
  const apenasNumeros = valor.replace(/\D/g, '')
  
  if (apenasNumeros.length <= 11) {
    return formatarCPF(valor)
  } else {
    return formatarCNPJ(valor)
  }
}

// Validação de CPF
export const validarCPF = (cpf: string): boolean => {
  const apenasNumeros = cpf.replace(/\D/g, '')
  
  if (apenasNumeros.length !== 11) return false
  if (/^(\d)\1{10}$/.test(apenasNumeros)) return false
  
  let soma = 0
  for (let i = 0; i < 9; i++) {
    soma += parseInt(apenasNumeros[i]) * (10 - i)
  }
  let resto = 11 - (soma % 11)
  if (resto === 10 || resto === 11) resto = 0
  if (resto !== parseInt(apenasNumeros[9])) return false
  
  soma = 0
  for (let i = 0; i < 10; i++) {
    soma += parseInt(apenasNumeros[i]) * (11 - i)
  }
  resto = 11 - (soma % 11)
  if (resto === 10 || resto === 11) resto = 0
  
  return resto === parseInt(apenasNumeros[10])
}

// Validação de CNPJ
export const validarCNPJ = (cnpj: string): boolean => {
  const apenasNumeros = cnpj.replace(/\D/g, '')
  
  if (apenasNumeros.length !== 14) return false
  if (/^(\d)\1{13}$/.test(apenasNumeros)) return false
  
  const calcularDigito = (numeros: string, multiplicadores: number[]): number => {
    let soma = 0
    for (let i = 0; i < multiplicadores.length; i++) {
      soma += parseInt(numeros[i]) * multiplicadores[i]
    }
    const resto = soma % 11
    return resto < 2 ? 0 : 11 - resto
  }
  
  const primeiroDigito = calcularDigito(apenasNumeros, [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2])
  const segundoDigito = calcularDigito(apenasNumeros, [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2])
  
  return parseInt(apenasNumeros[12]) === primeiroDigito && parseInt(apenasNumeros[13]) === segundoDigito
}

// Validação de CPF ou CNPJ
export const validarCpfCnpj = (valor: string): boolean => {
  const apenasNumeros = valor.replace(/\D/g, '')
  
  if (apenasNumeros.length === 11) {
    return validarCPF(valor)
  } else if (apenasNumeros.length === 14) {
    return validarCNPJ(valor)
  }
  
  return false
}

// Detectar tipo do documento
export const detectarTipoDocumento = (valor: string): 'CPF' | 'CNPJ' | null => {
  const apenasNumeros = valor.replace(/\D/g, '')
  
  if (apenasNumeros.length === 11) return 'CPF'
  if (apenasNumeros.length === 14) return 'CNPJ'
  return null
}

// Limpar formatação
export const limparFormatacao = (valor: string): string => {
  return valor.replace(/\D/g, '')
}
