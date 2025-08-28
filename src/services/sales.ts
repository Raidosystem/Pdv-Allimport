import { supabase } from '../lib/supabase'
import type { Product, Customer, Sale, CashRegister, SaleSearchParams } from '../types/sales'
import { EMBEDDED_PRODUCTS, searchEmbeddedProducts } from '../data/products'

// Serviços de Produtos
export const productService = {
  async search(params: SaleSearchParams): Promise<Product[]> {
    console.log('🔍 ProductService.search chamado com:', params);
    
    // Usa produtos embutidos diretamente (garantia de funcionamento)
    console.log('📦 Usando produtos embutidos');
    
    const embeddedResults = searchEmbeddedProducts(params.search);
    
    // Adapta formato dos produtos embutidos para o frontend
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
    
    // Filtra por código de barras se especificado
    if (params.barcode) {
      const filtered = adaptedProducts.filter(p => p.barcode === params.barcode);
      console.log(`🔍 Filtrado por código de barras ${params.barcode}:`, filtered.length, 'produtos');
      return filtered;
    }
    
    console.log('✅ Retornando', adaptedProducts.length, 'produtos embutidos');
    return adaptedProducts;
  },

  async getById(id: string): Promise<Product | null> {
    console.log('🔍 Buscando produto por ID:', id);
    
    const product = EMBEDDED_PRODUCTS.find(p => p.id === id);
    
    if (!product) {
      console.log('❌ Produto não encontrado');
      return null;
    }
    
    const adaptedProduct: Product = {
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
    };
    
    console.log('✅ Produto encontrado:', adaptedProduct.name);
    return adaptedProduct;
  }
};

// Serviços de Clientes
export const customerService = {
  async search(query?: string): Promise<Customer[]> {
    console.log('🔍 CustomerService.search chamado com:', query);
    
    try {
      let supabaseQuery = supabase
        .from('clientes')
        .select('*');
      
      if (query) {
        supabaseQuery = supabaseQuery.or(`nome.ilike.%${query}%,email.ilike.%${query}%,telefone.ilike.%${query}%`);
      }
      
      const { data, error } = await supabaseQuery.limit(20);
      
      if (error) throw error;
      
      console.log('✅ Clientes encontrados:', data?.length || 0);
      
      const adaptedCustomers: Customer[] = (data || []).map(item => ({
        id: item.id,
        name: item.nome,
        email: item.email || '',
        phone: item.telefone || '',
        document: item.documento || '',
        address: item.endereco || '',
        created_at: item.criado_em,
        updated_at: item.atualizado_em
      }));
      
      return adaptedCustomers;
      
    } catch (error) {
      console.warn('⚠️ Erro ao buscar clientes:', error);
      
      // Clientes simulados para fallback
      const mockCustomers: Customer[] = [
        {
          id: '1',
          name: 'Cliente Padrão',
          email: 'cliente@exemplo.com',
          phone: '(11) 99999-9999',
          document: '000.000.000-00',
          address: 'Rua Exemplo, 123',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }
      ];
      
      let filtered = mockCustomers;
      
      if (query) {
        const queryLower = query.toLowerCase();
        filtered = mockCustomers.filter(customer =>
          customer.name.toLowerCase().includes(queryLower) ||
          customer.email.toLowerCase().includes(queryLower) ||
          customer.phone.includes(query)
        );
      }
      
      return filtered;
    }
  },

  async getById(id: string): Promise<Customer | null> {
    try {
      const { data, error } = await supabase
        .from('clientes')
        .select('*')
        .eq('id', id)
        .single();
      
      if (error) throw error;
      
      const adaptedCustomer: Customer = {
        id: data.id,
        name: data.nome,
        email: data.email || '',
        phone: data.telefone || '',
        document: data.documento || '',
        address: data.endereco || '',
        created_at: data.criado_em,
        updated_at: data.atualizado_em
      };
      
      return adaptedCustomer;
      
    } catch (error) {
      console.error('Erro ao buscar cliente por ID:', error);
      return null;
    }
  }
};

// Serviços de Vendas
export const saleService = {
  async create(sale: Omit<Sale, 'id' | 'created_at' | 'updated_at'>): Promise<Sale> {
    try {
      const { data, error } = await supabase
        .from('vendas')
        .insert({
          cliente_id: sale.customer_id,
          total: sale.total,
          desconto: sale.discount || 0,
          status: sale.status,
          metodo_pagamento: sale.payment_method,
          observacoes: sale.notes || ''
        })
        .select()
        .single();
      
      if (error) throw error;
      
      // Inserir itens da venda
      for (const item of sale.items) {
        await supabase
          .from('vendas_itens')
          .insert({
            venda_id: data.id,
            produto_id: item.product_id,
            quantidade: item.quantity,
            preco_unitario: item.unit_price,
            subtotal: item.subtotal
          });
      }
      
      const adaptedSale: Sale = {
        id: data.id,
        customer_id: data.cliente_id,
        total: data.total,
        discount: data.desconto || 0,
        status: data.status,
        payment_method: data.metodo_pagamento,
        notes: data.observacoes || '',
        items: sale.items,
        created_at: data.criado_em,
        updated_at: data.atualizado_em
      };
      
      return adaptedSale;
      
    } catch (error) {
      console.error('Erro ao criar venda:', error);
      throw error;
    }
  }
};

// Serviços de Caixa
export const cashRegisterService = {
  async getStatus(): Promise<CashRegister | null> {
    try {
      const { data, error } = await supabase
        .from('caixa')
        .select('*')
        .eq('status', 'aberto')
        .single();
      
      if (error) {
        if (error.code === 'PGRST116') {
          // Nenhum caixa aberto encontrado
          return null;
        }
        throw error;
      }
      
      const adaptedCashRegister: CashRegister = {
        id: data.id,
        opening_balance: data.valor_abertura,
        current_balance: data.valor_atual,
        status: data.status,
        opened_at: data.aberto_em,
        closed_at: data.fechado_em
      };
      
      return adaptedCashRegister;
      
    } catch (error) {
      console.error('Erro ao verificar status do caixa:', error);
      return null;
    }
  },

  async open(openingBalance: number): Promise<CashRegister> {
    try {
      const { data, error } = await supabase
        .from('caixa')
        .insert({
          valor_abertura: openingBalance,
          valor_atual: openingBalance,
          status: 'aberto',
          aberto_em: new Date().toISOString()
        })
        .select()
        .single();
      
      if (error) throw error;
      
      const adaptedCashRegister: CashRegister = {
        id: data.id,
        opening_balance: data.valor_abertura,
        current_balance: data.valor_atual,
        status: data.status,
        opened_at: data.aberto_em,
        closed_at: data.fechado_em
      };
      
      return adaptedCashRegister;
      
    } catch (error) {
      console.error('Erro ao abrir caixa:', error);
      throw error;
    }
  },

  async close(closingBalance: number): Promise<void> {
    try {
      const { error } = await supabase
        .from('caixa')
        .update({
          valor_atual: closingBalance,
          status: 'fechado',
          fechado_em: new Date().toISOString()
        })
        .eq('status', 'aberto');
      
      if (error) throw error;
      
    } catch (error) {
      console.error('Erro ao fechar caixa:', error);
      throw error;
    }
  }
};
