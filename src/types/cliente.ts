export interface Cliente {
  id: string
  nome: string
  telefone: string
  cpf_cnpj?: string
  email?: string
  endereco?: string
  // Campos específicos de endereço
  tipo_logradouro?: string  // Rua, Avenida, Travessa, etc.
  logradouro?: string       // Nome da rua/avenida
  numero?: string           // Número do imóvel
  complemento?: string      // Apartamento, bloco, etc.
  bairro?: string           // Bairro/distrito
  cidade?: string           // Cidade
  estado?: string           // Estado (UF)
  cep?: string              // CEP
  ponto_referencia?: string // Ponto de referência
  tipo: 'Física' | 'Jurídica'
  observacoes?: string
  ativo: boolean
  criado_em: string
  atualizado_em: string
}

export interface ClienteInput {
  nome: string
  telefone: string
  cpf_cnpj?: string
  email?: string
  endereco?: string
  // Campos específicos de endereço
  tipo_logradouro?: string  // Rua, Avenida, Travessa, etc.
  logradouro?: string       // Nome da rua/avenida
  numero?: string           // Número do imóvel
  complemento?: string      // Apartamento, bloco, etc.
  bairro?: string           // Bairro/distrito
  cidade?: string           // Cidade
  estado?: string           // Estado (UF)
  cep?: string              // CEP
  ponto_referencia?: string // Ponto de referência
  tipo: 'Física' | 'Jurídica'
  observacoes?: string
  ativo: boolean
}

export interface ClienteFilters {
  search?: string
  ativo?: boolean | null
  tipo?: 'Física' | 'Jurídica' | null
}
