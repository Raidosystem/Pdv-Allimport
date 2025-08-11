import { supabase } from '../lib/supabase'
import type { Product, Customer, Sale, CashRegister, SaleSearchParams } from '../types/sales'

// Serviços de Produtos
export const productService = {
  async search(params: SaleSearchParams): Promise<Product[]> {
    try {
      let query = supabase
        .from('products')
        .select(`
          *,
          categories (
            id,
            name
          )
        `)
        .eq('active', true)

      if (params.search) {
        query = query.or(`name.ilike.%${params.search}%,sku.ilike.%${params.search}%`)
      }

      if (params.barcode) {
        query = query.eq('barcode', params.barcode)
      }

      if (params.category_id) {
        query = query.eq('category_id', params.category_id)
      }

      const { data, error } = await query.order('name').limit(20)

      if (error) throw error
      return data || []
    } catch (error) {
      console.warn('Erro ao conectar com Supabase, usando produtos simulados:', error)
      
      // Fallback: produtos simulados para teste
      const mockProducts: Product[] = [
        {
          id: '1',
          name: 'Produto Teste 1',
          description: 'Produto para teste do sistema',
          sku: 'TEST001',
          barcode: '123456789',
          price: 10.50,
          stock_quantity: 100,
          min_stock: 10,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        },
        {
          id: '2',
          name: 'Produto Teste 2',
          description: 'Outro produto para teste',
          sku: 'TEST002',
          barcode: '987654321',
          price: 25.99,
          stock_quantity: 50,
          min_stock: 5,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }
      ]

      if (params.search) {
        return mockProducts.filter(p => 
          p.name.toLowerCase().includes(params.search!.toLowerCase()) ||
          p.sku?.toLowerCase().includes(params.search!.toLowerCase())
        )
      }

      if (params.barcode) {
        return mockProducts.filter(p => p.barcode === params.barcode)
      }

      return mockProducts
    }
  },

  async getById(id: string): Promise<Product | null> {
    try {
      const { data, error } = await supabase
        .from('products')
        .select(`
          *,
          categories (
            id,
            name
          )
        `)
        .eq('id', id)
        .eq('active', true)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.warn('Erro ao conectar com Supabase, usando produto simulado:', error)
      
      // Fallback: produto simulado
      const mockProducts: Product[] = [
        {
          id: '1',
          name: 'Produto Teste 1',
          description: 'Produto para teste do sistema',
          sku: 'TEST001',
          barcode: '123456789',
          price: 10.50,
          stock_quantity: 100,
          min_stock: 10,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        },
        {
          id: '2',
          name: 'Produto Teste 2',
          description: 'Outro produto para teste',
          sku: 'TEST002',
          barcode: '987654321',
          price: 25.99,
          stock_quantity: 50,
          min_stock: 5,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }
      ]

      return mockProducts.find(p => p.id === id) || null
    }
  },

  async updateStock(productId: string, newQuantity: number): Promise<void> {
    const { error } = await supabase
      .from('products')
      .update({ stock_quantity: newQuantity })
      .eq('id', productId)

    if (error) throw error
  }
}

// Serviços de Clientes
export const customerService = {
  async search(query: string): Promise<Customer[]> {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .eq('active', true)
      .or(`name.ilike.%${query}%,email.ilike.%${query}%,phone.ilike.%${query}%,document.ilike.%${query}%`)
      .order('name')
      .limit(10)

    if (error) throw error
    return data || []
  },

  async getById(id: string): Promise<Customer | null> {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .eq('id', id)
      .eq('active', true)
      .single()

    if (error) throw error
    return data
  },

  async create(customer: Omit<Customer, 'id' | 'created_at' | 'updated_at'>): Promise<Customer> {
    const { data, error } = await supabase
      .from('customers')
      .insert(customer)
      .select()
      .single()

    if (error) throw error
    return data
  }
}

