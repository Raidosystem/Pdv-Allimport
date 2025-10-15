/**
 * Serviço de busca de CEP utilizando API ViaCEP
 * https://viacep.com.br/
 */

export interface AddressData {
  cep: string
  logradouro: string
  complemento: string
  bairro: string
  cidade: string
  estado: string
  uf: string
}

export interface CepResponse {
  success: boolean
  data?: AddressData
  error?: string
}

/**
 * Limpa a formatação do CEP (remove hífens e espaços)
 */
export function cleanCep(cep: string): string {
  return cep.replace(/\D/g, '')
}

/**
 * Formata o CEP no padrão 00000-000
 */
export function formatCep(cep: string): string {
  const cleaned = cleanCep(cep)
  if (cleaned.length !== 8) return cep
  return `${cleaned.slice(0, 5)}-${cleaned.slice(5)}`
}

/**
 * Valida se o CEP tem formato válido (8 dígitos)
 */
export function isValidCep(cep: string): boolean {
  const cleaned = cleanCep(cep)
  return cleaned.length === 8 && /^\d{8}$/.test(cleaned)
}

/**
 * Busca endereço completo através do CEP usando a API ViaCEP
 * @param cep CEP a ser consultado (com ou sem formatação)
 * @returns Dados do endereço ou erro
 */
export async function fetchAddressByCep(cep: string): Promise<CepResponse> {
  try {
    const cleanedCep = cleanCep(cep)
    
    // Validar formato do CEP
    if (!isValidCep(cleanedCep)) {
      return {
        success: false,
        error: 'CEP inválido. Use o formato 00000-000'
      }
    }

    // Fazer requisição para a API ViaCEP
    const response = await fetch(`https://viacep.com.br/ws/${cleanedCep}/json/`)
    
    if (!response.ok) {
      return {
        success: false,
        error: 'Erro ao consultar CEP. Tente novamente.'
      }
    }

    const data = await response.json()

    // Verificar se o CEP foi encontrado
    if (data.erro) {
      return {
        success: false,
        error: 'CEP não encontrado'
      }
    }

    // Retornar dados formatados
    return {
      success: true,
      data: {
        cep: formatCep(data.cep),
        logradouro: data.logradouro || '',
        complemento: data.complemento || '',
        bairro: data.bairro || '',
        cidade: data.localidade || '',
        estado: data.localidade ? `${data.localidade} - ${data.uf}` : '',
        uf: data.uf || ''
      }
    }
  } catch (error) {
    console.error('Erro ao buscar CEP:', error)
    return {
      success: false,
      error: 'Erro ao consultar CEP. Verifique sua conexão.'
    }
  }
}
