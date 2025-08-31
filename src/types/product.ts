export interface Product {
  id?: string
  nome: string
  codigo?: string
  codigo_barras?: string
  categoria?: string
  categoria_id?: string
  preco: number
  preco_custo?: number
  estoque: number
  unidade: string
  descricao?: string
  imagem_url?: string
  fornecedor?: string
  ativo: boolean
  created_at?: string
  updated_at?: string
  atualizado_em?: string
  user_id?: string
  sku?: string
  estoque_minimo?: number
}

export interface ProductFormData {
  nome: string
  codigo: string
  codigo_barras?: string
  categoria: string
  preco_venda: number
  preco_custo?: number
  estoque: number
  unidade: string
  descricao?: string
  fornecedor?: string
  ativo: boolean
  imagem?: File
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