// Serviços de Caixa
export const cashRegisterService = {
  async getOpenRegister(): Promise<CashRegister | null> {
    try {
      const { data, error } = await supabase
        .from('cash_registers')
        .select('*')
        .eq('status', 'open')
        .single()

      if (error && error.code !== 'PGRST116') throw error
      return data || null
    } catch (error) {
      console.warn('Erro ao conectar com Supabase, verificando dados simulados:', error)
      
      // Fallback: verificar localStorage
      const mockCashRegister = localStorage.getItem('mock-cash-register')
      if (mockCashRegister) {
        try {
          const cashRegister = JSON.parse(mockCashRegister)
          if (cashRegister.status === 'open') {
            return cashRegister
          }
        } catch (parseError) {
          console.error('Erro ao fazer parse do mock cash register:', parseError)
        }
      }
      
      return null
    }
  },

  async openRegister(openingAmount: number, userId: string): Promise<CashRegister> {
    try {
      const { data, error } = await supabase
        .from('cash_registers')
        .insert({
          opened_by: userId,
          opening_amount: openingAmount,
          status: 'open'
        })
        .select()
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.warn('Erro ao conectar com Supabase, usando dados simulados:', error)
      
      // Fallback: retornar dados simulados
      const mockCashRegister: CashRegister = {
        id: `mock-cash-register-${Date.now()}`,
        opened_by: userId,
        opening_amount: openingAmount,
        total_sales: 0,
        status: 'open',
        opened_at: new Date().toISOString(),
        closed_at: undefined,
        closed_by: undefined,
        closing_amount: undefined
      }
      
      // Salvar no localStorage para persistir
      localStorage.setItem('mock-cash-register', JSON.stringify(mockCashRegister))
      
      return mockCashRegister
    }
  },

  async closeRegister(registerId: string, closingAmount: number, userId: string): Promise<void> {
    const { error } = await supabase
      .from('cash_registers')
      .update({
        closed_by: userId,
        closing_amount: closingAmount,
        closed_at: new Date().toISOString(),
        status: 'closed'
      })
      .eq('id', registerId)

    if (error) throw error
  }
}

// Serviços de Vendas
export const salesService = {
  async create(sale: {
    customer_id?: string
    cash_register_id: string
    user_id: string
    total_amount: number
    discount_amount: number
    payment_method: string
    payment_details?: any
    notes?: string
    items: Array<{
      product_id: string
      quantity: number
      unit_price: number
      total_price: number
    }>
  }): Promise<Sale> {
    try {
      // Tentar inserir no Supabase
      const { data: saleData, error: saleError } = await supabase
        .from('sales')
        .insert({
          customer_id: sale.customer_id,
          cash_register_id: sale.cash_register_id,
          user_id: sale.user_id,
          total_amount: sale.total_amount,
          discount_amount: sale.discount_amount,
          payment_method: sale.payment_method,
          payment_details: sale.payment_details,
          notes: sale.notes,
          status: 'completed'
        })
        .select()
        .single()

      if (saleError) throw saleError

      // Inserir itens da venda
      const saleItems = sale.items.map(item => ({
        sale_id: saleData.id,
        product_id: item.product_id,
        quantity: item.quantity,
        unit_price: item.unit_price,
        total_price: item.total_price
      }))

      const { error: itemsError } = await supabase
        .from('sale_items')
        .insert(saleItems)

      if (itemsError) throw itemsError

      // Atualizar total de vendas no caixa
      const { error: updateCashError } = await supabase.rpc('update_cash_register_sales', {
        register_id: sale.cash_register_id,
        sale_amount: sale.total_amount
      })

      if (updateCashError) {
        console.warn('Erro ao atualizar total do caixa:', updateCashError)
      }

      return saleData
    } catch (error) {
      console.warn('Erro ao salvar venda no Supabase, simulando venda local:', error)
      
      // Fallback: simular venda local para teste
      const mockSale: Sale = {
        id: `sale_${Date.now()}`,
        customer_id: sale.customer_id,
        cash_register_id: sale.cash_register_id,
        user_id: sale.user_id,
        total_amount: sale.total_amount,
        discount_amount: sale.discount_amount,
        payment_method: sale.payment_method as 'cash' | 'card' | 'pix' | 'mixed',
        payment_details: sale.payment_details,
        notes: sale.notes || '',
        status: 'completed',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        sale_items: sale.items.map((item, index) => ({
          id: `item_${index}`,
          sale_id: `sale_${Date.now()}`,
          product_id: item.product_id,
          quantity: item.quantity,
          unit_price: item.unit_price,
          total_price: item.total_price,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }))
      }

      // Salvar no localStorage como backup
      const existingSales = JSON.parse(localStorage.getItem('offline_sales') || '[]')
      existingSales.push(mockSale)
      localStorage.setItem('offline_sales', JSON.stringify(existingSales))

      return mockSale
    }
  },

  async getById(id: string): Promise<Sale | null> {
    const { data, error } = await supabase
      .from('sales')
      .select(`
        *,
        customer:customers(*),
        sale_items(
          *,
          product:products(*)
        )
      `)
      .eq('id', id)
      .single()

    if (error) throw error
    return data
  },

  async getTodaySales(): Promise<Sale[]> {
    const today = new Date().toISOString().split('T')[0]
    
    const { data, error } = await supabase
      .from('sales')
      .select(`
        *,
        customer:customers(*),
        sale_items(
          *,
          product:products(*)
        )
      `)
      .gte('created_at', `${today}T00:00:00.000Z`)
      .lte('created_at', `${today}T23:59:59.999Z`)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data || []
  }
}

// Serviços de Categorias
export const categoryService = {
  async getAll() {
    const { data, error } = await supabase
      .from('categories')
      .select('*')
      .eq('active', true)
      .order('name')

    if (error) throw error
    return data || []
  }
}
