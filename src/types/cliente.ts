export interface Cliente {
  id: string
  nome: string
  telefone: string
  cpf_cnpj?: string
  cpf_digits?: string       // Nova coluna para CPF apenas dígitos
  email?: string
  endereco?: string
  // Campos específicos de endereço
  rua?: string              // Rua/Avenida
  numero?: string           // Número do imóvel
  cidade?: string           // Cidade
  estado?: string           // Estado (UF)
  cep?: string              // CEP
  tipo: 'fisica' | 'juridica'
  observacoes?: string
  ativo: boolean
  criado_em: string
  atualizado_em: string
}

export interface ClienteInput {
  nome: string
  telefone: string
  cpf_cnpj?: string
  cpf_digits?: string       // Nova coluna para CPF apenas dígitos
  email?: string
  endereco?: string
  // Campos específicos de endereço
  rua?: string              // Rua/Avenida
  numero?: string           // Número do imóvel
  cidade?: string           // Cidade
  estado?: string           // Estado (UF)
  cep?: string              // CEP
  tipo: 'fisica' | 'juridica'
  observacoes?: string
  ativo: boolean
}

export interface ClienteFilters {
  search?: string
  searchType?: 'geral' | 'telefone' // Tipo de busca específica
  ativo?: boolean | null
  tipo?: 'fisica' | 'juridica' | null
  limit?: number
}
