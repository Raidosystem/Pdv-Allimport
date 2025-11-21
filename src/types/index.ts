// Tipos base para o sistema PDV

export interface User {
  id: string
  email: string
  name: string
  role: 'admin' | 'operator' | 'manager'
  createdAt: string
  updatedAt: string
}

export interface Customer {
  id: string
  name: string
  email?: string
  phone?: string
  document?: string
  address?: Address
  createdAt: string
  updatedAt: string
}

export interface Address {
  street: string
  number: string
  complement?: string
  neighborhood: string
  city: string
  state: string
  zipCode: string
}

export interface Product {
  id: string
  name: string
  description?: string
  price: number
  cost?: number
  barcode?: string
  codigo_interno?: string
  category?: ProductCategory
  stock: number
  minStock?: number
  unit: 'un' | 'kg' | 'mt' | 'lt'
  active: boolean
  createdAt: string
  updatedAt: string
}

export interface ProductCategory {
  id: string
  name: string
  description?: string
  color?: string
}

export interface SaleItem {
  id: string
  productId: string
  product: Product
  quantity: number
  unitPrice: number
  discount: number
  total: number
}

export interface Sale {
  id: string
  customerId?: string
  customer?: Customer
  items: SaleItem[]
  subtotal: number
  discount: number
  total: number
  paymentMethod: PaymentMethod
  status: 'pending' | 'completed' | 'cancelled'
  userId: string
  user: User
  cashierId: string
  notes?: string
  createdAt: string
  updatedAt: string
}

export interface PaymentMethod {
  type: 'cash' | 'card' | 'pix' | 'check' | 'credit'
  amount: number
  installments?: number
  details?: Record<string, string | number | boolean>
}

export interface Cashier {
  id: string
  name: string
  openedAt: string
  closedAt?: string
  initialAmount: number
  finalAmount?: number
  totalSales?: number
  totalCash?: number
  totalCard?: number
  status: 'open' | 'closed'
  userId: string
  user: User
}

export interface ServiceOrder {
  id: string
  customerId: string
  customer: Customer
  equipment: string
  brand?: string
  model?: string
  defect: string
  observation?: string
  status: 'received' | 'analyzing' | 'waiting_parts' | 'repairing' | 'ready' | 'delivered'
  estimatedValue?: number
  finalValue?: number
  estimatedDate?: string
  deliveryDate?: string
  userId: string
  user: User
  createdAt: string
  updatedAt: string
}

export interface Report {
  id: string
  type: 'sales' | 'financial' | 'inventory' | 'customers'
  period: {
    start: string
    end: string
  }
  data: Record<string, unknown>
  generatedBy: string
  createdAt: string
}

// Tipos para formulários
export interface LoginForm {
  email: string
  password: string
}

export interface CustomerForm {
  name: string
  email?: string
  phone?: string
  document?: string
  address?: Partial<Address>
}

export interface ProductForm {
  name: string
  description?: string
  price: number
  cost?: number
  barcode?: string
  categoryId?: string
  stock: number
  minStock?: number
  unit: Product['unit']
  active: boolean
}

export interface SaleForm {
  customerId?: string
  items: Omit<SaleItem, 'id' | 'total'>[]
  discount: number
  paymentMethod: PaymentMethod
  notes?: string
}

// Tipos para API responses
export interface ApiResponse<T> {
  data: T
  message?: string
  error?: string
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  limit: number
  totalPages: number
}

// Tipos para configurações
export interface AppConfig {
  storeName: string
  storeDocument: string
  storeAddress: Address
  storeLogo?: string
  theme: {
    primaryColor: string
    secondaryColor: string
  }
  printer: {
    type: 'thermal' | 'inkjet' | 'laser'
    paperSize: '58mm' | '80mm' | 'A4'
  }
  features: {
    whatsapp: boolean
    nfe: boolean
    inventory: boolean
    serviceOrders: boolean
  }
}
