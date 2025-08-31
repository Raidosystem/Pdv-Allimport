import { supabase } from '../lib/supabase'
import type { Product, Customer, Sale, CashRegister, SaleSearchParams } from '../types/sales'
import { searchEmbeddedProducts } from '../data/products'

// UUID do usuário assistenciaallimport10@gmail.com para isolamento multi-tenant (atualizado)
const USER_ID_ASSISTENCIA = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

// Serviços de Produtos
export const productService = {
  async search(params: SaleSearchParams): Promise<Product[]> {
    console.log('🔍 ProductService.search chamado com:', params);
    
    try {
      // Buscar do Supabase primeiro
      console.log('📡 Buscando produtos do Supabase...');
      
      let query = supabase
        .from('produtos')
        .select(`
          id,
          nome,
          descricao,
          sku,
          codigo_barras,
          preco,
          estoque_atual,
          estoque_minimo,
          unidade,
          criado_em,
          atualizado_em
        `)
        .eq('user_id', USER_ID_ASSISTENCIA); // FILTRO POR USUÁRIO

      // Aplicar filtros de busca
      if (params.search) {
        query = query.or(`nome.ilike.%${params.search}%,codigo_barras.ilike.%${params.search}%`);
      }

      if (params.barcode) {
        query = query.eq('codigo_barras', params.barcode);
      }

      const { data, error } = await query.order('nome').limit(50);

      if (!error && data) {
        console.log(`✅ Encontrados ${data.length} produtos no Supabase`);
        
        // Adapta formato do Supabase para o frontend
        const adaptedProducts: Product[] = data.map(item => ({
          id: item.id,
          name: item.nome,
          description: item.descricao || item.nome,
          sku: item.sku || '',
          barcode: item.codigo_barras || '',
          price: item.preco || 0,
          stock_quantity: item.estoque_atual || 0,
          min_stock: item.estoque_minimo || 1,
          unit: item.unidade || 'un',
          active: true,
          created_at: item.criado_em,
          updated_at: item.atualizado_em
        }));

        return adaptedProducts;
      } else {
        console.warn('⚠️ Erro ao buscar no Supabase:', error?.message);
      }
    } catch (error) {
      console.warn('⚠️ Erro de conexão com Supabase:', error);
    }

    // Fallback apenas se Supabase falhar
    console.log('🔄 Usando produtos embutidos como fallback');
    const embeddedResults = searchEmbeddedProducts(params.search);
    
    const adaptedProducts: Product[] = embeddedResults.map(product => ({
      id: product.id,
      name: product.name,
      description: `${product.category} - ${product.name}`,
      sku: product.sku,
      barcode: product.barcode,
      price: product.price,
      stock_quantity: product.stock,
      min_stock: 1,
      unit: 'un',
      active: product.active,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }));

    return adaptedProducts;
  },

  async getAll(params?: SaleSearchParams): Promise<Product[]> {
    console.log('🔍 ProductService.getAll chamado com:', params);
    
    try {
      // Buscar todos os produtos do Supabase
      let query = supabase
        .from('produtos')
        .select(`
          id,
          nome,
          descricao,
          sku,
          codigo_barras,
          preco,
          estoque_atual,
          estoque_minimo,
          unidade,
          criado_em,
          atualizado_em
        `)
        .eq('user_id', USER_ID_ASSISTENCIA); // FILTRO POR USUÁRIO

      // Aplicar filtros se existirem
      if (params?.search) {
        query = query.or(`nome.ilike.%${params.search}%,codigo_barras.ilike.%${params.search}%`);
      }

      const { data, error } = await query.order('nome').limit(100);

      if (!error && data) {
        console.log(`✅ Encontrados ${data.length} produtos no Supabase (getAll)`);
        
        const adaptedProducts: Product[] = data.map(item => ({
          id: item.id,
          name: item.nome,
          description: item.descricao || item.nome,
          sku: item.sku || '',
          barcode: item.codigo_barras || '',
          price: item.preco || 0,
          stock_quantity: item.estoque_atual || 0,
          min_stock: item.estoque_minimo || 1,
          unit: item.unidade || 'un',
          active: true,
          created_at: item.criado_em,
          updated_at: item.atualizado_em
        }));
        
        return adaptedProducts;
      }
      
    } catch (error) {
      console.warn('⚠️ Erro ao conectar com Supabase, usando produtos simulados:', error);
    }

    // Fallback: produtos simulados mais realistas
    const mockProducts: Product[] = [
        {
          id: '1',
          name: 'Smartphone Samsung Galaxy',
          description: 'Smartphone Android com 128GB',
          sku: 'SAMSUNG001',
          barcode: '7891234567890',
          price: 899.99,
          stock_quantity: 25,
          min_stock: 5,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        },
        {
          id: '2', 
          name: 'Fone de Ouvido Bluetooth',
          description: 'Fone sem fio com cancelamento de ruído',
          sku: 'FONE001',
          barcode: '7891234567891',
          price: 199.99,
          stock_quantity: 50,
          min_stock: 10,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        },
        {
          id: '3',
          name: 'Carregador USB-C',
          description: 'Carregador rápido 20W',
          sku: 'CARREGADOR001',
          barcode: '7891234567892',
          price: 45.99,
          stock_quantity: 100,
          min_stock: 20,
          unit: 'un', 
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        },
        {
          id: '4',
          name: 'Capinha Transparente',
          description: 'Capinha de silicone transparente',
          sku: 'CAPINHA001', 
          barcode: '7891234567893',
          price: 29.99,
          stock_quantity: 75,
          min_stock: 15,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        },
        {
          id: '5',
          name: 'Película de Vidro',
          description: 'Película protetora temperada',
          sku: 'PELICULA001',
          barcode: '7891234567894',
          price: 19.99,
          stock_quantity: 60,
          min_stock: 12,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        },
        {
          id: '6',
          name: 'Cabo Lightning iPhone',
          description: 'Cabo USB para iPhone 1m',
          sku: 'CABO001',
          barcode: '7891234567895',
          price: 35.99,
          stock_quantity: 40,
          min_stock: 8,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }
      ];

    // Aplicar filtros nos produtos simulados
    let filtered = mockProducts;
    
    if (params?.search) {
      const searchLower = params.search.toLowerCase();
      filtered = filtered.filter(product => 
        (product.name && product.name.toLowerCase().includes(searchLower)) ||
        (product.description && product.description.toLowerCase().includes(searchLower)) ||
        (product.sku && product.sku.toLowerCase().includes(searchLower)) ||
        (product.barcode && params.search && product.barcode.includes(params.search))
      );
    }
    
    if (params?.barcode) {
      filtered = filtered.filter(product => product.barcode === params.barcode);
    }
    
    console.log('✅ Produtos simulados filtrados retornados:', filtered.length);
    return filtered;
  },

  async getById(id: string): Promise<Product | null> {
    try {
      const { data, error } = await supabase
        .from('produtos')
        .select(`
          id,
          nome,
          descricao,
          sku,
          codigo_barras,
          preco,
          estoque_atual,
          estoque_minimo,
          unidade,
          ativo,
          criado_em,
          atualizado_em,
          categorias (
            id,
            nome
          )
        `)
        .eq('id', id)
        .eq('user_id', USER_ID_ASSISTENCIA) // FILTRO POR USUÁRIO
        .eq('ativo', true)
        .single()

      if (error) throw error
      
      // Adaptar dados do banco
      return {
        id: data.id,
        name: data.nome,
        description: data.descricao,
        sku: data.sku,
        barcode: data.codigo_barras,
        price: data.preco,
        stock_quantity: data.estoque_atual,
        min_stock: data.estoque_minimo,
        unit: data.unidade,
        active: data.ativo,
        created_at: data.criado_em,
        updated_at: data.atualizado_em
      }
      
    } catch (error) {
      console.warn('Erro ao buscar produto por ID no Supabase, usando simulado:', error)
      
      // Fallback: produto simulado
      const mockProducts: Product[] = [
        {
          id: '1',
          name: 'Smartphone Samsung Galaxy',
          description: 'Smartphone Android com 128GB',
          sku: 'SAMSUNG001',
          barcode: '7891234567890',
          price: 899.99,
          stock_quantity: 25,
          min_stock: 5,
          unit: 'un',
          active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        },
        {
          id: '2',
          name: 'Fone de Ouvido Bluetooth',
          description: 'Fone sem fio com cancelamento de ruído',
          sku: 'FONE001',
          barcode: '7891234567891',
          price: 199.99,
          stock_quantity: 50,
          min_stock: 10,
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
      .from('produtos')
      .update({ estoque_atual: newQuantity })
      .eq('id', productId)
      .eq('user_id', USER_ID_ASSISTENCIA) // FILTRO POR USUÁRIO

    if (error) throw error
  }
}

// Serviços de Clientes
export const customerService = {
  // Adapter para converter dados do banco para frontend
  _adaptClienteToCustomer(cliente: any): Customer {
    return {
      id: cliente.id,
      name: cliente.nome,
      email: cliente.email,
      phone: cliente.telefone,
      document: cliente.cpf_cnpj,
      active: cliente.ativo,
      created_at: cliente.criado_em,
      updated_at: cliente.atualizado_em
    }
  },

  async search(query: string): Promise<Customer[]> {
    const { data, error } = await supabase
      .from('clientes')
      .select('*')
      .eq('ativo', true)
      .or(`nome.ilike.%${query}%,email.ilike.%${query}%,telefone.ilike.%${query}%,cpf_cnpj.ilike.%${query}%`)
      .order('nome')
      .limit(10)

    if (error) throw error
    return (data || []).map(this._adaptClienteToCustomer)
  },

  async getById(id: string): Promise<Customer | null> {
    const { data, error } = await supabase
      .from('clientes')
      .select('*')
      .eq('id', id)
      .eq('ativo', true)
      .single()

    if (error) throw error
    return data ? this._adaptClienteToCustomer(data) : null
  },

  async create(customer: Omit<Customer, 'id' | 'created_at' | 'updated_at'>): Promise<Customer> {
    const { data, error } = await supabase
      .from('clientes')
      .insert({
        nome: customer.name,
        email: customer.email,
        telefone: customer.phone,
        cpf_cnpj: customer.document,
        ativo: true
      })
      .select()
      .single()

    if (error) throw error
    return this._adaptClienteToCustomer(data)
  }
}

// Serviços de Caixa
export const cashRegisterService = {
  async getOpenRegister(): Promise<CashRegister | null> {
    try {
      const { data, error } = await supabase
        .from('caixa')
        .select('*')
        .eq('status', 'aberto')
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
        .from('caixa')
        .insert({
          user_id: userId,
          saldo_inicial: openingAmount,
          status: 'aberto'
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
        user_id: userId,
        saldo_inicial: openingAmount,
        saldo_final: 0,
        status: 'aberto',
        data_abertura: new Date().toISOString(),
        data_fechamento: undefined,
        observacoes: undefined,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
      
      // Salvar no localStorage para persistir
      localStorage.setItem('mock-cash-register', JSON.stringify(mockCashRegister))
      
      return mockCashRegister
    }
  },

  async closeRegister(registerId: string, closingAmount: number, userId: string): Promise<void> {
    const { error } = await supabase
      .from('caixa')
      .update({
        user_id: userId,
        saldo_final: closingAmount,
        data_fechamento: new Date().toISOString(),
        status: 'fechado'
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
        .from('vendas')
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
        .from('itens_venda')
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
      .from('vendas')
      .select(`
        *,
        customer:clientes(*),
        itens_venda(
          *,
          product:produtos(*)
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
      .from('vendas')
      .select(`
        *,
        customer:clientes(*),
        itens_venda(
          *,
          product:produtos(*)
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
      .from('categorias')
      .select('*')
      .eq('ativo', true)
      .order('nome')

    if (error) throw error
    return data || []
  }
}
