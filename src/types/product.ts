export interface Product {
  id?: string
  nome: string
  codigo: string
  codigo_barras?: string
  codigo_interno?: string  // Código interno sequencial automático
  categoria: string
  preco_venda: number
  preco_custo?: number
  estoque: number
  unidade: string
  descricao?: string
  imagem_url?: string
  image_url?: string  // URL da imagem (nome da coluna no banco)
  fornecedor?: string
  ativo: boolean
  exibir_loja_online?: boolean  // Controle de exibição na loja online
  criado_em?: string
  atualizado_em?: string
}

export interface ProductFormData {
  nome: string
  codigo: string
  codigo_barras?: string
  categoria_id: string
  preco_venda: number
  preco_custo?: number
  estoque: number
  unidade: string
  descricao?: string
  fornecedor?: string
  ativo: boolean
  exibir_loja_online: boolean  // Controle de exibição na loja online
  imagem?: File
  image_url?: string | null  // URL da imagem já salva
}

export interface Category {
  id: string
  name: string
  created_at?: string
}

export const UNIDADES_MEDIDA = [
  { value: 'UN', label: 'Unidade' },
  { value: 'KG', label: 'Quilograma' },
  { value: 'G', label: 'Grama' },
  { value: 'L', label: 'Litro' },
  { value: 'ML', label: 'Mililitro' },
  { value: 'CX', label: 'Caixa' },
  { value: 'PCT', label: 'Pacote' },
  { value: 'M', label: 'Metro' },
  { value: 'CM', label: 'Centímetro' },
  { value: 'PC', label: 'Peça' }
] as const
