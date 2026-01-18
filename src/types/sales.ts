/**
 * NOTA: Esta interface Product difere de types/product.ts propositalmente:
 * - Esta (sales.ts): Formato para vendas (campos em inglês, usado no carrinho)
 * - product.ts: Formato do banco Supabase (campos em português)
 * 
 * Use adaptProductForSales() se precisar converter entre os formatos
 */
export interface Product {
  id: string
  name: string
  description?: string
  sku?: string
  barcode?: string
  category_id?: string
  price: number
  cost?: number
  stock_quantity: number
  min_stock: number
  unit: string
  active: boolean
  image_url?: string
  categories?: {
    id: string
    name: string
  }
  created_at: string
  updated_at: string
}

export interface Customer {
  id: string
  name: string
  email?: string
  phone?: string
  document?: string
  address?: {
    street?: string
    number?: string
    city?: string
    state?: string
    zip_code?: string
  }
  active: boolean
  created_at: string
  updated_at: string
}

export interface CashRegister {
  id: string
  user_id: string
  data_abertura: string
  data_fechamento?: string
  saldo_inicial: number
  saldo_final?: number
  status: 'aberto' | 'fechado'
  observacoes?: string
  created_at: string
  updated_at: string
}

export interface Sale {
  id: string
  customer_id?: string
  cash_register_id: string
  user_id: string
  total_amount: number
  discount_amount: number
  payment_method: 'cash' | 'card' | 'pix' | 'mixed'
  payment_details?: Record<string, string | number | boolean>
  status: 'pending' | 'completed' | 'cancelled'
  notes?: string
  created_at: string
  updated_at: string
  customer?: Customer
  sale_items?: SaleItem[]
}

export interface SaleItem {
  id: string
  sale_id: string
  product_id: string
  quantity: number
  unit_price: number
  total_price: number
  product?: Product
  created_at: string
}

export interface CartItem {
  product: Product
  quantity: number
  unit_price: number
  total_price: number
}

export interface PaymentDetails {
  method: 'cash' | 'pix' | 'credit' | 'debit' | 'other'
  amount: number
  installments?: number
  card_last_digits?: string
  transaction_id?: string
}

export interface SaleForm {
  customer_id?: string
  items: CartItem[]
  subtotal: number
  discount_type: 'percentage' | 'fixed'
  discount_value: number
  discount_amount: number
  total_amount: number
  payments: PaymentDetails[]
  cash_received?: number
  change_amount?: number
  notes?: string
}

export interface SaleSearchParams {
  search?: string
  barcode?: string
  category_id?: string
}
