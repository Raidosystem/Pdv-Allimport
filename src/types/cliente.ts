export interface Cliente {
  id: string
  nome: string
  telefone: string
  cpf_cnpj?: string
  email?: string
  endereco?: string
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
  tipo: 'Física' | 'Jurídica'
  observacoes?: string
  ativo: boolean
}

export interface ClienteFilters {
  search?: string
  ativo?: boolean | null
  tipo?: 'Física' | 'Jurídica' | null
}
